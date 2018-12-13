require 'spec_helper'

describe 'swift::proxy::s3token' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it { is_expected.to contain_swift_proxy_config('filter:s3token/use').with_value('egg:swift3#s3token') }
    it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_port').with_value('35357') }
    it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_protocol').with_value('http') }
    it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_host').with_value('127.0.0.1') }
  end

  describe "when overriding default parameters" do
    let :params do
      {
          :auth_port     => 4212,
          :auth_protocol => 'https',
          :auth_host     => '1.2.3.4'
      }
    end
    it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_port').with_value('4212') }
    it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_protocol').with_value('https') }
    it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_host').with_value('1.2.3.4') }
  end

end
