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
# [*system_scope*]
#   (Optional) Scope for system operations
#   Defaults to $::os_service_default
#
# [*username*]
#   (Optional) The name of the service user
#   Defaults to 'swift'
#
# [*user_domain_name*]
#   (Optional) name of domain for $username
#   Defaults to 'default'
#
# [*password*]
#   (Optional) The password for the user
#   Defaults to 'password'
#
# [*region_name*]
#   (Optional) The region in which the identity server can be found.
#   Defaults to $::os_service_default.
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
# == DEPRECATED
#
# [*auth_uri*]
#   (Optional) Complete public Identity API endpoint.
#   Defaults to undef
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
  $auth_url                   = 'http://127.0.0.1:5000',
  $auth_type                  = 'password',
  $project_name               = 'services',
  $project_domain_name        = 'Default',
  $system_scope               = $::os_service_default,
  $username                   = 'swift',
  $user_domain_name           = 'Default',
  $password                   = undef,
  $region_name                = $::os_service_default,
  $notification_ssl_ca_file   = $::os_service_default,
  $notification_ssl_cert_file = $::os_service_default,
  $notification_ssl_key_file  = $::os_service_default,
  $amqp_ssl_key_password      = $::os_service_default,
  $rabbit_use_ssl             = $::os_service_default,
  $kombu_ssl_version          = $::os_service_default,
  # DEPRECATED PARAMETERS
  $auth_uri                   = undef
) inherits swift {

  include swift::deps

  User['swift'] {
    groups +> $group,
  }

  Package<| tag == 'ceilometer-package' |> -> User['swift']

  if defined(Service['swift-proxy-server']) {
    Package['python-ceilometermiddleware'] -> Service['swift-proxy-server']
  }

  if $auth_uri {
    warning('The swift::proxy::ceilometer::auth_uri parameter was deprecated, and has no effect')
  }

  if $password == undef {
    warning('Usage of the default password is deprecated and will be removed in a future release. \
Please set password parameter')
    $password_real = 'password'
  } else {
    $password_real = $password
  }

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $::os_service_default
    $project_domain_name_real = $::os_service_default
  }

  swift_proxy_config {
    'filter:ceilometer/topic':                value => $topic;
    'filter:ceilometer/driver':               value => $driver;
    'filter:ceilometer/url':                  value => $default_transport_url, secret => true;
    'filter:ceilometer/control_exchange':     value => $control_exchange;
    'filter:ceilometer/paste.filter_factory': value => 'ceilometermiddleware.swift:filter_factory';
    'filter:ceilometer/nonblocking_notify':   value => $nonblocking_notify;
    'filter:ceilometer/ignore_projects':      value => $ignore_projects;
    'filter:ceilometer/auth_url':             value => $auth_url;
    'filter:ceilometer/auth_type':            value => $auth_type;
    'filter:ceilometer/project_name':         value => $project_name_real;
    'filter:ceilometer/project_domain_name':  value => $project_domain_name_real;
    'filter:ceilometer/system_scope':         value => $system_scope;
    'filter:ceilometer/username':             value => $username;
    'filter:ceilometer/user_domain_name':     value => $user_domain_name;
    'filter:ceilometer/password':             value => $password_real, secret => true;
    'filter:ceilometer/region_name':          value => $region_name;
  }

  if $default_transport_url =~ /^rabbit.*/ {
    oslo::messaging::rabbit {'swift_proxy_config':
      kombu_ssl_ca_certs => $notification_ssl_ca_file,
      kombu_ssl_certfile => $notification_ssl_cert_file,
      kombu_ssl_keyfile  => $notification_ssl_key_file,
      kombu_ssl_version  => $kombu_ssl_version,
      rabbit_use_ssl     => $rabbit_use_ssl,
    }
  } elsif $default_transport_url =~ /^amqp.*/ {
    oslo::messaging::amqp {'swift_proxy_config':
      ssl_ca_file      => $notification_ssl_ca_file,
      ssl_cert_file    => $notification_ssl_cert_file,
      ssl_key_file     => $notification_ssl_key_file,
      ssl_key_password => $amqp_ssl_key_password,
    }
  }

  package { 'python-ceilometermiddleware':
    ensure => $ensure,
    name   => $::swift::params::ceilometermiddleware_package_name,
    tag    => ['openstack', 'swift-support-package'],
  }

}
