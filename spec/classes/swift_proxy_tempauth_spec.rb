require 'spec_helper'

describe 'swift::proxy::tempauth' do
  shared_examples 'swift::proxy::tempauth' do
    let :default_params do {
      'account_user_list' => [
        {
          'user'    => 'admin',
          'account' => 'admin',
          'key'     => 'admin',
          'groups'  => [ 'admin', 'reseller_admin' ],
        },
      ]
    }
    end

    let :params do default_params end

    it { is_expected.to contain_swift_proxy_config('filter:tempauth/use').with_value('egg:swift#tempauth') }
    it { is_expected.to contain_swift_proxy_config('filter:tempauth/user_admin_admin').with_value('admin .admin .reseller_admin') }

    it { is_expected.to_not contain_swift_proxy_config('filter:tempauth/reseller_prefix').with_value('') }
    it { is_expected.to_not contain_swift_proxy_config('filter:tempauth/token_life').with_value('') }
    it { is_expected.to_not contain_swift_proxy_config('filter:tempauth/auth_prefix').with_value('') }
    it { is_expected.to_not contain_swift_proxy_config('filter:tempauth/storage_url_scheme').with_value('') }

    context 'declaring two users' do
      let :params do {
        'account_user_list' => [
          {
            'user'    => 'admin',
            'account' => 'admin',
            'key'     => 'admin',
            'groups'  => [ 'admin', 'reseller_admin' ],
          },
          {
            'user'    => 'foo',
            'account' => 'bar',
            'key'     => 'pass',
            'groups'  => [ 'reseller_admin' ],
          },
        ]
      } end

      it { is_expected.to contain_swift_proxy_config('filter:tempauth/user_admin_admin').with_value('admin .admin .reseller_admin') }
      it { is_expected.to contain_swift_proxy_config('filter:tempauth/user_bar_foo').with_value('pass .reseller_admin') }
    end

    context 'when group is empty' do
      let :params do {
        'account_user_list' => [
          {
            'user'    => 'admin',
            'account' => 'admin',
            'key'     => 'admin',
            'groups'  => [],
          },
        ]
      } end

      it { is_expected.to contain_swift_proxy_config('filter:tempauth/user_admin_admin').with_value('admin') }
    end

    context 'when undef params are set' do
      let :params do {
        'reseller_prefix' => 'auth',
        'token_life'      => 81600,
        'auth_prefix'     => '/auth/',
        'storage_url_scheme' => 'http',
      }.merge(default_params)
      end

      it { is_expected.to contain_swift_proxy_config('filter:tempauth/reseller_prefix').with_value('AUTH') }
      it { is_expected.to contain_swift_proxy_config('filter:tempauth/token_life').with_value('81600') }
      it { is_expected.to contain_swift_proxy_config('filter:tempauth/auth_prefix').with_value('/auth/') }
      it { is_expected.to contain_swift_proxy_config('filter:tempauth/storage_url_scheme').with_value('http') }

      describe "invalid params" do
        ['account_user_list', 'token_life', 'auth_prefix', 'storage_url_scheme'].each do |param|
          let :params do { param => 'foobar' }.merge(default_params) end
          it "invalid #{param} should fail" do
            expect { catalogue }.to raise_error(Puppet::Error)
          end
        end
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

      it_configures 'swift::proxy::tempauth'
    end
  end
end
