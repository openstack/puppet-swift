require 'spec_helper'

describe 'swift::proxy::healthcheck' do
  shared_examples 'swift::proxy::healthcheck' do
    it { should contain_swift_proxy_config('filter:healthcheck/use').with_value('egg:swift#healthcheck') }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::healthcheck'
    end
  end
end
