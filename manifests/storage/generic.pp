# Creates the files packages and services that are
# needed to deploy each type of storage server.
#
# == Parameters
#  [*type*]
#    (optional) The type of device, e.g. account, object, or container.
#
#  [*enabled*]
#    (optional) Should the service be enabled to start
#    at boot. Defaults to true
#
#  [*manage_service*]
#    (optional) Whether the service should be managed by Puppet.
#    Defaults to true.
#
#  [*package_ensure*]
#    (optional) The desired ensure state of the swift storage packages.
#    Defaults to present.
#
#  [*config_file_name*]
#    (optional) The configuration file name.
#    Starting at the path "/etc/swift/"
#    Defaults to "${name}-server.conf"
#
#  [*service_provider*]
#    (optional)
#    To use the swiftinit service provider to manage swift services, set
#    service_provider to "swiftinit".  When enable is true the provider
#    will populate boot files that start swift using swift-init at boot.
#    See README for more details.
#    Defaults to $swift::params::service_provider.
#
# == Dependencies
#  Requires Class[swift::storage]
#
define swift::storage::generic (
  Swift::StorageServerType $type           = $name,
  Boolean $manage_service                  = true,
  Boolean $enabled                         = true,
  Stdlib::Ensure::Package $package_ensure  = 'present',
  String[1] $config_file_name              = "${name}-server.conf",
  Swift::ServiceProvider $service_provider = $swift::params::service_provider
) {
  include swift::deps
  include swift::params

  Class['swift::storage'] -> Swift::Storage::Generic[$type]

  package { "swift-${type}":
    ensure => $package_ensure,
    name   => getvar("::swift::params::${type}_package_name"),
    tag    => ['openstack', 'swift-package'],
  }

  file { "/etc/swift/${type}-server/":
    ensure  => directory,
    owner   => $swift::params::user,
    group   => $swift::params::group,
    require => Anchor['swift::config::begin'],
    before  => Anchor['swift::config::end'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    swift::service { "swift-${type}-server":
      os_family_service_name => getvar("::swift::params::${type}_server_service_name"),
      service_ensure         => $service_ensure,
      enabled                => $enabled,
      config_file_name       => $config_file_name,
      service_provider       => $service_provider,
      service_tag            => "swift-${name}-service",
    }

    swift::service { "swift-${type}-replicator":
      os_family_service_name => getvar("::swift::params::${type}_replicator_service_name"),
      service_ensure         => $service_ensure,
      enabled                => $enabled,
      config_file_name       => $config_file_name,
      service_provider       => $service_provider,
      service_tag            => "swift-${name}-service",
    }

    swift::service { "swift-${type}-auditor":
      os_family_service_name => getvar("::swift::params::${type}_auditor_service_name"),
      service_ensure         => $service_ensure,
      enabled                => $enabled,
      config_file_name       => $config_file_name,
      service_provider       => $service_provider,
      service_tag            => "swift-${name}-service",
    }
  }
}
