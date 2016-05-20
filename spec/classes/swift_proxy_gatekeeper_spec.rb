require 'spec_helper'

describe 'swift::proxy::gatekeeper' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_gatekeeper').with_content('
[filter:gatekeeper]
use = egg:swift#gatekeeper
set log_name = gatekeeper
set log_facility = LOG_LOCAL0
set log_level = INFO
set log_headers = false
set log_address = /dev/log
')
    end
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :log_name         => 'newgatekeeper',
        :log_facility     => 'LOG_LOCAL2',
        :log_level        => 'WARN',
      }
    end
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_gatekeeper').with_content(/set log_name = newgatekeeper/)
      is_expected.to contain_concat_fragment('swift_gatekeeper').with_content(/set log_facility = LOG_LOCAL2/)
      is_expected.to contain_concat_fragment('swift_gatekeeper').with_content(/set log_level = WARN/)
    end
  end

end
