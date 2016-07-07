require 'spec_helper'

describe 'swift::storage' do
  let :facts do
    OSDefaults.get_facts({
      :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian',
    })
  end

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
        {:use_xinetd => true,
         :address    => params[:storage_local_net_ip],
         :use_chroot => 'no'
        }
      )}
    end
    describe 'when local net ip is not specified' do
      if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0
        it_raises 'a Puppet::Error', /expects a value for parameter 'storage_local_net_ip'/
      else
        it_raises 'a Puppet::Error', /Must pass storage_local_net_ip/
      end
    end
  end
  describe 'when the dependencies are not specified' do
    it 'should fail' do
      expect { catalogue }.to raise_error(Puppet::Error)
    end
  end
end
