require 'spec_helper'

describe 'swift::proxy' do
  shared_examples 'swift::proxy' do
    describe 'without memcached being included' do
      it { should raise_error(Puppet::Error) }
    end

    describe 'with proper dependencies' do
      let :pre_condition do
        "class { memcached: }
         class { swift: swift_hash_path_suffix => string }
         include swift::proxy::catch_errors
         include swift::proxy::gatekeeper
         include swift::proxy::healthcheck
         include swift::proxy::proxy_logging
         include swift::proxy::cache
         include swift::proxy::listing_formats
         include swift::proxy::tempauth
         include swift::proxy::copy"
      end

      describe 'without the proxy local network ip address being specified' do
        it_raises 'a Puppet::Error', /expects a value for parameter 'proxy_local_net_ip'/
      end

      describe 'when proxy_local_net_ip is set' do
        let :params do
          {
            :proxy_local_net_ip => '127.0.0.1'
          }
        end

        it { should contain_resources('swift_proxy_config').with(
          :purge => false
        )}

        it { should contain_package('swift-proxy').that_requires('Anchor[swift::install::begin]') }
        it { should contain_package('swift-proxy').that_notifies('Anchor[swift::install::end]') }

        it { should contain_service('swift-proxy-server').with(
          :ensure    => 'running',
          :provider  => nil,
          :enable    => true,
          :hasstatus => true,
          :tag       => ['swift-service', 'swift-proxy-service'],
        )}

        it { is_expected.to contain_file('/etc/swift/proxy-server.conf').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'swift',
          :mode   => '0640',
        )}

        it { should contain_service('swift-proxy-server').that_subscribes_to('Anchor[swift::service::begin]') }
        it { should contain_service('swift-proxy-server').that_notifies('Anchor[swift::service::end]') }
        it { should contain_swift_proxy_config('DEFAULT/bind_port').with_value('8080') }
        it { should contain_swift_proxy_config('DEFAULT/bind_ip').with_value('127.0.0.1') }
        it { should contain_swift_proxy_config('DEFAULT/cert_file').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/key_file').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/workers').with_value('2') }
        it { should contain_swift_proxy_config('DEFAULT/user').with_value('swift') }
        it { should contain_swift_proxy_config('DEFAULT/log_name').with_value('proxy-server') }
        it { should contain_swift_proxy_config('DEFAULT/log_facility').with_value('LOG_LOCAL2') }
        it { should contain_swift_proxy_config('DEFAULT/log_level').with_value('INFO') }
        it { should contain_swift_proxy_config('DEFAULT/log_headers').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/log_address').with_value('/dev/log') }
        it { should contain_swift_proxy_config('DEFAULT/log_udp_host').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/log_udp_port').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/client_timeout').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/keepalive_timeout').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('pipeline:main/pipeline').with_value(
          ['catch_errors', 'gatekeeper', 'healthcheck', 'proxy-logging', 'cache',
           'listing_formats', 'tempauth', 'copy', 'proxy-logging', 'proxy-server'].join(' ')) }
        it { should contain_swift_proxy_config('app:proxy-server/use').with_value('egg:swift#proxy') }
        it { should contain_swift_proxy_config('app:proxy-server/set log_name').with_value('proxy-server') }
        it { should contain_swift_proxy_config('app:proxy-server/set log_facility').with_value('LOG_LOCAL2') }
        it { should contain_swift_proxy_config('app:proxy-server/set log_level').with_value('INFO') }
        it { should contain_swift_proxy_config('app:proxy-server/set log_address').with_value('/dev/log') }
        it { should contain_swift_proxy_config('app:proxy-server/log_handoffs').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/object_chunk_size').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/client_chunk_size').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/allow_account_management').with_value('true') }
        it { should contain_swift_proxy_config('app:proxy-server/account_autocreate').with_value('true') }
        it { should contain_swift_proxy_config('app:proxy-server/max_containers_per_account').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/max_containers_whitelist').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/timing_expiry').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/request_node_count').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/write_affinity').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/write_affinity_node_count').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/write_affinity_handoff_delete_count').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/swift_owner_headers').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/stale_worker_timeout').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/node_timeout').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/recoverable_node_timeout').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('app:proxy-server/allow_open_expired').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/cors_allow_origin').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/strict_cors_mode').with_value('<SERVICE DEFAULT>') }
        it { should contain_swift_proxy_config('DEFAULT/cors_expose_headers').with_value('<SERVICE DEFAULT>') }

        it { should contain_service('swift-proxy-server').with_require([
          'Class[Swift::Proxy::Catch_errors]',
          'Class[Swift::Proxy::Gatekeeper]',
          'Class[Swift::Proxy::Healthcheck]',
          'Class[Swift::Proxy::Proxy_logging]',
          'Class[Swift::Proxy::Cache]',
          'Class[Swift::Proxy::Listing_formats]',
          'Class[Swift::Proxy::Tempauth]',
          'Class[Swift::Proxy::Copy]',
          'Class[Swift::Proxy::Proxy_logging]',
        ])}

        describe "when using swift_proxy_config resource" do
          let :pre_condition do
            "
              class { memcached: }
              class { swift: swift_hash_path_suffix => string }
              swift_proxy_config { 'foo/bar': value => 'foo' }
              include swift::proxy::catch_errors
              include swift::proxy::gatekeeper
              include swift::proxy::healthcheck
              include swift::proxy::proxy_logging
              include swift::proxy::cache
              include swift::proxy::listing_formats
              include swift::proxy::tempauth
              include swift::proxy::copy
            "
          end
        end

        describe 'when more parameters are set' do
          let :pre_condition do
            "class { memcached: }
             class { swift: swift_hash_path_suffix => string }"
          end

          let :params do
            {
              :proxy_local_net_ip                  => '10.0.0.2',
              :port                                => '80',
              :cert_file                           => '/path/to/cert',
              :key_file                            => '/path/to/key',
              :workers                             => 3,
              :pipeline                            => ['proxy-server'],
              :allow_account_management            => false,
              :account_autocreate                  => false,
              :log_level                           => 'DEBUG',
              :log_headers                         => false,
              :log_name                            => 'swift-proxy-server',
              :object_chunk_size                   => '8192',
              :client_chunk_size                   => '8192',
              :max_containers_per_account          => 10,
              :max_containers_whitelist            => 'project1,project2',
              :timing_expiry                       => 300,
              :request_node_count                  => '2 * replicas',
              :read_affinity                       => 'r1z1=100, r1=200',
              :write_affinity                      => 'r1',
              :write_affinity_node_count           => '2 * replicas',
              :write_affinity_handoff_delete_count => 'auto',
              :swift_owner_headers                 => ['x-container-read', 'x-container-write'],
              :stale_worker_timeout                => 86400,
              :client_timeout                      => '120',
              :keepalive_timeout                   => '121',
              :node_timeout                        => '20',
              :recoverable_node_timeout            => '15',
              :allow_open_expired                  => false,
              :cors_allow_origin                   => ['http://foo.bar:1234', 'https://foo.bar'],
              :strict_cors_mode                    => true,
              :cors_expose_headers                 => ['header-a', 'header-b'],
            }
          end

          it { should contain_swift_proxy_config('DEFAULT/bind_port').with_value('80') }
          it { should contain_swift_proxy_config('DEFAULT/bind_ip').with_value('10.0.0.2') }
          it { should contain_swift_proxy_config('DEFAULT/cert_file').with_value('/path/to/cert') }
          it { should contain_swift_proxy_config('DEFAULT/key_file').with_value('/path/to/key') }
          it { should contain_swift_proxy_config('DEFAULT/workers').with_value('3') }
          it { should contain_swift_proxy_config('DEFAULT/user').with_value('swift') }
          it { should contain_swift_proxy_config('DEFAULT/log_name').with_value('swift-proxy-server') }
          it { should contain_swift_proxy_config('DEFAULT/log_facility').with_value('LOG_LOCAL2') }
          it { should contain_swift_proxy_config('DEFAULT/log_level').with_value('DEBUG') }
          it { should contain_swift_proxy_config('DEFAULT/log_headers').with_value(false) }
          it { should contain_swift_proxy_config('DEFAULT/log_address').with_value('/dev/log') }
          it { should contain_swift_proxy_config('DEFAULT/client_timeout').with_value('120') }
          it { should contain_swift_proxy_config('DEFAULT/keepalive_timeout').with_value('121') }
          it { should contain_swift_proxy_config('pipeline:main/pipeline').with_value('proxy-server') }
          it { should contain_swift_proxy_config('app:proxy-server/use').with_value('egg:swift#proxy') }
          it { should contain_swift_proxy_config('app:proxy-server/set log_name').with_value('swift-proxy-server') }
          it { should contain_swift_proxy_config('app:proxy-server/set log_facility').with_value('LOG_LOCAL2') }
          it { should contain_swift_proxy_config('app:proxy-server/set log_level').with_value('DEBUG') }
          it { should contain_swift_proxy_config('app:proxy-server/set log_address').with_value('/dev/log') }
          it { should contain_swift_proxy_config('app:proxy-server/log_handoffs').with_value('<SERVICE DEFAULT>') }
          it { should contain_swift_proxy_config('app:proxy-server/object_chunk_size').with_value('8192') }
          it { should contain_swift_proxy_config('app:proxy-server/client_chunk_size').with_value('8192') }
          it { should contain_swift_proxy_config('app:proxy-server/allow_account_management').with_value('false') }
          it { should contain_swift_proxy_config('app:proxy-server/account_autocreate').with_value('false') }
          it { should contain_swift_proxy_config('app:proxy-server/max_containers_per_account').with_value(10) }
          it { should contain_swift_proxy_config('app:proxy-server/max_containers_whitelist').with_value('project1,project2') }
          it { should contain_swift_proxy_config('app:proxy-server/timing_expiry').with_value(300) }
          it { should contain_swift_proxy_config('app:proxy-server/request_node_count').with_value('2 * replicas') }
          it { should contain_swift_proxy_config('app:proxy-server/sorting_method').with_value('affinity') }
          it { should contain_swift_proxy_config('app:proxy-server/read_affinity').with_value('r1z1=100, r1=200') }
          it { should contain_swift_proxy_config('app:proxy-server/write_affinity').with_value('r1') }
          it { should contain_swift_proxy_config('app:proxy-server/write_affinity_node_count').with_value('2 * replicas') }
          it { should contain_swift_proxy_config('app:proxy-server/write_affinity_handoff_delete_count').with_value('auto') }
          it { should contain_swift_proxy_config('app:proxy-server/swift_owner_headers').with_value('x-container-read,x-container-write') }
          it { should contain_swift_proxy_config('app:proxy-server/stale_worker_timeout').with_value(86400) }
          it { should contain_swift_proxy_config('app:proxy-server/node_timeout').with_value('20') }
          it { should contain_swift_proxy_config('app:proxy-server/recoverable_node_timeout').with_value('15') }
          it { should contain_swift_proxy_config('app:proxy-server/allow_open_expired').with_value(false) }
          it { should contain_swift_proxy_config('DEFAULT/cors_allow_origin').with_value('http://foo.bar:1234,https://foo.bar') }
          it { should contain_swift_proxy_config('DEFAULT/strict_cors_mode').with_value('true') }
          it { should contain_swift_proxy_config('DEFAULT/cors_expose_headers').with_value('header-a,header-b') }
        end

        describe "when log udp port is set" do
          context 'and log_udp_host is set' do
            let :params do
              {
                :proxy_local_net_ip => '10.0.0.2',
                :pipeline           => ['tempauth', 'proxy-server'],
                :log_level          => 'DEBUG',
                :log_name           => 'swift-proxy-server',
                :log_udp_host       => '127.0.0.1',
                :log_udp_port       => '514',
                :log_handoffs       => true,
              }
            end

            let :pre_condition do
              "class { memcached: }
               class { swift: swift_hash_path_suffix => string }
               include swift::proxy::tempauth
               "
            end

            it { should contain_swift_proxy_config('DEFAULT/bind_ip').with_value('10.0.0.2') }
            it { should contain_swift_proxy_config('DEFAULT/log_name').with_value('swift-proxy-server') }
            it { should contain_swift_proxy_config('DEFAULT/log_facility').with_value('LOG_LOCAL2') }
            it { should contain_swift_proxy_config('DEFAULT/log_level').with_value('DEBUG') }
            it { should contain_swift_proxy_config('DEFAULT/log_headers').with_value('<SERVICE DEFAULT>') }
            it { should contain_swift_proxy_config('DEFAULT/log_address').with_value('/dev/log') }
            it { should contain_swift_proxy_config('DEFAULT/log_udp_host').with_value('127.0.0.1') }
            it { should contain_swift_proxy_config('DEFAULT/log_udp_port').with_value('514') }
            it { should contain_swift_proxy_config('pipeline:main/pipeline').with_value('tempauth proxy-server') }
            it { should contain_swift_proxy_config('app:proxy-server/use').with_value('egg:swift#proxy') }
            it { should contain_swift_proxy_config('app:proxy-server/set log_name').with_value('swift-proxy-server') }
            it { should contain_swift_proxy_config('app:proxy-server/set log_facility').with_value('LOG_LOCAL2') }
            it { should contain_swift_proxy_config('app:proxy-server/set log_level').with_value('DEBUG') }
            it { should contain_swift_proxy_config('app:proxy-server/set log_address').with_value('/dev/log') }
          end
        end

        describe 'when supplying bad values for parameters' do
          [:account_autocreate, :allow_account_management].each do |param|
            it "should fail when #{param} is not passed a boolean" do
              params[param] = 'false'
              should raise_error(Puppet::Error)
            end
          end

          context 'write_affinity_node_count set without write_affinity' do
            let :params do
              {
                :proxy_local_net_ip        => '127.0.0.1',
                :write_affinity_node_count => '2 * replicas'
              }
            end

            it 'should fail if write_affinity_node_count is used without write_affinity' do
              should raise_error(Puppet::Error, /write_affinity_node_count requires write_affinity/)
            end
          end

          context 'write_affinity_handoff_delete_count set without write_affinity' do
            let :params do
              {
                :proxy_local_net_ip                  => '127.0.0.1',
                :write_affinity_handoff_delete_count => 'auto'
              }
            end

            it 'should fail if write_affinity_handoff_delete_count is used without write_affinity' do
              should raise_error(Puppet::Error, /write_affinity_handoff_delete_count requires write_affinity/)
            end
          end
        end
      end

      context 'with sorting_method' do
        let :params do
          {
            :proxy_local_net_ip => '127.0.0.1',
            :sorting_method     => 'timing'
          }
        end

        it 'should configure the sorting_method option' do
          should contain_swift_proxy_config('app:proxy-server/sorting_method').with_value('timing')
        end
      end
    end
  end

  shared_examples 'swift::proxy server' do
    let :params do
      {
        :proxy_local_net_ip => '127.0.0.1'
      }
    end

    let :pre_condition do
      "class { memcached: }
       class { swift: swift_hash_path_suffix => string }
       include swift::proxy::catch_errors
       include swift::proxy::gatekeeper
       include swift::proxy::healthcheck
       include swift::proxy::proxy_logging
       include swift::proxy::cache
       include swift::proxy::listing_formats
       include swift::proxy::tempauth
       include swift::proxy::copy"
    end

    [{ :enabled => true, :manage_service => true },
     { :enabled => false, :manage_service => true }].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures swift-proxy-server service' do
          should contain_service('swift-proxy-server').with(
            :name     => platform_params['swift-proxy-server'],
            :ensure   => (param_hash[:manage_service] && param_hash[:enabled]) ? 'running' : 'stopped',
            :enable   => param_hash[:enabled],
            :provider => nil,
            :tag      => ['swift-service', 'swift-proxy-service'],
          )
        end
      end
    end

    context 'with disabled service management' do
      before do
        params.merge!({
          :manage_service => false,
        })
      end

      it 'does not configure swift-proxy-server service' do
        should_not contain_service('swift-proxy-server')
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

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { 'swift-proxy-server' => 'swift-proxy' }
        when 'RedHat'
          { 'swift-proxy-server' => 'openstack-swift-proxy' }
        end
      end

      it_behaves_like 'swift::proxy'
      it_behaves_like 'swift::proxy server'
    end
  end
end
