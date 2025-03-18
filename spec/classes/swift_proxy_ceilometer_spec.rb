require 'spec_helper'

describe 'swift::proxy::ceilometer' do

  let :pre_condition do
     'class { "swift":
        swift_hash_path_suffix => "dummy"
     }'
  end

  shared_examples 'swift::proxy::ceilometer' do

    let :params do
      {
        :password              => 'swiftpassword',
        :default_transport_url => 'rabbit://user_1:user_1_passw@1.1.1.1:5673/rabbit',
      }
    end

    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/password').with_value('swiftpassword').with_secret(true) }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/paste.filter_factory').with_value('ceilometermiddleware.swift:filter_factory') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/url').with_value('rabbit://user_1:user_1_passw@1.1.1.1:5673/rabbit').with_secret(true) }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/driver').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/topic').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/control_exchange').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/nonblocking_notify').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/extra_config_files').with_value('/etc/swift/ceilometer.conf') }

      it { is_expected.to contain_package('python-ceilometermiddleware').with(
        :ensure => 'present',
        :name   => platform_params[:ceilometermiddleware_package_name],
        :tag    => ['openstack', 'swift-support-package'],
      )}

      it { is_expected.to contain_file('/etc/swift/ceilometer.conf').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'swift',
        :mode   => '0640',
      )}
    end

    describe "when overriding default parameters with rabbit driver" do
      before :each do
        params.merge!({
          :driver              => 'messagingv2',
          :topic               => 'notifications',
          :control_exchange    => 'swift',
          :nonblocking_notify  => true,
          :ignore_projects     => ['services', 'admin'],
          :auth_url            => 'http://127.0.0.1:5000',
          :auth_type           => 'password',
          :project_domain_name => 'Default',
          :user_domain_name    => 'Default',
          :project_name        => 'services',
          :username            => 'swift',
          :region_name         => 'region2'
        })
      end

      context 'with single rabbit host' do
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/paste.filter_factory').with_value('ceilometermiddleware.swift:filter_factory') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/url').with_value('rabbit://user_1:user_1_passw@1.1.1.1:5673/rabbit').with_secret(true) }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/driver').with_value('messagingv2') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/topic').with_value('notifications') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/control_exchange').with_value('swift') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/nonblocking_notify').with_value('true') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/ignore_projects').with_value('services,admin') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/auth_url').with_value('http://127.0.0.1:5000') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/auth_type').with_value('password') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/project_name').with_value('services') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/project_domain_name').with_value('Default') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/system_scope').with_value('<SERVICE DEFAULT>') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/username').with_value('swift') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/user_domain_name').with_value('Default') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/region_name').with_value('region2') }
      end

      it { is_expected.to contain_oslo__messaging__rabbit('swift_ceilometer_config').with(
        :rabbit_ha_queues              => '<SERVICE DEFAULT>',
        :rabbit_quorum_queue           => '<SERVICE DEFAULT>',
        :rabbit_transient_quorum_queue => '<SERVICE DEFAULT>',
        :heartbeat_timeout_threshold   => '<SERVICE DEFAULT>',
        :heartbeat_rate                => '<SERVICE DEFAULT>',
        :heartbeat_in_pthread          => nil,
        :rabbit_qos_prefetch_count     => '<SERVICE DEFAULT>',
        :amqp_durable_queues           => '<SERVICE DEFAULT>',
        :amqp_auto_delete              => '<SERVICE DEFAULT>',
        :kombu_ssl_ca_certs            => '<SERVICE DEFAULT>',
        :kombu_ssl_certfile            => '<SERVICE DEFAULT>',
        :kombu_ssl_keyfile             => '<SERVICE DEFAULT>',
        :kombu_ssl_version             => '<SERVICE DEFAULT>',
        :rabbit_use_ssl                => '<SERVICE DEFAULT>',
        :rabbit_quorum_delivery_limit  => '<SERVICE DEFAULT>',
        :rabbit_transient_queues_ttl   => '<SERVICE DEFAULT>',
        :kombu_reconnect_delay         => '<SERVICE DEFAULT>',
        :kombu_failover_strategy       => '<SERVICE DEFAULT>',
        :kombu_compression             => '<SERVICE DEFAULT>',
      )}

      context 'with overridden rabbit ssl params' do
        before do
          params.merge!(
            {
              :notification_ssl_ca_file   => '/etc/ca.cert',
              :notification_ssl_cert_file => '/etc/certfile',
              :notification_ssl_key_file  => '/etc/key',
              :rabbit_use_ssl             => true,
              :kombu_ssl_version          => 'TLSv1',
            })
        end

        it { is_expected.to contain_oslo__messaging__rabbit('swift_ceilometer_config').with(
          :rabbit_use_ssl     => true,
          :kombu_ssl_ca_certs => '/etc/ca.cert',
          :kombu_ssl_certfile => '/etc/certfile',
          :kombu_ssl_keyfile  => '/etc/key',
          :kombu_ssl_version  => 'TLSv1',
        )}
      end

    end

    describe 'when system_scope is set' do
      before :each do
        params.merge!({
          :system_scope => 'all'
        })
      end

      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/project_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/project_domain_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/system_scope').with_value('all') }
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
          { :ceilometermiddleware_package_name => 'python3-ceilometermiddleware' }
        when 'RedHat'
          { :ceilometermiddleware_package_name => 'python3-ceilometermiddleware' }
        end
      end

      it_behaves_like 'swift::proxy::ceilometer'
    end
  end

end
