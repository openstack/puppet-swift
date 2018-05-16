require 'spec_helper'

describe 'swift::storage::generic' do
  let :title do
    'account'
  end

  let :pre_condition do
    "class { 'swift': swift_hash_path_suffix => 'foo' }
     class { 'swift::storage': storage_local_net_ip => '10.0.0.1' }"
  end

  let :params do
    { :package_ensure => 'present',
      :enabled        => true,
      :manage_service => true }
  end

  shared_examples 'swift::storage::generic' do
    describe 'with an invalid title' do
      let :title do
        'foo'
      end

      it_raises 'a Puppet::Error', /does not match/
    end

    %w(account object container).each do |t|
      [{},
       { :package_ensure => 'latest', :service_provider => 'swiftinit' }
      ].each do |param_set|
        describe "when #{param_set == {} ? 'using default' : 'specifying'} class parameters" do
          before do
            params.merge!(param_set)
          end

          let :title do
            t
          end

          let :swiftinit_platform do
            {
              'swift-account-server'       => 'swift-account-server',
              'swift-account-replicator'   => 'swift-account-replicator',
              'swift-account-auditor'      => 'swift-account-auditor',
              'swift-container-server'     => 'swift-container-server',
              'swift-container-replicator' => 'swift-container-replicator',
              'swift-container-auditor'    => 'swift-container-auditor',
              'swift-object-server'        => 'swift-object-server',
              'swift-object-replicator'    => 'swift-object-replicator',
              'swift-object-auditor'       => 'swift-object-auditor',
            }
          end

          [{ :enabled => true, :manage_service => true },
           { :enabled => false, :manage_service => true }].each do |param_hash_manage|
            context "when service is_expected.to be #{param_hash_manage[:enabled] ? 'enabled' : 'disabled'}" do
              before do
                params.merge!(param_hash_manage)

                if param_set[:service_provider] == 'swiftinit'
                  platform_params.merge!(swiftinit_platform)
                end
              end

              it do
                is_expected.to contain_package("swift-#{t}").with(
                  :ensure => params[:package_ensure],
                  :tag    => ['openstack', 'swift-package'],
                  :notify => ['Anchor[swift::install::end]']
                )
              end

              it do
                is_expected.to contain_service("swift-#{t}-server").with(
                  :name     => platform_params["swift-#{t}-server"],
                  :ensure   => (param_hash_manage[:manage_service] && param_hash_manage[:enabled]) ? 'running' : 'stopped',
                  :enable   => param_hash_manage[:enabled],
                  :provider => param_set[:service_provider],
                  :tag      => 'swift-service'
                )
              end

              it do
                is_expected.to contain_service("swift-#{t}-replicator").with(
                  :name     => platform_params["swift-#{t}-replicator"],
                  :ensure   => (param_hash_manage[:manage_service] && param_hash_manage[:enabled]) ? 'running' : 'stopped',
                  :enable   => param_hash_manage[:enabled],
                  :provider => param_set[:service_provider],
                  :tag      => 'swift-service'
                )
              end

              it do
                is_expected.to contain_service("swift-#{t}-auditor").with(
                  :name     => platform_params["swift-#{t}-auditor"],
                  :ensure   => (param_hash_manage[:manage_service] && param_hash_manage[:enabled]) ? 'running' : 'stopped',
                  :enable   => param_hash_manage[:enabled],
                  :provider => param_set[:service_provider],
                  :tag      => 'swift-service'
                )
              end

              it do
                is_expected.to contain_file("/etc/swift/#{t}-server/").with(
                  :ensure => 'directory',
                )
              end
            end
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

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            'swift-account-server'       => 'swift-account',
            'swift-account-replicator'   => 'swift-account-replicator',
            'swift-account-auditor'      => 'swift-account-auditor',
            'swift-container-server'     => 'swift-container',
            'swift-container-replicator' => 'swift-container-replicator',
            'swift-container-auditor'    => 'swift-container-auditor',
            'swift-object-server'        => 'swift-object',
            'swift-object-replicator'    => 'swift-object-replicator',
            'swift-object-auditor'       => 'swift-object-auditor',
          }
        when 'RedHat'
          {
            'swift-account-server'       => 'openstack-swift-account',
            'swift-account-replicator'   => 'openstack-swift-account-replicator',
            'swift-account-auditor'      => 'openstack-swift-account-auditor',
            'swift-container-server'     => 'openstack-swift-container',
            'swift-container-replicator' => 'openstack-swift-container-replicator',
            'swift-container-auditor'    => 'openstack-swift-container-auditor',
            'swift-object-server'        => 'openstack-swift-object',
            'swift-object-replicator'    => 'openstack-swift-object-replicator',
            'swift-object-auditor'       => 'openstack-swift-object-auditor',
          }
        end
      end

      it_configures 'swift::storage::generic'
    end
  end
end
