require 'spec_helper'

describe 'swift::internal_client' do
  shared_examples 'swift::internal_client' do

    let :pre_condition do
      "class { memcached: }
       class { swift: swift_hash_path_suffix => string }
       include swift::internal_client::catch_errors
       include swift::internal_client::proxy_logging
       include swift::internal_client::cache"
    end

    context 'with defaults' do
      it { is_expected.to contain_file('/etc/swift/internal-client.conf').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'swift',
        :mode   => '0640',
      )}

      it 'should configure default values' do
        should contain_swift_internal_client_config('DEFAULT/user').with_value('swift')
        should contain_swift_internal_client_config('pipeline:main/pipeline').with_value('catch_errors proxy-logging cache proxy-server')
        should contain_swift_internal_client_config('app:proxy-server/use').with_value('egg:swift#proxy')
        should contain_swift_internal_client_config('app:proxy-server/account_autocreate').with_value(true)
        should contain_swift_internal_client_config('app:proxy-server/object_chunk_size').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/client_chunk_size').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/sorting_method').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/timing_expiry').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/request_node_count').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/read_affinity').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/write_affinity').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/write_affinity_node_count').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/write_affinity_handoff_delete_count').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/client_timeout').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/node_timeout').with_value('<SERVICE DEFAULT>')
        should contain_swift_internal_client_config('app:proxy-server/recoverable_node_timeout').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters' do
      let :params do
        {
          :pipeline                            => ['catch_errors', 'proxy-logging', 'proxy-server'],
          :object_chunk_size                   => 65536,
          :client_chunk_size                   => 65535,
          :timing_expiry                       => 300,
          :request_node_count                  => '2 * replicas',
          :read_affinity                       => 'r1z1=100, r1=200',
          :write_affinity                      => 'r1',
          :write_affinity_node_count           => '2 * replicas',
          :write_affinity_handoff_delete_count => 'auto',
          :client_timeout                      => '120',
          :node_timeout                        => '20',
          :recoverable_node_timeout            => '15',
        }
      end

      it 'should configure the given values' do
        should contain_swift_internal_client_config('pipeline:main/pipeline').with_value('catch_errors proxy-logging proxy-server')
        should contain_swift_internal_client_config('app:proxy-server/object_chunk_size').with_value(65536)
        should contain_swift_internal_client_config('app:proxy-server/client_chunk_size').with_value(65535)
        should contain_swift_internal_client_config('app:proxy-server/sorting_method').with_value('affinity')
        should contain_swift_internal_client_config('app:proxy-server/timing_expiry').with_value(300)
        should contain_swift_internal_client_config('app:proxy-server/request_node_count').with_value('2 * replicas')
        should contain_swift_internal_client_config('app:proxy-server/read_affinity').with_value('r1z1=100, r1=200')
        should contain_swift_internal_client_config('app:proxy-server/write_affinity').with_value('r1')
        should contain_swift_internal_client_config('app:proxy-server/write_affinity_node_count').with_value('2 * replicas')
        should contain_swift_internal_client_config('app:proxy-server/write_affinity_handoff_delete_count').with_value('auto')
        should contain_swift_internal_client_config('app:proxy-server/client_timeout').with_value('120')
        should contain_swift_internal_client_config('app:proxy-server/node_timeout').with_value('20')
        should contain_swift_internal_client_config('app:proxy-server/recoverable_node_timeout').with_value('15')
      end
    end

    context 'with sorting_method' do
      let :params do
        {
          :sorting_method => 'timing'
        }
      end

      it 'should configure the sorting_method option' do
        should contain_swift_internal_client_config('app:proxy-server/sorting_method').with_value('timing')
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

      it_behaves_like 'swift::internal_client'
    end
  end
end
