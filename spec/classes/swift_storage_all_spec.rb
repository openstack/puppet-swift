require 'spec_helper'

describe 'swift::storage::all' do
  let :pre_condition do
    "class { 'swift': swift_hash_path_suffix => 'changeme' }
     swift::storage::filter::healthcheck { 'container': }
     swift::storage::filter::healthcheck { 'object': }
     swift::storage::filter::healthcheck { 'account': }"
  end

  let :default_params do
    {
      :devices         => '/srv/node',
      :object_port     => 6000,
      :container_port  => 6001,
      :account_port    => 6002,
      :log_facility    => 'LOG_LOCAL2',
      :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
      :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
      :log_requests    => true,
      :max_connections => 25,
      :rsync_timeout   => 900,
      :rsync_bwlimit   => 0
    }
  end

  shared_examples 'swift::storage::all' do
    describe 'when an internal network ip is not specified' do
      it_raises 'a Puppet::Error', /expects a value for parameter 'storage_local_net_ip'/
    end

    [{ :storage_local_net_ip => '127.0.0.1' },
     {
       :devices              => '/tmp/node',
       :storage_local_net_ip => '10.0.0.1',
       :object_port          => "7000",
       :container_port       => "7001",
       :account_port         => "7002",
       :object_pipeline      => ['healthcheck', 'object-server'],
       :container_pipeline   => ['healthcheck', 'container-server'],
       :account_pipeline     => ['healthcheck', 'account-server'],
       :splice               => true,
       :log_facility         => ['LOG_LOCAL2', 'LOG_LOCAL3'],
       :incoming_chmod       => '0644',
       :outgoing_chmod       => '0644',
       :log_requests         => false,
       :max_connections      => 20,
       :rsync_timeout        => 3600,
       :rsync_bwlimit        => 1024
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
           :log_facility         => param_hash[:log_facility],
           :max_connections      => param_hash[:max_connections]
          }
        end

        it { is_expected.to contain_swift__storage__server(param_hash[:account_port]).with(
          {:type => 'account',
           :config_file_path => 'account-server.conf',
           :incoming_chmod   => param_hash[:incoming_chmod],
           :outgoing_chmod   => param_hash[:outgoing_chmod],
           :pipeline         => param_hash[:account_pipeline] || ['account-server'] }.merge(storage_server_defaults)
        )}
        it { is_expected.to contain_swift__storage__server(param_hash[:object_port]).with(
          {:type => 'object',
           :config_file_path => 'object-server.conf',
           :incoming_chmod   => param_hash[:incoming_chmod],
           :outgoing_chmod   => param_hash[:outgoing_chmod],
           :pipeline         => param_hash[:object_pipeline] || ['object-server'],
           :splice           => param_hash[:splice] || false }.merge(storage_server_defaults),
           :rsync_timeout    => param_hash[:rsync_timeout],
           :rsync_bwlimit    => param_hash[:rsync_bwlimit],
        )}
        it { is_expected.to contain_swift__storage__server(param_hash[:container_port]).with(
          {:type => 'container',
           :config_file_path => 'container-server.conf',
           :incoming_chmod   => param_hash[:incoming_chmod],
           :outgoing_chmod   => param_hash[:outgoing_chmod],
           :pipeline         => param_hash[:container_pipeline] || ['container-server'] }.merge(storage_server_defaults)
        )}

        it { is_expected.to contain_class('rsync::server').with(
           :use_xinetd => platform_params[:xinetd_available],
           :address    => param_hash[:storage_local_net_ip],
           :use_chroot => 'no'
        )}
      end
    end
  end

  shared_examples 'swift::storage::all debian' do
    describe "when installed on Debian" do
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

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'Debian'
            { :xinetd_available => true }
        when 'RedHat'
          if facts[:operatingsystemmajrelease] > '8'
            { :xinetd_available => false }
          else
            { :xinetd_available => true }
          end
        end
      end

      it_configures 'swift::storage::all'

      if facts[:osfamily] == 'Debian'
        it_configures 'swift::storage::all debian'
      end
    end
  end
end
