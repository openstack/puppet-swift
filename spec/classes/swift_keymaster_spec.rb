require 'spec_helper'

describe 'swift::keymaster' do
  shared_examples 'swift::keymaster' do
    let :params do
      {
        :password => 'swiftpassword'
      }
    end

    context "when using default parameters" do
      it 'configures keymaster options' do
        is_expected.to contain_swift_keymaster_config('kms_keymaster/api_class').with_value('barbican')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/key_id').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/username').with_value('swift')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/password').with_value('swiftpassword').with_secret(true)
        is_expected.to contain_swift_keymaster_config('kms_keymaster/project_name').with_value('services')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/project_id').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/auth_endpoint').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/barbican_endpoint').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/project_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/user_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/project_domain_id').with_value('default')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/user_domain_id').with_value('default')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/meta_version_to_write').with_value('<SERVICE DEFAULT>')
      end
    end

    describe "when overriding default parameters" do
      before :each do
        params.merge!({
          :api_class             => 'castellan.key_manager.barbican_key_manager.BarbicanKeyManager',
          :key_id                => 'dummy_key_id',
          :auth_endpoint         => 'http://127.0.0.1:5000',
          :barbican_endpoint     => 'https://barbican.example.com/keymaster',
          :project_name          => 'barbican_swift_service',
          :project_domain_name   => 'Default',
          :user_domain_name      => 'Default',
          :meta_version_to_write => 3,
        })
      end

      it 'configures keymaster options' do
        is_expected.to contain_swift_keymaster_config('kms_keymaster/api_class').with_value('castellan.key_manager.barbican_key_manager.BarbicanKeyManager')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/key_id').with_value('dummy_key_id')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/project_name').with_value('barbican_swift_service')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/auth_endpoint').with_value('http://127.0.0.1:5000')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/barbican_endpoint').with_value('https://barbican.example.com/keymaster')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/project_domain_name').with_value('Default')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/user_domain_name').with_value('Default')
        is_expected.to contain_swift_keymaster_config('kms_keymaster/meta_version_to_write').with_value('3')
      end
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
