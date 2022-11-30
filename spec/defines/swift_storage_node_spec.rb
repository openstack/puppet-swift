require 'spec_helper'

describe 'swift::storage::node' do
  shared_examples 'swift::storage::node' do
    let :title do
      "1"
    end

    context 'with valid preconditons and IPv4 address' do
      let :params do
        {
          :zone         => "1",
          :mnt_base_dir => '/srv/node'
        }
      end

      let :pre_condition do
        "class { 'swift': swift_hash_path_suffix => 'foo' }
         class { 'swift::storage': storage_local_net_ip => '127.0.0.1' }"
      end

      it 'should contain ring devices' do
        is_expected.to contain_ring_object_device("127.0.0.1:6010/1")
        is_expected.to contain_ring_container_device("127.0.0.1:6011/1")
        is_expected.to contain_ring_account_device("127.0.0.1:6012/1")
      end
    end

    context 'when zone is not a number' do
      let :params do
        {
          :zone         => 'invalid',
          :mnt_base_dir => '/srv/node'
        }
      end

      it { should raise_error(Puppet::Error) }
    end

    context 'with valid preconditions and IPv6 address' do
      let :params do
        {
          :zone                 => "1",
          :mnt_base_dir         => '/srv/node',
          :storage_local_net_ip => '::1',
        }
      end

      let :pre_condition do
        "class { 'swift': swift_hash_path_suffix => 'foo' }
         class { 'swift::storage': storage_local_net_ip => '::1' }"
      end

      it 'should contain ring devices with IPv6 address' do
        is_expected.to contain_ring_object_device("[::1]:6010/1")
        is_expected.to contain_ring_container_device("[::1]:6011/1")
        is_expected.to contain_ring_account_device("[::1]:6012/1")
      end
    end

    context 'with valid preconditons and policy_index=1' do
      let :params do
        {
          :zone         => "1",
          :mnt_base_dir => '/srv/node',
          :policy_index => '1',
        }
      end

      let :pre_condition do
        "class { 'swift': swift_hash_path_suffix => 'foo' }
         class { 'swift::storage': storage_local_net_ip => '127.0.0.1' }"
      end

      it 'should contain ring devices' do
        is_expected.to contain_ring_object_device("1:127.0.0.1:6010/1")
        is_expected.to contain_ring_container_device("127.0.0.1:6011/1")
        is_expected.to contain_ring_account_device("127.0.0.1:6012/1")
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::storage::node'
    end
  end
end
