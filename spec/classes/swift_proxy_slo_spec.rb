require 'spec_helper'

describe 'swift::proxy::slo' do
  shared_examples 'swift::proxy::slo' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:slo/use').with_value('egg:swift#slo') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/max_manifest_segments').with_value('1000') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/max_manifest_size').with_value('8388608') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/rate_limit_under_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/rate_limit_after_segment').with_value('10') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/rate_limit_segments_per_sec').with_value('1') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/max_get_time').with_value('86400') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/concurrency').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/delete_concurrency').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/yield_frequency').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:slo/allow_async_delete').with_value('<SERVICE DEFAULT>') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :max_manifest_segments     => 2000,
          :max_manifest_size         => 500000,
          :rate_limit_under_size     => 1048576,
          :rate_limit_after_segment  => 30,
          :max_get_time              => 6400,
          :concurrency               => 2,
          :delete_concurrency        => 4,
          :yield_frequency           => 10,
          :allow_async_delete        => false,
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:slo/max_manifest_segments').with_value(2000) }
      it { is_expected.to contain_swift_proxy_config('filter:slo/max_manifest_size').with_value(500000) }
      it { is_expected.to contain_swift_proxy_config('filter:slo/rate_limit_under_size').with_value(1048576) }
      it { is_expected.to contain_swift_proxy_config('filter:slo/rate_limit_after_segment').with_value(30) }
      it { is_expected.to contain_swift_proxy_config('filter:slo/max_get_time').with_value(6400) }
      it { is_expected.to contain_swift_proxy_config('filter:slo/concurrency').with_value(2) }
      it { is_expected.to contain_swift_proxy_config('filter:slo/delete_concurrency').with_value(4) }
      it { is_expected.to contain_swift_proxy_config('filter:slo/yield_frequency').with_value(10) }
      it { is_expected.to contain_swift_proxy_config('filter:slo/allow_async_delete').with_value(false) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::slo'
    end
  end
end
