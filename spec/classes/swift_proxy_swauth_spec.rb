require 'spec_helper'

describe 'swift::proxy::swauth' do

  let :facts do
    {}
  end

  it { is_expected.to contain_package('python-swauth').with_ensure('present') }

  it { is_expected.to contain_swift_proxy_config('filter:swauth/use').with_value('egg:swauth#swauth') }

  describe 'with defaults' do

    it { is_expected.to contain_swift_proxy_config('filter:swauth/default_swift_cluster').with_value('local#127.0.0.1') }
    it { is_expected.to contain_swift_proxy_config('filter:swauth/super_admin_key').with_value('swauthkey') }

  end

  describe 'with overridden parameters' do

    let :params do
      {:swauth_endpoint => '10.0.0.1',
       :swauth_super_admin_key => 'foo',
       :package_ensure => 'latest' }
    end

    it { is_expected.to contain_swift_proxy_config('filter:swauth/default_swift_cluster').with_value('local#10.0.0.1') }
    it { is_expected.to contain_swift_proxy_config('filter:swauth/super_admin_key').with_value('foo') }

    it { is_expected.to contain_package('python-swauth').with_ensure('latest') }

  end

end

