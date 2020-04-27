require 'spec_helper'

describe 'swift::proxy::etag_quoter' do
  shared_examples 'swift::proxy::etag_quoter' do
    context 'when using default parameters' do
      it { is_expected.to contain_swift_proxy_config('filter:etag-quoter/use').with_value('egg:swift#etag_quoter') }
      it { is_expected.to contain_swift_proxy_config('filter:etag-quoter/enabled_by_default').with_value('<SERVICE DEFAULT>') }
    end

    context 'when overriding default parameters' do
      let :params do
        {
          :enabled_by_default => true
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:etag-quoter/use').with_value('egg:swift#etag_quoter') }
      it { is_expected.to contain_swift_proxy_config('filter:etag-quoter/enabled_by_default').with_value(true) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'swift::proxy::etag_quoter'
    end
  end
end

