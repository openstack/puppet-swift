require 'spec_helper'

describe 'swift::proxy::copy' do

  let :facts do
    {}
  end

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
