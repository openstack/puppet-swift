require 'spec_helper'

describe 'swift::objectexpirer' do

  let :params do
    {}
  end

  let :pre_condition do
    'class { "memcached": }'
  end

  shared_examples 'swift::objectexpirer' do
    context 'with defaults' do
      it { is_expected.to contain_file('/etc/swift/object-expirer.conf').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'swift',
        :mode   => '0640',
      )}

      it 'configures object-expirer.conf' do
        is_expected.to contain_swift_object_expirer_config(
          'pipeline:main/pipeline').with_value('catch_errors proxy-logging cache proxy-server')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/concurrency').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/expiring_objects_account_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/process').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/processes').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/reclaim_age').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/request_tries').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/tasks_per_second').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/recon_cache_path').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/report_interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/log_name').with_value('object-expirer')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/log_level').with_value('INFO')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/log_facility').with_value('LOG_LOCAL2')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/log_address').with_value('/dev/log')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/log_max_line_length').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/memcache_servers').with_value('127.0.0.1:11211')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/tls_enabled').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/tls_cafile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/tls_certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/tls_keyfile').with_value('<SERVICE DEFAULT>')
      end

      it 'configures object-expirer service' do
        is_expected.to contain_service('swift-object-expirer').with(
          :ensure    => 'running',
          :name      => platform_params[:service_name],
          :provider  => platform_params[:service_provider],
          :enable    => true,
        )
      end
    end

    context 'when overriding parameters' do
      before do
        params.merge!(
          :concurrency      => 4,
          :interval         => 600,
          :reclaim_age      => 86400,
          :request_tries    => 3,
          :tasks_per_second => 50,
        )
      end
      it 'configures object-expirer.conf' do
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/concurrency').with_value(4)
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/interval').with_value('600')
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/reclaim_age').with_value(86400)
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/request_tries').with_value(3)
        is_expected.to contain_swift_object_expirer_config(
          'object-expirer/tasks_per_second').with_value(50)
      end
    end

    context 'when cache is not included in pipeline' do
      before do
        params.merge!(
          :pipeline => ['catch_errors', 'proxy-logging', 'proxy-server'],
        )
      end

      it 'should not configure memcache servers' do
        is_expected.to contain_swift_object_expirer_config(
          'pipeline:main/pipeline').with_value('catch_errors proxy-logging proxy-server')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/memcache_servers').with_ensure('absent')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/tls_enabled').with_ensure('absent')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/tls_cafile').with_ensure('absent')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/tls_certfile').with_ensure('absent')
        is_expected.to contain_swift_object_expirer_config(
          'filter:cache/tls_keyfile').with_ensure('absent')
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
          { :service_name => 'swift-object-expirer' }
        when 'RedHat'
          { :service_name => 'openstack-swift-object-expirer' }
        end
      end

      it_configures 'swift::objectexpirer'
    end

  end
end
