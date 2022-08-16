require 'spec_helper'

describe 'swift::storage' do
  shared_examples 'swift::storage' do
    describe 'when required classes are specified' do
      let :pre_condition do
        "class { 'swift': swift_hash_path_suffix => 'changeme' }"
      end

      describe 'when the local net ip is specified' do
        let :params do
          {
            :storage_local_net_ip => '127.0.0.1',
          }
        end

        it { is_expected.to contain_class('rsync::server').with(
           :use_xinetd => platform_params[:xinetd_available],
           :address    => params[:storage_local_net_ip],
           :use_chroot => 'no'
        )}
      end

      describe 'when the rsync_use_xinetd is specified' do
        let :params do
          {
            :storage_local_net_ip => '127.0.0.1',
            :rsync_use_xinetd     => false,
          }
        end

        it { is_expected.to contain_class('rsync::server').with(
          {:use_xinetd => false,
           :address    => params[:storage_local_net_ip],
           :use_chroot => 'no'
          }
        )}
      end

      describe 'when local net ip is not specified' do
        it_raises 'a Puppet::Error', /expects a value for parameter 'storage_local_net_ip'/
      end
    end

    describe 'when the dependencies are not specified' do
      it 'should fail' do
        expect { catalogue }.to raise_error(Puppet::Error)
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

      let (:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :xinetd_available => true }
        when 'RedHat'
          if facts[:operatingsystemmajrelease] > '8'
            { :xinetd_available => false }
          else
            { :xinetd_available => true }
          end
        end
      end

      it_configures 'swift::storage'
    end
  end
end
