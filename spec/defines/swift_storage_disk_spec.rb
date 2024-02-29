require 'spec_helper'

describe 'swift::storage::disk' do

  let :title do
    'sdb'
  end

  shared_examples 'swift::storage::disk' do
    context 'with defaults' do
      let :params do
        {}
      end

      it { is_expected.to contain_exec('create_partition_label-sdb').with(
        :command => 'parted -s /dev/sdb mklabel gpt ',
        :path    => ['/usr/bin/', '/sbin', '/bin'],
        :onlyif  => ['test -b /dev/sdb', 'parted /dev/sdb print|tail -1|grep \'Error\''],
        :before  => 'Anchor[swift::config::end]'
      )}

      it { is_expected.to contain_swift__storage__xfs('sdb').with(
        :device            => '/dev/sdb',
        :mnt_base_dir      => '/srv/node',
        :byte_size         => '1024',
        :loopback          => false,
        :mount_type        => 'path',
        :manage_filesystem => true,
        :label             => 'sdb',
      ) }
    end

    context 'with parameters' do
      let :params do
        {
          :mnt_base_dir      => '/srv/data',
          :byte_size         => '2048',
          :ext_args          => 'mkpart primary 0% 100%',
          :mount_type        => 'label',
          :manage_filesystem => false,
        }
      end

      it { is_expected.to contain_exec('create_partition_label-sdb').with(
        :command => 'parted -s /dev/sdb mklabel gpt mkpart primary 0% 100%',
        :path    => ['/usr/bin/', '/sbin', '/bin'],
        :onlyif  => ['test -b /dev/sdb', 'parted /dev/sdb print|tail -1|grep \'Error\''],
        :before  => 'Anchor[swift::config::end]'
      )}

      it { is_expected.to contain_swift__storage__xfs('sdb').with(
        :device            => '/dev/sdb',
        :mnt_base_dir      => '/srv/data',
        :byte_size         => '2048',
        :loopback          => false,
        :mount_type        => 'label',
        :manage_filesystem => false,
        :label             => 'sdb',
      ) }
    end

    context 'with ext4 filesystem type' do
      let :params do
        {
          :filesystem_type => 'ext4'
        }
      end

      it { is_expected.to contain_exec('create_partition_label-sdb').with(
        :command => 'parted -s /dev/sdb mklabel gpt ',
        :path    => ['/usr/bin/', '/sbin', '/bin'],
        :onlyif  => ['test -b /dev/sdb', 'parted /dev/sdb print|tail -1|grep \'Error\''],
        :before  => 'Anchor[swift::config::end]'
      )}

      it { is_expected.to contain_swift__storage__ext4('sdb').with(
        :device            => '/dev/sdb',
        :mnt_base_dir      => '/srv/node',
        :byte_size         => '1024',
        :loopback          => false,
        :mount_type        => 'path',
        :manage_filesystem => true,
        :label             => 'sdb',
      ) }
    end

    context 'with partition is not managed' do
      let :params do
        {
          :manage_partition => false
        }
      end
      it { is_expected.to_not contain_exec('create_partition_label-sdb') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::storage::disk'
    end
  end
end
