require 'spec_helper'

describe 'swift::proxy::cache' do

  let :facts do
    {
      :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian',
      :processorcount  => 1
    }
  end

  let :pre_condition do
    'class { "memcached": max_memory => 1 }'
  end


  it { is_expected.to contain_concat_fragment('swift_cache').with_content(/\[filter:cache\]\nuse = egg:swift#memcache/) }

  describe 'with defaults' do

    it { is_expected.to contain_concat_fragment('swift_cache').with_content(/memcache_servers = 127\.0\.0\.1:11211/) }

  end

  describe 'with overridden memcache server' do

    let :params do
      {:memcache_servers => '10.0.0.1:1'}
    end

    it { is_expected.to contain_concat_fragment('swift_cache').with_content(/memcache_servers = 10\.0\.0\.1:1/) }

  end

  describe 'with overridden memcache server array' do

    let :params do
      {:memcache_servers => ['10.0.0.1:1', '10.0.0.2:2']}
    end

    it { is_expected.to contain_concat_fragment('swift_cache').with_content(/memcache_servers = 10\.0\.0\.1:1,10\.0\.0\.2:2/) }

  end

end
