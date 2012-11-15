require 'spec_helper'

describe 'swift::proxy::authtoken' do

  let :facts do
    {
      :concat_basedir => '/var/lib/puppet/concat',
    }
  end

  let :pre_condition do
    '
      include concat::setup
      concat { "/etc/swift/proxy-server.conf": }
    '
  end

  let :fragment_file do
    "/var/lib/puppet/concat/_etc_swift_proxy-server.conf/fragments/22_swift_authtoken"
  end

  describe "when using default parameters" do
    it 'should build the fragment with correct parameters' do
      verify_contents(subject, fragment_file,
        [
          '[filter:authtoken]',
          'paste.filter_factory = keystone.middleware.auth_token:filter_factory',
          'signing_dir = /etc/swift',
          'auth_host = 127.0.0.1',
          'auth_port = 35357',
          'auth_protocol = http',
          'auth_uri = http://127.0.0.1:5000',
          'admin_tenant_name = services',
          'admin_user = swift',
          'admin_password = password',
          'delay_auth_decision = 1',
        ]
      )
    end
  end

  describe "when override parameters" do
    let :params do
      {
        :admin_token => 'ADMINTOKEN'
      }
    end

    it { should contain_file(fragment_file).with_content(/admin_token = ADMINTOKEN/) }
  end


end
