require 'spec_helper'

describe 'swift::proxy::ceilometer' do

  let :facts do
    OSDefaults.get_facts({ :osfamily => 'Debian' })
  end

  let :pre_condition do
    'concat { "/etc/swift/proxy-server.conf": }
     class { "swift":
        swift_hash_path_suffix => "dummy"
     }'
  end

  describe "when using default parameters" do
    it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/[filter:ceilometer]/) }
    it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/paste.filter_factory = ceilometermiddleware.swift:filter_factory/) }
    it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/url = rabbit:\/\/guest:guest@127.0.0.1:5672\//) }
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
        :nonblocking_notify  => true,
	:ignore_projects     => 'services',
        :auth_uri            => 'http://127.0.0.1:5000',
        :auth_url            => 'http://127.0.0.1:35357',
        :auth_type           => 'password',
        :project_domain_name => 'Default',
        :user_domain_name    => 'Default',
        :project_name        => 'services',
        :username            => 'swift',
        :password            => 'password',
      }
    end

    context 'with single rabbit host' do
      it { is_expected.to contain_user('swift').with_groups('www-data') }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/[filter:ceilometer]/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/paste.filter_factory = ceilometermiddleware.swift:filter_factory/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/url = rabbit:\/\/user_1:user_1_passw@1.1.1.1:5673\/rabbit/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/driver = messagingv2/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/topic = notifications/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/control_exchange = swift/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/nonblocking_notify = true/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/ignore_projects = services/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/auth_uri = http:\/\/127.0.0.1:5000/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/auth_url = http:\/\/127.0.0.1:35357/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/auth_type = password/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/project_domain_name = Default/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/user_domain_name = Default/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/project_name = services/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/username = swift/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/password = password/) }
    end

    context 'with multiple rabbit hosts' do
      before do
        params.merge!({ :rabbit_hosts => ['127.0.0.1:5672', '127.0.0.2:5672'] })
      end

      it { is_expected.to contain_user('swift').with_groups('www-data') }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/[filter:ceilometer]/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/paste.filter_factory = ceilometermiddleware.swift:filter_factory/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/url = rabbit:\/\/user_1:user_1_passw@127.0.0.1:5672,user_1:user_1_passw@127.0.0.2:5672\/rabbit/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/driver = messagingv2/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/topic = notifications/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/control_exchange = swift/) }
      it { is_expected.to contain_concat_fragment('swift_ceilometer').with_content(/nonblocking_notify = true/) }
    end

  end

end
