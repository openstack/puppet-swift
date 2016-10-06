require 'spec_helper'

describe 'swift::proxy::dlo' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it { is_expected.to contain_swift_proxy_config('filter:dlo/use').with_value('egg:swift#dlo') }
    it { is_expected.to contain_swift_proxy_config('filter:dlo/rate_limit_after_segment').with_value('10') }
    it { is_expected.to contain_swift_proxy_config('filter:dlo/rate_limit_segments_per_sec').with_value('1') }
    it { is_expected.to contain_swift_proxy_config('filter:dlo/max_get_time').with_value('86400') }
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :rate_limit_after_segment    => '30',
        :rate_limit_segments_per_sec => '5',
        :max_get_time                => '6400',
      }
    end
    it { is_expected.to contain_swift_proxy_config('filter:dlo/rate_limit_after_segment').with_value('30') }
    it { is_expected.to contain_swift_proxy_config('filter:dlo/rate_limit_segments_per_sec').with_value('5') }
    it { is_expected.to contain_swift_proxy_config('filter:dlo/max_get_time').with_value('6400') }
  end

end
