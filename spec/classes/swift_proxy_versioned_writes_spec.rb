require 'spec_helper'

describe 'swift::proxy::versioned_writes' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_versioned_writes').with_content('
[filter:versioned_writes]
use = egg:swift#versioned_writes
allow_versioned_writes = false
')
    end
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :allow_versioned_writes => true,
      }
    end
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_versioned_writes').with_content(/allow_versioned_writes = true/)
    end
  end

end
