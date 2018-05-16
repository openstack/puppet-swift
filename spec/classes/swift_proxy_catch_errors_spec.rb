require 'spec_helper'

describe 'swift::proxy::catch_errors' do
  shared_examples 'swift::proxy::catch_errors' do
    it { should contain_swift_proxy_config('filter:catch_errors/use').with_value('egg:swift#catch_errors') }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::catch_errors'
    end
  end
end
