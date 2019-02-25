require 'spec_helper'

describe 'swift::proxy::authtoken' do
  shared_examples 'swift::proxy::authtoken' do
    describe 'when using the default signing directory' do
      let :file_defaults do
        {
          :mode    => '0700',
          :owner   => 'swift',
          :group   => 'swift',
        }
      end

      it {is_expected.to contain_file('/var/cache/swift').with(
        {:ensure                  => 'directory',
         :selinux_ignore_defaults => true}.merge(file_defaults)
      )}
    end

    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/log_name').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/signing_dir').with_value(platform_params[:default_signing_dir]) }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/paste.filter_factory').with_value('keystonemiddleware.auth_token:filter_factory') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/www_authenticate_uri').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_url').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_plugin').with_value('password') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/user_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_name').with_value('services') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/username').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/password').with_value('password') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/delay_auth_decision').with_value('1') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/cache').with_value('swift.cache') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/include_service_catalog').with_value('false') }
    end

    describe "when overriding parameters" do
      let :params do
        {
          :admin_tenant_name   => 'admin',
          :admin_user          => 'swiftuser',
          :admin_password      => 'swiftpassword',
          :cache               => 'foo',
          :delay_auth_decision => '0',
          :signing_dir         => '/home/swift/keystone-signing'
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/log_name').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/signing_dir').with_value('/home/swift/keystone-signing') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/paste.filter_factory').with_value('keystonemiddleware.auth_token:filter_factory') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/www_authenticate_uri').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_url').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_plugin').with_value('password') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/user_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/project_name').with_value('admin') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/username').with_value('swiftuser') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/password').with_value('swiftpassword') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/delay_auth_decision').with_value('0') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/cache').with_value('foo') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/include_service_catalog').with_value('false') }
    end

    describe 'when overriding www_authenticate_uri' do
      let :params do
        { :www_authenticate_uri => 'http://public.host/keystone/main' }
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/www_authenticate_uri').with_value('http://public.host/keystone/main') }
    end

    describe "when identity_uri is set" do
      let :params do
        {
          :identity_uri => 'https://foo.bar:5000/'
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_url').with_value('https://foo.bar:5000/') }
    end

    describe "when both www_authenticate_uri and identity_uri are set" do
      let :params do
        {
          :www_authenticate_uri => 'https://foo.bar:5000/v3/',
          :identity_uri         => 'https://foo.bar:5000/'
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:authtoken/www_authenticate_uri').with_value('https://foo.bar:5000/v3/') }
      it { is_expected.to contain_swift_proxy_config('filter:authtoken/auth_url').with_value('https://foo.bar:5000/') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          if facts[:os_package_type] == 'debian'
            { :default_signing_dir => '/var/lib/swift' }
          else
            { :default_signing_dir => '/var/cache/swift' }
          end
        when 'RedHat'
          { :default_signing_dir => '/var/cache/swift' }
        end
      end

      it_configures 'swift::proxy::authtoken'
    end
  end
end
