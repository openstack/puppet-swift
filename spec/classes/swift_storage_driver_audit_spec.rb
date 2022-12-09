require 'spec_helper'

describe 'swift::storage::drive_audit' do
  shared_examples 'swift::storage::drive_audit' do

    context 'with defaults' do
      it 'should configure default values' do
        should contain_swift_drive_audit_config('drive-audit/log_name').with_value('drive-audit')
        should contain_swift_drive_audit_config('drive-audit/log_facility').with_value('LOG_LOCAL2')
        should contain_swift_drive_audit_config('drive-audit/log_level').with_value('INFO')
        should contain_swift_drive_audit_config('drive-audit/log_address').with_value('/dev/log')
        should contain_swift_drive_audit_config('drive-audit/log_udp_host').with_value('<SERVICE DEFAULT>')
        should contain_swift_drive_audit_config('drive-audit/log_udp_port').with_value('<SERVICE DEFAULT>')

        should contain_swift_drive_audit_config('drive-audit/user').with_value('swift')
        should contain_swift_drive_audit_config('drive-audit/device_dir').with_value('/srv/node')
        should contain_swift_drive_audit_config('drive-audit/minutes').with_value('<SERVICE DEFAULT>')
        should contain_swift_drive_audit_config('drive-audit/error_limit').with_value('<SERVICE DEFAULT>')
        should contain_swift_drive_audit_config('drive-audit/recon_cache_path').with_value('<SERVICE DEFAULT>')
        should contain_swift_drive_audit_config('drive-audit/log_file_pattern').with_value('<SERVICE DEFAULT>')
        should contain_swift_drive_audit_config('drive-audit/log_file_encoding').with_value('<SERVICE DEFAULT>')
        should contain_swift_drive_audit_config('drive-audit/log_to_console').with_value('<SERVICE DEFAULT>')
        should contain_swift_drive_audit_config('drive-audit/unmount_failed_device').with_value('<SERVICE DEFAULT>')

        should contain_cron('swift-drive-audit').with(
          :command     => 'swift-drive-audit /etc/swift/drive-audit.conf',
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
          :user        => 'swift',
          :minute      => 1,
          :hour        => 0,
          :monthday    => '*',
          :month       => '*',
          :weekday     => '*',
        )
      end
    end

    context 'with parameters' do
      let :params do
        {
          :maxdelay              => 30,
          :user                  => 'alt_swift',
          :device_dir            => '/opt/swift',
          :minutes               => 60,
          :error_limit           => 1,
          :recon_cache_path      => '/var/cache/swift',
          :log_file_pattern      => '/var/log/kern.*[!.][!g][!z]',
          :log_file_encoding     => 'auto',
          :log_to_console        => true,
          :unmount_failed_device => true,
          :regex_pattern         => {'1' => 'pattern1', '2' => 'pattern2'},
        }
      end

      it 'should configure the given values' do
        should contain_swift_drive_audit_config('drive-audit/user').with_value('alt_swift')
        should contain_swift_drive_audit_config('drive-audit/device_dir').with_value('/opt/swift')
        should contain_swift_drive_audit_config('drive-audit/minutes').with_value(60)
        should contain_swift_drive_audit_config('drive-audit/error_limit').with_value(1)
        should contain_swift_drive_audit_config('drive-audit/recon_cache_path').with_value('/var/cache/swift')
        should contain_swift_drive_audit_config('drive-audit/log_file_pattern').with_value('/var/log/kern.*[!.][!g][!z]')
        should contain_swift_drive_audit_config('drive-audit/log_file_encoding').with_value('auto')
        should contain_swift_drive_audit_config('drive-audit/log_to_console').with_value(true)
        should contain_swift_drive_audit_config('drive-audit/unmount_failed_device').with_value(true)
        should contain_swift_drive_audit_config('drive-audit/regex_pattern_1').with_value('pattern1')
        should contain_swift_drive_audit_config('drive-audit/regex_pattern_2').with_value('pattern2')

        should contain_cron('swift-drive-audit').with(
          :command     => 'sleep `expr ${RANDOM} \\% 30`; swift-drive-audit /etc/swift/drive-audit.conf',
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
          :user        => 'alt_swift',
          :minute      => 1,
          :hour        => 0,
          :monthday    => '*',
          :month       => '*',
          :weekday     => '*',
        )
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

      it_behaves_like 'swift::storage::drive_audit'
    end
  end
end
