require 'spec_helper'

describe 'swift::memcache' do
  shared_examples 'swift::memcache' do

    describe 'when using default parameters' do

      let :file_defaults do
        {
          :owner   => 'swift',
          :group   => 'swift',
          :mode    => '0640',
        }
      end

      it {is_expected.to contain_file('/etc/swift/memcache.conf').with(
         {:ensure => 'file'}.merge(file_defaults)
      )}

      it { is_expected.to contain_swift_memcache_config(
        'memcache/memcache_servers').with_value(['127.0.0.1:11211']) }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/memcache_serialization_support').with_value('<SERVICE DEFAULT>') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/memcache_max_connections').with_value('<SERVICE DEFAULT>') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/connect_timeout').with_value('<SERVICE DEFAULT>') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/pool_timeout').with_value('<SERVICE DEFAULT>') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/tries').with_value('<SERVICE DEFAULT>') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/io_timeout').with_value('<SERVICE DEFAULT>') }
    end

    describe 'when overridding parameters' do
      let :params do
        {
          :memcache_servers               => ['1.1.1.1:11211', '2.2.2.2:11211'],
          :memcache_serialization_support => 1,
          :memcache_max_connections       => 3,
          :connect_timeout                => '0.5',
          :pool_timeout                   => '2.0',
          :tries                          => 5,
          :io_timeout                     => '1.0'
        }
      end
      it { is_expected.to contain_swift_memcache_config(
        'memcache/memcache_servers').with_value('1.1.1.1:11211,2.2.2.2:11211') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/memcache_serialization_support').with_value('1') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/memcache_max_connections').with_value('3') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/connect_timeout').with_value('0.5') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/pool_timeout').with_value('2.0') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/tries').with_value('5') }
      it {  is_expected.to contain_swift_memcache_config(
        'memcache/io_timeout').with_value('1.0') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::memcache'
    end
  end
end
