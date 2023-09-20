#
# Usage
#   swift::storage::mount
#
#
# === Parameters:
#
# [*device*]
#   (mandatory) An array of devices (prefixed or not by /dev)
#
# [*mnt_base_dir*]
#   (optional) The directory where the flat files that store the file system
#   to be loop back mounted are actually mounted at.
#   Defaults to '/srv/node', base directory where disks are mounted to
#
# [*loopback*]
#   (optional) Define if the device must be mounted as a loopback or not
#   Defaults to false.
#
# [*fstype*]
#   (optional) The filesystem type.
#   Defaults to 'xfs'.
#
define swift::storage::mount(
  $device,
  Stdlib::Absolutepath $mnt_base_dir = '/srv/node',
  Boolean $loopback                  = false,
  String[1] $fstype                  = 'xfs'
) {

  include swift::deps
  include swift::params

  if($loopback){
    $options = 'noatime,nodiratime,nofail,loop'
  } else {
    $options = 'noatime,nodiratime,nofail'
  }

  if($fstype == 'xfs'){
    $fsoptions = 'logbufs=8'
  } else {
    $fsoptions = 'user_xattr'
  }

  # The directory that represents the mount point needs to exist.
  file { "${mnt_base_dir}/${name}":
    ensure  => directory,
    require => Anchor['swift::config::begin'],
    before  => Anchor['swift::config::end'],
  }

  # Make root own the mount point to prevent swift processes from writing files
  # when the disk device is not mounted
  exec { "fix_mountpoint_permissions_${name}":
    command => "chown -R root:root ${mnt_base_dir}/${name}",
    path    => ['/usr/sbin', '/bin'],
    before  => Anchor['swift::config::end'],
    unless  => "grep ${mnt_base_dir}/${name} /etc/mtab",
  }

  mount { "${mnt_base_dir}/${name}":
    ensure  => present,
    device  => $device,
    fstype  => $fstype,
    options => "${options},${fsoptions}",
  }

  # double checks to make sure that things are mounted
  exec { "mount_${name}":
    command => "mount ${mnt_base_dir}/${name}",
    path    => ['/bin'],
    unless  => "grep ${mnt_base_dir}/${name} /etc/mtab",
    before  => Anchor['swift::config::end'],
  }

  $user = $::swift::params::user
  $group = $::swift::params::group

  exec { "fix_mount_permissions_${name}":
    command     => "chown -R ${user}:${group} ${mnt_base_dir}/${name}",
    path        => ['/usr/sbin', '/bin'],
    refreshonly => true,
    before      => Anchor['swift::config::end'],
  }

  # mounting in linux and puppet is broken and non-atomic
  # we have to mount, check mount with executing command,
  # fix ownership and on selinux systems fix context.
  # It would be definitely nice if passing options uid=,gid=
  # would be possible as context is. But, as there already is
  # chown command we'll just restorecon on selinux enabled
  # systems :(
  if (str2bool($facts['os']['selinux']['enabled']) == true) {
    exec { "restorecon_mount_${name}":
      command     => "restorecon ${mnt_base_dir}/${name}",
      path        => ['/usr/sbin', '/sbin'],
      before      => Anchor['swift::config::end'],
      refreshonly => true,
    }

  File<| title == "${mnt_base_dir}/${name}" |>
  ~> Exec<| title == "fix_mountpoint_permissions_${name}" |>
  -> Exec<| title == "mount_${name}" |>

  File<| title == "${mnt_base_dir}/${name}" |>
  ~> Mount<| title == "${mnt_base_dir}/${name}" |>
  ~> Exec<| title == "mount_${name}" |>
  ~> Exec<| title == "fix_mount_permissions_${name}" |>
  ~> Exec<| title == "restorecon_mount_${name}" |>

  }
}
