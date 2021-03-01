require 'spec_helper'

describe 'swift::proxy::listing_formats' do
  shared_examples 'swift::proxy::listing_formats' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:listing_formats/use').with_value('egg:swift#listing_formats') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::listing_formats'
    end
  end
end
