require 'spec_helper'

describe 'swift::test_file' do

  let :default_params do
    {:password => 'foo'}
  end

  shared_examples 'swift::test_file' do
    describe 'with defaults' do
      let :params do
        default_params
      end

      it 'should create a reasonable test file' do
        verify_contents(catalogue, '/tmp/swift_test_file.rb',
          [
            'proxy_local_net_ip="127.0.0.1"',
            "user='openstack:admin'",
            "password='foo'"
          ]
        )
      end
    end

    describe 'when overridding' do
      let :params do
        default_params.merge({
          :auth_server => '127.0.0.2',
          :tenant      => 'tenant',
          :user        => 'user',
          :password    => 'password'
        })
      end

      it 'should create a configured test file' do
        verify_contents(catalogue, '/tmp/swift_test_file.rb',
          [
            'proxy_local_net_ip="127.0.0.2"',
            "user='tenant:user'",
            "password='password'"
          ]
        )
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::test_file'
    end
  end
end
