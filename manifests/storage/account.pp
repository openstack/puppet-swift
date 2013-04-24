class swift::storage::account(
  $package_ensure = 'present'
) {
  swift::storage::generic { 'account':
    package_ensure => $package_ensure,
  }

  service { 'swift-account-reaper':
    name  => $::swift::params::account_reaper_service_name,
    ensure    => running,
    enable    => true,
    provider  => $::swift::params::service_provider,
    require   => Package['swift-account'],
  }

  service { 'swift-account-auditor':
    name  => $::swift::params::account_auditor_service_name,
    ensure    => running,
    enable    => true,
    provider  => $::swift::params::service_provider,
    require   => Package['swift-account'],
  }
}
