require 'spec_helper'

describe 'swift::proxy::staticweb' do

  let :facts do
    {}
  end

  it { is_expected.to contain_swift_proxy_config('filter:staticweb/use').with_value('egg:swift#staticweb') }

end
