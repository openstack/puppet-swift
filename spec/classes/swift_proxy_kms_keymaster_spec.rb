require 'spec_helper'

describe 'swift::proxy::kms_keymaster' do
  shared_examples 'swift::proxy::kms_keymaster' do
    describe "when using default parameters" do
      it { should contain_swift_proxy_config('filter:kms_keymaster/use').with_value('egg:swift#kms_keymaster') }
      it { should contain_swift_proxy_config('filter:kms_keymaster/keymaster_config_path').with_value('/etc/swift/keymaster.conf') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :keymaster_config_path => '/tmp/keymaster.conf',
        }
      end

      it { should contain_swift_proxy_config('filter:kms_keymaster/keymaster_config_path').with_value('/tmp/keymaster.conf') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::kms_keymaster'
    end
  end
end
