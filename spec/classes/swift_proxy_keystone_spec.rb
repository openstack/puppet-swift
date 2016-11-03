require 'spec_helper'

describe 'swift::proxy::keystone' do

  let :facts do
    {}
  end

  it { is_expected.to contain_swift_proxy_config('filter:keystone/use').with_value('egg:swift#keystoneauth') }

  describe 'with defaults' do

    it { is_expected.to contain_swift_proxy_config('filter:keystone/operator_roles').with_value('admin, SwiftOperator') }
    it { is_expected.to contain_swift_proxy_config('filter:keystone/reseller_prefix').with_value('AUTH_') }

  end

  describe 'with parameter overrides' do

    let :params do
      {
        :operator_roles      => 'foo',
        :reseller_prefix     => 'SWIFT_',
        :reseller_admin_role => 'ResellerAdmin'
      }

      it { is_expected.to contain_swift_proxy_config('filter:keystone/operator_roles').with_value('foo') }
      it { is_expected.to contain_swift_proxy_config('filter:keystone/reseller_prefix').with_value('SWIFT_') }
      it { is_expected.to contain_swift_proxy_config('filter:keystone/reseller_admin_role').with_value('ResellerAdmin') }

    end

  end

end
