require 'spec_helper'

describe 'swift::storage::filter::healthcheck' do
  let :title do
    'dummy'
  end

  shared_examples 'swift::storage::filter::healthcheck' do
    it 'should build the fragment with correct content' do
      is_expected.to contain_concat_fragment('swift_healthcheck_dummy').with_content('
[filter:healthcheck]
use = egg:swift#healthcheck
')
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
