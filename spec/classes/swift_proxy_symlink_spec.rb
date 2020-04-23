require 'spec_helper'

describe 'swift::proxy::symlink' do
  shared_examples 'swift::proxy::symlink' do
    context 'when using default parameters' do
      it { is_expected.to contain_swift_proxy_config('filter:symlink/use').with_value('egg:swift#symlink') }
      it { is_expected.to contain_swift_proxy_config('filter:symlink/symloop_max').with_value('<SERVICE DEFAULT>') }
    end

    context 'when overriding default parameters' do
      let :params do
        {
          :symloop_max => '3'
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:symlink/use').with_value('egg:swift#symlink') }
      it { is_expected.to contain_swift_proxy_config('filter:symlink/symloop_max').with_value('3') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'swift::proxy::symlink'
    end
  end
end
