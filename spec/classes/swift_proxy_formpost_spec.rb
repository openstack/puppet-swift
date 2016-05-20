require 'spec_helper'

describe 'swift::proxy::formpost' do

  let :facts do
    {}
  end

  it { is_expected.to contain_concat_fragment('swift-proxy-formpost').with_content(/[filter:formpost]/) }
  it { is_expected.to contain_concat_fragment('swift-proxy-formpost').with_content(/use = egg:swift#formpost/) }

end
