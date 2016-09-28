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

  it { is_expected.to contain_swift_proxy_config('filter:container_sync/use').with_value('egg:swift#container_sync') }

end
