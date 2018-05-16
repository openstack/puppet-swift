require 'spec_helper'

describe 'swift::proxy::swift3' do
  shared_examples 'swift::proxy::swift3' do
    it { is_expected.to contain_swift_proxy_config('filter:swift3/use').with_value('egg:swift3#swift3') }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::swift3'
    end
  end
end
