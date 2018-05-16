require 'spec_helper'

describe 'swift::proxy::crossdomain' do
  shared_examples 'swift::proxy::crossdomain' do
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

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::crossdomain'
    end
  end
end
