#
# Author: Denis Egorenko <degorenko@mirantis.com>
#
# Tests for swift::proxy::container_sync
#
require 'spec_helper'

describe 'swift::proxy::container_sync' do

  let :facts do
    {}
  end

  it { is_expected.to contain_concat_fragment('swift_container_sync').with_content(/\[filter:container_sync\]/) }
  it { is_expected.to contain_concat_fragment('swift_container_sync').with_content(/use = egg:swift#container_sync/) }

end
