require 'spec_helper'

describe 'swift::proxy::tempauth_account' do
  shared_examples 'swift::proxy::tempauth_account' do
    let :title do
      '    user_admin_admin,    admin .admin .reseller_admin'
    end

    describe 'when passing in a string containing "user_<account>_<user>, <key> .<group1> .<groupx>"' do
      it { should contain_swift_proxy_config('filter:tempauth/user_admin_admin').with_value('admin .admin .reseller_admin') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::tempauth_acount'
    end
  end
end
