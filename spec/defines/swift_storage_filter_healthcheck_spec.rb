require 'spec_helper'

describe 'swift::storage::filter::healthcheck' do
  let :title do
    'account'
  end

  shared_examples 'swift::storage::filter::healthcheck' do
    it 'should configure the healthcheck middleware' do
      is_expected.to contain_swift_account_config('filter:healthcheck/use').\
        with_value('egg:swift#healthcheck')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::storage::filter::healthcheck'
    end
  end
end
