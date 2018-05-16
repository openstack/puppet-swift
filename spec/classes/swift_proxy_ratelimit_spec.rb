require 'spec_helper'

describe 'swift::proxy::ratelimit' do
  shared_examples 'swift::proxy::ratelimit' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/use').with_value('egg:swift#ratelimit') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/clock_accuracy').with_value('1000') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/max_sleep_time_seconds').with_value('60') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/log_sleep_time_seconds').with_value('0') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/rate_buffer_seconds').with_value('5') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/account_ratelimit').with_value('0') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :clock_accuracy         => 9436,
          :max_sleep_time_seconds => 3600,
          :log_sleep_time_seconds => 42,
          :rate_buffer_seconds    => 51,
          :account_ratelimit      => 69
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/clock_accuracy').with_value('9436') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/max_sleep_time_seconds').with_value('3600') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/log_sleep_time_seconds').with_value('42') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/rate_buffer_seconds').with_value('51') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/account_ratelimit').with_value('69') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::ratelimit'
    end
  end
end
