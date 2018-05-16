require 'spec_helper'

describe 'swift::containerreconciler' do

  let :default_params do
    { :manage_service   => true,
      :enabled          => true,
      :package_ensure   => 'present',
      :pipeline         => ['catch_errors', 'proxy-logging', 'proxy-server'],
      :interval         => 300,
      :reclaim_age      => 604800,
      :request_tries    => 3,
      :memcache_servers => ['127.0.0.1:11211'] }
  end

  let :params do
    {}
  end

  let :pre_condition do
    'class { "memcached": max_memory => 1 }'
  end

  shared_examples 'swift::container::reconciler' do
    let (:p) { default_params.merge!(params) }

    context 'with defaults' do
      it 'configures container-reconciler.conf' do
        is_expected.to contain_swift_container_reconciler_config(
          'pipeline:main/pipeline').with_value(p[:pipeline].join(' '))
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/interval').with_value(p[:interval])
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/reclaim_age').with_value(p[:reclaim_age])
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/request_tries').with_value(p[:request_tries])
      end

      it 'configures container-reconciler service' do
        is_expected.to contain_service('swift-container-reconciler').with(
          :ensure   => (p[:manage_service] && p[:enabled]) ? 'running' : 'stopped',
          :name     => platform_params[:service_name],
          :provider => platform_params[:service_provider],
          :enable   => p[:enabled]
        )
      end
    end

    context 'when overridding parameters' do
      before do
        params.merge!(
          :interval      => '600',
          :reclaim_age   => '10000',
          :request_tries => '3',
        )
      end
    end

    context 'when including cache in pipeline' do
      before do
        params.merge!(
          :pipeline         => ['catch_errors', 'proxy-logging', 'cache', 'proxy-server'],
          :memcache_servers => ['127.0.0.1:11211'],
        )
      end

      it 'configures memcache servers' do
        is_expected.to contain_swift_container_reconciler_config(
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
          { :service_name     => 'swift-container-reconciler',
            :service_provider => nil }
        when 'RedHat'
          { :service_name     => 'openstack-swift-container-reconciler',
            :service_provider => nil }
        end
      end

      it_configures 'swift::container::reconciler'
    end

  end
end
