require 'spec_helper'

describe 'swift::storage::object' do

  let :pre_condition do
    "class { 'swift': swift_hash_path_suffix => 'foo' }
     class { 'swift::storage': storage_local_net_ip => '10.0.0.1' }"
  end

  let :params do
    { :package_ensure => 'present',
      :enabled        => true,
      :manage_service => true }
  end

  shared_examples_for 'swift-storage-object' do

    [{},
     { :package_ensure => 'latest' }
    ].each do |param_set|
      describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
        before do
          params.merge!(param_set)
        end

        it { is_expected.to contain_swift__storage__generic('object').with_package_ensure(params[:package_ensure]) }
      end
    end

    [{ :enabled => true, :manage_service => true },
     { :enabled => false, :manage_service => true }].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
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
       :operatingsystem => 'Ubuntu',
       :osfamily        => 'Debian',
      })
    end

    let :platform_params do
      { :service_names => {
          'swift-object-server'     => 'swift-object',
          'swift-object-replicator' => 'swift-object-replicator',
          'swift-object-updater'    => 'swift-object-updater',
          'swift-object-auditor'    => 'swift-object-auditor'
        },
        :service_provider => nil
      }
    end

    it_configures 'swift-storage-object'
    context 'on debian using swiftinit service provider' do

      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      let :platform_params do
        { :service_names => {
            'swift-object-server'     => 'swift-object-server',
            'swift-object-replicator' => 'swift-object-replicator',
            'swift-object-updater'    => 'swift-object-updater',
            'swift-object-auditor'    => 'swift-object-auditor',
          },
          :service_provider => 'swiftinit'
        }
      end

      it_configures 'swift-storage-object'
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
          'swift-object-server'     => 'openstack-swift-object',
          'swift-object-replicator' => 'openstack-swift-object-replicator',
          'swift-object-updater'    => 'openstack-swift-object-updater',
          'swift-object-auditor'    => 'openstack-swift-object-auditor'
        }
      }
    end

    it_configures 'swift-storage-object'
    context 'on redhat using swiftinit service provider' do

      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      let :platform_params do
        { :service_names => {
            'swift-object-server'     => 'swift-object-server',
            'swift-object-replicator' => 'swift-object-replicator',
            'swift-object-updater'    => 'swift-object-updater',
            'swift-object-auditor'    => 'swift-object-auditor',
          },
          :service_provider => 'swiftinit'
        }
      end

      it_configures 'swift-storage-object'
    end
  end
end
