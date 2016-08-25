require 'spec_helper_acceptance'

describe 'basic swift' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      package { 'curl': ensure => present }

      class { '::memcached':
        listen_ip => '127.0.0.1',
      }

      # Swift resources
      class { '::swift':
        # not sure how I want to deal with this shared secret
        swift_hash_path_suffix => 'secrete',
        package_ensure    => latest,
      }
      class { '::swift::keystone::auth':
        password => 'a_big_secret',
      }
      # === Configure Storage
      class { '::swift::storage':
        storage_local_net_ip => '127.0.0.1',
      }
      # create xfs partitions on a loopback device and mounts them
      swift::storage::loopback { '2':
        seek    => '200000',
        require => Class['swift'],
      }
      # sets up storage nodes which is composed of a single
      # device that contains an endpoint for an object, account, and container
      swift::storage::node { '2':
        mnt_base_dir         => '/srv/node',
        weight               => 1,
        manage_ring          => true,
        zone                 => '2',
        storage_local_net_ip => '127.0.0.1',
        require              => Swift::Storage::Loopback['2'] ,
      }
      class { '::swift::ringbuilder':
        part_power     => '18',
        replicas       => '1',
        min_part_hours => 1,
      }
      class { '::swift::proxy':
        proxy_local_net_ip => '127.0.0.1',
        pipeline           => ['healthcheck', 'proxy-logging', 'cache', 'authtoken', 'keystone', 'dlo', 'proxy-server'],
        account_autocreate => true,
      }
      class { '::swift::proxy::authtoken':
        password => 'a_big_secret',
      }
      class { '::swift::keystone::dispersion': } -> class { '::swift::dispersion': }
      class {'::swift::objectexpirer':
        interval => 600,
      }
      class {
        [ '::swift::proxy::healthcheck', '::swift::proxy::proxy_logging', '::swift::proxy::cache',
        '::swift::proxy::keystone', '::swift::proxy::dlo' ]:
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
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      package { 'curl': ensure => present }

      class { '::memcached':
        listen_ip => '127.0.0.1',
      }

      # Swift resources
      class { '::swift':
        # not sure how I want to deal with this shared secret
        swift_hash_path_suffix => 'secrete',
        package_ensure    => latest,
      }
      class { '::swift::keystone::auth':
        password => 'a_big_secret',
      }
      # === Configure Storage
      class { '::swift::storage':
        storage_local_net_ip => '127.0.0.1',
      }
      # create xfs partitions on a loopback device and mounts them
      swift::storage::loopback { '2':
        seek    => '200000',
        require => Class['swift'],
      }
      # sets up storage nodes which is composed of a single
      # device that contains an endpoint for an object, account, and container
      swift::storage::node { '2':
        mnt_base_dir         => '/srv/node',
        weight               => 1,
        manage_ring          => true,
        zone                 => '2',
        storage_local_net_ip => '127.0.0.1',
        require              => Swift::Storage::Loopback['2'] ,
      }
      class { '::swift::storage::account':
        service_provider => 'swiftinit',
      }
      class { '::swift::storage::container':
        service_provider => 'swiftinit',
      }
      class { '::swift::storage::object':
        service_provider => 'swiftinit',
      }
      class { '::swift::ringbuilder':
        part_power     => '18',
        replicas       => '1',
        min_part_hours => 1,
      }
      class { '::swift::proxy':
        proxy_local_net_ip => '127.0.0.1',
        pipeline           => ['healthcheck', 'proxy-logging', 'cache', 'authtoken', 'keystone', 'dlo', 'proxy-server'],
        account_autocreate => true,
        service_provider   => 'swiftinit',
      }
      class { '::swift::proxy::authtoken':
        admin_password => 'a_big_secret',
      }
      class { '::swift::keystone::dispersion': } -> class { '::swift::dispersion': }
      class {'::swift::objectexpirer':
        interval         => 600,
        service_provider => 'swiftinit',
      }
      class {
        [ '::swift::proxy::healthcheck', '::swift::proxy::proxy_logging', '::swift::proxy::cache',
        '::swift::proxy::keystone', '::swift::proxy::dlo' ]:
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
