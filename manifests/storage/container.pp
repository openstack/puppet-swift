# Class swift::storage::container
#
# === Parameters
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
#    (optional) Value of package resource parameter 'ensure'.
#    Defaults to 'present'.
#
#  [*allowed_sync_hosts*]
#    (optional) A list of hosts allowed in the X-Container-Sync-To
#    field for containers. Defaults to one entry list '127.0.0.1'.
#
#  [*config_file_name*]
#    (optional) The configuration file name.
#    Starting at the path "/etc/swift/"
#    Defaults to "object-server.conf"
#
#  [*service_provider*]
#    (optional)
#    To use the swiftinit service provider to manage swift services, set
#    service_provider to "swiftinit".  When enable is true the provider
#    will populate boot files that start swift using swift-init at boot.
#    See README for more details.
#    Defaults to $::swift::params::service_provider.
#
class swift::storage::container(
  Boolean $manage_service                  = true,
  Boolean $enabled                         = true,
  $package_ensure                          = 'present',
  Array[String[1]] $allowed_sync_hosts     = ['127.0.0.1'],
  String[1] $config_file_name              = 'container-server.conf',
  Swift::ServiceProvider $service_provider = $::swift::params::service_provider
) inherits swift::params {

  include swift::deps

  swift::storage::generic { 'container':
    manage_service   => $manage_service,
    enabled          => $enabled,
    package_ensure   => $package_ensure,
    config_file_name => $config_file_name,
    service_provider => $service_provider
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    swift::service { 'swift-container-updater':
      os_family_service_name => $::swift::params::container_updater_service_name,
      service_ensure         => $service_ensure,
      enabled                => $enabled,
      config_file_name       => $config_file_name,
      service_provider       => $service_provider,
      service_tag            => 'swift-container-service',
    }

    swift::service { 'swift-container-sync':
      os_family_service_name => $::swift::params::container_sync_service_name,
      service_ensure         => $service_ensure,
      enabled                => $enabled,
      config_file_name       => $config_file_name,
      service_provider       => $service_provider,
      service_tag            => 'swift-container-service',
    }

    swift::service { 'swift-container-sharder':
      os_family_service_name => $::swift::params::container_sharder_service_name,
      service_ensure         => $service_ensure,
      enabled                => $enabled,
      config_file_name       => $config_file_name,
      service_provider       => $service_provider,
      service_tag            => 'swift-container-service',
    }
  }
}
