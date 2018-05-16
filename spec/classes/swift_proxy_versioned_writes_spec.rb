require 'spec_helper'

describe 'swift::proxy::versioned_writes' do
  shared_examples 'swift::proxy::versioned_writes' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:versioned_writes/use').with_value('egg:swift#versioned_writes') }
      it { is_expected.to contain_swift_proxy_config('filter:versioned_writes/allow_versioned_writes').with_value('false') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :allow_versioned_writes => true,
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:versioned_writes/allow_versioned_writes').with_value('true') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::versioned_writes'
    end
  end
end
