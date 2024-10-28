# == Class swift::storage::drive_audit
#
# Set up swift-drive-audit cron job
#
# == Parameters
#
# [*user*]
#   (Optional) User with access to swift files.
#   Defaults to $::swift::params::user.
#
# [*minute*]
#   (Optional) Defaults to '1'.
#
# [*hour*]
#   (Optional) Defaults to '0'.
#
# [*monthday*]
#   (Optional) Defaults to '*'.
#
# [*month*]
#   (Optional) Defaults to '*'.
#
# [*weekday*]
#   (Optional) Defaults to '*'.
#
# [*maxdelay*]
#   (Optional) In Seconds. Should be a positive integer.
#   Induces a random delay before running the cronjob to avoid running
#   all cron jobs at the same time on all hosts this job is configured.
#   Defaults to 0.
#
# [*log_facility*]
#   (Optional) Syslog log facility.
#   Defaults to 'LOG_LOCAL2'.
#
# [*log_level*]
#   (Optional) Logging level.
#   Defaults to 'INFO'.
#
# [*log_address*]
#   (Optional) Location where syslog sends the logs to.
#   Defaults to '/dev/log'.
#
# [*log_name*]
#   (Optional) Label used when logging.
#   Defaults to 'drive-audit'.
#
# [*log_udp_host*]
#   (Optional) If not set, the UDP receiver for syslog is disabled.
#   Defaults to undef.
#
# [*log_udp_port*]
#   (Optional) Port value for UDP receiver, if enabled.
#   Defaults to undef.
#
# [*log_max_line_length*]
#   (Optional) Caps the length of log lines to the value given.
#   Defaults to $facts['os_service_default'].
#
# [*device_dir*]
#   (Optional) Directory devices are mounted under
#   Defaults to $facts['os_service_default'].
#
# [*minutes*]
#   (Optional) Number of minutes to look back in the log file.
#   Defaults to $facts['os_service_default'].
#
# [*error_limit*]
#   (Optional) Number of errors to find before a device is unmounted
#   Defaults to $facts['os_service_default'].
#
# [*recon_cache_path*]
#   (Optional) The path for recon cache
#   Defaults to $facts['os_service_default'].
#
# [*log_file_pattern*]
#   (Optional) Location of the log file with globbing pattern to check against
#   device errors.
#   Defaults to $facts['os_service_default'].
#
# [*log_file_encoding*]
#   (Optional) The encoding used to interpret the log files.
#   Defaults to $facts['os_service_default'].
#
# [*log_to_console*]
#   (Optional) Make drive-audit log to console in addition to syslog
#   Defaults to $facts['os_service_default'].
#
# [*unmount_failed_device*]
#   (Optional) Unmount the device with errors detected.
#   Defaults to $facts['os_service_default'].
#
# [*regex_pattern*]
#   (Optional) Regular expression patterns to be used to locate device blocks
#   with errors in the log file.
#   Defaults to {}
#
#  [*purge_config*]
#   (Optional) Whether to set only the specified config options in the drive
#   audit config.
#   Defaults to false.
#
class swift::storage::drive_audit(
  # cron options
  $user                                     = $::swift::params::user,
  $minute                                   = 1,
  $hour                                     = 0,
  $monthday                                 = '*',
  $month                                    = '*',
  $weekday                                  = '*',
  Integer[0] $maxdelay                      = 0,
  # drive-audit.conf options
  $log_facility                             = 'LOG_LOCAL2',
  $log_level                                = 'INFO',
  $log_address                              = '/dev/log',
  $log_name                                 = 'drive-audit',
  $log_udp_host                             = undef,
  $log_udp_port                             = undef,
  $log_max_line_length                      = $facts['os_service_default'],
  $device_dir                               = '/srv/node',
  $minutes                                  = $facts['os_service_default'],
  $error_limit                              = $facts['os_service_default'],
  $recon_cache_path                         = $facts['os_service_default'],
  $log_file_pattern                         = $facts['os_service_default'],
  $log_file_encoding                        = $facts['os_service_default'],
  $log_to_console                           = $facts['os_service_default'],
  $unmount_failed_device                    = $facts['os_service_default'],
  Hash[String[1], String[1]] $regex_pattern = {},
  Boolean $purge_config                     = false,
) inherits swift::params {

  include swift::deps

  resources { 'swift_drive_audit_config':
    purge => $purge_config,
  }

  file { '/etc/swift/drive-audit.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => $::swift::params::group,
    mode    => '0640',
    require => Anchor['swift::config::begin'],
    before  => Anchor['swift::config::end']
  }
  File['/etc/swift/drive-audit.conf'] -> Swift_drive_audit_config<||>


  swift_drive_audit_config {
    'drive-audit/log_name'            : value => $log_name;
    'drive-audit/log_facility'        : value => $log_facility;
    'drive-audit/log_level'           : value => $log_level;
    'drive-audit/log_address'         : value => $log_address;
    'drive-audit/log_max_line_length' : value => $log_max_line_length;
  }

  if $log_udp_host {
    swift_drive_audit_config {
      'drive-audit/log_udp_host': value => $log_udp_host;
      'drive-audit/log_udp_port': value => pick($log_udp_port, $facts['os_service_default']);
    }
  } else {
    swift_drive_audit_config {
      'drive-audit/log_udp_host': value => $facts['os_service_default'];
      'drive-audit/log_udp_port': value => $facts['os_service_default'];
    }
  }

  swift_drive_audit_config {
    'drive-audit/user'                 : value => $user;
    'drive-audit/device_dir'           : value => $device_dir;
    'drive-audit/minutes'              : value => $minutes;
    'drive-audit/error_limit'          : value => $error_limit;
    'drive-audit/recon_cache_path'     : value => $recon_cache_path;
    'drive-audit/log_file_pattern'     : value => $log_file_pattern;
    'drive-audit/log_file_encoding'    : value => $log_file_encoding;
    'drive-audit/log_to_console'       : value => $log_to_console;
    'drive-audit/unmount_failed_device': value => $unmount_failed_device;
  }

  $regex_pattern.each | $number, $regex | {
    swift_drive_audit_config {
      "drive-audit/regex_pattern_${number}": value => $regex;
    }
  }

  if $maxdelay == 0 {
    $sleep = ''
  } else {
    $sleep = "sleep `expr \${RANDOM} \\% ${maxdelay}`; "
  }

  cron { 'swift-drive-audit':
    command     => "${sleep}swift-drive-audit /etc/swift/drive-audit.conf",
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => $user,
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday,
    require     => Anchor['swift::config::end'],
  }
}
