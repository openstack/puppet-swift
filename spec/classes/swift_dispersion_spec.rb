require 'spec_helper'

describe 'swift::dispersion' do

  let :default_params do
    { :auth_url      => 'http://127.0.0.1:5000/v3/',
      :auth_user     => 'dispersion',
      :auth_tenant   => 'services',
      :auth_pass     => 'dispersion_password',
      :auth_version  => '2.0',
      :endpoint_type => 'publicURL',
      :swift_dir     => '/etc/swift',
      :coverage      => 1,
      :retries       => 5,
      :concurrency   => 25,
      :dump_json     => 'no' }
  end

  let :pre_condition do
    "class { 'swift': swift_hash_path_suffix => 'string' }"
  end

  let :params do
    {}
  end

  shared_examples 'swift::dispersion' do
    describe 'with default' do
      let (:p) { default_params.merge!(params) }

      it { should contain_file('/etc/swift/dispersion.conf').with(
        :ensure  => 'file',
        :owner   => 'swift',
        :group   => 'swift',
        :mode    => '0640',
      )}

      it 'configures dispersion.conf' do
        is_expected.to contain_swift_dispersion_config(
          'dispersion/auth_url').with_value(p[:auth_url])
        is_expected.to contain_swift_dispersion_config(
          'dispersion/auth_version').with_value(p[:auth_version])
        is_expected.to contain_swift_dispersion_config(
          'dispersion/auth_user').with_value("#{p[:auth_tenant]}:#{p[:auth_user]}")
        is_expected.to contain_swift_dispersion_config(
          'dispersion/auth_key').with_value(p[:auth_pass]).with_secret(true)
        is_expected.to contain_swift_dispersion_config(
          'dispersion/endpoint_type').with_value(p[:endpoint_type])
        is_expected.to contain_swift_dispersion_config(
          'dispersion/swift_dir').with_value(p[:swift_dir])
        is_expected.to contain_swift_dispersion_config(
          'dispersion/dispersion_coverage').with_value(p[:coverage])
        is_expected.to contain_swift_dispersion_config(
          'dispersion/retries').with_value(p[:retries])
        is_expected.to contain_swift_dispersion_config(
          'dispersion/concurrency').with_value(p[:concurrency])
        is_expected.to contain_swift_dispersion_config(
          'dispersion/dump_json').with_value(p[:dump_json])
      end

      it 'triggers swift-dispersion-populate' do
        is_expected.to contain_exec('swift-dispersion-populate').with(
          :path      => ['/bin', '/usr/bin'],
          :subscribe => 'File[/etc/swift/dispersion.conf]',
          :onlyif    => "swift -A #{p[:auth_url]} --os-username #{p[:auth_user]} --os-project-name #{p[:auth_tenant]} --os-password #{p[:auth_pass]} -V #{p[:auth_version]} stat | grep 'Account: '",
          :unless    => "swift -A #{p[:auth_url]} --os-username #{p[:auth_user]} --os-project-name #{p[:auth_tenant]} --os-password #{p[:auth_pass]} -V #{p[:auth_version]} list | grep dispersion_",
          :require => 'Package[swiftclient]'
        )
      end
    end

    describe 'with override' do
      before do
        params.merge!(
          :auth_url      => 'https://10.0.0.10:7000/auth/v8.0/',
          :auth_user     => 'foo',
          :auth_tenant   => 'bar',
          :auth_pass     => 'dummy',
          :auth_version  => '1.0',
          :endpoint_type => 'internalURL',
          :swift_dir     => '/usr/local/etc/swift',
          :coverage      => 42,
          :retries       => 51,
          :concurrency   => 4682,
          :dump_json     => 'yes'
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

      it_configures 'swift::dispersion'
    end
  end
end
