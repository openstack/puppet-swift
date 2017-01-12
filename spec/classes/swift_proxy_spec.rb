require 'spec_helper'

describe 'swift::proxy' do

  describe 'without memcached being included' do
    it 'should raise an error' do
      expect { catalogue }.to raise_error(Puppet::Error)
    end
  end

  # set os so memcache will not fail
  let :facts do
    OSDefaults.get_facts({
     :operatingsystem => 'Ubuntu',
     :osfamily        => 'Debian',
     :processorcount  => 1,
    })
  end

  describe 'with proper dependencies' do

    let :pre_condition do
      "class { memcached: max_memory => 1}
       class { swift: swift_hash_path_suffix => string }"
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
        {:proxy_local_net_ip => '127.0.0.1'}
      end

      it { is_expected.to contain_package('swift-proxy').that_requires('Anchor[swift::install::begin]')
           is_expected.to contain_package('swift-proxy').that_notifies('Anchor[swift::install::end]') }

      it { is_expected.to contain_service('swift-proxy-server').with(
        {:ensure     => 'running',
         :provider   => nil,
         :enable     => true,
         :hasstatus  => true,
         :subscribe  => 'Concat[/etc/swift/proxy-server.conf]',
         :tag        => 'swift-service',
        }
      )}
      it { is_expected.to contain_concat('/etc/swift/proxy-server.conf').with(
        {:ensure  => 'present',
         :mode    => '0640',
         :owner   => 'swift',
         :group   => 'swift',
        }
      )}

      it 'should build the header file with all of the default contents' do
        is_expected.to contain_concat_fragment('swift_proxy').with_content('# This file is managed by puppet.  Do not edit
#
[DEFAULT]
bind_port = 8080
bind_ip = 127.0.0.1
workers = 1
user = swift
log_name = proxy-server
log_facility = LOG_LOCAL1
log_level = INFO
log_headers = False
log_address = /dev/log

[pipeline:main]
pipeline = healthcheck cache tempauth proxy-server

[app:proxy-server]
use = egg:swift#proxy
set log_name = proxy-server
set log_facility = LOG_LOCAL1
set log_level = INFO
set log_address = /dev/log
log_handoffs = true
allow_account_management = true
account_autocreate = true
')
      end

      it { is_expected.to contain_concat__fragment('swift_proxy').with_before(
        [
          'Class[Swift::Proxy::Healthcheck]',
          'Class[Swift::Proxy::Cache]',
          'Class[Swift::Proxy::Tempauth]'
        ]
      )}

      describe "when using swift_proxy_config resource" do
        let :pre_condition do
          "
            class { memcached: max_memory => 1}
            class { swift: swift_hash_path_suffix => string }
            swift_proxy_config { 'foo/bar': value => 'foo' }
          "
        end
        it { is_expected.to contain_concat("/etc/swift/proxy-server.conf").that_comes_before("Swift_proxy_config[foo/bar]") }
      end

      describe 'when more parameters are set' do
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
        it 'should build the header file with provided values' do
          is_expected.to contain_concat_fragment('swift_proxy').with_content('# This file is managed by puppet.  Do not edit
#
[DEFAULT]
bind_port = 80
bind_ip = 10.0.0.2
workers = 3
user = swift
log_name = swift-proxy-server
log_facility = LOG_LOCAL1
log_level = DEBUG
log_headers = False
log_address = /dev/log
cors_allow_origin = http://foo.bar:1234,https://foo.bar
strict_cors_mode = true

[pipeline:main]
pipeline = swauth proxy-server

[app:proxy-server]
use = egg:swift#proxy
set log_name = swift-proxy-server
set log_facility = LOG_LOCAL1
set log_level = DEBUG
set log_address = /dev/log
log_handoffs = true
allow_account_management = false
account_autocreate = false
sorting_method = affinity
read_affinity = r1z1=100, r1=200
write_affinity = r1
write_affinity_node_count = 2 * replicas
node_timeout = 20
')
        end
        if Puppet.version.to_f < 4.0
          it { is_expected.to contain_concat__fragment('swift_proxy').with_before('Class[Swift::Proxy::Swauth]')}
        else
          it { is_expected.to contain_concat__fragment('swift_proxy').with_before(['Class[Swift::Proxy::Swauth]'])}
        end
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
        it 'should build the header file with provided values' do
          is_expected.to contain_concat_fragment('swift_proxy').with_content('# This file is managed by puppet.  Do not edit
#
[DEFAULT]
bind_port = 80
bind_ip = 10.0.0.2
workers = 3
user = swift
log_name = swift-proxy-server
log_facility = LOG_LOCAL1
log_level = DEBUG
log_headers = False
log_address = /dev/log
# If set, log_udp_host will override log_address
log_udp_host = 127.0.0.1
log_udp_port = 514
cors_allow_origin = http://foo.bar:1234,https://foo.bar
strict_cors_mode = true

[pipeline:main]
pipeline = swauth proxy-server

[app:proxy-server]
use = egg:swift#proxy
set log_name = swift-proxy-server
set log_facility = LOG_LOCAL1
set log_level = DEBUG
set log_address = /dev/log
log_handoffs = true
allow_account_management = false
account_autocreate = false
sorting_method = affinity
read_affinity = r1z1=100, r1=200
write_affinity = r1
write_affinity_node_count = 2 * replicas
node_timeout = 20
')
        end
      end
    end

      describe 'when supplying bad values for parameters' do
        [:account_autocreate, :allow_account_management].each do |param|
          it "should fail when #{param} is not passed a boolean" do
            params[param] = 'false'
            expect { catalogue }.to raise_error(Puppet::Error, /is not a boolean/)
          end
        end

        let :params do
          {
           :proxy_local_net_ip        => '127.0.0.1',
           :write_affinity_node_count => '2 * replicas'
          }
        end

        it "should fail if write_affinity_node_count is used without write_affinity" do
          expect { catalogue }.to raise_error(Puppet::Error, /write_affinity_node_count requires write_affinity/)
        end
      end
    end
  end

  shared_examples_for 'swift-proxy-server' do
    let :params do
      { :proxy_local_net_ip => '127.0.0.1' }
    end

    [{ :enabled => true, :manage_service => true },
     { :enabled => false, :manage_service => true }].each do |param_hash|
      context "when service is_expected.to be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures swift-proxy-server service' do
          is_expected.to contain_service('swift-proxy-server').with(
            :name     => platform_params['swift-proxy-server'],
            :ensure   => (param_hash[:manage_service] && param_hash[:enabled]) ? 'running' : 'stopped',
            :enable   => param_hash[:enabled],
            :provider => platform_params['service_provider'],
            :tag      => 'swift-service',
          )
        end
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures swift-proxy-server service' do

        is_expected.to contain_service('swift-proxy-server').with(
          :ensure     => nil,
          :name       => platform_params['swift-proxy-server'],
          :provider   => platform_params['service_provider'],
          :enable     => false,
          :hasstatus  => true,
          :subscribe  => 'Concat[/etc/swift/proxy-server.conf]'
        )
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      OSDefaults.get_facts({
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :concat_basedir  => '/var/lib/puppet/concat',
      })
    end

    let :platform_params do
      {   'swift-proxy-server' => 'swift-proxy',
          'service_provider'   => nil
      }
    end
    it_configures 'swift-proxy-server'

    context 'on Debian platforms using swiftinit service provider' do
      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      let :platform_params do
        {   'swift-proxy-server' => 'swift-proxy-server',
            'service_provider'   => 'swiftinit'
        }
      end
      it_configures 'swift-proxy-server'
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      OSDefaults.get_facts({
        :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat',
        :concat_basedir  => '/var/lib/puppet/concat',
      })
    end

    let :platform_params do
      {
        'swift-proxy-server' => 'openstack-swift-proxy',
      }
    end
    it_configures 'swift-proxy-server'

    context 'on Redhat platforms using swiftinit service provider' do
      before do
        params.merge!({ :service_provider => 'swiftinit' })
      end

      let :platform_params do
        {   'swift-proxy-server' => 'swift-proxy-server',
            'service_provider'   => 'swiftinit'
        }
      end
      it_configures 'swift-proxy-server'
    end
  end
end
