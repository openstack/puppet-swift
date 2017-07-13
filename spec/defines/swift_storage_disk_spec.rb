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
    :subscribe    => 'Exec[create_partition_label-sdb]',
    :loopback     =>  false
  ) }

end
