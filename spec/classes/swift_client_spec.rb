require 'spec_helper'

describe 'swift::client' do

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure   => 'present' }
  end

  shared_examples 'swift::client' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('swift::params') }

    it 'installs swift client package' do
      is_expected.to contain_package('swiftclient').with(
        :name   => platform_params[:client_package_name],
        :ensure => p[:package_ensure],
        :tag    => ['openstack','swift-support-package'],
      )
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :fqdn           => 'some.host.tld',
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          if facts[:os_package_type] == 'debian'
            { :client_package_name => 'python3-swiftclient' }
          else
            { :client_package_name => 'python-swiftclient' }
          end
        when 'RedHat'
          { :client_package_name => 'python-swiftclient' }
        end
      end

      it_configures 'swift::client'
    end
  end

end
