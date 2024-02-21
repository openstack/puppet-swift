require 'spec_helper'

describe 'swift::storage::ext4' do
  let :title do
    'foo'
  end

  shared_examples 'swift::storage::ext4' do
    describe 'when a device is specified' do
      let :default_params do
        {
         :device       => "/dev/#{title}",
         :byte_size    => '1024',
         :mnt_base_dir => '/srv/node',
         :loopback     => false,
         :device_type  => 'path'
        }
      end

      [{},
       {
         :device       => '/dev/foo',
         :byte_size    => 1,
         :mnt_base_dir => '/mnt/bar',
         :loopback     => true
       }
      ].each do |param_set|

        describe "#{param_set == {} ? "using default" : "specifying"} class parameters" do
          let :param_hash do
            default_params.merge(param_set)
          end

          let :params do
            param_set
          end

          it { is_expected.to contain_exec("mkfs-foo").with(
            :command     => ['mkfs.ext4', '-I', param_hash[:byte_size], '-F', param_hash[:device]],
            :path        => ['/sbin/', '/usr/sbin/'],
            :refreshonly => true,
          )}

          it { is_expected.to contain_swift__storage__mount(title).with(
             :device       => param_hash[:device],
             :mnt_base_dir => param_hash[:mnt_base_dir],
             :loopback     => param_hash[:loopback],
          )}
        end
      end

      context 'with mount type label' do
        let :params do
          {
            :mount_type => :label
          }
        end

        let :param_hash do
          default_params.merge(params)
        end

        it { is_expected.to contain_exec("mkfs-foo").with(
          :command     => ['mkfs.ext4', '-I', param_hash[:byte_size], '-F', '-L', title, param_hash[:device]],
          :path        => ['/sbin/', '/usr/sbin/'],
          :refreshonly => true,
        )}

        it { is_expected.to contain_swift__storage__mount(title).with(
           :device       => "LABEL=#{title}",
           :mnt_base_dir => param_hash[:mnt_base_dir],
           :loopback     => param_hash[:loopback],
        )}
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

      it_configures 'swift::storage::ext4'
    end
  end
end
