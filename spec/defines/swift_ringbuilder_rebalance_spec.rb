require 'spec_helper'

describe 'swift::ringbuilder::rebalance' do
  shared_examples 'swift::ringbuilder::rebalance' do
    describe 'with allowed titles' do
      ['object', 'container', 'account', 'object-1', 'object-123'].each do |type|
        describe "when title is #{type}" do
          let :title do
            type
          end

          it { is_expected.to contain_exec("rebalance_#{type}").with(
            {:command     => "swift-ring-builder /etc/swift/#{type}.builder rebalance",
             :path        => ['/usr/bin'],
             :refreshonly => true}
          )}
        end
      end
    end

    describe 'with valid seed' do
      let :params do
        { :seed => '999' }
      end

      let :title do
        'object'
      end

      it { is_expected.to contain_exec("rebalance_object").with(
        {:command     => "swift-ring-builder /etc/swift/object.builder rebalance 999",
         :path        => ['/usr/bin'],
         :refreshonly => true}
      )}
    end

    describe 'with an invalid seed' do
      let :title do
        'object'
      end

      let :params do
        { :seed => 'invalid' }
      end

      it 'should raise an error' do
        expect { catalogue }.to raise_error(Puppet::Error)
      end
    end

    describe 'with an invalid title' do
      ['invalid', 'container-1', 'account-1', 'object-a', 'object-12a'].each do |type|
        describe "when title is #{type}" do
          let :title do
            type
          end

          it 'should raise an error' do
            expect { catalogue }.to raise_error(Puppet::Error)
          end
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

      it_configures 'swift::ringbuilder::rebalance'
    end
  end
end
