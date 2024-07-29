require 'spec_helper'

describe 'swift::storage::filter::backend_ratelimit' do
  let :title do
    'account'
  end

  shared_examples 'swift::storage::filter::backend_ratelimit' do
    describe 'when passing default parameters' do
      it 'should configure the backend_ratelimit middleware' do
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/use'
        ).with_value('egg:swift#backend_ratelimit')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/requests_per_device_per_second'
        ).with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/delete_requests_per_device_per_second'
        ).with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/get_requests_per_device_per_second'
        ).with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/head_requests_per_device_per_second'
        ).with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/post_requests_per_device_per_second'
        ).with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/put_requests_per_device_per_second'
        ).with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/replicate_requests_per_device_per_second'
        ).with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/update_requests_per_device_per_second'
        ).with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/requests_per_device_rate_buffer'
        ).with_value('<SERVICE DEFAULT>')
      end
    end

    describe 'when overriding default parameters' do
      let :params do
        {
          :requests_per_device_per_second           => 10.0,
          :delete_requests_per_device_per_second    => 11.0,
          :get_requests_per_device_per_second       => 12.0,
          :head_requests_per_device_per_second      => 13.0,
          :post_requests_per_device_per_second      => 14.0,
          :put_requests_per_device_per_second       => 15.0,
          :replicate_requests_per_device_per_second => 16.0,
          :update_requests_per_device_per_second    => 17.0,
          :requests_per_device_rate_buffer          => 1.0
        }
      end

      it 'should configure the backend_ratelimit middleware' do
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/requests_per_device_per_second'
        ).with_value(10.0)
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/delete_requests_per_device_per_second'
        ).with_value(11.0)
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/get_requests_per_device_per_second'
        ).with_value(12.0)
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/head_requests_per_device_per_second'
        ).with_value(13.0)
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/post_requests_per_device_per_second'
        ).with_value(14.0)
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/put_requests_per_device_per_second'
        ).with_value(15.0)
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/replicate_requests_per_device_per_second'
        ).with_value(16.0)
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/update_requests_per_device_per_second'
        ).with_value(17.0)
        is_expected.to contain_swift_account_config(
          'filter:backend_ratelimit/requests_per_device_rate_buffer'
        ).with_value(1.0)
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

      it_configures 'swift::storage::filter::backend_ratelimit'
    end
  end
end
