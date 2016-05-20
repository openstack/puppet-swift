require 'spec_helper'

describe 'swift::proxy::dlo' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_dlo').with_content('
[filter:dlo]
use = egg:swift#dlo
rate_limit_after_segment = 10
rate_limit_segments_per_sec = 1
max_get_time = 86400
')
    end
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :rate_limit_after_segment    => '30',
        :rate_limit_segments_per_sec => '5',
        :max_get_time                => '6400',
      }
    end
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_dlo').with_content(/rate_limit_after_segment = 30/)
      is_expected.to contain_concat_fragment('swift_dlo').with_content(/rate_limit_segments_per_sec = 5/)
      is_expected.to contain_concat_fragment('swift_dlo').with_content(/max_get_time = 6400/)
    end
  end

end
