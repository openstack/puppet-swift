# Creates the files packages and services that are
# needed to deploy each type of storage server.
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
#    Defaults to $::swift::params::service_provider.
#
# == Dependencies
#  Requires Class[swift::storage]
#
define swift::storage::generic(
  $manage_service   = true,
  $enabled          = true,
  $package_ensure   = 'present',
  $config_file_name = "${name}-server.conf",
  $service_provider = $::swift::params::service_provider
) {

  include ::swift::deps
  include ::swift::params

  Class['swift::storage'] -> Swift::Storage::Generic[$name]
  Swift_config<| |> ~> Service["swift-${name}-server"]
  Swift_config<| |> ~> Service["swift-${name}-auditor"]
  Swift_config<| |> ~> Service["swift-${name}-replicator"]

  validate_re($name, '^object|container|account$')

  package { "swift-${name}":
    ensure => $package_ensure,
    name   => getvar("::swift::params::${name}_package_name"),
    tag    => ['openstack', 'swift-package'],
    before => Service["swift-${name}-server", "swift-${name}-replicator"],
  }

  file { "/etc/swift/${name}-server/":
    ensure => directory,
    owner  => 'swift',
    group  => 'swift',
    tag    => 'swift-file',
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  swift::service { "swift-${name}-server":
    os_family_service_name => getvar("::swift::params::${name}_server_service_name"),
    service_ensure         => $service_ensure,
    enabled                => $enabled,
    config_file_name       => $config_file_name,
    service_provider       => $service_provider,
    service_subscribe      => Package["swift-${name}"],
  }

  swift::service { "swift-${name}-replicator":
    os_family_service_name => getvar("::swift::params::${name}_replicator_service_name"),
    service_ensure         => $service_ensure,
    enabled                => $enabled,
    config_file_name       => $config_file_name,
    service_provider       => $service_provider,
    service_subscribe      => Package["swift-${name}"],
  }

  swift::service { "swift-${name}-auditor":
    os_family_service_name => getvar("::swift::params::${name}_auditor_service_name"),
    service_ensure         => $service_ensure,
    enabled                => $enabled,
    config_file_name       => $config_file_name,
    service_provider       => $service_provider,
    service_subscribe      => Package["swift-${name}"],
  }
}
