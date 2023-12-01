require 'spec_helper'

describe 'swift::storage::server' do
  let :pre_condition do
    "class { 'swift': swift_hash_path_suffix => 'foo' }
     class { 'swift::storage': storage_local_net_ip => '10.0.0.1' }
    "
  end

  shared_examples 'swift::storage::server' do
    describe 'with an invalid title' do
      let :params do
        {
          :storage_local_net_ip => '127.0.0.1',
          :type                 => 'object'
        }
      end

      let :title do
        'foo'
      end

      it { should raise_error(Puppet::Error) }
    end

    describe 'for type account' do
      let :title do
        '6002'
      end

      let :req_params do
        {
          :storage_local_net_ip => '10.0.0.1',
          :type                 => 'account'
        }
      end

      let :params do
        req_params
      end

      it { is_expected.to contain_package('swift-account').with_ensure('present') }
      it { is_expected.to contain_service('swift-account-server').with(
        :ensure     => 'running',
        :enable     => true,
        :hasstatus  => true,
      )}

      it { is_expected.to contain_rsync__server__module('account').with(
        :path            => '/srv/node',
        :lock_file       => '/var/lock/account.lock',
        :uid             => 'swift',
        :gid             => 'swift',
        :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
        :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
        :max_connections => 25,
        :read_only       => false,
      )}

      it {
        is_expected.to contain_swift_account_config('DEFAULT/devices').with_value('/srv/node')
        is_expected.to contain_swift_account_config('DEFAULT/bind_ip').with_value('10.0.0.1')
        is_expected.to contain_swift_account_config('DEFAULT/bind_port').with_value('6002')
        is_expected.to contain_swift_account_config('DEFAULT/mount_check').with_value(true)
        is_expected.to contain_swift_account_config('DEFAULT/disable_fallocate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('DEFAULT/fallocate_reserve').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('DEFAULT/user').with_value('swift')
        is_expected.to contain_swift_account_config('DEFAULT/workers').with_value(4)
        is_expected.to contain_swift_account_config('DEFAULT/log_name').with_value('account-server')
        is_expected.to contain_swift_account_config('DEFAULT/log_facility').with_value('LOG_LOCAL2')
        is_expected.to contain_swift_account_config('DEFAULT/log_level').with_value('INFO')
        is_expected.to contain_swift_account_config('DEFAULT/log_address').with_value('/dev/log')
        is_expected.to contain_swift_account_config('DEFAULT/log_udp_host').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('DEFAULT/log_udp_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('pipeline:main/pipeline').with_value('account-server')
        is_expected.to contain_swift_account_config('app:account-server/use').with_value('egg:swift#account')
        is_expected.to contain_swift_account_config('app:account-server/set log_name').with_value('account-server')
        is_expected.to contain_swift_account_config('app:account-server/set log_facility').with_value('LOG_LOCAL2')
        is_expected.to contain_swift_account_config('app:account-server/set log_level').with_value('INFO')
        is_expected.to contain_swift_account_config('app:account-server/set log_requests').with_value(true)
        is_expected.to contain_swift_account_config('app:account-server/set log_address').with_value('/dev/log')
        is_expected.to contain_swift_account_config('app:account-server/fallocate_reserve').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_swift_account_config('DEFAULT/log_statsd_host').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('DEFAULT/log_statsd_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('DEFAULT/log_statsd_default_sample_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('DEFAULT/log_statsd_sample_rate_factor').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('DEFAULT/log_statsd_metric_prefix').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_swift_account_config('account-auditor/').with_ensure('present')
        is_expected.to contain_swift_account_config('account-replicator/').with_ensure('present')
        is_expected.to contain_swift_account_config('account-replicator/rsync_module').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('account-replicator/concurrency').with_value(1)
        is_expected.to contain_swift_account_config('account-replicator/interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_account_config('account-reaper/').with_ensure('present')
        is_expected.to contain_swift_account_config('account-reaper/concurrency').with_value(1)
      }

      context 'with customized pipeline' do
        let :pre_condition do
          "class { 'swift': swift_hash_path_suffix => 'foo' }
           class { 'swift::storage': storage_local_net_ip => '10.0.0.1' }
           swift::storage::filter::healthcheck { 'account': }
           swift::storage::filter::recon { 'account': }
          "
        end

        before do
          params.merge!({
            :pipeline => ['healthcheck', 'recon', 'account-server']
          })
        end

        it {
          is_expected.to contain_swift_account_config('pipeline:main/pipeline').with_value('healthcheck recon account-server')
        }
      end

      context 'with rsync_module_per_device' do
        before do
          params.merge!({
            :rsync_module_per_device => true,
            :device_names            => ['sda', 'sdb'],
          })
        end

        it { is_expected.to contain_rsync__server__module('account_sda').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/account_sda.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :max_connections => 25,
          :read_only       => false,
        )}
        it { is_expected.to contain_rsync__server__module('account_sdb').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/account_sdb.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :max_connections => 25,
          :read_only       => false,
        )}
        it { is_expected.to contain_swift_account_config('account-replicator/rsync_module').with_value('{replication_ip}::account_{device}') }
      end

      context 'with rsync parameters' do
        before do
          params.merge!({
            :max_connections => 100,
            :hosts_allow     => '192.0.2.0/25',
            :hosts_deny      => '192.0.2.128/25',
            :incoming_chmod  => '0644',
            :outgoing_chmod  => '0644',
          })
        end

        it { is_expected.to contain_rsync__server__module('account').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/account.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :hosts_allow     => '192.0.2.0/25',
          :hosts_deny      => '192.0.2.128/25',
          :incoming_chmod  => '0644',
          :outgoing_chmod  => '0644',
          :max_connections => 100,
          :read_only       => false,
        )}
      end
    end

    describe 'for type container' do
      let :title do
        '6001'
      end

      let :req_params do
        {
          :storage_local_net_ip => '10.0.0.1',
          :type                 => 'container'
        }
      end

      let :params do
        req_params
      end

      it { is_expected.to contain_package('swift-container').with_ensure('present') }
      it { is_expected.to contain_service('swift-container-server').with(
        :ensure     => 'running',
        :enable     => true,
        :hasstatus  => true,
      )}

      it { is_expected.to contain_rsync__server__module('container').with(
        :path            => '/srv/node',
        :lock_file       => '/var/lock/container.lock',
        :uid             => 'swift',
        :gid             => 'swift',
        :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
        :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
        :max_connections => 25,
        :read_only       => false,
      )}

      it {
        is_expected.to contain_swift_container_config('DEFAULT/devices').with_value('/srv/node')
        is_expected.to contain_swift_container_config('DEFAULT/bind_ip').with_value('10.0.0.1')
        is_expected.to contain_swift_container_config('DEFAULT/bind_port').with_value('6001')
        is_expected.to contain_swift_container_config('DEFAULT/mount_check').with_value(true)
        is_expected.to contain_swift_container_config('DEFAULT/disable_fallocate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('DEFAULT/fallocate_reserve').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('DEFAULT/user').with_value('swift')
        is_expected.to contain_swift_container_config('DEFAULT/workers').with_value(4)
        is_expected.to contain_swift_container_config('DEFAULT/log_name').with_value('container-server')
        is_expected.to contain_swift_container_config('DEFAULT/log_facility').with_value('LOG_LOCAL2')
        is_expected.to contain_swift_container_config('DEFAULT/log_level').with_value('INFO')
        is_expected.to contain_swift_container_config('DEFAULT/log_address').with_value('/dev/log')
        is_expected.to contain_swift_container_config('DEFAULT/log_udp_host').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('DEFAULT/log_udp_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('pipeline:main/pipeline').with_value('container-server')
        is_expected.to contain_swift_container_config('app:container-server/use').with_value('egg:swift#container')
        is_expected.to contain_swift_container_config('app:container-server/set log_name').with_value('container-server')
        is_expected.to contain_swift_container_config('app:container-server/set log_facility').with_value('LOG_LOCAL2')
        is_expected.to contain_swift_container_config('app:container-server/set log_level').with_value('INFO')
        is_expected.to contain_swift_container_config('app:container-server/set log_requests').with_value(true)
        is_expected.to contain_swift_container_config('app:container-server/set log_address').with_value('/dev/log')
        is_expected.to contain_swift_container_config('app:container-server/fallocate_reserve').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_swift_container_config('DEFAULT/log_statsd_host').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('DEFAULT/log_statsd_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('DEFAULT/log_statsd_default_sample_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('DEFAULT/log_statsd_sample_rate_factor').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('DEFAULT/log_statsd_metric_prefix').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_swift_container_config('DEFAULT/allowed_sync_hosts').with_value('127.0.0.1')
        is_expected.to contain_swift_container_config('container-auditor/').with_ensure('present')
        is_expected.to contain_swift_container_config('container-replicator/').with_ensure('present')
        is_expected.to contain_swift_container_config('container-replicator/rsync_module').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('container-replicator/concurrency').with_value(1)
        is_expected.to contain_swift_container_config('container-replicator/interval').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('container-updater/').with_ensure('present')
        is_expected.to contain_swift_container_config('container-updater/concurrency').with_value(1)
        is_expected.to contain_swift_container_config('container-sharder/').with_ensure('present')
        is_expected.to contain_swift_container_config('container-sharder/auto_shard').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('container-sharder/concurrency').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_container_config('container-sharder/interval').with_value('<SERVICE DEFAULT>')
      }

      context 'with customized pipeline' do
        let :pre_condition do
          "class { 'swift': swift_hash_path_suffix => 'foo' }
           class { 'swift::storage': storage_local_net_ip => '10.0.0.1' }
           swift::storage::filter::healthcheck { 'container': }
           swift::storage::filter::recon { 'container': }
          "
        end

        before do
          params.merge!({
            :pipeline => ['healthcheck', 'recon', 'container-server']
          })
        end

        it {
          is_expected.to contain_swift_container_config('pipeline:main/pipeline').with_value('healthcheck recon container-server')
        }
      end

      context 'with rsync_module_per_device' do
        before do
          params.merge!({
            :rsync_module_per_device => true,
            :device_names            => ['sda', 'sdb'],
          })
        end

        it { is_expected.to contain_rsync__server__module('container_sda').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/container_sda.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :max_connections => 25,
          :read_only       => false,
        )}
        it { is_expected.to contain_rsync__server__module('container_sdb').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/container_sdb.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :max_connections => 25,
          :read_only       => false,
        )}
        it { is_expected.to contain_swift_container_config('container-replicator/rsync_module').with_value('{replication_ip}::container_{device}') }
      end

      context 'with rsync parameters' do
        before do
          params.merge!({
            :max_connections => 100,
            :hosts_allow     => '192.0.2.0/25',
            :hosts_deny      => '192.0.2.128/25',
            :incoming_chmod  => '0644',
            :outgoing_chmod  => '0644',
          })
        end

        it { is_expected.to contain_rsync__server__module('container').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/container.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :hosts_allow     => '192.0.2.0/25',
          :hosts_deny      => '192.0.2.128/25',
          :incoming_chmod  => '0644',
          :outgoing_chmod  => '0644',
          :max_connections => 100,
          :read_only       => false,
        )}
      end
    end

    describe 'for type object' do
      let :title do
        '6000'
      end

      let :req_params do
        {
          :storage_local_net_ip => '10.0.0.1',
          :type                 => 'object'
        }
      end

      let :params do
        req_params
      end

      it { is_expected.to contain_package('swift-object').with_ensure('present') }
      it { is_expected.to contain_service('swift-object-server').with(
        :ensure     => 'running',
        :enable     => true,
        :hasstatus  => true,
      )}

      it { is_expected.to contain_rsync__server__module('object').with(
        :path            => '/srv/node',
        :lock_file       => '/var/lock/object.lock',
        :uid             => 'swift',
        :gid             => 'swift',
        :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
        :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
        :max_connections => 25,
        :read_only       => false,
      )}

      it {
        is_expected.to contain_swift_object_config('DEFAULT/devices').with_value('/srv/node')
        is_expected.to contain_swift_object_config('DEFAULT/bind_ip').with_value('10.0.0.1')
        is_expected.to contain_swift_object_config('DEFAULT/bind_port').with_value('6000')
        is_expected.to contain_swift_object_config('DEFAULT/mount_check').with_value(true)
        is_expected.to contain_swift_object_config('DEFAULT/disable_fallocate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/fallocate_reserve').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/user').with_value('swift')
        is_expected.to contain_swift_object_config('DEFAULT/workers').with_value(4)
        is_expected.to contain_swift_object_config('DEFAULT/log_name').with_value('object-server')
        is_expected.to contain_swift_object_config('DEFAULT/log_facility').with_value('LOG_LOCAL2')
        is_expected.to contain_swift_object_config('DEFAULT/log_level').with_value('INFO')
        is_expected.to contain_swift_object_config('DEFAULT/log_address').with_value('/dev/log')
        is_expected.to contain_swift_object_config('DEFAULT/log_udp_host').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/log_udp_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('pipeline:main/pipeline').with_value('object-server')
        is_expected.to contain_swift_object_config('app:object-server/use').with_value('egg:swift#object')
        is_expected.to contain_swift_object_config('app:object-server/set log_name').with_value('object-server')
        is_expected.to contain_swift_object_config('app:object-server/set log_facility').with_value('LOG_LOCAL2')
        is_expected.to contain_swift_object_config('app:object-server/set log_level').with_value('INFO')
        is_expected.to contain_swift_object_config('app:object-server/set log_requests').with_value(true)
        is_expected.to contain_swift_object_config('app:object-server/set log_address').with_value('/dev/log')
        is_expected.to contain_swift_object_config('app:object-server/fallocate_reserve').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_swift_object_config('DEFAULT/log_statsd_host').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/log_statsd_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/log_statsd_default_sample_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/log_statsd_sample_rate_factor').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/log_statsd_metric_prefix').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_swift_object_config('DEFAULT/servers_per_port').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/network_chunk_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/disk_chunk_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('DEFAULT/client_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('app:object-server/splice').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('app:object-server/mb_per_sync').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('object-auditor/').with_ensure('present')
        is_expected.to contain_swift_object_config('object-auditor/disk_chunk_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('object-replicator/').with_ensure('present')
        is_expected.to contain_swift_object_config('object-replicator/rsync_module').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('object-replicator/rsync_module').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('object-replicator/concurrency').with_value(1)
        is_expected.to contain_swift_object_config('object-replicator/rsync_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('object-replicator/rsync_bwlimit').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_swift_object_config('object-updater/').with_ensure('present')
        is_expected.to contain_swift_object_config('object-updater/concurrency').with_value(1)
        is_expected.to contain_swift_object_config('object-reconstructor/').with_ensure('present')
      }

      context 'with customized pipeline' do
        let :pre_condition do
          "class { 'swift': swift_hash_path_suffix => 'foo' }
           class { 'swift::storage': storage_local_net_ip => '10.0.0.1' }
           swift::storage::filter::healthcheck { 'object': }
           swift::storage::filter::recon { 'object': }
          "
        end

        before do
          params.merge!({
            :pipeline => ['healthcheck', 'recon', 'object-server']
          })
        end

        it {
          is_expected.to contain_swift_object_config('pipeline:main/pipeline').with_value('healthcheck recon object-server')
        }
      end

      context 'with rsync_module_per_device' do
        before do
          params.merge!({
            :rsync_module_per_device => true,
            :device_names            => ['sda', 'sdb'],
          })
        end

        it { is_expected.to contain_rsync__server__module('object_sda').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/object_sda.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :max_connections => 25,
          :read_only       => false,
        )}
        it { is_expected.to contain_rsync__server__module('object_sdb').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/object_sdb.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :incoming_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :outgoing_chmod  => 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
          :max_connections => 25,
          :read_only       => false,
        )}
        it { is_expected.to contain_swift_object_config('object-replicator/rsync_module').with_value('{replication_ip}::object_{device}') }
      end

      context 'with rsync parameters' do
        before do
          params.merge!({
            :max_connections => 100,
            :hosts_allow     => '192.0.2.0/25',
            :hosts_deny      => '192.0.2.128/25',
            :incoming_chmod  => '0644',
            :outgoing_chmod  => '0644',
          })
        end

        it { is_expected.to contain_rsync__server__module('object').with(
          :path            => '/srv/node',
          :lock_file       => '/var/lock/object.lock',
          :uid             => 'swift',
          :gid             => 'swift',
          :hosts_allow     => '192.0.2.0/25',
          :hosts_deny      => '192.0.2.128/25',
          :incoming_chmod  => '0644',
          :outgoing_chmod  => '0644',
          :max_connections => 100,
          :read_only       => false,
        )}
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :os_workers => 4
        }))
      end

      it_configures 'swift::storage::server'
    end
  end
end
