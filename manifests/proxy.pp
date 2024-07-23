#
# Installs and configures the swift proxy node.
#
# == Parameters
#
#  [*proxy_local_net_ip*]
#    The address that the proxy will bind to.
#
#  [*port*]
#    (optional) The port to which the proxy server will bind.
#    Defaults to 8080.
#
#  [*pipeline*]
#    (optional) The list of elements of the swift proxy pipeline.
#    Currently supports healthcheck, cache, proxy-server, and
#    one of the following auth_types: tempauth, swauth, keystone.
#    Each of the specified elements also need to be declared externally
#    as a puppet class with the exception of proxy-server.
#    Defaults to ['catch_errors', 'gatekeeper', 'healthcheck', 'proxy-logging',
#    'cache', 'listing_formats', 'tempauth', 'copy', 'proxy-logging',
#    'proxy-server'].
#
#  [*workers*]
#    (optional) Number of threads to process requests.
#    Defaults to $facts['os_workers'].
#
#  [*allow_account_management*]
#    (optional) Rather or not requests through this proxy can create and
#    delete accounts.
#    Defaults to true.
#
#  [*account_autocreate*]
#    (optional) Rather accounts should automatically be created.
#    Has to be set to true for tempauth.
#    Defaults to true.
#
#  [*log_headers*]
#    (optional) If True, log headers in each request
#    Defaults to $facts['os_service_default'].
#
#  [*log_udp_host*]
#    (optional) If not set, the UDP receiver for syslog is disabled.
#    Defaults to $facts['os_service_default'].
#
#  [*log_udp_port*]
#    (optional) Port value for UDP receiver, if enabled.
#    Defaults to $facts['os_service_default'].
#
#  [*log_address*]
#    (optional) Location where syslog sends the logs to.
#    Defaults to '/dev/log'.
#
#  [*log_level*]
#    (optional) Log level.
#    Defaults to 'INFO'.
#
#  [*log_facility*]
#    (optional) Log level
#    Defaults to 'LOG_LOCAL2'.
#
#  [*log_handoffs*]
#    (optional) If True, the proxy will log whenever it has to failover to a handoff node
#    Defaults to $facts['os_service_default'].
#
#  [*object_chunk_size*]
#    (optional) Chunk size to read from object servers.
#    Defaults to $facts['os_service_default'].
#
#  [*client_chunk_size*]
#    (optional) Chunk size to read from clients.
#    Defaults to $facts['os_service_default'].
#
#  [*max_containers_per_account*]
#     (optional) If set to a positive value, will limit container number per account.
#     Default to 0.
#
#  [*max_containers_whitelist*]
#     (optional) This is a comma separated list of account hashes that ignore the max_containers_per_account cap.
#     Default to $facts['os_service_default'].
#
#  [*sorting_method*]
#    (optional) Method to chose storage nodes during GET and HEAD requests.
#    Defaults to undef.
#
#  [*timing_expiry*]
#    (optional) If the "timing" sorting_method is used, the timings will only
#    be valid for the number of seconds configured by timing_expiry.
#    Defaults to $facts['os_service_default'].
#
#  [*request_node_count*]
#    (optional) Number of nodes to contact for a normal request.
#    Defaults to $facts['os_service_default'].
#
#  [*read_affinity*]
#    (optional) Configures the read affinity of proxy-server.
#    Defaults to undef.
#
#  [*write_affinity*]
#    (optional) Configures the write affinity of proxy-server.
#    Defaults to undef.
#
#  [*write_affinity_node_count*]
#    (optional) Configures write_affinity_node_count for proxy-server.
#    Optional but requires write_affinity to be set.
#    Defaults to $facts['os_service_default'].
#
#  [*write_affinity_handoff_delete_count*]
#    (optional) Configures write_affinity_handoff_delete_count for proxy-server.
#    Optional but requires write_affinity to be set.
#    Defaults to $facts['os_service_default'].
#
#  [*client_timeout*]
#    (optional) Configures client_timeout for swift proxy-server.
#    Defaults to $facts['os_service_default'].
#
#  [*keepalive_timeout*]
#    (optional) Configures keep_timeout for swift proxy-server.
#    Defaults to $facts['os_service_default'].
#
#  [*node_timeout*]
#    (optional) Configures node_timeout for swift proxy-server
#    Defaults to $facts['os_service_default'].
#
#  [*recoverable_node_timeout*]
#    (optional) Configures recoverable_node_timeout for swift proxy-server
#    Defaults to $facts['os_service_default'].
#
#  [*allow_open_expired*]
#    (optional) Allow access to an object that has expired but not yet been
#    reaped, by setting the x-open-expired header.
#    Defaults to $facts['os_service_default'].
#
#  [*enabled*]
#    (optional) Should the service be enabled.
#    Defaults to true
#
#  [*manage_service*]
#    (optional) Whether the service should be managed by Puppet.
#    Defaults to true.
#
#  [*package_ensure*]
#    (optional) Ensure state of the swift proxy package.
#    Defaults to present.
#
#  [*log_name*]
#    Configures log_name for swift proxy-server.
#    Optional. Defaults to proxy-server
#
#  [*cors_allow_origin*]
#    (optional) Origins to be allowed to make Cross Origin Requests.
#    A comma separated list of full url (http://foo.bar:1234,https://foo.bar)
#    Defaults to $facts['os_service_default'].
#
#  [*strict_cors_mode*]
#    (optional) If True (default) then CORS requests are only allowed if their
#    Origin header matches an allowed origin. Otherwise, any Origin is allowed.
#    Defaults to $facts['os_service_default'].
#
#  [*cors_expose_headers*]
#    (optional) List of headers to expose through Access-Control-Expose-Headers,
#    in addition to the defaults and any headers set in container metadata.
#    Defaults to $facts['os_service_default'].
#
#  [*service_provider*]
#    (optional)
#    To use the swiftinit service provider to manage swift services, set
#    service_provider to "swiftinit".  When enable is true the provider
#    will populate boot files that start swift using swift-init at boot.
#    See README for more details.
#    Defaults to $::swift::params::service_provider.
#
#  [*purge_config*]
#    (optional) Whether to set only the specified config options
#    in the proxy config.
#    Defaults to false.
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift::proxy(
  $proxy_local_net_ip,
  $port                                          = '8080',
  Swift::Pipeline $pipeline                      = [
    'catch_errors', 'gatekeeper', 'healthcheck', 'proxy-logging', 'cache',
    'listing_formats', 'tempauth', 'copy', 'proxy-logging', 'proxy-server'],
  $workers                                       = $facts['os_workers'],
  Boolean $allow_account_management              = true,
  Boolean $account_autocreate                    = true,
  $log_headers                                   = $facts['os_service_default'],
  $log_udp_host                                  = $facts['os_service_default'],
  $log_udp_port                                  = $facts['os_service_default'],
  $log_address                                   = '/dev/log',
  $log_level                                     = 'INFO',
  $log_facility                                  = 'LOG_LOCAL2',
  $log_handoffs                                  = $facts['os_service_default'],
  $log_name                                      = 'proxy-server',
  $cors_allow_origin                             = $facts['os_service_default'],
  $strict_cors_mode                              = $facts['os_service_default'],
  $cors_expose_headers                           = $facts['os_service_default'],
  $object_chunk_size                             = $facts['os_service_default'],
  $client_chunk_size                             = $facts['os_service_default'],
  $max_containers_per_account                    = $facts['os_service_default'],
  $max_containers_whitelist                      = $facts['os_service_default'],
  Optional[Swift::SortingMethod] $sorting_method = undef,
  $timing_expiry                                 = $facts['os_service_default'],
  $request_node_count                            = $facts['os_service_default'],
  $read_affinity                                 = undef,
  $write_affinity                                = undef,
  $write_affinity_node_count                     = $facts['os_service_default'],
  $write_affinity_handoff_delete_count           = $facts['os_service_default'],
  $client_timeout                                = $facts['os_service_default'],
  $keepalive_timeout                             = $facts['os_service_default'],
  $node_timeout                                  = $facts['os_service_default'],
  $recoverable_node_timeout                      = $facts['os_service_default'],
  $allow_open_expired                            = $facts['os_service_default'],
  Boolean $manage_service                        = true,
  Boolean $enabled                               = true,
  $package_ensure                                = 'present',
  Swift::ServiceProvider $service_provider       = $::swift::params::service_provider,
  Boolean $purge_config                          = false,
) inherits swift::params {

  include swift::deps

  if(member($pipeline, 'tempauth')) {
    $auth_type = 'tempauth'
  } elsif(member($pipeline, 'swauth')) {
    $auth_type = 'swauth'
  } elsif(member($pipeline, 'keystone')) {
    $auth_type = 'keystone'
  } else {
    warning('no auth type provided in the pipeline')
  }

  if $pipeline[-1] != 'proxy-server' {
    fail('proxy-server must be the last element in pipeline')
  }

  if($auth_type == 'tempauth' and ! $account_autocreate ){
    fail('account_autocreate must be set to true when auth_type is tempauth')
  }

  package { 'swift-proxy':
    ensure => $package_ensure,
    name   => $::swift::params::proxy_package_name,
    tag    => ['openstack', 'swift-package'],
  }

  resources { 'swift_proxy_config':
    purge => $purge_config,
  }

  file { '/etc/swift/proxy-server.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => $::swift::params::group,
    mode    => '0640',
    require => Anchor['swift::config::begin'],
    before  => Anchor['swift::config::end']
  }
  File['/etc/swift/proxy-server.conf'] -> Swift_proxy_config<||>

  swift_proxy_config {
    'DEFAULT/bind_port':                           value => $port;
    'DEFAULT/bind_ip':                             value => $proxy_local_net_ip;
    'DEFAULT/workers':                             value => $workers;
    'DEFAULT/user':                                value => $::swift::params::user;
    'DEFAULT/log_name':                            value => $log_name;
    'DEFAULT/log_facility':                        value => $log_facility;
    'DEFAULT/log_level':                           value => $log_level;
    'DEFAULT/log_headers':                         value => $log_headers;
    'DEFAULT/log_address':                         value => $log_address;
    'DEFAULT/log_udp_host':                        value => $log_udp_host;
    'DEFAULT/log_udp_port':                        value => $log_udp_port;
    'DEFAULT/client_timeout':                      value => $client_timeout;
    'DEFAULT/keepalive_timeout':                   value => $keepalive_timeout;
    'pipeline:main/pipeline':                      value => join($pipeline, ' ');
    'app:proxy-server/use':                        value => 'egg:swift#proxy';
    'app:proxy-server/set log_name':               value => $log_name;
    'app:proxy-server/set log_facility':           value => $log_facility;
    'app:proxy-server/set log_level':              value => $log_level;
    'app:proxy-server/set log_address':            value => $log_address;
    'app:proxy-server/log_handoffs':               value => $log_handoffs;
    'app:proxy-server/object_chunk_size':          value => $object_chunk_size;
    'app:proxy-server/client_chunk_size':          value => $client_chunk_size;
    'app:proxy-server/allow_account_management':   value => $allow_account_management;
    'app:proxy-server/account_autocreate':         value => $account_autocreate;
    'app:proxy-server/max_containers_per_account': value => $max_containers_per_account;
    'app:proxy-server/max_containers_whitelist':   value => $max_containers_whitelist;
    'app:proxy-server/timing_expiry':              value => $timing_expiry;
    'app:proxy-server/request_node_count':         value => $request_node_count;
    'app:proxy-server/node_timeout':               value => $node_timeout;
    'app:proxy-server/recoverable_node_timeout':   value => $recoverable_node_timeout;
    'app:proxy-server/allow_open_expired':         value => $allow_open_expired;
  }

  swift_proxy_config {
    'DEFAULT/cors_allow_origin':   value => join(any2array($cors_allow_origin), ',');
    'DEFAULT/strict_cors_mode':    value => $strict_cors_mode;
    'DEFAULT/cors_expose_headers': value => join(any2array($cors_expose_headers), ',');
  }

  if $write_affinity {
    $write_affinity_real = join(any2array($write_affinity), ',')
    swift_proxy_config {
      'app:proxy-server/write_affinity':                      value => $write_affinity_real;
      'app:proxy-server/write_affinity_node_count':           value => $write_affinity_node_count;
      'app:proxy-server/write_affinity_handoff_delete_count': value => $write_affinity_handoff_delete_count;
    }
  } else {
    if !is_service_default($write_affinity_node_count) {
      fail('Usage of write_affinity_node_count requires write_affinity to be set')
    }
    if !is_service_default($write_affinity_handoff_delete_count) {
      fail('Usage of write_affinity_handoff_delete_count requires write_affinity to be set')
    }
    swift_proxy_config {
      'app:proxy-server/write_affinity':                      value => $facts['os_service_default'];
      'app:proxy-server/write_affinity_node_count':           value => $facts['os_service_default'];
      'app:proxy-server/write_affinity_handoff_delete_count': value => $facts['os_service_default'];
    }
  }

  if $read_affinity {
    if $sorting_method and $sorting_method != 'affinity' {
      fail('sorting_method should be \'affinity\' to use read affinity')
    }
    $read_affinity_real = $read_affinity ? {
      Hash    => join(join_keys_to_values($read_affinity, '='), ','),
      default => join(any2array($read_affinity), ',')
    }

    swift_proxy_config {
      'app:proxy-server/sorting_method': value => 'affinity';
      'app:proxy-server/read_affinity':  value => $read_affinity_real;
    }
  } else {
    swift_proxy_config {
      'app:proxy-server/sorting_method': value => pick($sorting_method, $facts['os_service_default']);
      'app:proxy-server/read_affinity':  value => $facts['os_service_default'];
    }
  }

  # Remove 'proxy-server' from the pipeline, convert pipeline elements
  # into class names then convert '-' to '_'.
  $required_classes = split(
    inline_template(
      "<%=
          (@pipeline - ['proxy-server']).collect do |x|
            'swift::proxy::' + x.gsub(/-/){ %q(_) }
          end.join(',')
      %>"), ',')

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    # Require 'swift::proxy::' classes for each of the elements in pipeline.
    swift::service { 'swift-proxy-server':
      os_family_service_name => $::swift::params::proxy_server_service_name,
      service_ensure         => $service_ensure,
      enabled                => $enabled,
      config_file_name       => 'proxy-server.conf',
      service_provider       => $service_provider,
      service_require        => Class[$required_classes],
      service_tag            => 'swift-proxy-service',
    }
  } else {
    exec { 'validate-proxy-pipeline':
      command     => '/usr/bin/true',
      refreshonly => true,
      require     => Class[$required_classes],
      before      => Anchor['swift::config::end'],
    }
    Swift_Proxy_config<||> ~> Exec['validate-proxy-pipeline']
  }
}
