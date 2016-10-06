require 'spec_helper'

describe 'swift::proxy::slo' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it { is_expected.to contain_swift_proxy_config('filter:slo/use').with_value('egg:swift#slo') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/max_manifest_segments').with_value('1000') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/max_manifest_size').with_value('2097152') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/min_segment_size').with_value('1048576') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/rate_limit_after_segment').with_value('10') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/rate_limit_segments_per_sec').with_value('0') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/max_get_time').with_value('86400') }
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :max_manifest_segments     => '2000',
        :max_manifest_size         => '500000',
        :rate_limit_after_segment  => '30',
        :max_get_time              => '6400',
      }
    end
    it { is_expected.to contain_swift_proxy_config('filter:slo/max_manifest_segments').with_value('2000') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/max_manifest_size').with_value('500000') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/rate_limit_after_segment').with_value('30') }
    it { is_expected.to contain_swift_proxy_config('filter:slo/max_get_time').with_value('6400') }
  end

end
