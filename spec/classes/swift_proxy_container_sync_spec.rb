#
# Author: Denis Egorenko <degorenko@mirantis.com>
#
# Tests for swift::proxy::container_sync
#
require 'spec_helper'

describe 'swift::proxy::container_sync' do
  shared_examples 'swift::proxy::container_sync' do
    it { should contain_swift_proxy_config('filter:container_sync/use').with_value('egg:swift#container_sync') }
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
