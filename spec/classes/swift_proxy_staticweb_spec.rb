require 'spec_helper'

describe 'swift::proxy::staticweb' do

  let :facts do
    {}
  end

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
