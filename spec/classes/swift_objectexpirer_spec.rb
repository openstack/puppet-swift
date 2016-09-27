require 'spec_helper'

describe 'swift::objectexpirer' do

  let :default_params do
    { :manage_service                => true,
      :enabled                       => true,
      :package_ensure                => 'present',
      :pipeline                      => ['catch_errors', 'proxy-server'],
      :auto_create_account_prefix    => '.',
      :concurrency                   => 1,
      :expiring_objects_account_name => 'expiring_objects',
      :interval                      => 300,
      :process                       => 0,
      :processes                     => 0,
      :reclaim_age                   => 604800,
      :recon_cache_path              => '/var/cache/swift',
      :report_interval               => 300,
      :memcache_servers              => ['127.0.0.1:11211'] }
  end

  let :params do
    {}
  end

  let :pre_condition do
    'class { "memcached": max_memory => 1 }'
  end

  shared_examples_for 'swift-object-expirer' do
    let (:p) { default_params.merge!(params) }

    context 'with defaults' do
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

    context 'when overridding parameters' do
      before do
        params.merge!(
          :interval    => '600',
          :reclaim_age => '10000',
          :concurrency => '3',
        )
      end
    end

    context 'when including cache in pipeline' do
      before do
        params.merge!(
          :pipeline         => ['catch_errors', 'cache', 'proxy-server'],
          :memcache_servers => ['127.0.0.1:11211'],
        )
      end

      it 'configures memcache servers' do
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/memcache_servers').with_value(p[:memcache_servers])
      end
    end

    context 'when using swiftinit service provider' do
      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      before do
        platform_params.merge!({ :service_provider => 'swiftinit' })
      end
    end

  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :service_name     => 'swift-object-expirer',
            :service_provider => nil }
        when 'RedHat'
          { :service_name     => 'openstack-swift-object-expirer',
            :service_provider => nil }
        end
      end

      it_configures 'swift-object-expirer'
    end

  end
end
