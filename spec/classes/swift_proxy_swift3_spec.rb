require 'spec_helper'

describe 'swift::proxy::swift3' do

  let :facts do
    OSDefaults.get_facts({
      :osfamily        => 'Debian',
      :operatingsystem => 'Ubuntu',
    })
  end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }'
  end

  let :fragment_file do
    "/var/lib/puppet/concat/_etc_swift_proxy-server.conf/fragments/27_swift_swift3"
  end

  it { is_expected.to contain_swift_proxy_config('filter:swift3/use').with_value('egg:swift3#swift3') }

end
