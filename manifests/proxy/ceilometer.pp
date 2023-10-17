#
# Configure ceilometer middleware for swift
#
# == Dependencies
#
# puppet-ceilometer (http://github.com/enovance/puppet-ceilometer)
#
# == Parameters
#
# [*password*]
#   (Required) The password for the user
#
# [*default_transport_url*]
#   (optional) A URL representing the messaging driver to use and its full
#   configuration. Transport URLs take the form:
#     transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
#
# [*username*]
#   (Optional) The name of the service user
#   Defaults to 'swift'
#
# [*user_domain_name*]
#   (Optional) name of domain for $username
#   Defaults to 'default'
#
# [*region_name*]
#   (Optional) The region in which the identity server can be found.
#   Defaults to $facts['os_service_default'].
#
# [*notification_ssl_ca_file*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   (string value)
#   Defaults to $facts['os_service_default']
#
# [*notification_ssl_cert_file*]
#   (optional) SSL cert file. (string value)
#   Defaults to $facts['os_service_default']
#
# [*notification_ssl_key_file*]
#   (optional) SSL key file. (string value)
#   Defaults to $facts['os_service_default']
#
# [*amqp_ssl_key_password*]
#   (Optional) Password for decrypting ssl_key_file (if encrypted)
#   Defaults to $facts['os_service_default'].
#
# [*rabbit_use_ssl*]
#   (Optional) Connect over SSL for RabbitMQ. (boolean value)
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions. (string value)
#   Defaults to $facts['os_service_default']
#
# [*rabbit_ha_queues*]
#   (Optional) Use HA queues in RabbitMQ (x-ha-policy: all). If you change this
#   option, you must wipe the RabbitMQ database. (boolean value)
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_timeout_threshold*]
#   (Optional) Number of seconds after which the Rabbit broker is
#   considered down if heartbeat's keep-alive fails
#   (0 disable the heartbeat). EXPERIMENTAL. (integer value)
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_rate*]
#   (Optional) How often times during the heartbeat_timeout_threshold
#   we check the heartbeat. (integer value)
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_in_pthread*]
#   (Optional) EXPERIMENTAL: Run the health check heartbeat thread
#   through a native python thread. By default if this
#   option isn't provided the  health check heartbeat will
#   inherit the execution model from the parent process. By
#   example if the parent process have monkey patched the
#   stdlib by using eventlet/greenlet then the heartbeat
#   will be run through a green thread.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_qos_prefetch_count*]
#   (Optional) Specifies the number of messages to prefetch.
#   Defaults to $facts['os_service_default']
#
# [*amqp_durable_queues*]
#   (optional) Define queues as "durable" to rabbitmq.
#   Defaults to $facts['os_service_default']
#
# [*kombu_reconnect_delay*]
#   (Optional) How long to wait before reconnecting in response
#   to an AMQP consumer cancel notification. (floating point value)
#   Defaults to $facts['os_service_default']
#
# [*kombu_failover_strategy*]
#   (Optional) Determines how the next RabbitMQ node is chosen in case the one
#   we are currently connected to becomes unavailable. Takes effect only if
#   more than one RabbitMQ node is provided in config. (string value)
#   Defaults to $facts['os_service_default']
#
# [*kombu_compression*]
#   (optional) Possible values are: gzip, bz2. If not set compression will not
#   be used. This option may notbe available in future versions. EXPERIMENTAL.
#   (string value)
#   Defaults to $facts['os_service_default']
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
  String[1] $password,
  $default_transport_url              = undef,
  $driver                             = $facts['os_service_default'],
  $topic                              = undef,
  $control_exchange                   = undef,
  $ensure                             = 'present',
  $nonblocking_notify                 = false,
  $ignore_projects                    = ['services'],
  $auth_url                           = 'http://127.0.0.1:5000',
  $auth_type                          = 'password',
  $project_name                       = 'services',
  $project_domain_name                = 'Default',
  $system_scope                       = $facts['os_service_default'],
  $username                           = 'swift',
  $user_domain_name                   = 'Default',
  $region_name                        = $facts['os_service_default'],
  $notification_ssl_ca_file           = $facts['os_service_default'],
  $notification_ssl_cert_file         = $facts['os_service_default'],
  $notification_ssl_key_file          = $facts['os_service_default'],
  $amqp_ssl_key_password              = $facts['os_service_default'],
  $rabbit_use_ssl                     = $facts['os_service_default'],
  $kombu_ssl_version                  = $facts['os_service_default'],
  $rabbit_ha_queues                   = $facts['os_service_default'],
  $rabbit_heartbeat_timeout_threshold = $facts['os_service_default'],
  $rabbit_heartbeat_rate              = $facts['os_service_default'],
  $rabbit_heartbeat_in_pthread        = $facts['os_service_default'],
  $rabbit_qos_prefetch_count          = $facts['os_service_default'],
  $amqp_durable_queues                = $facts['os_service_default'],
  $kombu_reconnect_delay              = $facts['os_service_default'],
  $kombu_failover_strategy            = $facts['os_service_default'],
  $kombu_compression                  = $facts['os_service_default'],
) inherits swift {

  include swift::deps

  Package['python-ceilometermiddleware'] ~> Service<| title == 'swift-proxy-server' |>

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $facts['os_service_default']
    $project_domain_name_real = $facts['os_service_default']
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
    'filter:ceilometer/password':             value => $password, secret => true;
    'filter:ceilometer/region_name':          value => $region_name;
  }

  if $default_transport_url =~ /^rabbit.*/ {
    oslo::messaging::rabbit { 'swift_proxy_config':
      rabbit_ha_queues            => $rabbit_ha_queues,
      heartbeat_timeout_threshold => $rabbit_heartbeat_timeout_threshold,
      heartbeat_rate              => $rabbit_heartbeat_rate,
      heartbeat_in_pthread        => $rabbit_heartbeat_in_pthread,
      rabbit_qos_prefetch_count   => $rabbit_qos_prefetch_count,
      amqp_durable_queues         => $amqp_durable_queues,
      kombu_ssl_ca_certs          => $notification_ssl_ca_file,
      kombu_ssl_certfile          => $notification_ssl_cert_file,
      kombu_ssl_keyfile           => $notification_ssl_key_file,
      kombu_ssl_version           => $kombu_ssl_version,
      rabbit_use_ssl              => $rabbit_use_ssl,
      kombu_reconnect_delay       => $kombu_reconnect_delay,
      kombu_failover_strategy     => $kombu_failover_strategy,
      kombu_compression           => $kombu_compression,
    }
    oslo::messaging::amqp { 'swift_proxy_config': }

  } elsif $default_transport_url =~ /^amqp.*/ {
    oslo::messaging::rabbit { 'swift_proxy_config': }
    oslo::messaging::amqp { 'swift_proxy_config':
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
