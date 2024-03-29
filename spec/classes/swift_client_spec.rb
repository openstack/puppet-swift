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
        :tag    => 'openstack',
      )
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :client_package_name => 'python3-swiftclient' }
        when 'RedHat'
          { :client_package_name => 'python3-swiftclient' }
        end
      end

      it_configures 'swift::client'
    end
  end

end
