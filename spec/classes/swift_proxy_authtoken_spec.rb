require 'spec_helper'

describe 'swift::proxy::authtoken' do

  let :facts do
    {}
  end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }'
  end

  describe 'when using the default signing directory' do
    let :file_defaults do
      {
        :mode    => '0700',
        :owner   => 'swift',
        :group   => 'swift',
      }
    end
    it {is_expected.to contain_file('/var/cache/swift').with(
      {:ensure                  => 'directory',
       :selinux_ignore_defaults => true}.merge(file_defaults)
    )}
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_authtoken').with_content('
[filter:authtoken]
log_name = swift
signing_dir = /var/cache/swift
paste.filter_factory = keystonemiddleware.auth_token:filter_factory

auth_uri = http://127.0.0.1:5000
auth_url = http://127.0.0.1:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = services
username = swift
password = password

delay_auth_decision = 1

cache = swift.cache
include_service_catalog = false
')
    end
  end


  describe "when overriding parameters" do
    let :params do
      {
        :admin_tenant_name   => 'admin',
        :admin_user          => 'swiftuser',
        :admin_password      => 'swiftpassword',
        :cache               => 'foo',
        :delay_auth_decision => '0',
        :signing_dir         => '/home/swift/keystone-signing'
      }
    end

    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_authtoken').with_content('
[filter:authtoken]
log_name = swift
signing_dir = /home/swift/keystone-signing
paste.filter_factory = keystonemiddleware.auth_token:filter_factory

auth_uri = http://127.0.0.1:5000
auth_url = http://127.0.0.1:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = admin
username = swiftuser
password = swiftpassword

delay_auth_decision = 0

cache = foo
include_service_catalog = false
')
    end
  end

  describe 'when overriding auth_uri' do
    let :params do
      { :auth_uri => 'http://public.host/keystone/main' }
    end

    it { is_expected.to contain_concat_fragment('swift_authtoken').with_content(/auth_uri = http:\/\/public\.host\/keystone\/main/)}
  end

  describe "when identity_uri is set" do
    let :params do
      {
        :identity_uri => 'https://foo.bar:35357/'
      }
    end

    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_authtoken').with_content(/auth_url = https:\/\/foo\.bar:35357\//)
    end
  end

  describe "when both auth_uri and identity_uri are set" do
    let :params do
      {
        :auth_uri => 'https://foo.bar:5000/v2.0/',
        :identity_uri => 'https://foo.bar:35357/'
      }
    end

    it 'should build the fragment with correct parameters' do
      is_expected.to contain_concat_fragment('swift_authtoken').with_content(/auth_uri = https:\/\/foo\.bar:5000\/v2\.0\//)
      is_expected.to contain_concat_fragment('swift_authtoken').with_content(/auth_url = https:\/\/foo\.bar:35357\//)
    end
  end

end
