require 'spec_helper'

describe 'swift::proxy::cname_lookup' do
  shared_examples 'swift::proxy::cname_lookup' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_facility').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_level').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_headers').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_address').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/storage_domain').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/lookup_depth').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/nameservers').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_package('python-dnspython').with(
        :name   => platform_params[:dnspython_package_name],
        :ensure => 'present',
        :tag    => ['openstack','swift-support-package'],
      ) }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :log_name       => 'newcname_lookup',
          :log_facility   => 'LOG_LOCAL3',
          :log_level      => 'WARN',
          :log_headers    => 'True',
          :log_address    => '/var/log',
          :storage_domain => 'example.com',
          :lookup_depth   => '2',
          :nameservers    => '8.8.8.8',
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_name').with_value('newcname_lookup') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_facility').with_value('LOG_LOCAL3') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_level').with_value('WARN') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_headers').with_value('True') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/set log_address').with_value('/var/log') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/storage_domain').with_value('example.com') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/lookup_depth').with_value('2') }
      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/nameservers').with_value('8.8.8.8') }
    end

    describe "when nameservers parameter accept an array" do
      let :params do
        {
          :nameservers => ['8.8.8.8', '8.8.4.4'],
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:cname_lookup/nameservers').with_value('8.8.8.8,8.8.4.4') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :dnspython_package_name => 'python3-dnspython' }
        when 'RedHat'
          { :dnspython_package_name => 'python3-dnspython' }
        end
      end

      it_configures 'swift::proxy::cname_lookup'
    end
  end
end
