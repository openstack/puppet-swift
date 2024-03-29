require 'spec_helper'

describe 'swift::storage::account' do
  let :pre_condition do
     "class { 'swift': swift_hash_path_suffix => 'foo' }
     class { 'swift::storage::all': storage_local_net_ip => '10.0.0.1' }"
  end

  let :params do
    { :package_ensure => 'present',
      :enabled        => true,
      :manage_service => true }
  end

  shared_examples 'swift::storage::account' do
    [{},
     {:package_ensure => 'latest'}
    ].each do |param_set|
      describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
        before do
          params.merge!(param_set)
        end

        it { is_expected.to contain_swift__storage__generic('account').with_package_ensure(params[:package_ensure]) }
      end
    end

    [{ :enabled => true, :manage_service => true },
     { :enabled => false, :manage_service => true }].each do |param_hash|
      context "when service is_expected.to be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures services' do
          platform_params[:service_names].each do |service_alias, service_name|
            is_expected.to contain_service(service_alias).with(
              :name     => service_name,
              :ensure   => (param_hash[:manage_service] && param_hash[:enabled]) ? 'running' : 'stopped',
              :enable   => param_hash[:enabled],
              :provider => nil,
              :tag      => ['swift-service', 'swift-account-service'],
            )
          end
        end
      end
    end

    context 'with disabled service management' do
      before do
        params.merge!({
          :manage_service => false,
        })
      end

      it 'does not configure services' do 
        [
          'swift-account-server', 
          'swift-account-replicator',
          'swift-account-reaper',
          'swift-account-auditor'
        ].each do |service_alias, service_name|
          is_expected.to_not contain_service(service_alias)
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

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :service_names => {
              'swift-account-server'     => 'swift-account',
              'swift-account-replicator' => 'swift-account-replicator',
              'swift-account-reaper'     => 'swift-account-reaper',
              'swift-account-auditor'    => 'swift-account-auditor'
            }
          }
        when 'RedHat'
          { :service_names => {
              'swift-account-server'     => 'openstack-swift-account',
              'swift-account-replicator' => 'openstack-swift-account-replicator',
              'swift-account-reaper'     => 'openstack-swift-account-reaper',
              'swift-account-auditor'    => 'openstack-swift-account-auditor'
            }
          }
        end
      end

      it_configures 'swift::storage::account'
    end
  end
end
