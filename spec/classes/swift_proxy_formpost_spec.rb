require 'spec_helper'

describe 'swift::proxy::formpost' do

  let :facts do
    {}
  end

  it { is_expected.to contain_swift_proxy_config('filter:formpost/use').with_value('egg:swift#formpost') }

end
