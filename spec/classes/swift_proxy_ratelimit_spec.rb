require 'spec_helper'

describe 'swift::proxy::ratelimit' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_ratelimit').with_content('
[filter:ratelimit]
use = egg:swift#ratelimit
clock_accuracy = 1000
max_sleep_time_seconds = 60
log_sleep_time_seconds = 0
rate_buffer_seconds = 5
account_ratelimit = 0
')
    end
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
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_ratelimit').with_content(/clock_accuracy = 9436/)
      is_expected.to contain_concat_fragment('swift_ratelimit').with_content(/max_sleep_time_seconds = 3600/)
      is_expected.to contain_concat_fragment('swift_ratelimit').with_content(/log_sleep_time_seconds = 42/)
      is_expected.to contain_concat_fragment('swift_ratelimit').with_content(/rate_buffer_seconds = 51/)
      is_expected.to contain_concat_fragment('swift_ratelimit').with_content(/account_ratelimit = 69/)
    end
  end

end
