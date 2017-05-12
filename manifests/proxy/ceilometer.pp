#
# Configure ceilometer middleware for swift
#
# == Dependencies
#
# puppet-ceilometer (http://github.com/enovance/puppet-ceilometer)
#
# == Parameters
#
# [*rabbit_host*]
#   (Optional) IP or hostname of the rabbit server.
#   Defaults to '127.0.0.1'.
#
# [*rabbit_port*]
#   (Optional) Port of the rabbit server.
#   Defaults to 5672.
#
# [*rabbit_hosts*]
#   (Optional) IP or hostname of the rabbits servers.
#   comma separated array (ex: ['1.0.0.10:5672','1.0.0.11:5672'])
#   Defaults to undef.
#
# [*rabbit_user*]
#   (Optional) Username for rabbit.
#   Defaults to 'guest'.
#
# [*rabbit_password*]
#   (Optional) Password for rabbit user.
#   Defaults to 'guest'.
#
# [*rabbit_virtual_host*]
#   (Optional) Virtual host to use.
#   Defaults to '/'.
#
# [*driver*]
#   (Optional) The Drivers(s) to handle sending notifications.
#   Defaults to undef.
#
# [*topic*]
#   (Optional) AMQP topic used for OpenStack notifications.
#   Defaults to undef.
#
# [*control_exchange*]
#   (Optional) The default exchange under which topics are scoped.
#   Defaults to undef.
#
# [*ensure*]
#   Enable or not ceilometer fragment
#   Defaults to 'present'
#
# [*group*]
#   Group name to add to 'swift' user.
#   ceilometer/eventlet: set 'ceilometer' (default)
#   ceilometer/wsgi: set $::apache::group
#   Defaults to 'ceilometer'
#
# [*nonblocking_notify*]
#   Whether to send events to messaging driver in a background thread
#   Defaults to false
#
# [*ignore_projects*]
#   What projects to ignore to send events to ceilometer
#   Defaults to ['services']
#
# [*auth_uri*]
#   (Optional) Complete public Identity API endpoint.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*auth_url*]
#   (Optional) The URL to use for authentication.
#   Defaults to 'http://127.0.0.1:35357'
#
# [*auth_type*]
#   (Optional) The plugin for authentication
#   Defaults to 'password'
#
# [*project_name*]
#   (Optional) Service project name
#   Defaults to 'services'
#
# [*project_domain_name*]
#   (Optional) name of domain for $project_name
#   Defaults to 'default'
#
# [*user_domain_name*]
#   (Optional) name of domain for $username
#   Defaults to 'default'
#
# [*username*]
#   (Optional) The name of the service user
#   Defaults to 'swift'
#
# [*password*]
#   (Optional) The password for the user
#   Defaults to 'password'
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@enovance.com
#
# == Copyright
#
# Copyright 2013 eNovance licensing@enovance.com
#
class swift::proxy::ceilometer(
  $rabbit_user         = 'guest',
  $rabbit_password     = 'guest',
  $rabbit_host         = '127.0.0.1',
  $rabbit_port         = '5672',
  $rabbit_hosts        = undef,
  $rabbit_virtual_host = '/',
  $driver              = undef,
  $topic               = undef,
  $control_exchange    = undef,
  $ensure              = 'present',
  $group               = 'ceilometer',
  $nonblocking_notify  = false,
  $ignore_projects       = ['services'],
  $auth_uri              = 'http://127.0.0.1:5000',
  $auth_url              = 'http://127.0.0.1:35357',
  $auth_type             = 'password',
  $project_domain_name   = 'Default',
  $user_domain_name      = 'Default',
  $project_name          = 'services',
  $username              = 'swift',
  $password              = 'password',
) inherits swift {

  include ::swift::deps

  if(is_array($rabbit_hosts)) {
    $rabbit_hosts_with_creds = prefix($rabbit_hosts, "${rabbit_user}:${rabbit_password}@")
  }

  User['swift'] {
    groups +> $group,
  }

  if defined(Service['swift-proxy-server']) {
    File['/var/log/ceilometer/swift-proxy-server.log'] -> Service['swift-proxy-server']
    Package['python-ceilometermiddleware'] -> Service['swift-proxy-server']
  }

  file { '/var/log/ceilometer/swift-proxy-server.log':
    ensure => file,
    mode   => '0664',
    owner  => 'swift',
    group  => 'swift',
  }

  concat::fragment { 'swift_ceilometer':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/ceilometer.conf.erb'),
    order   => '260',
  }

  package { 'python-ceilometermiddleware':
    ensure => $ensure,
    tag    => ['openstack', 'swift-support-package'],
  }

}
