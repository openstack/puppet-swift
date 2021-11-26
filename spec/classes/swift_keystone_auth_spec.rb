#
# Unit tests for swift::keystone::auth
#

require 'spec_helper'

describe 'swift::keystone::auth' do
  shared_examples_for 'swift::keystone::auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'swift_password' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('swift').with(
        :configure_user      => true,
        :configure_user_role => true,
        :configure_endpoint  => true,
        :service_name        => 'swift',
        :service_type        => 'object-store',
        :service_description => 'Openstack Object-Store Service',
        :region              => 'RegionOne',
        :auth_name           => 'swift',
        :password            => 'swift_password',
        :email               => 'swift@localhost',
        :tenant              => 'services',
        :public_url          => 'http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s',
        :internal_url        => 'http://127.0.0.1:8080/v1/AUTH_%(tenant_id)s',
        :admin_url           => 'http://127.0.0.1:8080',
      ) }

      it { is_expected.to contain_keystone__resource__service_identity('swift_s3').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => true,
        :service_name        => 'swift_s3',
        :service_type        => 's3',
        :service_description => 'Openstack S3 Service',
        :region              => 'RegionOne',
        :public_url          => 'http://127.0.0.1:8080',
        :internal_url        => 'http://127.0.0.1:8080',
        :admin_url           => 'http://127.0.0.1:8080',
      ) }

      it { is_expected.to contain_keystone_role('admin').with(
        :ensure => 'present'
      ) }
      it { is_expected.to contain_keystone_role('SwiftOperator').with(
        :ensure => 'present'
      ) }
    end

    context 'when overriding parameters' do
      let :params do
        { :password               => 'swift_password',
          :auth_name              => 'alt_swift',
          :email                  => 'alt_swift@alt_localhost',
          :tenant                 => 'alt_service',
          :configure_endpoint     => false,
          :configure_s3_endpoint  => false,
          :configure_user         => false,
          :configure_user_role    => false,
          :service_description    => 'Alternative Openstack Object-Store Service',
          :service_name           => 'alt_service',
          :service_type           => 'alt_object-store',
          :service_description_s3 => 'Alternative Openstack S3 Service',
          :service_name_s3        => 'alt_service_s3',
          :service_type_s3        => 'alt_s3',
          :region                 => 'RegionTwo',
          :public_url             => 'https://10.10.10.10:80',
          :internal_url           => 'http://10.10.10.11:81',
          :admin_url              => 'http://10.10.10.12:81',
          :operator_roles         => ['role1', 'role2']
        }
      end

      it { is_expected.to contain_keystone__resource__service_identity('swift').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => false,
        :service_name        => 'alt_service',
        :service_type        => 'alt_object-store',
        :service_description => 'Alternative Openstack Object-Store Service',
        :region              => 'RegionTwo',
        :auth_name           => 'alt_swift',
        :password            => 'swift_password',
        :email               => 'alt_swift@alt_localhost',
        :tenant              => 'alt_service',
        :public_url          => 'https://10.10.10.10:80',
        :internal_url        => 'http://10.10.10.11:81',
        :admin_url           => 'http://10.10.10.12:81',
      ) }
      it { is_expected.to contain_keystone__resource__service_identity('swift_s3').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => false,
        :service_name        => 'alt_service_s3',
        :service_type        => 'alt_s3',
        :service_description => 'Alternative Openstack S3 Service',
        :region              => 'RegionTwo',
        :public_url          => 'http://127.0.0.1:8080',
        :internal_url        => 'http://127.0.0.1:8080',
        :admin_url           => 'http://127.0.0.1:8080',
      ) }

      it { is_expected.to contain_keystone_role('role1').with(
        :ensure => 'present'
      ) }
      it { is_expected.to contain_keystone_role('role2').with(
        :ensure => 'present'
      ) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'swift::keystone::auth'
    end
  end
end
