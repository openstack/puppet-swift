require 'spec_helper'

describe 'swift::proxy::ratelimit' do
  shared_examples 'swift::proxy::ratelimit' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/use').with_value('egg:swift#ratelimit') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/clock_accuracy').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/max_sleep_time_seconds').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/log_sleep_time_seconds').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/rate_buffer_seconds').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/account_ratelimit').with_value('<SERVICE DEFAULT>') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :clock_accuracy         => 1000,
          :max_sleep_time_seconds => 60,
          :log_sleep_time_seconds => 0,
          :rate_buffer_seconds    => 5,
          :account_ratelimit      => 0
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/clock_accuracy').with_value('1000') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/max_sleep_time_seconds').with_value('60') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/log_sleep_time_seconds').with_value('0') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/rate_buffer_seconds').with_value('5') }
      it { is_expected.to contain_swift_proxy_config('filter:ratelimit/account_ratelimit').with_value('0') }
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
