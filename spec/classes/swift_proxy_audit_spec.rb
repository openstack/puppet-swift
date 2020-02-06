require 'spec_helper'

describe 'swift::proxy::audit' do
  shared_examples 'swift::proxy::audit' do
    context 'when using default parameters' do
      it { is_expected.to contain_swift_proxy_config('filter:audit/paste.filter_factory').with_value('keystonemiddleware.audit:filter_factory') }
      it { is_expected.to contain_swift_proxy_config('filter:audit/audit_map_file').with_value('/etc/pycadf/swift_api_audit_map.conf') }
    end

    context 'when overriding default parameters' do
      let :params do
        {
          :filter_factory => 'keystonemiddleware.audit:some_audit',
          :audit_map_file => '/etc/some_audit/some_audit.conf'
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:audit/paste.filter_factory').with_value('keystonemiddleware.audit:some_audit') }
      it { is_expected.to contain_swift_proxy_config('filter:audit/audit_map_file').with_value('/etc/some_audit/some_audit.conf') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'swift::proxy::audit'
    end
  end
end
