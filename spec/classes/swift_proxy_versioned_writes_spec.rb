require 'spec_helper'

describe 'swift::proxy::versioned_writes' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it { is_expected.to contain_swift_proxy_config('filter:versioned_writes/use').with_value('egg:swift#versioned_writes') }
    it { is_expected.to contain_swift_proxy_config('filter:versioned_writes/allow_versioned_writes').with_value('false') }
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :allow_versioned_writes => true,
      }
    end
    it { is_expected.to contain_swift_proxy_config('filter:versioned_writes/allow_versioned_writes').with_value('true') }
  end

end
