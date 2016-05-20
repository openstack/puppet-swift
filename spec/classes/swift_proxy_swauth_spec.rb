require 'spec_helper'

describe 'swift::proxy::swauth' do

  let :facts do
    {}
  end

  it { is_expected.to contain_package('python-swauth').with_ensure('present') }

  it { is_expected.to contain_concat_fragment('swift_proxy_swauth').with_content(/[filter:swauth]/) }
  it { is_expected.to contain_concat_fragment('swift_proxy_swauth').with_content(/use = egg:swauth#swauth/) }

  describe 'with defaults' do

    it { is_expected.to contain_concat_fragment('swift_proxy_swauth').with_content(/default_swift_cluster = local#127\.0\.0\.1/) }
    it { is_expected.to contain_concat_fragment('swift_proxy_swauth').with_content(/super_admin_key = swauthkey/) }

  end

  describe 'with overridden parameters' do

    let :params do
      {:swauth_endpoint => '10.0.0.1',
       :swauth_super_admin_key => 'foo',
       :package_ensure => 'latest' }
    end

    it { is_expected.to contain_concat_fragment('swift_proxy_swauth').with_content(/default_swift_cluster = local#10\.0\.0\.1/) }
    it { is_expected.to contain_concat_fragment('swift_proxy_swauth').with_content(/super_admin_key = foo/) }
    it { is_expected.to contain_package('python-swauth').with_ensure('latest') }

  end

end

