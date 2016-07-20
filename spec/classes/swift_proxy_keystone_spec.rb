require 'spec_helper'

describe 'swift::proxy::keystone' do

  let :facts do
    {}
  end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }'
  end

  it { is_expected.to contain_concat_fragment('swift_keystone').with_content(/\[filter:keystone\]\nuse = egg:swift#keystoneauth/) }

  describe 'with defaults' do

    it { is_expected.to contain_concat_fragment('swift_keystone').with_content(/operator_roles = admin, SwiftOperator/) }
    it { is_expected.to contain_concat_fragment('swift_keystone').with_content(/reseller_prefix = AUTH_/) }

  end

  describe 'with parameter overrides' do

    let :params do
      {
        :operator_roles  => 'foo',
        :reseller_prefix => 'SWIFT_'
      }

      it { is_expected.to contain_concat_fragment('swift_keystone').with_content(/operator_roles = foo/) }
      it { is_expected.to contain_concat_fragment('swift_keystone').with_content(/reseller_prefix = SWIFT_/) }

    end

  end

end
