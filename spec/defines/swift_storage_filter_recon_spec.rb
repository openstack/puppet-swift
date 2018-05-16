require 'spec_helper'

describe 'swift::storage::filter::recon' do
  let :title do
    'dummy'
  end

  shared_examples 'swift::storage::filter::recon' do
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

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::storage::filter::recon'
    end
  end
end
