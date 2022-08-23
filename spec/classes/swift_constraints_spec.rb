require 'spec_helper'

describe 'swift::constraints' do
  shared_examples 'swift::constraints' do
    context 'with defaults' do
      it 'should configure swift.conf' do
        is_expected.to contain_swift_config('swift-constraints/max_file_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/max_meta_name_length').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/max_meta_value_length').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/max_meta_count').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/max_meta_overall_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/max_header_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/extra_header_count').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/max_object_name_length').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/container_listing_limit').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/account_listing_limit').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/max_account_name_length').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/max_container_name_length').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/valid_api_versions').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_config('swift-constraints/auto_create_account_prefix').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters' do
      let :params do
        {
          :max_file_size              => 5368709122,
          :max_meta_name_length       => 128,
          :max_meta_value_length      => 256,
          :max_meta_count             => 20,
          :max_meta_overall_size      => 4096,
          :max_header_size            => 8192,
          :extra_header_count         => 0,
          :max_object_name_length     => 1024,
          :container_listing_limit    => 10000,
          :account_listing_limit      => 10000,
          :max_account_name_length    => 256,
          :max_container_name_length  => 256,
          :valid_api_versions         => ['v1', 'v1.0'],
          :auto_create_account_prefix => '.',
        }
      end
      it 'should configure swift.conf' do
        is_expected.to contain_swift_config('swift-constraints/max_file_size').with_value(5368709122)
        is_expected.to contain_swift_config('swift-constraints/max_meta_name_length').with_value(128)
        is_expected.to contain_swift_config('swift-constraints/max_meta_value_length').with_value(256)
        is_expected.to contain_swift_config('swift-constraints/max_meta_count').with_value(20)
        is_expected.to contain_swift_config('swift-constraints/max_meta_overall_size').with_value(4096)
        is_expected.to contain_swift_config('swift-constraints/max_header_size').with_value(8192)
        is_expected.to contain_swift_config('swift-constraints/extra_header_count').with_value(0)
        is_expected.to contain_swift_config('swift-constraints/max_object_name_length').with_value(1024)
        is_expected.to contain_swift_config('swift-constraints/container_listing_limit').with_value(10000)
        is_expected.to contain_swift_config('swift-constraints/account_listing_limit').with_value(10000)
        is_expected.to contain_swift_config('swift-constraints/max_account_name_length').with_value(256)
        is_expected.to contain_swift_config('swift-constraints/max_container_name_length').with_value(256)
        is_expected.to contain_swift_config('swift-constraints/valid_api_versions').with_value('v1,v1.0')
        is_expected.to contain_swift_config('swift-constraints/auto_create_account_prefix').with_value('.')
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

      it_configures 'swift::constraints'
    end
  end
end
