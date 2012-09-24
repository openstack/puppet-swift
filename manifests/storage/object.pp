class swift::storage::object(
  $package_ensure = 'present'
) {
  swift::storage::generic { 'object':
    package_ensure => $package_ensure
  }

  # Not tested in other distros, safety measure
  if $operatingsystem == 'Ubuntu' {
    service { 'swift-object-updater':
      ensure    => running,
      enable    => true,
      provider  => $::swift::params::service_provider,
      require   => Package['swift-object'],
    }
    service { 'swift-object-auditor':
      ensure    => running,
      enable    => true,
      provider  => $::swift::params::service_provider,
      require   => Package['swift-object'],
    }
  }
}
