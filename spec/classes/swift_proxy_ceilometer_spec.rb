require 'spec_helper'

describe 'swift::proxy::ceilometer' do

  let :pre_condition do
     'class { "swift":
        swift_hash_path_suffix => "dummy"
     }'
  end

  shared_examples 'swift-proxy-ceilometer' do

    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/paste.filter_factory').with_value('ceilometermiddleware.swift:filter_factory') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/url').with_value('rabbit://guest:guest@127.0.0.1:5672//') }
      it { is_expected.to contain_swift_proxy_config('filter:ceilometer/nonblocking_notify').with_value('false') }
      it { is_expected.to contain_user('swift').with_groups('ceilometer') }
      it { is_expected.to contain_file('/var/log/ceilometer/swift-proxy-server.log').with(:owner => 'swift', :group => 'swift', :mode => '0664') }
    end

    describe "when overriding default parameters with rabbit driver" do
      let :params do
        { :group               => 'www-data',
          :rabbit_user         => 'user_1',
          :rabbit_password     => 'user_1_passw',
          :rabbit_host         => '1.1.1.1',
          :rabbit_port         => '5673',
          :rabbit_virtual_host => 'rabbit',
          :driver              => 'messagingv2',
          :topic               => 'notifications',
          :control_exchange    => 'swift',
          :nonblocking_notify  => true,
        }
      end

      context 'with single rabbit host' do
        it { is_expected.to contain_user('swift').with_groups('www-data') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/paste.filter_factory').with_value('ceilometermiddleware.swift:filter_factory') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/url').with_value('rabbit://user_1:user_1_passw@1.1.1.1:5673/rabbit') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/driver').with_value('messagingv2') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/topic').with_value('notifications') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/control_exchange').with_value('swift') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/nonblocking_notify').with_value('true') }
      end

      context 'with multiple rabbit hosts' do
        before do
          params.merge!({ :rabbit_hosts => ['127.0.0.1:5672', '127.0.0.2:5672'] })
        end

        it { is_expected.to contain_user('swift').with_groups('www-data') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/paste.filter_factory').with_value('ceilometermiddleware.swift:filter_factory') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/url').with_value('rabbit://user_1:user_1_passw@127.0.0.1:5672,user_1:user_1_passw@127.0.0.2:5672/rabbit') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/driver').with_value('messagingv2') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/topic').with_value('notifications') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/control_exchange').with_value('swift') }
        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/nonblocking_notify').with_value('true') }
      end

      context 'with default transport url' do
        before do
          params.merge!({ :default_transport_url => 'rabbit://user:pass@host:1234/virt' })
        end

        it { is_expected.to contain_swift_proxy_config('filter:ceilometer/url').with_value('rabbit://user:pass@host:1234/virt').with_secret(true) }
      end

      it { is_expected.to contain_oslo__messaging__rabbit('swift_proxy_config').with(
        :rabbit_use_ssl     => '<SERVICE DEFAULT>',
        :kombu_ssl_ca_certs => '<SERVICE DEFAULT>',
        :kombu_ssl_certfile => '<SERVICE DEFAULT>',
        :kombu_ssl_keyfile  => '<SERVICE DEFAULT>',
        :kombu_ssl_version  => '<SERVICE DEFAULT>',
      )}

      context 'with overriden rabbit ssl params' do
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

        it { is_expected.to contain_oslo__messaging__rabbit('swift_proxy_config').with(
          :rabbit_use_ssl     => true,
          :kombu_ssl_ca_certs => '/etc/ca.cert',
          :kombu_ssl_certfile => '/etc/certfile',
          :kombu_ssl_keyfile  => '/etc/key',
          :kombu_ssl_version  => 'TLSv1',
        )}
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
      it_behaves_like 'swift-proxy-ceilometer'
    end
  end

end
