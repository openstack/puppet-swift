require 'spec_helper'

describe 'swift::keymaster' do
  shared_examples 'swift::keymaster' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/api_class').with_value('castellan.key_manager.barbican_key_manager.BarbicanKeyManager') }
      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/username').with_value('swift') }
      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/project_name').with_value('service') }
      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/project_domain_id').with_value('default') }
      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/user_domain_id').with_value('default') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :key_id => 'dummy_key_id',
          :password => 'fake_password',
          :auth_endpoint => 'http://127.0.0.1:5000',
          :project_name => 'barbican_swift_service',
        }
      end

      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/key_id').with_value('dummy_key_id') }
      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/password').with_value('fake_password') }
      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/auth_endpoint').with_value('http://127.0.0.1:5000') }
      it { is_expected.to contain_swift_keymaster_config('kms_keymaster/project_name').with_value('barbican_swift_service') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::keymaster'
    end
  end
end
