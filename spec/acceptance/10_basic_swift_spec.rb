require 'spec_helper_acceptance'

describe 'basic swift' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::rabbitmq
      include openstack_integration::mysql
      include openstack_integration::memcached
      include openstack_integration::keystone

      exec { 'setenforce 0':
        path   => '/bin:/sbin:/usr/bin:/usr/sbin',
        onlyif => 'which setenforce && getenforce | grep Enforcing',
        before => Class['::swift'],
      }

      package { 'curl': ensure => present }

      # Swift resources
      class { 'swift':
        # not sure how I want to deal with this shared secret
        swift_hash_path_suffix => 'secrete',
        package_ensure    => latest,
      }
      class { 'swift::keystone::auth':
        public_url   => "http://${::openstack_integration::config::ip_for_url}:8080/v1/AUTH_%(tenant_id)s",
        admin_url    => "http://${::openstack_integration::config::ip_for_url}:8080",
        internal_url => "http://${::openstack_integration::config::ip_for_url}:8080/v1/AUTH_%(tenant_id)s",
        password     => 'a_big_secret',
      }
      # === Configure Storage
      class { 'swift::storage':
        storage_local_net_ip => $::openstack_integration::config::host,
      }
      # create xfs partitions on a loopback device and mounts them
      swift::storage::loopback { ['2','3','4']:
        seek    => '200000',
        require => Class['swift'],
      }
      # Create storage policy 0 in swift.conf
      swift::storage::policy { '0':
        policy_name    => 'Policy-0',
        policy_aliases => 'basic, single, A',
        default_policy => true,
        policy_type    => 'replication'
      }
      # Create storage policy 1 in swift.conf
      swift::storage::policy { '1':
        policy_name    => '3-Replica-Policy',
        policy_aliases => 'extra, triple, B',
        default_policy => false,
        deprecated     => 'No',
      }
      # sets up storage nodes which is composed of a single
      # device that contains an endpoint for an object, account, and container
      swift::storage::node { '2':
        mnt_base_dir         => '/srv/node',
        weight               => 1,
        zone                 => '2',
        storage_local_net_ip => $::openstack_integration::config::host,
        policy_index         => 0,
        require              => Swift::Storage::Loopback['2','3','4'] ,
      }
      # ring_object_devices for a storage policy start with the policy id.
      # Create 3 ring_object_device starting with "1:" to be
      # added to an object-1 ring for storage policy 1.
      ring_object_device { "1:${::openstack_integration::config::ip_for_url}:6000/2":
        zone    => 2,
        weight  => 1,
        require => Swift::Storage::Loopback['2'],
      }
      ring_object_device { "1:${::openstack_integration::config::ip_for_url}:6000/3":
        zone    => 2,
        weight  => 1,
        require => Swift::Storage::Loopback['3'] ,
      }
      ring_object_device { "1:${::openstack_integration::config::ip_for_url}:6000/4":
        zone    => 2,
        weight  => 1,
        require => Swift::Storage::Loopback['4'] ,
      }
      class { 'swift::ringbuilder':
        part_power     => 18,
        replicas       => 1,
        min_part_hours => 1,
      }
      swift::ringbuilder::policy_ring { '1':
        part_power     => 18,
        replicas       => 3,
        min_part_hours => 1,
      }
      class { 'swift::proxy':
        proxy_local_net_ip => $::openstack_integration::config::host,
        pipeline           => [
          'catch_errors', 'gatekeeper', 'healthcheck', 'proxy-logging',
          'cache', 'authtoken', 'keystone', 'symlink', 'proxy-logging',
          'proxy-server'
        ],
        account_autocreate => true,
      }
      class { 'swift::proxy::authtoken':
        www_authenticate_uri => "${::openstack_integration::config::keystone_auth_uri}/v3",
        auth_url             => "${::openstack_integration::config::keystone_admin_uri}/",
        password             => 'a_big_secret',
      }
      class { 'swift::keystone::dispersion': } -> class { 'swift::dispersion': }
      class { 'swift::objectexpirer':
        interval => 600,
      }
      class { 'swift::proxy::cache':
        memcache_servers => $::openstack_integration::config::swift_memcached_servers
      }
      class {
        [
          'swift::proxy::catch_errors',
          'swift::proxy::gatekeeper',
          'swift::proxy::healthcheck',
          'swift::proxy::proxy_logging',
          'swift::proxy::keystone',
          'swift::proxy::symlink'
        ]:
      }
      EOS

      # Need to be run 2 times because we have an exported when creating the ring.
      apply_manifest(pp, :catch_failures => false)
      apply_manifest(pp, :catch_failures => true)
      # The third run tests idempotency
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8080) do
      it { is_expected.to be_listening.with('tcp') }
    end

  end

  context 'Using swiftinit service provider' do

    it 'should work with no errors' do
      swiftinit_pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::rabbitmq
      include openstack_integration::mysql
      include openstack_integration::memcached
      include openstack_integration::keystone

      exec { 'setenforce 0':
        path   => '/bin:/sbin:/usr/bin:/usr/sbin',
        onlyif => 'which setenforce && getenforce | grep Enforcing',
        before => Class['::swift'],
      }

      package { 'curl': ensure => present }

      # Swift resources
      class { 'swift':
        # not sure how I want to deal with this shared secret
        swift_hash_path_suffix => 'secrete',
        package_ensure    => latest,
      }
      class { 'swift::keystone::auth':
        public_url   => "http://${::openstack_integration::config::ip_for_url}:8080/v1/AUTH_%(tenant_id)s",
        admin_url    => "http://${::openstack_integration::config::ip_for_url}:8080",
        internal_url => "http://${::openstack_integration::config::ip_for_url}:8080/v1/AUTH_%(tenant_id)s",
        password     => 'a_big_secret',
      }
      # === Configure Storage
      class { 'swift::storage':
        storage_local_net_ip => $::openstack_integration::config::host,
      }
      # create xfs partitions on a loopback device and mounts them
      swift::storage::loopback { ['2','3','4']:
        seek    => '200000',
        require => Class['swift'],
      }
      # Create storage policy 0 in swift.conf
      swift::storage::policy { '0':
        policy_name    => 'Policy-0',
        policy_aliases => 'basic, single, A',
        default_policy => true,
        policy_type    => 'replication'
      }
      # Create storage policy 1 in swift.conf
      swift::storage::policy { '1':
        policy_name    => '3-Replica-Policy',
        policy_aliases => 'extra, triple, B',
        default_policy => false,
        deprecated     => 'No',
      }
      # sets up storage nodes which is composed of a single
      # device that contains an endpoint for an object, account, and container
      swift::storage::node { '2':
        mnt_base_dir         => '/srv/node',
        weight               => 1,
        zone                 => '2',
        storage_local_net_ip => $::openstack_integration::config::host,
        policy_index         => 0,
        require              => Swift::Storage::Loopback['2','3','4'] ,
      }
      # ring_object_devices for a storage policy start with the policy id.
      # Create 3 ring_object_device starting with "1:" to be
      # added to an object-1 ring for storage policy 1.
      ring_object_device { "1:${::openstack_integration::config::ip_for_url}:6000/2":
        zone    => 2,
        weight  => 1,
        require => Swift::Storage::Loopback['2'],
      }
      ring_object_device { "1:${::openstack_integration::config::ip_for_url}:6000/3":
        zone    => 2,
        weight  => 1,
        require => Swift::Storage::Loopback['3'] ,
      }
      ring_object_device { "1:${::openstack_integration::config::ip_for_url}:6000/4":
        zone    => 2,
        weight  => 1,
        require => Swift::Storage::Loopback['4'] ,
      }
      class { 'swift::storage::account':
        service_provider => 'swiftinit',
      }
      class { 'swift::storage::container':
        service_provider => 'swiftinit',
      }
      class { 'swift::storage::object':
        service_provider => 'swiftinit',
      }
      class { 'swift::ringbuilder':
        part_power     => 18,
        replicas       => 1,
        min_part_hours => 1,
      }
      swift::ringbuilder::policy_ring { '1':
        part_power     => 18,
        replicas       => 3,
        min_part_hours => 1,
      }
      class { 'swift::proxy':
        proxy_local_net_ip => $::openstack_integration::config::host,
        pipeline           => [
          'catch_errors', 'gatekeeper', 'healthcheck', 'proxy-logging',
          'cache', 'authtoken', 'keystone', 'symlink', 'proxy-logging',
          'proxy-server'
        ],
        account_autocreate => true,
        service_provider   => 'swiftinit',
      }
      class { 'swift::proxy::authtoken':
        www_authenticate_uri => "${::openstack_integration::config::keystone_auth_uri}/v3",
        auth_url             => "${::openstack_integration::config::keystone_admin_uri}/",
        password             => 'a_big_secret',
      }
      class { 'swift::keystone::dispersion': } -> class { 'swift::dispersion': }
      class { 'swift::objectexpirer':
        interval         => 600,
        service_provider => 'swiftinit',
      }
      class { 'swift::proxy::cache':
        memcache_servers => $::openstack_integration::config::swift_memcached_servers
      }
      class {
        [
          'swift::proxy::catch_errors',
          'swift::proxy::gatekeeper',
          'swift::proxy::healthcheck',
          'swift::proxy::proxy_logging',
          'swift::proxy::keystone',
          'swift::proxy::symlink'
        ]:
      }
      EOS

      # Run one time to catch any errors upgrading to swiftinit service provider
      apply_manifest(swiftinit_pp, :catch_failures => true)
      # The second run tests idempotency
      apply_manifest(swiftinit_pp, :catch_changes => true)

    end

    describe port(8080) do
      it { is_expected.to be_listening.with('tcp') }
    end
  end
end
