require 'spec_helper'

describe 'swift::proxy::gatekeeper' do
  shared_examples 'swift::proxy::gatekeeper' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/use').with_value('egg:swift#gatekeeper') }
      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/set log_name').with_value('gatekeeper') }
      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/set log_facility').with_value('LOG_LOCAL2') }
      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/set log_level').with_value('INFO') }
      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/set log_headers').with_value('false') }
      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/set log_address').with_value('/dev/log') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :log_name         => 'newgatekeeper',
          :log_facility     => 'LOG_LOCAL3',
          :log_level        => 'WARN',
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/set log_name').with_value('newgatekeeper') }
      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/set log_facility').with_value('LOG_LOCAL3') }
      it { is_expected.to contain_swift_proxy_config('filter:gatekeeper/set log_level').with_value('WARN') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::gatekeeper'
    end
  end
end
