require 'spec_helper'

describe 'swift::proxy::crossdomain' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it { is_expected.to contain_swift_proxy_config('filter:crossdomain/use').with_value('egg:swift#crossdomain') }
    it { is_expected.to contain_swift_proxy_config('filter:crossdomain/cross_domain_policy').with_value('<allow-access-from domain="*" secure="false" />') }
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :cross_domain_policy => '<allow-access-from domain="xml-fragment-in-ini-file.so.wrong" secure="true" /><allow-access-from domain="*" secure="false" />',
      }
    end
    it { is_expected.to contain_swift_proxy_config('filter:crossdomain/use').with_value('egg:swift#crossdomain') }
    it { is_expected.to contain_swift_proxy_config('filter:crossdomain/cross_domain_policy').with_value('<allow-access-from domain="xml-fragment-in-ini-file.so.wrong" secure="true" /><allow-access-from domain="*" secure="false" />') }

  end

end
