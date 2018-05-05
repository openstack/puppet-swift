require 'spec_helper'

describe 'swift::proxy::s3token' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it { is_expected.to contain_swift_proxy_config('filter:s3token/use').with_value('egg:swift#s3token') }
    it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_uri').with_value('http://127.0.0.1:35357') }
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
	      :auth_uri     => 'http://192.168.24.11:35357'
      }
    end
    it { is_expected.to contain_swift_proxy_config('filter:s3token/auth_uri').with_value('http://192.168.24.11:35357') }
  end

end
