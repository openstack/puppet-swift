require 'spec_helper'

describe 'swift::storage::all' do

  let :facts do
    OSDefaults.get_facts({
      :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian',
    })
  end

  let :pre_condition do
    "class { 'swift': swift_hash_path_suffix => 'changeme' }"
  end

  let :default_params do
    {
      :devices => '/srv/node',
      :object_port => '6000',
      :container_port => '6001',
      :account_port => '6002',
      :log_facility => 'LOG_LOCAL2',
      :incoming_chmod => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
      :outgoing_chmod => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
      :log_requests => true
    }
  end

  describe 'when an internal network ip is not specified' do
    if Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0
      it_raises 'a Puppet::Error', /expects a value for parameter 'storage_local_net_ip'/
    else
      it_raises 'a Puppet::Error', /Must pass storage_local_net_ip/
    end
  end

  [{  :storage_local_net_ip => '127.0.0.1' },
   {
      :devices => '/tmp/node',
      :storage_local_net_ip => '10.0.0.1',
      :object_port => '7000',
      :container_port => '7001',
      :account_port => '7002',
      :object_pipeline => ["1", "2"],
      :container_pipeline => ["3", "4"],
      :account_pipeline => ["5", "6"],
      :allow_versions => true,
      :log_facility => ['LOG_LOCAL2', 'LOG_LOCAL3'],
      :incoming_chmod => '0644',
      :outgoing_chmod => '0644',
      :log_requests => false
    }
  ].each do |param_set|

    describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
      let :param_hash do
        default_params.merge(param_set)
      end

      let :params do
        param_set
      end

      ['object', 'container', 'account'].each do |type|
        it { is_expected.to contain_package("swift-#{type}").with_ensure('present') }
        it { is_expected.to contain_service("swift-#{type}-server").with(
          {:provider  => nil,
           :ensure    => 'running',
           :enable    => true,
           :hasstatus => true
          })}
        it { is_expected.to contain_service("swift-#{type}-replicator").with(
          {:provider  => nil,
           :ensure    => 'running',
           :enable    => true,
           :hasstatus => true
          }
        )}
        it { is_expected.to contain_file("/etc/swift/#{type}-server/").with(
          {:ensure => 'directory'}
        )}
      end

      let :storage_server_defaults do
        {:devices              => param_hash[:devices],
         :storage_local_net_ip => param_hash[:storage_local_net_ip],
         :incoming_chmod       => param_hash[:incoming_chmod],
         :outgoing_chmod       => param_hash[:outgoing_chmod],
         :log_facility         => param_hash[:log_facility]
        }
      end

      it { is_expected.to contain_swift__storage__server(param_hash[:account_port]).with(
        {:type => 'account',
         :config_file_path => 'account-server.conf',
         :incoming_chmod => param_hash[:incoming_chmod],
         :outgoing_chmod => param_hash[:outgoing_chmod],
         :pipeline => param_hash[:account_pipeline] || ['account-server'] }.merge(storage_server_defaults)
      )}
      it { is_expected.to contain_swift__storage__server(param_hash[:object_port]).with(
        {:type => 'object',
         :config_file_path => 'object-server.conf',
         :incoming_chmod => param_hash[:incoming_chmod],
         :outgoing_chmod => param_hash[:outgoing_chmod],
         :pipeline => param_hash[:object_pipeline] || ['object-server'] }.merge(storage_server_defaults)
      )}
      it { is_expected.to contain_swift__storage__server(param_hash[:container_port]).with(
        {:type => 'container',
         :config_file_path => 'container-server.conf',
         :incoming_chmod => param_hash[:incoming_chmod],
         :outgoing_chmod => param_hash[:outgoing_chmod],
         :pipeline => param_hash[:container_pipeline] || ['container-server'],
         :allow_versions => param_hash[:allow_versions] || false }.merge(storage_server_defaults)
      )}

      it { is_expected.to contain_class('rsync::server').with(
        {:use_xinetd => true,
         :address    => param_hash[:storage_local_net_ip],
         :use_chroot => 'no'
        }
      )}

    end
  end

  describe "when specifying statsd enabled" do
    let :params do
      {
        :storage_local_net_ip           => '127.0.0.1',
        :statsd_enabled                 => true,
        :log_statsd_host                => 'statsd.example.com',
        :log_statsd_port                => '9999',
        :log_statsd_default_sample_rate => '2.0',
        :log_statsd_sample_rate_factor  => '1.5',
        :log_statsd_metric_prefix       => 'foo',
      }
    end

    {'object' => '6000', 'container' => '6001', 'account' => '6002'}.each do |type,name|
      it "should configure statsd in the #{type} config file" do
       is_expected.to contain_concat_fragment("swift-#{type}-#{name}").with_content(
         /log_statsd_host = statsd.example.com/
       ).with_content(
         /log_statsd_port = 9999/
       ).with_content(
         /log_statsd_default_sample_rate = 2.0/
       ).with_content(
         /log_statsd_sample_rate_factor = 1.5/
       ).with_content(
         /log_statsd_metric_prefix = foo/
       )
      end
    end
  end

  describe "when installed on Debian" do
    let :facts do
      OSDefaults.get_facts({
        :operatingsystem => 'Debian',
        :osfamily        => 'Debian',
      })
    end

    [{  :storage_local_net_ip => '127.0.0.1' },
      {
      :devices => '/tmp/node',
      :storage_local_net_ip => '10.0.0.1',
      :object_port => '7000',
      :container_port => '7001',
      :account_port => '7002'
    }
    ].each do |param_set|
      describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
        let :param_hash do
          default_params.merge(param_set)
        end

        let :params do
          param_set
        end
        ['object', 'container', 'account'].each do |type|
          it { is_expected.to contain_package("swift-#{type}").with_ensure('present') }
          it { is_expected.to contain_service("swift-#{type}-server").with(
            {:provider  => nil,
              :ensure    => 'running',
              :enable    => true,
              :hasstatus => true
            })}
            it { is_expected.to contain_service("swift-#{type}-replicator").with(
              {:provider  => nil,
                :ensure    => 'running',
                :enable    => true,
                :hasstatus => true
              }
            )}
        end
      end
    end
  end
end
