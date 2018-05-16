require 'spec_helper'

describe 'swift::xfs' do
  shared_examples 'swift::xfs' do
    ['xfsprogs', 'parted'].each do |present_package|
      it { is_expected.to contain_package(present_package).with_ensure('present') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::xfs'
    end
  end
end
