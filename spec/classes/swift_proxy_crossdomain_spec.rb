require 'spec_helper'

describe 'swift::proxy::crossdomain' do

  let :facts do
    {}
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_crossdomain').with_content('
[filter:crossdomain]
use = egg:swift#crossdomain
cross_domain_policy = <allow-access-from domain="*" secure="false" />
')
    end
  end

  describe "when overriding default parameters" do
    let :params do
      {
        :cross_domain_policy => '<allow-access-from domain="xml-fragment-in-ini-file.so.wrong" secure="true" />
<allow-access-from domain="*" secure="false" />',
      }
    end
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_crossdomain').with_content('
[filter:crossdomain]
use = egg:swift#crossdomain
cross_domain_policy = <allow-access-from domain="xml-fragment-in-ini-file.so.wrong" secure="true" />
<allow-access-from domain="*" secure="false" />
')
    end
  end

end
