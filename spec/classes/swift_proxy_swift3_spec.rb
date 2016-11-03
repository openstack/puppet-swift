require 'spec_helper'

describe 'swift::proxy::swift3' do

  let :facts do
    OSDefaults.get_facts({
      :osfamily        => 'Debian',
      :operatingsystem => 'Ubuntu',
    })
  end

  it { is_expected.to contain_swift_proxy_config('filter:swift3/use').with_value('egg:swift3#swift3') }

end
