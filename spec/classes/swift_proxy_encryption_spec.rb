require 'spec_helper'

describe 'swift::proxy::encryption' do
  shared_examples 'swift::proxy::encryption' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:encryption/use').with_value('egg:swift#encryption') }
      it { is_expected.to contain_swift_proxy_config('filter:encryption/disable_encryption').with_value('false') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :disable_encryption => true,
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:encryption/disable_encryption').with_value('true') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::encryption'
    end
  end
end
