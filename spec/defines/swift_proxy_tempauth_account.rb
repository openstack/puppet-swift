require 'spec_helper'

describe 'swift::proxy::tempauth_account' do

  let :title do
    '    user_admin_admin,    admin .admin .reseller_admin'
  end

  describe 'when passing in a string containing "user_<account>_<user>, <key> .<group1> .<groupx>"' do

    it { is_expected.to contain_swift_proxy_config('filter:tempauth/user_admin_admin').with_value('admin .admin .reseller_admin') }

  end

end
