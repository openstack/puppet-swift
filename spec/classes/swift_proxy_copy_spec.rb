require 'spec_helper'

describe 'swift::proxy::copy' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_copy').with_content('
[filter:copy]
use = egg:swift#copy
object_post_as_copy = true
')
    end
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :object_post_as_copy => false,
      }
    end
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_copy').with_content(/object_post_as_copy = false/)
    end
  end

end
