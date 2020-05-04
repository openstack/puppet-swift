require 'spec_helper'

describe 'swift::proxy::s3token' do
  shared_examples 'swift::proxy::s3token' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:s3token/use').with_value('egg:swift#s3token') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_uri').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/reseller_prefix').with_value('AUTH_') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/delay_auth_decision').with_value('false') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/http_timeout').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/secret_cache_duration').with_value('0') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_url').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_type').with_value('password') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/username').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/password').with_value('password') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/project_name').with_value('services') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/project_domain_id').with_value('default') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/user_domain_id').with_value('default') }

    end

    describe "when overriding default parameters" do
      let :params do
        {
          :auth_protocol     => 'https',
          :auth_host         => '192.168.4.2',
          :auth_port         => '3452'
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_uri').with_value('https://192.168.4.2:3452') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :auth_uri               => 'http://192.168.24.11:5000',
          :reseller_prefix        => 'SWIFT_',
          :delay_auth_decision    => true,
          :http_timeout           => '5',
          :secret_cache_duration  => '10',
          :auth_url               => 'http://192.168.24.11:5000',
          :auth_type              => 'password',
          :username               => 'swift',
          :password               => 'swift',
          :project_name           => 'admin',
          :project_domain_id      => '12345',
          :user_domain_id         => '12345'

        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_uri').with_value('http://192.168.24.11:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/reseller_prefix').with_value('SWIFT_') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/delay_auth_decision').with_value('true') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/http_timeout').with_value('5') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/secret_cache_duration').with_value('10') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_url').with_value('http://192.168.24.11:5000') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_type').with_value('password') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/username').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/password').with_value('swift') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/project_name').with_value('admin') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/project_domain_id').with_value('12345') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/user_domain_id').with_value('12345') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::s3token'
    end
  end
end
