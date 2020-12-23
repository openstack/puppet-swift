require 'spec_helper'

describe 'swift::proxy::s3api' do

  let :params do
    {}
  end

  shared_examples 'swift::proxy::s3api' do
    context 'with default parameters' do
      it 'configures with default' do
        is_expected.to contain_swift_proxy_config('filter:s3api/use').with_value('egg:swift#s3api')
        is_expected.to contain_swift_proxy_config('filter:s3api/allow_no_owner').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/location').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/dns_compliant_bucket_names').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/max_bucket_listing').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/max_parts_listing').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/max_multi_delete_objects').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/multi_delete_concurrency').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/s3_acl').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/storage_domain').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/auth_pipeline_check').with_value('false')
        is_expected.to contain_swift_proxy_config('filter:s3api/allow_multipart_uploads').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/max_upload_part_num').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/check_bucket_owner').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/force_swift_request_proxy_log').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/min_segment_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_proxy_config('filter:s3api/log_name').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with overriding parameters' do
      before do
        params.merge!({
          :allow_no_owner                => true,
          :location                      => 'regionOne',
          :dns_compliant_bucket_names    => true,
          :max_bucket_listing            => 1000,
          :max_parts_listing             => 1000,
          :max_multi_delete_objects      => 1000,
          :multi_delete_concurrency      => 2,
          :s3_acl                        => false,
          :storage_domain                => 'swift.openstack.org',
          :auth_pipeline_check           => true,
          :allow_multipart_uploads       => true,
          :max_upload_part_num           => 1000,
          :check_bucket_owner            => false,
          :force_swift_request_proxy_log => false,
          :min_segment_size              => 5242880,
          :log_name                      => 's3api',
        })
      end
      it 'configures with overridden parameters' do
        is_expected.to contain_swift_proxy_config('filter:s3api/use').with_value('egg:swift#s3api')
        is_expected.to contain_swift_proxy_config('filter:s3api/allow_no_owner').with_value(true)
        is_expected.to contain_swift_proxy_config('filter:s3api/location').with_value('regionOne')
        is_expected.to contain_swift_proxy_config('filter:s3api/dns_compliant_bucket_names').with_value(true)
        is_expected.to contain_swift_proxy_config('filter:s3api/max_bucket_listing').with_value(1000)
        is_expected.to contain_swift_proxy_config('filter:s3api/max_parts_listing').with_value(1000)
        is_expected.to contain_swift_proxy_config('filter:s3api/max_multi_delete_objects').with_value(1000)
        is_expected.to contain_swift_proxy_config('filter:s3api/multi_delete_concurrency').with_value(2)
        is_expected.to contain_swift_proxy_config('filter:s3api/s3_acl').with_value(false)
        is_expected.to contain_swift_proxy_config('filter:s3api/storage_domain').with_value('swift.openstack.org')
        is_expected.to contain_swift_proxy_config('filter:s3api/auth_pipeline_check').with_value('true')
        is_expected.to contain_swift_proxy_config('filter:s3api/allow_multipart_uploads').with_value(true)
        is_expected.to contain_swift_proxy_config('filter:s3api/max_upload_part_num').with_value(1000)
        is_expected.to contain_swift_proxy_config('filter:s3api/check_bucket_owner').with_value(false)
        is_expected.to contain_swift_proxy_config('filter:s3api/force_swift_request_proxy_log').with_value(false)
        is_expected.to contain_swift_proxy_config('filter:s3api/min_segment_size').with_value(5242880)
        is_expected.to contain_swift_proxy_config('filter:s3api/log_name').with_value('s3api')
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
