# == Class: swift::ringserver
#
# Used to create an rsync server to serve up the ring databases via rsync
#
# === Parameters
#
# [*local_net_ip*]
#   (required) ip address that the swift servers should bind to.
#
# [*max_connections*]
#   (optional) maximum connections to rsync server
#   Defaults to 5
#
# [*rsync_use_xinetd*]
#   (optional) Override whether to use xinetd to manage rsync service
#   Defaults to swift::params::xinetd_available
#
# == Dependencies
#
#   Class['swift']
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift::ringserver(
  $local_net_ip,
  $max_connections = 5,
  $rsync_use_xinetd = $::swift::params::xinetd_available,
) inherits swift::params {

  include swift::deps
  Class['swift::ringbuilder'] -> Class['swift::ringserver']

  if $rsync_use_xinetd and ! $::swift::params::xinetd_available {
    fail('xinetd is not available in this distro')
  }

  ensure_resource('class', 'rsync::server', {
    'use_xinetd' => $rsync_use_xinetd,
    'address'    => $local_net_ip,
    'use_chroot' => 'no',
  })

  rsync::server::module { 'swift_server':
    path            => '/etc/swift',
    lock_file       => '/var/lock/swift_server.lock',
    uid             => $::swift::params::user,
    gid             => $::swift::params::group,
    max_connections => $max_connections,
    read_only       => true,
  }
}
