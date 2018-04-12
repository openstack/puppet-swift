require 'spec_helper'

describe 'swift::client' do

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure   => 'present' }
  end

  shared_examples_for 'swift client' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('swift::params') }

    it 'installs swift client package' do
      is_expected.to contain_package('swiftclient').with(
        :name   => 'python-swiftclient',
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

      it_configures 'swift client'
    end
  end

end
