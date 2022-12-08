require 'spec_helper'

describe 'swift::storage::filter::backend_ratelimit' do
  let :title do
    'account'
  end

  shared_examples 'swift::storage::filter::backend_ratelimit' do
    describe 'when passing default parameters' do
      it 'should configure the backend_ratelimit middleware' do
        is_expected.to contain_swift_account_config('filter:backend_ratelimit/use').\
          with_value('egg:swift#backend_ratelimit')
        is_expected.to contain_swift_account_config('filter:backend_ratelimit/requests_per_device_per_second').\
          with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('filter:backend_ratelimit/requests_per_device_rate_buffer').\
          with_value('<SERVICE DEFAULT>')
      end
    end

    describe 'when overriding default parameters' do
      let :params do
        {
          :requests_per_device_per_second  => 0.0,
          :requests_per_device_rate_buffer => 1.0
        }
      end

      it 'should configure the backend_ratelimit middleware' do
        is_expected.to contain_swift_account_config('filter:backend_ratelimit/requests_per_device_per_second').\
          with_value(0.0)
        is_expected.to contain_swift_account_config('filter:backend_ratelimit/requests_per_device_rate_buffer').\
          with_value(1.0)
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
