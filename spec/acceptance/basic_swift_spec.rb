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
        swift_hash_suffix => 'secrete',
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
        require              => Swift::Storage::Loopback[2] ,
      }
      class { '::swift::ringbuilder':
        part_power     => '18',
        replicas       => '1',
        min_part_hours => 1,
        require        => Class['swift'],
      }
      class { '::swift::proxy':
        proxy_local_net_ip => '127.0.0.1',
        pipeline           => ['healthcheck', 'cache', 'tempauth', 'dlo', 'proxy-server'],
        account_autocreate => true,
        require            => Class['swift::ringbuilder'],
      }
      class { '::swift::proxy::authtoken':
        admin_password => 'a_big_secret',
      }
      class {'::swift::objectexpirer':
        interval => 600,
      }
      class {
        [ '::swift::proxy::healthcheck', '::swift::proxy::cache',
        '::swift::proxy::tempauth', '::swift::proxy::dlo' ]:
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
end
