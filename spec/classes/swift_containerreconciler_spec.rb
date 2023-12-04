require 'spec_helper'

describe 'swift::containerreconciler' do

  let :params do
    {}
  end

  let :pre_condition do
    'class { "memcached": max_memory => 1 }'
  end

  shared_examples 'swift::container::reconciler' do
    context 'with defaults' do
      it 'configures container-reconciler.conf' do
        is_expected.to contain_swift_container_reconciler_config(
          'pipeline:main/pipeline').with_value('catch_errors proxy-logging proxy-server')
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/reclaim_age').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/request_tries').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/memcache_servers').with_ensure('absent')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/tls_enabled').with_ensure('absent')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/tls_cafile').with_ensure('absent')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/tls_certfile').with_ensure('absent')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/tls_keyfile').with_ensure('absent')
      end

      it 'configures container-reconciler service' do
        is_expected.to contain_service('swift-container-reconciler').with(
          :ensure   => 'running',
          :name     => platform_params[:service_name],
          :provider => platform_params[:service_provider],
          :enable   => true,
        )
      end
    end

    context 'when overriding parameters' do
      before do
        params.merge!(
          :interval      => '600',
          :reclaim_age   => '10000',
          :request_tries => '3',
        )
      end

      it 'configures container-reconciler.conf' do
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/interval').with_value(600)
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/reclaim_age').with_value(10000)
        is_expected.to contain_swift_container_reconciler_config(
          'container-reconciler/request_tries').with_value(3)
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
          'pipeline:main/pipeline').with_value('catch_errors proxy-logging cache proxy-server')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/memcache_servers').with_value('127.0.0.1:11211')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/tls_enabled').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/tls_cafile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/tls_certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_reconciler_config(
          'filter:cache/tls_keyfile').with_value('<SERVICE DEFAULT>')
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
        case facts[:os]['family']
        when 'Debian'
          { :service_name => 'swift-container-reconciler' }
        when 'RedHat'
          { :service_name => 'openstack-swift-container-reconciler' }
        end
      end

      it_configures 'swift::container::reconciler'
    end

  end
end
