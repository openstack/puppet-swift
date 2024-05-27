require 'spec_helper'

describe 'swift::proxy::keymaster' do
  shared_examples 'swift::proxy::keymaster' do
    let :params do
      {
        :encryption_root_secret => 'secret',
      }
    end

    context "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:keymaster/use').with_value('egg:swift#keymaster') }
      it { is_expected.to contain_swift_proxy_config('filter:keymaster/encryption_root_secret').with_value('secret').with_secret(true) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::keymaster'
    end
  end
end
