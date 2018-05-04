# Class swift::objectexpirer
#
# == Parameters
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
#    (optional) The list of elements of the object expirer pipeline.
#    Defaults to ['catch_errors', 'cache', 'proxy-server']
#
#  [*auto_create_account_prefix*]
#    (optional) Prefix to use when automatically creating accounts.
#    Defaults to '.'.
#
#  [*concurrency*]
#    (optional) Number of replication workers to spawn.
#    Defaults to 1.
#
#  [*expiring_objects_account_name*]
#    (optional) Account name used for expiring objects.
#    Defaults to 'expiring_objects'.
#
#  [*interval*]
#    (optional) Minimum time for a pass to take, in seconds.
#    Defaults to 300.
#
#  [*process*]
#    (optional) Which part of the work defined by $processes
#    will this instance take.
#    Defaults to 0.
#
#  [*processes*]
#    (optional) How many parts to divide the work into, one part per
#    process. 0 means a single process will do all work.
#    Defaults to 0.
#
#  [*reclaim_age*]
#    (optional) Time elapsed in seconds before an object can be
#    reclaimed.
#    Defaults to 604800 (1 week).
#
#  [*recon_cache_path*]
#    (optional) Directory where stats for a few items will be stored.
#    Defaults to '/var/cache/swift'.
#
#  [*report_interval*]
#    (optional) Report interval, in seconds.
#    Defaults to 300.
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
#    pipeline, e.g. ['catch_errors', 'cache', 'proxy-server']
#    Defaults to ['127.0.0.1:11211']
#
#  [*log_level*]
#    (optional) Log level.
#    Defaults to 'INFO'.
#
#  [*log_facility*]
#    (optional) Log level
#    Defaults to 'LOG_LOCAL2'.
#
class swift::objectexpirer(
  $manage_service                = true,
  $enabled                       = true,
  $package_ensure                = 'present',
  $pipeline                      = ['catch_errors', 'proxy-server'],
  $auto_create_account_prefix    = '.',
  $concurrency                   = 1,
  $expiring_objects_account_name = 'expiring_objects',
  $interval                      = 300,
  $process                       = 0,
  $processes                     = 0,
  $reclaim_age                   = 604800,
  $recon_cache_path              = '/var/cache/swift',
  $report_interval               = 300,
  $service_provider              = $::swift::params::service_provider,
  $memcache_servers              = ['127.0.0.1:11211'],
  $log_level                     = 'INFO',
  $log_facility                  = 'LOG_LOCAL2',
) inherits ::swift::params {

  include ::swift::deps
  Swift_config<| |> ~> Service['swift-object-expirer']
  Swift_object_expirer_config<||> ~> Service['swift-object-expirer']

  # On Red Hat platforms, it may be defined already,
  # because it is part of openstack-swift-proxy
  if $::swift::params::object_expirer_package_name != $::swift::params::proxy_package_name {
    package { 'swift-object-expirer':
      ensure => $package_ensure,
      name   => $::swift::params::object_expirer_package_name,
      tag    => ['openstack', 'swift-package'],
    }
  }

  # only add memcache servers if 'cache' is included in the pipeline
  if !empty(grep(any2array($pipeline), 'cache')) {

    swift_object_expirer_config {
      'filter:cache/memcache_servers': value => join(any2array($memcache_servers), ',');
    }

    # require the memcached class if it is on the same machine
    if !empty(grep(any2array($memcache_servers), '127.0.0.1')) {
      Class['::memcached'] -> Class['::swift::objectexpirer']
    }
  }

  swift_object_expirer_config {
    'pipeline:main/pipeline':                       value => join($pipeline, ' ');
    'object-expirer/auto_create_account_prefix':    value => $auto_create_account_prefix;
    'object-expirer/concurrency':                   value => $concurrency;
    'object-expirer/expiring_objects_account_name': value => $expiring_objects_account_name;
    'object-expirer/interval':                      value => $interval;
    'object-expirer/process':                       value => $process;
    'object-expirer/processes':                     value => $processes;
    'object-expirer/reclaim_age':                   value => $reclaim_age;
    'object-expirer/recon_cache_path':              value => $recon_cache_path;
    'object-expirer/report_interval':               value => $report_interval;
    'object-expirer/log_facility':                  value => $log_facility;
    'object-expirer/log_level':                     value => $log_level;
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  swift::service { 'swift-object-expirer':
    os_family_service_name => $::swift::params::object_expirer_service_name,
    service_ensure         => $service_ensure,
    enabled                => $enabled,
    config_file_name       => 'object-expirer.conf',
    service_provider       => $service_provider,
  }
}
