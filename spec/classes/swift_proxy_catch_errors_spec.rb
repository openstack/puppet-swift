require 'spec_helper'

describe 'swift::proxy::catch_errors' do

  let :facts do
    {}
  end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }'
  end

  it { is_expected.to contain_concat_fragment('swift_catch_errors').with_content(/[filter:catch_errors]/) }
  it { is_expected.to contain_concat_fragment('swift_catch_errors').with_content(/use = egg:swift#catch_errors/) }

end
