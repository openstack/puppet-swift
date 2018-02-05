require 'spec_helper'

describe 'swift::proxy::cache' do

  let :facts do
    {
      :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian',
      :os_workers      => 1,
      :processorcount  => 1,
    }
  end

  describe 'with defaults' do
    let :pre_condition do
      'class { "memcached": max_memory => 1 }'
    end

    it 'should have the required classes' do
      is_expected.to contain_class('swift::deps')
      is_expected.to contain_class('swift::proxy::cache')
    end
    it { is_expected.to contain_swift_proxy_config('filter:cache/use').with_value('egg:swift#memcache') }
    it { is_expected.to contain_swift_proxy_config('filter:cache/memcache_servers').with_value('127.0.0.1:11211') }
  end

  describe 'without memcached being included' do
    it 'should raise an error' do
      expect { catalogue }.to raise_error(Puppet::Error)
    end
  end

  describe 'with overridden memcache server' do
    let :params do
      {:memcache_servers => '10.0.0.1:1'}
    end

    it { is_expected.to contain_swift_proxy_config('filter:cache/use').with_value('egg:swift#memcache') }
    it { is_expected.to contain_swift_proxy_config('filter:cache/memcache_servers').with_value('10.0.0.1:1') }
  end

  describe 'with overridden memcache server array' do
    let :params do
      {:memcache_servers => ['10.0.0.1:1', '10.0.0.2:2']}
    end

    it { is_expected.to contain_swift_proxy_config('filter:cache/use').with_value('egg:swift#memcache') }
    it { is_expected.to contain_swift_proxy_config('filter:cache/memcache_servers').with_value('10.0.0.1:1,10.0.0.2:2') }
  end

end
