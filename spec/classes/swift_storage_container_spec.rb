require 'spec_helper'

describe 'swift::storage::container' do
  let :pre_condition do
    "class { 'swift': swift_hash_path_suffix => 'foo' }
     class { 'swift::storage': storage_local_net_ip => '10.0.0.1' }"
  end

  let :params do
    { :package_ensure => 'present',
      :enabled        => true,
      :manage_service => true }
  end

  shared_examples_for 'swift-storage-container' do
    [{},
     {:package_ensure => 'latest'}
    ].each do |param_set|
      describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
        before do
          params.merge!(param_set)
        end

        it { is_expected.to contain_swift__storage__generic('container').with_package_ensure(params[:package_ensure]) }
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
              :provider => platform_params[:service_provider],
              :tag      => 'swift-service',
            )
          end
        end
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures services' do
        platform_params[:service_names].each do |service_alias, service_name|
          is_expected.to contain_service(service_alias).with(
            :ensure    => nil,
            :name      => service_name,
            :enable    => false,
            :tag       => 'swift-service',
          )
        end
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      OSDefaults.get_facts({
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
      })
    end

    let :platform_params do
      { :service_names => {
          'swift-container-server'     => 'swift-container',
          'swift-container-replicator' => 'swift-container-replicator',
          'swift-container-updater'    => 'swift-container-updater',
          'swift-container-auditor'    => 'swift-container-auditor'
        },
        :service_provider => nil
      }
    end

    it_configures 'swift-storage-container'

    context 'on debian using swiftinit service provider' do

      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      let :platform_params do
        { :service_names => {
            'swift-container-server'     => 'swift-container-server',
            'swift-container-replicator' => 'swift-container-replicator',
            'swift-container-updater'    => 'swift-container-updater',
            'swift-container-auditor'    => 'swift-container-auditor',
            'swift-container-sync'       => 'swift-container-sync'
          },
          :service_provider => 'swiftinit'
        }
      end

      it_configures 'swift-storage-container'
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      OSDefaults.get_facts({
        :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat',
      })
    end

    let :platform_params do
      { :service_names => {
          'swift-container-server'     => 'openstack-swift-container',
          'swift-container-replicator' => 'openstack-swift-container-replicator',
          'swift-container-updater'    => 'openstack-swift-container-updater',
          'swift-container-auditor'    => 'openstack-swift-container-auditor'
        }
      }
    end

    it_configures 'swift-storage-container'

    context 'on redhat using swiftinit service provider' do

      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      let :platform_params do
        { :service_names => {
            'swift-container-server'     => 'swift-container-server',
            'swift-container-replicator' => 'swift-container-replicator',
            'swift-container-updater'    => 'swift-container-updater',
            'swift-container-auditor'    => 'swift-container-auditor',
          },
          :service_provider => 'swiftinit'
        }
      end

      it_configures 'swift-storage-container'
    end
  end
end
