require 'spec_helper'

describe 'swift::keystone::dispersion' do
  shared_examples 'swift::keystone::dispersion' do
    describe 'with default class parameters' do
      it { is_expected.to contain_keystone_user('dispersion').with(
        :ensure   => 'present',
        :password => 'dispersion_password',
        :email    => 'swift@localhost',
      ) }

      it { is_expected.to contain_keystone_user_role('dispersion@services').with(
        :ensure  => 'present',
        :roles   => 'admin',
      ) }
    end

    describe 'when overriding parameters' do
      let :params do
        {
          :auth_user => 'bar',
          :auth_pass => 'foo',
          :email     => 'bar@example.com',
          :tenant    => 'dummyTenant'
        }
      end

      it { is_expected.to contain_keystone_user('bar').with(
        :ensure   => 'present',
        :password => 'foo',
        :email    => 'bar@example.com',
      ) }

      it { is_expected.to contain_keystone_user_role('bar@dummyTenant') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::keystone::dispersion'
    end
  end
end
