require 'spec_helper'

describe 'swift::proxy::s3api' do

  let :params do
    {}
  end

  shared_examples 'swift::proxy::s3api' do
    context 'with default parameters' do
      it 'configures with default' do
        is_expected.to contain_swift_proxy_config('filter:s3api/use').with_value('egg:swift#s3api')
        is_expected.to contain_swift_proxy_config('filter:s3api/location').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/auth_pipeline_check').with_value('false')
        is_expected.to contain_swift_proxy_config('filter:s3api/max_upload_part_num').with_value('1000')
      end
    end

    context 'with overriding parameters' do
      before do
        params.merge!({
          :location            => 'regionOne',
          :auth_pipeline_check => true,
          :max_upload_part_num => '2000'
        })
      end
      it 'configures with overridden parameters' do
        is_expected.to contain_swift_proxy_config('filter:s3api/use').with_value('egg:swift#s3api')
        is_expected.to contain_swift_proxy_config('filter:s3api/location').with_value('regionOne')
        is_expected.to contain_swift_proxy_config('filter:s3api/auth_pipeline_check').with_value('true')
        is_expected.to contain_swift_proxy_config('filter:s3api/max_upload_part_num').with_value('2000')
      end
    end
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
