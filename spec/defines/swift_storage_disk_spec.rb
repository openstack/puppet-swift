require 'spec_helper'

describe 'swift::storage::disk' do
  # TODO add more unit tests

  let :title do
    'sdb'
  end

  let :params do
    {
      :base_dir     => '/dev',
      :mnt_base_dir => '/srv/node',
      :byte_size    => '1024',
      :ext_args     => 'mkpart primary 0% 100%',
    }
  end

  shared_examples 'swift::storage::disk' do
    it { is_expected.to contain_exec("create_partition_label-sdb").with(
      :command => "parted -s #{params[:base_dir]}/sdb mklabel gpt #{params[:ext_args]}",
      :path    => ["/usr/bin/", "/sbin", "/bin"],
      :onlyif  => ["test -b #{params[:base_dir]}/sdb","parted #{params[:base_dir]}/sdb print|tail -1|grep 'Error'"],
      :before  => 'Anchor[swift::config::end]'
    )}

    it { is_expected.to contain_swift__storage__xfs('sdb').with(
      :device       => '/dev/sdb',
      :mnt_base_dir => '/srv/node',
      :byte_size    => '1024',
      :loopback     =>  false
    ) }
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
