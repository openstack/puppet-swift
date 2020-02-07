require 'spec_helper'

describe 'swift::storage::cron::recon' do
  shared_examples 'swift::storage::cron::recon' do

    let :pre_condition do
      "class { 'swift': swift_hash_path_suffix => 'foo' }
       class { 'swift::storage': storage_local_net_ip => '10.0.0.1' }"
    end

    let :params do
      {}
    end

    context 'with no parameters specified' do
      it { is_expected.to contain_cron('swift-recon-cron').with(
          :command     => 'swift-recon-cron /etc/swift/object-server.conf',
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
          :user        => 'swift',
          :minute      => '*/5',
          :hour        => '*',
          :monthday    => '*',
          :month       => '*',
          :weekday     => '*',
      )}
    end

    context 'with parameters specified' do
      before :each do
        params.merge!({
          :configfile  => '/opt/swift/object-server.conf',
          :user        => 'foo',
          :minute      => '*/1'
        })
      end

      it { is_expected.to contain_cron('swift-recon-cron').with(
          :command     => 'swift-recon-cron /opt/swift/object-server.conf',
          :user        => 'foo',
          :minute      => '*/1',
          :hour        => '*',
          :monthday    => '*',
          :month       => '*',
          :weekday     => '*',
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end
      it_configures 'swift::storage::cron::recon'
    end
  end
end
