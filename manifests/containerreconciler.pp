# Class swift::containerreconciler
#
# == Parameters
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
#    (optional) Value of package resource parameter 'ensure'.
#    Defaults to 'present'.
#
#  [*pipeline*]
#    (optional) The list of elements of the container reconciler pipeline.
#    Defaults to ['catch_errors', 'proxy-logging', 'cache', 'proxy-server']
#
#  [*interval*]
#    (optional) Minimum time for a pass to take, in seconds.
#    Defaults to $facts['os_service_default']
#
#  [*reclaim_age*]
#    (optional) The reconciler will re-attempt reconciliation if the source
#    object is not available up to reclaim_age seconds before it gives up and
#    deletes the entry in the queue.
#    Defaults to $facts['os_service_default']
#
#  [*request_tries*]
#    (optional) Server errors from requests will be retried by default
#    Defaults to $facts['os_service_default']
#
#  [*service_provider*]
#    (optional)
#    To use the swiftinit service provider to manage swift services, set
#    service_provider to "swiftinit".  When enable is true the provider
#    will populate boot files that start swift using swift-init at boot.
#    See README for more details.
#    Defaults to $::swift::params::service_provider.
#
#  [*memcache_servers*]
#    (optional)
#    A list of the memcache servers to be used. Entries should be in the
#    form host:port. This value is only used if 'cache' is added to the
#    pipeline,
#    e.g. ['catch_errors', 'proxy-logging', 'cache', 'proxy-server']
#    Defaults to ['127.0.0.1:11211']
#
# [*cache_tls_enabled*]
#   (Optional) Global toggle for TLS usage when communicating with
#   the caching servers.
#   Default to false
#
# [*cache_tls_cafile*]
#   (Optional) Path to a file of concatenated CA certificates in PEM
#   format necessary to establish the caching server's authenticity.
#   If tls_enabled is False, this option is ignored.
#   Defaults to $facts['os_service_default']
#
# [*cache_tls_certfile*]
#   (Optional) Path to a single file in PEM format containing the
#   client's certificate as well as any number of CA certificates
#   needed to establish the certificate's authenticity. This file
#   is only required when client side authentication is necessary.
#   If tls_enabled is False, this option is ignored.
#   Defaults to $facts['os_service_default']
#
# [*cache_tls_keyfile*]
#   (Optional) Path to a single file containing the client's private
#   key in. Otherwise the private key will be taken from the file
#   specified in tls_certfile. If tls_enabled is False, this option
#   is ignored.
#   Defaults to $facts['os_service_default']
#
class swift::containerreconciler(
  $manage_service     = true,
  $enabled            = true,
  $package_ensure     = 'present',
  $pipeline           = ['catch_errors', 'proxy-logging', 'proxy-server'],
  $interval           = $facts['os_service_default'],
  $reclaim_age        = $facts['os_service_default'],
  $request_tries      = $facts['os_service_default'],
  $service_provider   = $::swift::params::service_provider,
  $memcache_servers   = ['127.0.0.1:11211'],
  $cache_tls_enabled  = false,
  $cache_tls_cafile   = $facts['os_service_default'],
  $cache_tls_certfile = $facts['os_service_default'],
  $cache_tls_keyfile  = $facts['os_service_default'],
) inherits swift::params {

  include swift::deps
  Swift_config<| |> ~> Service['swift-container-reconciler']
  Swift_container_reconciler_config<||> ~> Service['swift-container-reconciler']

  # only add memcache servers if 'cache' is included in the pipeline
  if !empty(grep(any2array($pipeline), 'cache')) {

    swift_container_reconciler_config {
      'filter:cache/memcache_servers': value => join(any2array($memcache_servers), ',');
      'filter:cache/tls_enabled':      value => $cache_tls_enabled;
      'filter:cache/tls_cafile':       value => $cache_tls_cafile;
      'filter:cache/tls_certfile':     value => $cache_tls_certfile;
      'filter:cache/tls_keyfile':      value => $cache_tls_keyfile;
    }

    # require the memcached class if it is on the same machine
    if !empty(grep(any2array($memcache_servers), '127.0.0.1')) {
      Class['memcached'] -> Class['swift::containerreconciler']
    }
  } else {
    swift_container_reconciler_config {
      'filter:cache/memcache_servers': ensure => absent;
      'filter:cache/tls_enabled':      ensure => absent;
      'filter:cache/tls_cafile':       ensure => absent;
      'filter:cache/tls_certfile':     ensure => absent;
      'filter:cache/tls_keyfile':      ensure => absent;
    }
  }

  swift_container_reconciler_config {
    'pipeline:main/pipeline':             value => join($pipeline, ' ');
    'container-reconciler/interval':      value => $interval;
    'container-reconciler/reclaim_age':   value => $reclaim_age;
    'container-reconciler/request_tries': value => $request_tries;
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  swift::service { 'swift-container-reconciler':
    os_family_service_name => $::swift::params::container_reconciler_service_name,
    service_ensure         => $service_ensure,
    enabled                => $enabled,
    config_file_name       => 'container-reconciler.conf',
    service_provider       => $service_provider,
  }

}
