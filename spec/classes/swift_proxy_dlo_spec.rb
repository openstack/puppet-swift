require 'spec_helper'

describe 'swift::proxy::dlo' do
  shared_examples 'swift::proxy::dlo' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:dlo/use').with_value('egg:swift#dlo') }
      it { is_expected.to contain_swift_proxy_config('filter:dlo/rate_limit_after_segment').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:dlo/rate_limit_segments_per_sec').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:dlo/max_get_time').with_value('<SERVICE DEFAULT>') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :rate_limit_after_segment    => '10',
          :rate_limit_segments_per_sec => '1',
          :max_get_time                => '86400',
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:dlo/rate_limit_after_segment').with_value('10') }
      it { is_expected.to contain_swift_proxy_config('filter:dlo/rate_limit_segments_per_sec').with_value('1') }
      it { is_expected.to contain_swift_proxy_config('filter:dlo/max_get_time').with_value('86400') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::dlo'
    end
  end
end
