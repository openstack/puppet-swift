require 'spec_helper'

describe 'swift::proxy::copy' do
  shared_examples 'swift::proxy::copy' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:copy/use').with_value('egg:swift#copy') }
      it { is_expected.to contain_swift_proxy_config('filter:copy/object_post_as_copy').with_value('true') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :object_post_as_copy => false,
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:copy/object_post_as_copy').with_value('false') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::copy'
    end
  end
end
