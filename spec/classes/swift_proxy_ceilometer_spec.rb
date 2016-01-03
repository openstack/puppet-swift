require 'spec_helper'

describe 'swift::proxy::ceilometer' do

  let :facts do
    {
      :osfamily => 'Debian'
    }
  end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }
     class { "swift":
        swift_hash_suffix => "dummy"
     }'
  end

  let :fragment_file do
    "/var/lib/puppet/concat/_etc_swift_proxy-server.conf/fragments/33_swift_ceilometer"
  end

  describe "when using default parameters" do
    it { is_expected.to contain_file(fragment_file).with_content(/[filter:ceilometer]/) }
    it { is_expected.to contain_file(fragment_file).with_content(/paste.filter_factory = ceilometermiddleware.swift:filter_factory/) }
    it { is_expected.to contain_file(fragment_file).with_content(/url = rabbit:\/\/guest:guest@127.0.0.1:5672\//) }
    if Puppet.version.to_f < 4.0
      it { is_expected.to contain_concat__fragment('swift_ceilometer').with_require('Class[Ceilometer]')}
    else
      it { is_expected.to contain_concat__fragment('swift_ceilometer').with_require('Class[Ceilometer]')}
    end
    it { is_expected.to contain_user('swift').with_groups('ceilometer') }
    it { is_expected.to contain_file('/var/log/ceilometer/swift-proxy-server.log').with(:owner => 'swift', :group => 'swift', :mode => '0664') }
  end

  describe "when overriding default parameters" do
    let :params do
      { :group               => 'www-data',
        :rabbit_user         => 'user_1',
        :rabbit_password     => 'user_1_passw',
        :rabbit_host         => '1.1.1.1',
        :rabbit_port         => '5673',
        :rabbit_virtual_host => 'rabbit',
        :driver              => 'messagingv2',
        :topic               => 'notifications',
        :control_exchange    => 'swift',
      }
    end

    context 'with single rabbit host' do
      it { is_expected.to contain_user('swift').with_groups('www-data') }
      it { is_expected.to contain_file(fragment_file).with_content(/[filter:ceilometer]/) }
      it { is_expected.to contain_file(fragment_file).with_content(/paste.filter_factory = ceilometermiddleware.swift:filter_factory/) }
      it { is_expected.to contain_file(fragment_file).with_content(/url = rabbit:\/\/user_1:user_1_passw@1.1.1.1:5673\/rabbit/) }
      it { is_expected.to contain_file(fragment_file).with_content(/driver = messagingv2/) }
      it { is_expected.to contain_file(fragment_file).with_content(/topic = notifications/) }
      it { is_expected.to contain_file(fragment_file).with_content(/control_exchange = swift/) }
    end

    context 'with multiple rabbit hosts' do
      before do
        params.merge!({ :rabbit_hosts => ['127.0.0.1:5672', '127.0.0.2:5672'] })
      end

      it { is_expected.to contain_user('swift').with_groups('www-data') }
      it { is_expected.to contain_file(fragment_file).with_content(/[filter:ceilometer]/) }
      it { is_expected.to contain_file(fragment_file).with_content(/paste.filter_factory = ceilometermiddleware.swift:filter_factory/) }
      it { is_expected.to contain_file(fragment_file).with_content(/url = rabbit:\/\/user_1:user_1_passw@127.0.0.1:5672,127.0.0.2:5672\/rabbit/) }
      it { is_expected.to contain_file(fragment_file).with_content(/driver = messagingv2/) }
      it { is_expected.to contain_file(fragment_file).with_content(/topic = notifications/) }
      it { is_expected.to contain_file(fragment_file).with_content(/control_exchange = swift/) }
    end

  end

end
