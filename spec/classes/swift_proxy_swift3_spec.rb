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

  it { is_expected.to contain_concat_fragment('swift_swift3').with_content(/[filter:swift3]/) }
  it { is_expected.to contain_concat_fragment('swift_swift3').with_content(/use = egg:swift3#swift3/) }

end
