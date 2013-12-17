require 'spec_helper'

describe 'swift::keystone::auth' do

  describe 'with default class parameters' do

    it { should contain_keystone_user('swift').with(
      :ensure   => 'present',
      :password => 'swift_password'
    ) }

    it { should contain_keystone_user_role('swift@services').with(
      :ensure  => 'present',
      :roles   => 'admin',
      :require => 'Keystone_user[swift]'
    )}

    it { should contain_keystone_service('swift').with(
      :ensure      => 'present',
      :type        => 'object-store',
      :description => 'Openstack Object-Store Service'
    ) }

    it { should contain_keystone_endpoint('RegionOne/swift').with(
      :ensure       => 'present',
      :public_url   => "http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s",
      :admin_url    => "http://127.0.0.1:8080/",
      :internal_url => "http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s"
    ) }

    it { should contain_keystone_service('swift_s3').with(
      :ensure      => 'present',
      :type        => 's3',
      :description => 'Openstack S3 Service'
    ) }

    it { should contain_keystone_endpoint('RegionOne/swift_s3').with(
      :ensure       => 'present',
      :public_url   => 'http://127.0.0.1:8080',
      :admin_url    => 'http://127.0.0.1:8080',
      :internal_url => 'http://127.0.0.1:8080'
    ) }

    ['admin', 'SwiftOperator'].each do |role_name|
      it { should contain_keystone_role(role_name).with_ensure('present') }
    end
  end

  describe 'when overriding public_port, public address, admin_address and internal_address' do

    let :params do
      {
        :public_port      => '80',
        :public_address   => '10.10.10.10',
        :admin_address    => '10.10.10.2',
        :internal_address => '127.0.0.1'
      }
    end

    it { should contain_keystone_endpoint('RegionOne/swift').with(
      :ensure       => 'present',
      :public_url   => "http://10.10.10.10:80/v1/AUTH_%(tenant_id)s",
      :admin_url    => "http://10.10.10.2:8080/",
      :internal_url => "http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s"
    ) }

    it { should contain_keystone_endpoint('RegionOne/swift_s3').with(
      :ensure       => 'present',
      :public_url   => 'http://10.10.10.10:80',
      :admin_url    => 'http://10.10.10.2:8080',
      :internal_url => 'http://127.0.0.1:8080'
    ) }


  end


  describe 'when overriding password' do

    let :params do
      {
        :password => 'foo'
      }
    end

    it { should contain_keystone_user('swift').with(
      :ensure   => 'present',
      :password => 'foo'
    ) }

  end

  describe 'when overriding auth name' do

    let :params do
      {
        :auth_name => 'swifty'
      }
    end

    it { should contain_keystone_user('swifty') }

    it { should contain_keystone_user_role('swifty@services') }

    it { should contain_keystone_service('swifty') }

    it { should contain_keystone_endpoint('RegionOne/swifty') }

    it { should contain_keystone_service('swifty_s3') }

    it { should contain_keystone_endpoint('RegionOne/swifty_s3') }

  end

  describe 'when overriding address' do

    let :params do
      {
        :address => '192.168.0.1',
        :port => '8081'
      }
    end

    it { should contain_keystone_endpoint('RegionOne/swift').with(
      :ensure       => 'present',
      :public_url   => "http://192.168.0.1:8081/v1/AUTH_%(tenant_id)s",
      :admin_url    => "http://192.168.0.1:8081/",
      :internal_url => "http://192.168.0.1:8081/v1/AUTH_%(tenant_id)s"
    ) }

    it { should contain_keystone_endpoint('RegionOne/swift_s3').with(
      :ensure       => 'present',
      :public_url   => 'http://192.168.0.1:8081',
      :admin_url    => 'http://192.168.0.1:8081',
      :internal_url => 'http://192.168.0.1:8081'
    ) }

  end

  describe 'when overriding operator_roles' do

    let :params do
      {
        :operator_roles => 'foo',
      }
    end

    it { should contain_keystone_role('foo').with(
      :ensure       => 'present'
    ) }

  end
end
