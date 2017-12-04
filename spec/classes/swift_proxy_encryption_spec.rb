require 'spec_helper'

describe 'swift::proxy::encryption' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it { is_expected.to contain_swift_proxy_config('filter:encryption/use').with_value('egg:swift#encryption') }
    it { is_expected.to contain_swift_proxy_config('filter:encryption/disable_encryption').with_value('false') }

  end

  describe "when overriding default parameters" do
    let :params do
      {
        :disable_encryption => true,
      }
    end
    it { is_expected.to contain_swift_proxy_config('filter:encryption/disable_encryption').with_value('true') }
  end

end
