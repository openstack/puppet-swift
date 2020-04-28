require 'spec_helper'

describe 'swift::proxy::domain_remap' do
  shared_examples 'swift::proxy::domain_remap' do
    describe "when using default parameters" do
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/use').with_value('egg:swift#domain_remap') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_facility').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_level').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_headers').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_address').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/storage_domain').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/path_root').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/reseller_prefixes').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/default_reseller_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/mangle_client_paths').with_value('<SERVICE DEFAULT>') }
    end

    describe "when overriding default parameters" do
      let :params do
        {
          :log_name                => 'newdomain_remap',
          :log_facility            => 'LOG_LOCAL3',
          :log_level               => 'WARN',
          :log_headers             => 'True',
          :log_address             => '/var/log',
          :storage_domain          => 'example.com',
          :path_root               => 'v1',
          :reseller_prefixes       => 'AUTH',
          :default_reseller_prefix => 'prefix',
          :mangle_client_paths     => 'True',
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_name').with_value('newdomain_remap') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_facility').with_value('LOG_LOCAL3') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_level').with_value('WARN') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_headers').with_value('True') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/set log_address').with_value('/var/log') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/storage_domain').with_value('example.com') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/path_root').with_value('v1') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/reseller_prefixes').with_value('AUTH') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/default_reseller_prefix').with_value('prefix') }
      it { is_expected.to contain_swift_proxy_config('filter:domain_remap/mangle_client_paths').with_value('True') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::domain_remap'
    end
  end
end
