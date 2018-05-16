require 'spec_helper'

describe 'swift::ringbuilder::policy_ring' do

  let :title do
    "1"
  end

  shared_examples 'swift::ringbuilder::policy_ring' do
    describe 'when swift class is not included' do
      it { should raise_error(Puppet::Error) }
    end

    describe 'when swift class is included and policy is >= 1' do
      let :pre_condition do
        "class { memcached: max_memory => 1}
         class { swift: swift_hash_path_suffix => string }"
      end

      it 'should rebalance the object ring' do
        is_expected.to contain_swift__ringbuilder__rebalance('object-1')
      end

      describe 'with default parameters' do
        it { is_expected.to contain_swift__ringbuilder__create('object-1').with(
          :part_power     => '18',
          :replicas       => '3',
          :min_part_hours => '24'
        )}
      end

      describe 'with parameter overrides' do
        let :params do
          {:part_power     => '19',
           :replicas       => '3',
           :min_part_hours => '2'
          }
        end

        it { is_expected.to contain_swift__ringbuilder__create('object-1').with(
          :part_power     => '19',
          :replicas       => '3',
          :min_part_hours => '2'
        )}
      end

      describe 'when specifying ring devices' do
        let :pre_condition do
           'class { memcached: max_memory => 1}
            class { swift: swift_hash_path_suffix => string }
            ring_object_device { "1:127.0.0.1:6000/1":
            zone        => 1,
            weight      => 1,
          }'
        end

        it 'should set up all of the correct dependencies' do
          is_expected.to contain_swift__ringbuilder__create('object-1').with(
            {:before => ['Ring_object_device[1:127.0.0.1:6000/1]']}
          )
          is_expected.to contain_ring_object_device('1:127.0.0.1:6000/1').with(
          {:notify => ['Swift::Ringbuilder::Rebalance[object-1]']}
          )
        end
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

      it_configures 'swift::ringbuilder::policy_ring'
    end
  end
end
