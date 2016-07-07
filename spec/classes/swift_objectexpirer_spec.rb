require 'spec_helper'

describe 'swift::objectexpirer' do

  let :default_params do
    { :manage_service                => true,
      :enabled                       => true,
      :package_ensure                => 'present',
      :pipeline                      => ['catch_errors', 'cache', 'proxy-server'],
      :auto_create_account_prefix    => '.',
      :concurrency                   => 1,
      :expiring_objects_account_name => 'expiring_objects',
      :interval                      => 300,
      :process                       => 0,
      :processes                     => 0,
      :reclaim_age                   => 604800,
      :recon_cache_path              => '/var/cache/swift',
      :report_interval               => 300 }
  end

  let :params do
    {}
  end


  shared_examples_for 'swift-object-expirer' do
    let (:p) { default_params.merge!(params) }

    it 'configures object-expirer.conf' do
      is_expected.to contain_swift_object_expirer_config(
        'pipeline:main/pipeline').with_value(p[:pipeline].join(' '))
      is_expected.to contain_swift_object_expirer_config(
        'object-expirer/auto_create_account_prefix').with_value(p[:auto_create_account_prefix])
      is_expected.to contain_swift_object_expirer_config(
        'object-expirer/concurrency').with_value(p[:concurrency])
      is_expected.to contain_swift_object_expirer_config(
        'object-expirer/expiring_objects_account_name').with_value(p[:expiring_objects_account_name])
      is_expected.to contain_swift_object_expirer_config(
        'object-expirer/interval').with_value(p[:interval])
      is_expected.to contain_swift_object_expirer_config(
        'object-expirer/process').with_value(p[:process])
      is_expected.to contain_swift_object_expirer_config(
        'object-expirer/processes').with_value(p[:processes])
      is_expected.to contain_swift_object_expirer_config(
        'object-expirer/reclaim_age').with_value(p[:reclaim_age])
      is_expected.to contain_swift_object_expirer_config(
       'object-expirer/recon_cache_path').with_value(p[:recon_cache_path])
      is_expected.to contain_swift_object_expirer_config(
        'object-expirer/report_interval').with_value(p[:report_interval])
    end

    it 'configures object-expirer service' do
      is_expected.to contain_service('swift-object-expirer').with(
        :ensure    => (p[:manage_service] && p[:enabled]) ? 'running' : 'stopped',
        :name      => platform_params[:service_name],
        :provider  => platform_params[:service_provider],
        :enable    => p[:enabled]
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      OSDefaults.get_facts({
        :operatingsystem  => 'Ubuntu',
        :osfamily         => 'Debian',
      })
    end

    let :platform_params do
      { :object_expirer_package_name => 'swift-object-expirer',
        :service_name                => 'swift-object-expirer',
        :service_provider            => nil }
    end

    it_configures 'swift-object-expirer'

    context 'when overridding parameters' do
      before do
        params.merge!(
          :interval        => '600',
          :reclaim_age     => '10000',
          :concurrency     => '3',
        )
      end

      it_configures 'swift-object-expirer'
    end

    context 'on debian using swiftinit service provider' do
      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      before do
        platform_params.merge!({ :service_provider => 'swiftinit' })
      end

      it_configures 'swift-object-expirer'
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
          { :object_expirer_package_name => 'openstack-swift-proxy',
            :service_name                => 'openstack-swift-object-expirer',
            :service_provider            => nil }
        end

    it_configures 'swift-object-expirer'
    context 'when overridding parameters' do
      before do
        params.merge!(
          :interval        => '600',
          :reclaim_age     => '10000',
          :concurrency     => '3',
        )
      end

      it_configures 'swift-object-expirer'
    end

    context 'on redhat using swiftinit service provider' do
      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      let :platform_params do
        { :object_expirer_package_name => 'openstack-swift-proxy',
          :service_name                => 'swift-object-expirer',
          :service_provider            => 'swiftinit' }
      end

      it_configures 'swift-object-expirer'
    end
  end
end
