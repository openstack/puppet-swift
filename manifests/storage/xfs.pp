#
# === Parameters:
#
# [*device*]
#   (optional) Path to the device.
#   Defaults to "/dev/${name}"
#
# [*mnt_base_dir*]
#   (optional) The directory where the flat files that store the file system
#   to be loop back mounted are actually mounted at.
#   Defaults to '/srv/node', base directory where disks are mounted to
#
# [*byte_size*]
#   (optional) Byte size to use for every inode in the created filesystem.
#   Defaults to '1024'. It is recommended to use 1024 to ensure that
#   the metadata can fit in a single inode.
#
# [*loopback*]
#   (optional) Define if the device must be mounted as a loopback or not
#   Defaults to false.
#
# [*mount_type*]
#   (optional) Define if the device is mounted by the device partition path,
#   UUID, or filesystem label.
#   Defaults to 'path'.
#
# [*manage_filesystem*]
#   (optional) If set to false, skip calling xfs_admin -l to check if a
#   partition needs to be formatted with mkfs.xfs, which can, in some cases,
#   increase the load on the server. This is to set to false only after the
#   server is fully setup, or if the filesystem was created outside of puppet.
#   Defaults to true.
#
# [*label*]
#   (optional) Filesystem label.
#   Defaults to $name.
#
# Sample usage:
#
# swift::storage::xfs {
#   ['sdb', 'sdc', 'sde', 'sdf', 'sdg', 'sdh', 'sdi', 'sdj', 'sdk']:
#     mnt_base_dir => '/srv/node',
#     mount_type  => 'uuid',
#     require      => Class['swift'];
# }
#
# Creates /srv/node if dir does not exist, formats sdbX with XFS unless
# it already has an XFS FS, and mounts de FS in /srv/node/sdX
#
define swift::storage::xfs(
  Stdlib::Absolutepath $device              = "/dev/${name}",
  $byte_size                                = '1024',
  Stdlib::Absolutepath $mnt_base_dir        = '/srv/node',
  Boolean $loopback                         = false,
  Enum['path', 'uuid', 'label'] $mount_type = 'path',
  Boolean $manage_filesystem                = true,
  String[1] $label                          = $name,
) {

  include swift::deps
  include swift::params
  include swift::xfs

  # Currently, facter doesn't support to fetch the device's uuid, only the partition's.
  # If you want to mount device by uuid, you should set $ext_args to 'mkpart primary 0% 100%'
  # in swift::storage::disk to make a partition. Also, the device name should change accordingly.
  # For example: from 'sda' to 'sda1'.
  # The code does NOT work in existing Swift cluster.
  case $mount_type {
    'uuid': {
      $mount_device = dig44($facts, ['partitions', $device, 'uuid'])
      if !$mount_device {
        fail("Unable to fetch uuid of ${device}")
      }
    }
    'label': {
      $mount_device = "LABEL=${label}"
    }
    default: { # path
      $mount_device = $device
    }
  }

  if(!defined(File[$mnt_base_dir])) {
    file { $mnt_base_dir:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      require => Anchor['swift::config::begin'],
      before  => Anchor['swift::config::end'],
    }
  }

  # We use xfs_admin -l to print FS label
  # If it's not a valid XFS FS, command will return 1
  # so we format it. If device has a valid XFS FS, command returns 0
  # So we do NOT touch it.
  if $manage_filesystem {
    $mkfs_command = ['mkfs.xfs', '-f', '-i', "size=${byte_size}"]
    $mkfs_label_opt = $mount_type ? {
      'label' => ['-L', $label],
      default => []
    }

    exec { "mkfs-${name}":
      command => $mkfs_command + $mkfs_label_opt + [$device],
      path    => ['/sbin/', '/usr/sbin/'],
      unless  => "xfs_admin -l ${device}",
      before  => Anchor['swift::config::end'],
    }
    Package<| title == 'xfsprogs' |>
    ~> Exec["mkfs-${name}"]
    ~> Swift::Storage::Mount<| title == $name |>
  } else {
    Package<| title == 'xfsprogs' |>
    ~> Swift::Storage::Mount<| title == $name |>
  }

  swift::storage::mount { $name:
    device       => $mount_device,
    mnt_base_dir => $mnt_base_dir,
    loopback     => $loopback,
  }
}
