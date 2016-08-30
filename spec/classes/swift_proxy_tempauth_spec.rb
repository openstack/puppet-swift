require 'spec_helper'

describe 'swift::proxy::tempauth' do
  let :default_params do {
    'account_user_list' => [
      {
        'user'    => 'admin',
        'account' => 'admin',
        'key'     => 'admin',
        'groups'  => [ 'admin', 'reseller_admin' ],
      },
    ]
  }
  end

  let :params do default_params end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }'
  end

  it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(/\[filter:tempauth\]\nuse = egg:swift#tempauth/) }
  it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(/user_admin_admin = admin \.admin \.reseller_admin/) }

  it { is_expected.to_not contain_concat_fragment('swift-proxy-tempauth').with_content(/reseller_prefix/) }
  it { is_expected.to_not contain_concat_fragment('swift-proxy-tempauth').with_content(/token_life/) }
  it { is_expected.to_not contain_concat_fragment('swift-proxy-tempauth').with_content(/auth_prefix/) }
  it { is_expected.to_not contain_concat_fragment('swift-proxy-tempauth').with_content(/storage_url_scheme/) }

  context 'declaring two users' do
    let :params do {
      'account_user_list' => [
        {
          'user'    => 'admin',
          'account' => 'admin',
          'key'     => 'admin',
          'groups'  => [ 'admin', 'reseller_admin' ],
        },
        {
          'user'    => 'foo',
          'account' => 'bar',
          'key'     => 'pass',
          'groups'  => [ 'reseller_admin' ],
        },
      ]
    } end
    it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(
      /user_admin_admin = admin \.admin \.reseller_admin/
    ) }
    it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(
      /user_bar_foo = pass \.reseller_admin/
    ) }
  end

  context 'when group is empty' do
    let :params do {
      'account_user_list' => [
        {
          'user'    => 'admin',
          'account' => 'admin',
          'key'     => 'admin',
          'groups'  => [],
        },
      ]
    } end
    it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(/user_admin_admin = admin $/) }
  end


  context 'when undef params are set' do
    let :params do {
      'reseller_prefix' => 'auth',
      'token_life'      => 81600,
      'auth_prefix'     => '/auth/',
      'storage_url_scheme' => 'http',
    }.merge(default_params)
    end

    it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(/reseller_prefix = AUTH/) }
    it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(/token_life = 81600/) }
    it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(/auth_prefix = \/auth\//) }
    it { is_expected.to contain_concat_fragment('swift-proxy-tempauth').with_content(/storage_url_scheme = http/) }

    describe "invalid params" do
      ['account_user_list', 'token_life', 'auth_prefix', 'storage_url_scheme'].each do |param|
        let :params do { param => 'foobar' }.merge(default_params) end
        it "invalid #{param} should fail" do
          expect { catalogue }.to raise_error(Puppet::Error)
        end
      end
    end
  end
end
