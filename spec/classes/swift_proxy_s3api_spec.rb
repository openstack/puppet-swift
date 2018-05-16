require 'spec_helper'

describe 'swift::proxy::s3api' do
  shared_examples 'swift::proxy::s3api' do
    it { is_expected.to contain_swift_proxy_config('filter:s3api/use').with_value('egg:swift#s3api') }
    it { is_expected.to contain_swift_proxy_config('filter:s3api/auth_pipeline_check').with_value('false') }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::s3api'
    end
  end
end
