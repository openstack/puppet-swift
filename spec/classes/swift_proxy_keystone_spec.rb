require 'spec_helper'

describe 'swift::proxy::keystone' do
  shared_examples 'swift::proxy::keystone' do
    it { is_expected.to contain_swift_proxy_config('filter:keystone/use').with_value('egg:swift#keystoneauth') }

    describe 'with defaults' do
      it { is_expected.to contain_swift_proxy_config('filter:keystone/operator_roles').with_value('admin, SwiftOperator') }
      it { is_expected.to contain_swift_proxy_config('filter:keystone/reseller_prefix').with_value('AUTH_') }
      it { is_expected.to contain_swift_proxy_config('filter:keystone/project_reader_roles').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:keystone/system_reader_roles').with_value('<SERVICE DEFAULT>') }
    end

    describe 'with parameter overrides' do
      let :params do
        {
          :operator_roles       => 'foo',
          :reseller_prefix      => 'SWIFT_',
          :reseller_admin_role  => 'ResellerAdmin',
          :project_reader_roles => ['SwiftProjectReader'],
          :system_reader_roles  => ['SwiftSystemReader'],
        }

        it { is_expected.to contain_swift_proxy_config('filter:keystone/operator_roles').with_value('foo') }
        it { is_expected.to contain_swift_proxy_config('filter:keystone/reseller_prefix').with_value('SWIFT_') }
        it { is_expected.to contain_swift_proxy_config('filter:keystone/reseller_admin_role').with_value('ResellerAdmin') }
        it { is_expected.to contain_swift_proxy_config('filter:keystone/project_reader_roles').with_value('SwiftProjectReader') }
        it { is_expected.to contain_swift_proxy_config('filter:keystone/system_reader_roles').with_value('SwiftSystemReader') }
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

      it_configures 'swift::proxy::keystone'
    end
  end
end
