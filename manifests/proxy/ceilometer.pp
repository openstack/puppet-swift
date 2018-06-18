#
# Configure ceilometer middleware for swift
#
# == Dependencies
#
# puppet-ceilometer (http://github.com/enovance/puppet-ceilometer)
#
# == Parameters
#
# [*default_transport_url*]
#   (optional) A URL representing the messaging driver to use and its full
#   configuration. Transport URLs take the form:
#     transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $::os_service_default
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
#   Defaults to 'http://127.0.0.1:5000'
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
# [*notification_ssl_ca_file*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   (string value)
#   Defaults to $::os_service_default
#
# [*notification_ssl_cert_file*]
#   (optional) SSL cert file. (string value)
#   Defaults to $::os_service_default
#
# [*notification_ssl_key_file*]
#   (optional) SSL key file. (string value)
#   Defaults to $::os_service_default
#
# [*amqp_ssl_key_password*]
#   (Optional) Password for decrypting ssl_key_file (if encrypted)
#   Defaults to $::os_service_default.
#
# [*rabbit_use_ssl*]
#   (optional) Boolean. Connect over SSL for RabbitMQ. (boolean value)
#   Defaults to $::os_service_default
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions. (string value)
#   Defaults to $::os_service_default
#
# === DEPRECATED PARAMETERS
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
  $default_transport_url      = undef,
  $driver                     = $::os_service_default,
  $topic                      = undef,
  $control_exchange           = undef,
  $ensure                     = 'present',
  $group                      = 'ceilometer',
  $nonblocking_notify         = false,
  $ignore_projects            = ['services'],
  $auth_uri                   = 'http://127.0.0.1:5000',
  $auth_url                   = 'http://127.0.0.1:5000',
  $auth_type                  = 'password',
  $project_domain_name        = 'Default',
  $user_domain_name           = 'Default',
  $project_name               = 'services',
  $username                   = 'swift',
  $password                   = 'password',
  $notification_ssl_ca_file   = $::os_service_default,
  $notification_ssl_cert_file = $::os_service_default,
  $notification_ssl_key_file  = $::os_service_default,
  $amqp_ssl_key_password      = $::os_service_default,
  $rabbit_use_ssl             = $::os_service_default,
  $kombu_ssl_version          = $::os_service_default,
  # DEPRECATED PARAMETERS
  $rabbit_user                = 'guest',
  $rabbit_password            = 'guest',
  $rabbit_host                = '127.0.0.1',
  $rabbit_port                = '5672',
  $rabbit_hosts               = undef,
  $rabbit_virtual_host        = '/',
) inherits swift {

  include ::swift::deps

  if $default_transport_url {
    $amqp_url = $default_transport_url
  } else {
    warning("swift::proxy::ceilometer::rabbit_host,
swift::proxy::ceilometer::rabbit_hosts, swift::proxy::ceilometer::rabbit_password, \
swift::proxy::ceilometer::rabbit_port, swift::proxy::ceilometer::rabbit_userid \
and swift::proxy::ceilometer::rabbit_virtual_host are \
deprecated. Please use swift::proxy::ceilometer::default_transport_url instead.")

    if(is_array($rabbit_hosts)) {
      $rabbit_hosts_with_creds = prefix($rabbit_hosts, "${rabbit_user}:${rabbit_password}@")
    }

    if !$rabbit_hosts {
      $amqp_url = "rabbit://${rabbit_user}:${rabbit_password}@${rabbit_host}:${rabbit_port}/${rabbit_virtual_host}"
    } else {
      $hosts = join($rabbit_hosts_with_creds, ',')
      $amqp_url = "rabbit://${hosts}/${rabbit_virtual_host}"
    }
  }

  User['swift'] {
    groups +> $group,
  }

  Package<| tag == 'ceilometer-package' |> -> User['swift']

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

  swift_proxy_config {
    'filter:ceilometer/topic':                value => $topic;
    'filter:ceilometer/driver':               value => $driver;
    'filter:ceilometer/url':                  value => $amqp_url, secret => true;
    'filter:ceilometer/control_exchange':     value => $control_exchange;
    'filter:ceilometer/paste.filter_factory': value => 'ceilometermiddleware.swift:filter_factory';
    'filter:ceilometer/nonblocking_notify':   value => $nonblocking_notify;
    'filter:ceilometer/ignore_projects':      value => $ignore_projects;
    'filter:ceilometer/auth_uri':             value => $auth_uri;
    'filter:ceilometer/auth_url':             value => $auth_url;
    'filter:ceilometer/auth_type':            value => $auth_type;
    'filter:ceilometer/project_domain_name':  value => $project_domain_name;
    'filter:ceilometer/user_domain_name':     value => $user_domain_name;
    'filter:ceilometer/project_name':         value => $project_name;
    'filter:ceilometer/username':             value => $username;
    'filter:ceilometer/password':             value => $password;
  }

  if $amqp_url =~ /^rabbit.*/ {
    oslo::messaging::rabbit {'swift_proxy_config':
      kombu_ssl_ca_certs => $notification_ssl_ca_file,
      kombu_ssl_certfile => $notification_ssl_cert_file,
      kombu_ssl_keyfile  => $notification_ssl_key_file,
      kombu_ssl_version  => $kombu_ssl_version,
      rabbit_use_ssl     => $rabbit_use_ssl,
    }
  } elsif $amqp_url =~ /^amqp.*/ {
    oslo::messaging::amqp {'swift_proxy_config':
      ssl_ca_file      => $notification_ssl_ca_file,
      ssl_cert_file    => $notification_ssl_cert_file,
      ssl_key_file     => $notification_ssl_key_file,
      ssl_key_password => $amqp_ssl_key_password,
    }
  }

  package { 'python-ceilometermiddleware':
    ensure => $ensure,
    tag    => ['openstack', 'swift-support-package'],
  }

}
