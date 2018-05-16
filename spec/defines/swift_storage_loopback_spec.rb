require 'spec_helper'

describe 'swift::storage::loopback' do
  # TODO add more unit tests

  let :title do
    'dans_disk'
  end

  shared_examples 'swift::storage::loopback' do
    it { is_expected.to contain_swift__storage__xfs('dans_disk').with(
      :device       => '/srv/loopback-device/dans_disk',
      :mnt_base_dir => '/srv/node',
      :byte_size    => '1024',
      :subscribe    => 'Exec[create_partition-dans_disk]',
      :loopback     => true
    )}
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::storage::loopback'
    end
  end
end
