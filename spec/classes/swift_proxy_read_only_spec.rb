require 'spec_helper'

describe 'swift::proxy::read_only' do
  shared_examples 'swift::proxy::read_only' do
    context 'when using default parameters' do
      it { is_expected.to contain_swift_proxy_config('filter:read_only/use').with_value('egg:swift#read_only') }
      it { is_expected.to contain_swift_proxy_config('filter:read_only/read_only').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:read_only/allow_deletes').with_value('<SERVICE DEFAULT>') }
    end

    context 'when overriding default parameters' do
      let :params do
        {
          :read_only     => true,
          :allow_deletes => false,
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:read_only/use').with_value('egg:swift#read_only') }
      it { is_expected.to contain_swift_proxy_config('filter:read_only/read_only').with_value(true) }
      it { is_expected.to contain_swift_proxy_config('filter:read_only/allow_deletes').with_value(false) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'swift::proxy::read_only'
    end
  end
end
