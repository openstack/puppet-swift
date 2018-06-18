require 'spec_helper'

describe 'swift::proxy::s3token' do
  shared_examples 'swift::proxy::s3token' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:s3token/use').with_value('egg:swift#s3token') }
      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_uri').with_value('http://127.0.0.1:5000') }
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
          :auth_uri => 'http://192.168.24.11:5000'
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_uri').with_value('http://192.168.24.11:5000') }
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
