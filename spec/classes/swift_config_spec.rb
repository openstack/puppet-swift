require 'spec_helper'

describe 'swift::config' do
  let :params do
    { :swift_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :swift_proxy_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :swift_account_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :swift_container_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :swift_object_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :swift_internal_client_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      }
    }
  end

  shared_examples 'swift::config' do
    it 'configures arbitrary swift configurations' do
      is_expected.to contain_swift_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_swift_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_swift_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary swift proxy configurations' do
      is_expected.to contain_swift_proxy_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_swift_proxy_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_swift_proxy_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary swift account configurations' do
      is_expected.to contain_swift_account_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_swift_account_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_swift_account_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary swift container configurations' do
      is_expected.to contain_swift_container_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_swift_container_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_swift_container_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary swift object configurations' do
      is_expected.to contain_swift_object_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_swift_object_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_swift_object_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary swift internal client configurations' do
      is_expected.to contain_swift_internal_client_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_swift_internal_client_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_swift_internal_client_config('DEFAULT/baz').with_ensure('absent')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::config'
    end
  end
end
