require 'spec_helper'

describe 'swift::storage::node' do
  shared_examples 'swift::storage::node' do
    describe 'with valid preconditons should contain ring devices' do
      let :params do
        {
          :zone => "1",
          :mnt_base_dir => '/srv/node'
        }
      end

      let :title do
        "1"
      end

      let :pre_condition do
        "class { 'swift': swift_hash_path_suffix => 'foo' }
         class { 'swift::storage': storage_local_net_ip => '127.0.0.1' }"
      end

      it { is_expected.to contain_ring_object_device("127.0.0.1:6010/1") }
      it { is_expected.to contain_ring_container_device("127.0.0.1:6011/1") }
      it { is_expected.to contain_ring_account_device("127.0.0.1:6012/1") }
    end

    context 'when zone is not a number' do
       let(:title) { '1' }

       let :params do
       { :zone => 'invalid',
         :mnt_base_dir => '/srv/node' }
       end

      it_raises 'a Puppet::Error', /The zone parameter must be an integer/
    end

    describe 'with valid preconditons and policy_index=1 should contain ring devices' do
      let :params do
        {
          :zone => "1",
          :mnt_base_dir => '/srv/node',
          :policy_index => '1',
        }
      end

      let :title do
        "1"
      end

      let :pre_condition do
        "class { 'swift': swift_hash_path_suffix => 'foo' }
         class { 'swift::storage': storage_local_net_ip => '127.0.0.1' }"
      end

      it { is_expected.to contain_ring_object_device("1:127.0.0.1:6010/1") }
      it { is_expected.to contain_ring_container_device("127.0.0.1:6011/1") }
      it { is_expected.to contain_ring_account_device("127.0.0.1:6012/1") }
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
