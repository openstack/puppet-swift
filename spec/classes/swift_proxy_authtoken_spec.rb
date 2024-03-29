require 'spec_helper'

describe 'swift::proxy::authtoken' do
  shared_examples 'swift::proxy::authtoken' do
    let :params do
      {
        :password => 'swiftpassword',
      }
    end

    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/log_name').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/paste.filter_factory').with_value('keystonemiddleware.auth_token:filter_factory') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/www_authenticate_uri').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_url').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_type').with_value('password') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/username').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/user_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/password').with_value('swiftpassword').with_secret(true) }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_name').with_value('services') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/system_scope').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/region_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/delay_auth_decision').with_value('1') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/cache').with_value('swift.cache') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/include_service_catalog').with_value('false') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/service_token_roles').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/service_token_roles_required').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/service_type').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/interface').with_value('<SERVICE DEFAULT>') }
    end

    describe "when overriding parameters" do
      before :each do
        params.merge!({
          :username                     => 'swiftuser',
          :password                     => 'swiftpassword',
          :project_name                 => 'admin',
          :region_name                  => 'region2',
          :cache                        => 'foo',
          :delay_auth_decision          => '0',
          :service_token_roles          => ['service'],
          :service_token_roles_required => true,
          :service_type                 => 'identity',
          :interface                    => 'internal',
        })
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/log_name').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/paste.filter_factory').with_value('keystonemiddleware.auth_token:filter_factory') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/www_authenticate_uri').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_url').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_type').with_value('password') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/username').with_value('swiftuser') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/user_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/password').with_value('swiftpassword').with_secret(true) }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_name').with_value('admin') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/system_scope').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/region_name').with_value('region2') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/delay_auth_decision').with_value('0') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/cache').with_value('foo') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/include_service_catalog').with_value('false') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/service_token_roles').with_value(['service']) }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/service_token_roles_required').with_value(true) }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/service_type').with_value('identity') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/interface').with_value('internal') }
    end

    describe 'when overriding www_authenticate_uri' do
      before :each do
        params.merge!({
          :www_authenticate_uri => 'http://public.host/keystone/main'
        })
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/www_authenticate_uri').with_value('http://public.host/keystone/main') }
    end

    describe "when auth_url is set" do
      before :each do
        params.merge!({
          :auth_url => 'https://foo.bar:5000/'
        })
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_url').with_value('https://foo.bar:5000/') }
    end

    describe "when both www_authenticate_uri and auth_url are set" do
      before :each do
        params.merge!({
          :www_authenticate_uri => 'https://foo.bar:5000/v3/',
          :auth_url             => 'https://foo.bar:5000/'
        })
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/www_authenticate_uri').with_value('https://foo.bar:5000/v3/') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_url').with_value('https://foo.bar:5000/') }
    end

    describe 'when system_scope is set' do
      before :each do
        params.merge!({
          :system_scope => 'all'
        })
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_domain_id').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/system_scope').with_value('all') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::authtoken'
    end
  end
end
