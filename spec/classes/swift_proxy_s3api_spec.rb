require 'spec_helper'

describe 'swift::proxy::s3api' do

  let :facts do
    OSDefaults.get_facts({
      :osfamily        => 'Debian',
      :operatingsystem => 'Ubuntu',
    })
  end

  it { is_expected.to contain_swift_proxy_config('filter:s3api/use').with_value('egg:swift#s3api') }
  it { is_expected.to contain_swift_proxy_config('filter:s3api/auth_pipeline_check').with_value('false') }

end
