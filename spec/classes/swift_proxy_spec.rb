require 'spec_helper'

describe 'swift::proxy' do
  shared_examples 'swift::proxy' do
    describe 'without memcached being included' do
      it { should raise_error(Puppet::Error) }
    end

    describe 'with proper dependencies' do
      let :pre_condition do
        "class { memcached: max_memory => 1}
         class { swift: swift_hash_path_suffix => string }
         include ::swift::proxy::healthcheck
         include ::swift::proxy::cache
         include ::swift::proxy::tempauth"
      end

      describe 'without the proxy local network ip address being specified' do
        if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0
          it_raises 'a Puppet::Error', /expects a value for parameter 'proxy_local_net_ip'/
        else
          it_raises 'a Puppet::Error', /Must pass proxy_local_net_ip/
        end
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
          :tag       => 'swift-service',
        )}

        it { should contain_service('swift-proxy-server').that_subscribes_to('Anchor[swift::service::begin]') }
        it { should contain_service('swift-proxy-server').that_notifies('Anchor[swift::service::end]') }
        it { should contain_swift_proxy_config('DEFAULT/bind_port').with_value('8080') }
        it { should contain_swift_proxy_config('DEFAULT/bind_ip').with_value('127.0.0.1') }
        it { should contain_swift_proxy_config('DEFAULT/workers').with_value('2') }
        it { should contain_swift_proxy_config('DEFAULT/user').with_value('swift') }
        it { should contain_swift_proxy_config('DEFAULT/log_name').with_value('proxy-server') }
        it { should contain_swift_proxy_config('DEFAULT/log_facility').with_value('LOG_LOCAL2') }
        it { should contain_swift_proxy_config('DEFAULT/log_level').with_value('INFO') }
        it { should contain_swift_proxy_config('DEFAULT/log_headers').with_value('False') }
        it { should contain_swift_proxy_config('DEFAULT/log_address').with_value('/dev/log') }
        it { should contain_swift_proxy_config('pipeline:main/pipeline').with_value('healthcheck cache tempauth proxy-server') }
        it { should contain_swift_proxy_config('app:proxy-server/use').with_value('egg:swift#proxy') }
        it { should contain_swift_proxy_config('app:proxy-server/set log_name').with_value('proxy-server') }
        it { should contain_swift_proxy_config('app:proxy-server/set log_facility').with_value('LOG_LOCAL2') }
        it { should contain_swift_proxy_config('app:proxy-server/set log_level').with_value('INFO') }
        it { should contain_swift_proxy_config('app:proxy-server/set log_address').with_value('/dev/log') }
        it { should contain_swift_proxy_config('app:proxy-server/log_handoffs').with_value('true') }
        it { should contain_swift_proxy_config('app:proxy-server/allow_account_management').with_value('true') }
        it { should contain_swift_proxy_config('app:proxy-server/account_autocreate').with_value('true') }

        it { should contain_service('swift-proxy-server').with_require([
          'Class[Swift::Proxy::Healthcheck]',
          'Class[Swift::Proxy::Cache]',
          'Class[Swift::Proxy::Tempauth]',
        ])}

        describe "when using swift_proxy_config resource" do
          let :pre_condition do
            "
              class { memcached: max_memory => 1}
              class { swift: swift_hash_path_suffix => string }
              swift_proxy_config { 'foo/bar': value => 'foo' }
              include ::swift::proxy::healthcheck
              include ::swift::proxy::cache
              include ::swift::proxy::tempauth
            "
          end

          it { should contain_swift_proxy_config('foo/bar').with_value('foo').that_notifies('Anchor[swift::config::end]') }
        end

        describe 'when more parameters are set' do
          let :pre_condition do
            "class { memcached: max_memory => 1}
             class { swift: swift_hash_path_suffix => string }
             include ::swift::proxy::swauth"
          end

          let :params do
            {
              :proxy_local_net_ip        => '10.0.0.2',
              :port                      => '80',
              :workers                   => 3,
              :pipeline                  => ['swauth', 'proxy-server'],
              :allow_account_management  => false,
              :account_autocreate        => false,
              :log_level                 => 'DEBUG',
              :log_name                  => 'swift-proxy-server',
              :read_affinity             => 'r1z1=100, r1=200',
              :write_affinity            => 'r1',
              :write_affinity_node_count => '2 * replicas',
              :node_timeout              => '20',
              :cors_allow_origin         => 'http://foo.bar:1234,https://foo.bar',
            }
          end

          it { should contain_swift_proxy_config('DEFAULT/bind_port').with_value('80') }
          it { should contain_swift_proxy_config('DEFAULT/bind_ip').with_value('10.0.0.2') }
          it { should contain_swift_proxy_config('DEFAULT/workers').with_value('3') }
          it { should contain_swift_proxy_config('DEFAULT/user').with_value('swift') }
          it { should contain_swift_proxy_config('DEFAULT/log_name').with_value('swift-proxy-server') }
          it { should contain_swift_proxy_config('DEFAULT/log_facility').with_value('LOG_LOCAL2') }
          it { should contain_swift_proxy_config('DEFAULT/log_level').with_value('DEBUG') }
          it { should contain_swift_proxy_config('DEFAULT/log_headers').with_value('False') }
          it { should contain_swift_proxy_config('DEFAULT/log_address').with_value('/dev/log') }
          it { should contain_swift_proxy_config('DEFAULT/cors_allow_origin').with_value('http://foo.bar:1234,https://foo.bar') }
          it { should contain_swift_proxy_config('DEFAULT/strict_cors_mode').with_value('true') }
          it { should contain_swift_proxy_config('pipeline:main/pipeline').with_value('swauth proxy-server') }
          it { should contain_swift_proxy_config('app:proxy-server/use').with_value('egg:swift#proxy') }
          it { should contain_swift_proxy_config('app:proxy-server/set log_name').with_value('swift-proxy-server') }
          it { should contain_swift_proxy_config('app:proxy-server/set log_facility').with_value('LOG_LOCAL2') }
          it { should contain_swift_proxy_config('app:proxy-server/set log_level').with_value('DEBUG') }
          it { should contain_swift_proxy_config('app:proxy-server/set log_address').with_value('/dev/log') }
          it { should contain_swift_proxy_config('app:proxy-server/log_handoffs').with_value('true') }
          it { should contain_swift_proxy_config('app:proxy-server/allow_account_management').with_value('false') }
          it { should contain_swift_proxy_config('app:proxy-server/account_autocreate').with_value('false') }
          it { should contain_swift_proxy_config('app:proxy-server/sorting_method').with_value('affinity') }
          it { should contain_swift_proxy_config('app:proxy-server/read_affinity').with_value('r1z1=100, r1=200') }
          it { should contain_swift_proxy_config('app:proxy-server/write_affinity').with_value('r1') }
          it { should contain_swift_proxy_config('app:proxy-server/write_affinity_node_count').with_value('2 * replicas') }
          it { should contain_swift_proxy_config('app:proxy-server/node_timeout').with_value('20') }
        end

        describe "when log udp port is set" do
          context 'and log_udp_host is not set' do
            let :params do
              {
                :proxy_local_net_ip        => '10.0.0.2',
                :port                      => '80',
                :workers                   => 3,
                :pipeline                  => ['swauth', 'proxy-server'],
                :allow_account_management  => false,
                :account_autocreate        => false,
                :log_level                 => 'DEBUG',
                :log_name                  => 'swift-proxy-server',
                :log_udp_port              => '514',
                :read_affinity             => 'r1z1=100, r1=200',
                :write_affinity            => 'r1',
                :write_affinity_node_count => '2 * replicas',
                :node_timeout              => '20',
                :cors_allow_origin         => 'http://foo.bar:1234,https://foo.bar',
              }
            end

            it_raises 'a Puppet::Error', /log_udp_port requires log_udp_host to be set/
          end

          context 'and log_udp_host is set' do
            let :params do
              {
                :proxy_local_net_ip        => '10.0.0.2',
                :port                      => '80',
                :workers                   => 3,
                :pipeline                  => ['swauth', 'proxy-server'],
                :allow_account_management  => false,
                :account_autocreate        => false,
                :log_level                 => 'DEBUG',
                :log_name                  => 'swift-proxy-server',
                :log_udp_host              => '127.0.0.1',
                :log_udp_port              => '514',
                :read_affinity             => 'r1z1=100, r1=200',
                :write_affinity            => 'r1',
                :write_affinity_node_count => '2 * replicas',
                :node_timeout              => '20',
                :cors_allow_origin         => 'http://foo.bar:1234,https://foo.bar',
              }
            end

            let :pre_condition do
              "class { memcached: max_memory => 1}
               class { swift: swift_hash_path_suffix => string }
               include ::swift::proxy::swauth"
            end

            it { should contain_swift_proxy_config('DEFAULT/bind_port').with_value('80') }
            it { should contain_swift_proxy_config('DEFAULT/bind_ip').with_value('10.0.0.2') }
            it { should contain_swift_proxy_config('DEFAULT/workers').with_value('3') }
            it { should contain_swift_proxy_config('DEFAULT/user').with_value('swift') }
            it { should contain_swift_proxy_config('DEFAULT/log_name').with_value('swift-proxy-server') }
            it { should contain_swift_proxy_config('DEFAULT/log_facility').with_value('LOG_LOCAL2') }
            it { should contain_swift_proxy_config('DEFAULT/log_level').with_value('DEBUG') }
            it { should contain_swift_proxy_config('DEFAULT/log_headers').with_value('False') }
            it { should contain_swift_proxy_config('DEFAULT/log_address').with_value('/dev/log') }
            it { should contain_swift_proxy_config('DEFAULT/log_udp_host').with_value('127.0.0.1') }
            it { should contain_swift_proxy_config('DEFAULT/log_udp_port').with_value('514') }
            it { should contain_swift_proxy_config('DEFAULT/cors_allow_origin').with_value('http://foo.bar:1234,https://foo.bar') }
            it { should contain_swift_proxy_config('DEFAULT/strict_cors_mode').with_value('true') }
            it { should contain_swift_proxy_config('pipeline:main/pipeline').with_value('swauth proxy-server') }
            it { should contain_swift_proxy_config('app:proxy-server/use').with_value('egg:swift#proxy') }
            it { should contain_swift_proxy_config('app:proxy-server/set log_name').with_value('swift-proxy-server') }
            it { should contain_swift_proxy_config('app:proxy-server/set log_facility').with_value('LOG_LOCAL2') }
            it { should contain_swift_proxy_config('app:proxy-server/set log_level').with_value('DEBUG') }
            it { should contain_swift_proxy_config('app:proxy-server/set log_address').with_value('/dev/log') }
            it { should contain_swift_proxy_config('app:proxy-server/log_handoffs').with_value('true') }
            it { should contain_swift_proxy_config('app:proxy-server/allow_account_management').with_value('false') }
            it { should contain_swift_proxy_config('app:proxy-server/account_autocreate').with_value('false') }
            it { should contain_swift_proxy_config('app:proxy-server/sorting_method').with_value('affinity') }
            it { should contain_swift_proxy_config('app:proxy-server/read_affinity').with_value('r1z1=100, r1=200') }
            it { should contain_swift_proxy_config('app:proxy-server/write_affinity').with_value('r1') }
            it { should contain_swift_proxy_config('app:proxy-server/write_affinity_node_count').with_value('2 * replicas') }
            it { should contain_swift_proxy_config('app:proxy-server/node_timeout').with_value('20') }
          end
        end

        describe 'when supplying bad values for parameters' do
          [:account_autocreate, :allow_account_management].each do |param|
            it "should fail when #{param} is not passed a boolean" do
              params[param] = 'false'
              should raise_error(Puppet::Error, /is not a boolean/)
            end
          end

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
      "class { memcached: max_memory => 1}
       class { swift: swift_hash_path_suffix => string }
       include ::swift::proxy::healthcheck
       include ::swift::proxy::cache
       include ::swift::proxy::tempauth"
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
            :tag      => 'swift-service',
          )
        end
      end
    end

    context 'with disabled service managing and service provider' do
      before do
        params.merge!({
          :manage_service   => false,
          :enabled          => false,
          :service_provider => 'swiftinit',
        })
      end

      it 'configures swift-proxy-server service' do
        should contain_service('swift-proxy-server').with(
          :ensure    => nil,
          :name      => 'swift-proxy-server',
          :provider  => 'swiftinit',
          :enable    => false,
          :hasstatus => true,
        )
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
        case facts[:osfamily]
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
