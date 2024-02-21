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
# [*loopback*]
#   (optional) Define if the device must be mounted as a loopback or not
#   Defaults to false.
#
# [*fstype*]
#   (optional) The filesystem type.
#   Defaults to 'xfs'.
#
define swift::storage::mount(
  Swift::MountDevice $device         = "/dev/${name}",
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
    command => ['chown', '-R', 'root:root', "${mnt_base_dir}/${name}"],
    path    => ['/usr/bin', '/bin'],
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
    command     => ['chown', '-R', "${user}:${group}", "${mnt_base_dir}/${name}"],
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
    before      => Anchor['swift::config::end'],
  }

  File["${mnt_base_dir}/${name}"]
  -> Exec["fix_mountpoint_permissions_${name}"]
  -> Mount["${mnt_base_dir}/${name}"]
  -> Exec["mount_${name}"]

  Mount["${mnt_base_dir}/${name}"] ~> Exec["fix_mount_permissions_${name}"]
  Exec["mount_${name}"] ~> Exec["fix_mount_permissions_${name}"]

  # mounting in linux and puppet is broken and non-atomic
  # we have to mount, check mount with executing command,
  # fix ownership and on selinux systems fix context.
  # It would be definitely nice if passing options uid=,gid=
  # would be possible as context is. But, as there already is
  # chown command we'll just restorecon on selinux enabled
  # systems :(
  if (str2bool($facts['os']['selinux']['enabled']) == true) {
    exec { "restorecon_mount_${name}":
      command     => ['restorecon', "${mnt_base_dir}/${name}"],
      path        => ['/usr/sbin', '/sbin'],
      before      => Anchor['swift::config::end'],
      refreshonly => true,
    }

    Mount["${mnt_base_dir}/${name}"] ~> Exec["restorecon_mount_${name}"]
    Exec["mount_${name}"] ~> Exec["restorecon_mount_${name}"]
  }
}
