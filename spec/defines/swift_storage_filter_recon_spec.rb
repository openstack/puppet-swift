require 'spec_helper'

describe 'swift::storage::filter::recon' do
  let :title do
    'account'
  end

  shared_examples 'swift::storage::filter::recon' do
    describe 'when passing default parameters' do
      it 'should configure the recon middleware' do
        is_expected.to contain_swift_account_config('filter:recon/use').\
          with_value('egg:swift#recon')
        is_expected.to contain_swift_account_config('filter:recon/recon_cache_path').\
          with_value('<SERVICE DEFAULT>')
      end
    end

    describe 'when overriding default parameters' do
      let :params do
        {
          :cache_path => '/var/cache/swift'
        }
      end

      it 'should configure the recon middleware' do
        is_expected.to contain_swift_account_config('filter:recon/use').\
          with_value('egg:swift#recon')
        is_expected.to contain_swift_account_config('filter:recon/recon_cache_path').\
          with_value('/var/cache/swift')
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
