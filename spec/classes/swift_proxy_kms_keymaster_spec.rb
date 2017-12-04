require 'spec_helper'

describe 'swift::proxy::kms_keymaster' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it { is_expected.to contain_swift_proxy_config('filter:kms_keymaster/use').with_value('egg:swift#kms_keymaster') }
    it { is_expected.to contain_swift_proxy_config('filter:kms_keymaster/keymaster_config_path').with_value('/etc/swift/keymaster.conf') }

  end

  describe "when overriding default parameters" do
    let :params do
      {
	      :keymaster_config_path => '/tmp/keymaster.conf',
      }
    end
    it { is_expected.to contain_swift_proxy_config('filter:kms_keymaster/keymaster_config_path').with_value('/tmp/keymaster.conf') }
  end

end
