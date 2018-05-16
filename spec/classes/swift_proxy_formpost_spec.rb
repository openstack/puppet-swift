require 'spec_helper'

describe 'swift::proxy::formpost' do
  shared_examples 'swift::proxy::formpost' do
    it { should contain_swift_proxy_config('filter:formpost/use').with_value('egg:swift#formpost') }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::formpost'
    end
  end
end
