class swift::storage::object(
  $package_ensure = 'present'
) {
  swift::storage::generic { 'object':
    package_ensure => $package_ensure
  }

  service { 'swift-object-updater':
    name  => $::swift::params::object_updater_service_name,
    ensure    => running,
    enable    => true,
    provider  => $::swift::params::service_provider,
    require   => Package['swift-object'],
  }
  service { 'swift-object-auditor':
    name  => $::swift::params::object_auditor_service_name,
    ensure    => running,
    enable    => true,
    provider  => $::swift::params::service_provider,
    require   => Package['swift-object'],
  }
}
