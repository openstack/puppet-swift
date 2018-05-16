require 'spec_helper'

describe 'swift::proxy::staticweb' do
  shared_examples 'swift::proxy::staticweb' do
    it { is_expected.to contain_swift_proxy_config('filter:staticweb/use').with_value('egg:swift#staticweb') }

    describe "when overriding default parameters" do
      let :params do
        {
          :url_base => 'https://www.example.com',
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:staticweb/url_base').with_value('https://www.example.com') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::staticweb'
    end
  end
end
