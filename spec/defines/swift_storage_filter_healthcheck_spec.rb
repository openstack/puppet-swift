require 'spec_helper'

describe 'swift::storage::filter::healthcheck' do
  let :title do
    'dummy'
  end

  let :facts do
    {}
  end

it 'should build the fragment with correct content' do
  is_expected.to contain_concat_fragment('swift_healthcheck_dummy').with_content('
[filter:healthcheck]
use = egg:swift#healthcheck
')
end

end
