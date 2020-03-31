require 'spec_helper'

describe 'swift::client' do

  let :params do
    {}
  end

  let :default_params do
    { :ensure   => 'present' }
  end

  shared_examples 'swift::client' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('swift::deps') }
    it { is_expected.to contain_class('swift::params') }

    it 'installs swift client package' do
      is_expected.to contain_package('swiftclient').with(
        :name   => platform_params[:client_package_name],
        :ensure => p[:ensure],
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
          { :client_package_name => 'python3-swiftclient' }
        when 'RedHat'
          if facts[:operatingsystem] == 'Fedora'
            { :client_package_name => 'python3-swiftclient' }
          else
            if facts[:operatingsystemmajrelease] > '7'
              { :client_package_name => 'python3-swiftclient' }
            else
              { :client_package_name => 'python-swiftclient' }
            end
          end
        end
      end

      it_configures 'swift::client'
    end
  end

end
