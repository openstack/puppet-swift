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

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }'
  end

  let :fragment_file do
    "/var/lib/puppet/concat/_etc_swift_proxy-server.conf/fragments/82_swift_container_sync"
  end

  it { is_expected.to contain_file(fragment_file).with_content(/\[filter:container_sync\]/) }
  it { is_expected.to contain_file(fragment_file).with_content(/use = egg:swift#container_sync/) }

end
