# Class swift::storage::object
#
# == Parameters
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
class swift::storage::object(
  $manage_service   = true,
  $enabled          = true,
  $package_ensure   = 'present',
  $config_file_name = 'object-server.conf',
  $service_provider = $::swift::params::service_provider
) inherits ::swift::params {

  include ::swift::deps

  swift::storage::generic { 'object':
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
  }

  swift::service { 'swift-object-updater':
    os_family_service_name => $::swift::params::object_updater_service_name,
    service_ensure         => $service_ensure,
    enabled                => $enabled,
    config_file_name       => $config_file_name,
    service_provider       => $service_provider,
    require                => Anchor['swift::install::end'],
    service_subscribe      => Concat["/etc/swift/${config_file_name}"],
  }

  swift::service { 'swift-object-reconstructor':
    os_family_service_name => $::swift::params::object_reconstructor_service_name,
    service_ensure         => $service_ensure,
    enabled                => $enabled,
    config_file_name       => $config_file_name,
    service_provider       => $service_provider,
    require                => Anchor['swift::install::end'],
    service_subscribe      => Concat["/etc/swift/${config_file_name}"],
  }

}
