require 'spec_helper'

describe 'swift::proxy::healthcheck' do

  let :facts do
    {}
  end

  it { is_expected.to contain_swift_proxy_config('filter:healthcheck/use').with_value('egg:swift#healthcheck') }

end
