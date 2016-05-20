require 'spec_helper'

describe 'swift::storage::filter::recon' do
  let :title do
    'dummy'
  end

  let :facts do
    {}
  end

  describe 'when passing default parameters' do
    it 'should build the fragment with correct content' do
      is_expected.to contain_concat_fragment('swift_recon_dummy').with_content('
[filter:recon]
use = egg:swift#recon
recon_cache_path = /var/cache/swift
')
    end
  end

  describe 'when overriding default parameters' do
    let :params do
      {
        :cache_path => '/some/other/path'
      }
    end
    it 'should build the fragment with correct content' do
      is_expected.to contain_concat_fragment('swift_recon_dummy').with_content(/recon_cache_path = \/some\/other\/path/)
    end
  end

end
