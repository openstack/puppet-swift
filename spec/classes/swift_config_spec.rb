require 'spec_helper'

describe 'swift::config' do

  let :params do
    { :swift_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      }
    }
  end

  it 'configures arbitrary swift configurations' do
    is_expected.to contain_swift_config('DEFAULT/foo').with_value('fooValue')
    is_expected.to contain_swift_config('DEFAULT/bar').with_value('barValue')
    is_expected.to contain_swift_config('DEFAULT/baz').with_ensure('absent')
  end

end
