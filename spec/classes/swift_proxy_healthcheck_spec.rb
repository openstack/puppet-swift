require 'spec_helper'

describe 'swift::proxy::healthcheck' do

  let :facts do
    {}
  end

  it { is_expected.to contain_concat_fragment('swift_healthcheck').with_content(/[filter:healthcheck]/) }
  it { is_expected.to contain_concat_fragment('swift_healthcheck').with_content(/use = egg:swift#healthcheck/) }

end
