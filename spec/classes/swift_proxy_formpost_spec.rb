require 'spec_helper'

describe 'swift::proxy::formpost' do
  shared_examples 'swift::proxy::formpost' do
    context 'with defaults' do
      it { should contain_swift_proxy_config('filter:formpost/use').with_value('egg:swift#formpost') }
      it { should contain_swift_proxy_config('filter:formpost/allowed_digests').with_value('<SERVICE DEFAULT>') }
    end

    context 'with parameters' do
      let :params do
        {
          :allowed_digests => ['sha1', 'sha256', 'sha512']
        }
      end

      it { should contain_swift_proxy_config('filter:formpost/allowed_digests').with_value('sha1 sha256 sha512') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::formpost'
    end
  end
end
