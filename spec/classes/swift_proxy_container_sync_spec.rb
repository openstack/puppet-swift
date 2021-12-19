#
# Author: Denis Egorenko <degorenko@mirantis.com>
#
# Tests for swift::proxy::container_sync
#
require 'spec_helper'

describe 'swift::proxy::container_sync' do
  shared_examples 'swift::proxy::container_sync' do
    context 'when using default parameters' do
      it { is_expected.to contain_swift_proxy_config('filter:container_sync/use').with_value('egg:swift#container_sync') }
      it { is_expected.to contain_swift_proxy_config('filter:container_sync/allow_full_urls').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_swift_proxy_config('filter:container_sync/current').with_value('<SERVICE DEFAULT>') }
    end

    context 'when overriding default parameters' do
      let :params do
        {
          :allow_full_urls => true,
          :current         => '//REALM/CLUSTER',
        }
      end

      it { is_expected.to contain_swift_proxy_config('filter:container_sync/use').with_value('egg:swift#container_sync') }
      it { is_expected.to contain_swift_proxy_config('filter:container_sync/allow_full_urls').with_value(true) }
      it { is_expected.to contain_swift_proxy_config('filter:container_sync/current').with_value('//REALM/CLUSTER') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::proxy::container_sync'
    end
  end
end
