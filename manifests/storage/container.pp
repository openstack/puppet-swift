class swift::storage::container(
  $package_ensure = 'present',
  $allowed_sync_hosts = ['127.0.0.1'],
) {
  swift::storage::generic { 'container':
    package_ensure => $package_ensure
  }

  service { 'swift-container-updater':
    name  => $::swift::params::container_updater_service_name,
    ensure    => running,
    enable    => true,
    provider  => $::swift::params::service_provider,
    require   => Package['swift-container'],
  }
  service { 'swift-container-auditor':
    name  => $::swift::params::container_auditor_service_name,
    ensure    => running,
    enable    => true,
    provider  => $::swift::params::service_provider,
    require   => Package['swift-container'],
  }

  if $operatingsystem == 'Ubuntu' {
    # The following service conf is missing in Ubunty 12.04
    file { '/etc/init/swift-container-sync.conf':
      source  => 'puppet:///modules/swift/swift-container-sync.conf.upstart',
      require => Package['swift-container'],
    }
    file { '/etc/init.d/swift-container-sync':
      ensure => link,
      target => '/lib/init/upstart-job',
    }
    service { 'swift-container-sync':
      ensure    => running,
      enable    => true,
      provider  => $::swift::params::service_provider,
      require   => File['/etc/init/swift-container-sync.conf', '/etc/init.d/swift-container-sync']
    }
  }
}
