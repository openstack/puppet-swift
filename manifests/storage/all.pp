#
# configures all storage types
# on the same node
#
#  [*storage_local_net_ip*] ip address that the swift servers should
#    bind to. Required
#
#  [*devices*] The path where the managed volumes can be found.
#    This assumes that all servers use the same path.
#    Optional. Defaults to /srv/node/
#
#  [*object_port*] Port where object storage server should be hosted.
#    Optional. Defaults to 6000.
#
#  [*container_port*] Port where the container storage server should be hosted.
#    Optional. Defaults to 6001.
#
#  [*account_port*] Port where the account storage server should be hosted.
#    Optional. Defaults to 6002.
#
#  [*object_pipeline*]
#    (optional) Specify the object pipeline
#    Defaults to undef
#
#  [*container_pipeline*]
#    (optional) Specify the container pipeline
#    Defaults to undef
#
#  [*account_pipeline*]
#    (optional) Specify the account pipeline
#    Defaults to undef
#
#  [*mount_check*]
#    (optional) Whether or not check if the devices are mounted
#    to prevent accidentally writing to the root device
#    Defaults to true.
#
#  [*log_facility*]
#    (optional) Syslog log facility
#    Defaults to 'LOG_LOCAL2'
#
#  [*log_level*]
#    (optional) Log level.
#    Defaults to 'INFO'.
#
#  [*log_name_per_daemon*]
#    (optional) Set log_name according differently for each daemon
#    For example: container-replicator, contaier-sharder, etc.
#    Defaults to false.
#
#  [*log_udp_host*]
#    (optional) If not set, the UDP receiver for syslog is disabled.
#    Defaults to undef.
#
#  [*log_udp_port*]
#    (optional) Port value for UDP receiver, if enabled.
#    Defaults to undef.
#
#  [*log_requests*]
#    (optional) Whether or not log every request. reduces logging output if false,
#    good for seeing errors if true
#    Defaults to true.
#
# [*max_connections*]
#   (optional) maximum number of simultaneous connections allowed for rsync.
#   Defaults to 25.
#
# [*hosts_allow*]
#   (optional) List of patterns allowed to connect to this module
#   Defaults to undef.
#
# [*hosts_deny*]
#   (optional) List of patterns not allowed to connect to this module
#   Defaults to undef.
#
# [*incoming_chmod*] Incoming chmod to set in the rsync server.
#   Optional. Defaults to 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r'
#   This mask translates to 0755 for directories and 0644 for files.
#
# [*outgoing_chmod*] Outgoing chmod to set in the rsync server.
#   Optional. Defaults to 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r'
#   This mask translates to 0755 for directories and 0644 for files.
#
# [*statsd_enabled*]
#  (optional) Should statsd configuration items be writen out to config files
#  Defaults to false.
#
# [*log_statsd_host*]
#   (optional) statsd host to send data to.
#   Defaults to 'localhost'
#
# [*log_statsd_port*]
#   (optional) statsd port to send data to.
#   Default to $facts['os_service_default'].
#
# [*log_statsd_default_sample_rate*]
#   (optional) Default sample rate for data. This should be a number between 0
#   and 1. According to the documentation this should be set to 1 and the
#   sample rate factor should be adjusted.
#   Default to $facts['os_service_default'].
#
# [*log_statsd_sample_rate_factor*]
#   (optional) sample rate factor for data.
#   Default to $facts['os_service_default'].
#
# [*log_statsd_metric_prefix*]
#   (optional) Prefix for data being sent to statsd.
#   Default to $facts['os_service_default'].
#
# [*account_server_workers*]
#   (optional) Number of account server workers.
#   Defaults to $facts['os_workers'].
#
# [*container_server_workers*]
#   (optional) Number of container server workers.
#   Defaults to $facts['os_workers'].
#
# [*object_server_workers*]
#   (optional) Number of account server workers.
#   Defaults to $facts['os_workers'].
#
# [*object_server_mb_per_sync*]
#   (optional) Number of MB allocated for the cache.
#   Defaults to 512, which is the swift default value.
#
# [*rsync_timeout*]
#   (optional) Max duration of a partition rsync.
#   Default to $facts['os_service_default'].
#
# [*rsync_bwlimit*]
#   (optional) Bandwidth limit for rsync in kB/s. 0 means unlimited.
#   Default to $facts['os_service_default'].
#
# [*splice*]
#   (optional) Use splice for zero-copy object GETs. This requires Linux Kernel
#   version 3.0 or greater.
#   Default to $facts['os_service_default'].
#
# [*rsync_use_xinetd*]
#   (optional) Override whether to use xinetd to manage rsync service
#   Defaults to swift::params::xinetd_available
#
class swift::storage::all(
  $storage_local_net_ip,
  $devices                        = '/srv/node',
  $object_port                    = 6000,
  $container_port                 = 6001,
  $account_port                   = 6002,
  $object_pipeline                = undef,
  $container_pipeline             = undef,
  $account_pipeline               = undef,
  $mount_check                    = true,
  $log_facility                   = 'LOG_LOCAL2',
  $log_level                      = 'INFO',
  Boolean $log_name_per_daemon    = false,
  $log_udp_host                   = undef,
  $log_udp_port                   = undef,
  $log_requests                   = true,
  $max_connections                = 25,
  $hosts_allow                    = undef,
  $hosts_deny                     = undef,
  $incoming_chmod                 = 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
  $outgoing_chmod                 = 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
  $statsd_enabled                 = false,
  $log_statsd_host                = 'localhost',
  $log_statsd_port                = $facts['os_service_default'],
  $log_statsd_default_sample_rate = $facts['os_service_default'],
  $log_statsd_sample_rate_factor  = $facts['os_service_default'],
  $log_statsd_metric_prefix       = $facts['os_service_default'],
  $account_server_workers         = $facts['os_workers'],
  $container_server_workers       = $facts['os_workers'],
  $object_server_workers          = $facts['os_workers'],
  $object_server_mb_per_sync      = $facts['os_service_default'],
  $rsync_timeout                  = $facts['os_service_default'],
  $rsync_bwlimit                  = $facts['os_service_default'],
  $splice                         = false,
  $rsync_use_xinetd               = $::swift::params::xinetd_available,
) inherits swift::params {

  include swift::deps

  if ("${$object_port}" == '6000') {
    warning("The default port for the object storage server has changed \
from 6000 to 6200 and will be changed in a later release")
  }

  if ("${container_port}" == '6001') {
    warning("The default port for the container storage server has changed \
from 6001 to 6201 and will be changed in a later release")
  }

  if ("${$account_port}" == '6002') {
    warning("The default port for the account storage server has changed \
from 6002 to 6202 and will be changed in a later release")
  }

  if $rsync_use_xinetd and ! $::swift::params::xinetd_available {
    fail('xinetd is not available in this distro')
  }

  class { 'swift::storage':
    storage_local_net_ip => $storage_local_net_ip,
    rsync_use_xinetd     => $rsync_use_xinetd,
  }

  Swift::Storage::Server {
    devices                        => $devices,
    storage_local_net_ip           => $storage_local_net_ip,
    mount_check                    => $mount_check,
    log_level                      => $log_level,
    log_name_per_daemon            => $log_name_per_daemon,
    log_facility                   => $log_facility,
    log_udp_host                   => $log_udp_host,
    log_udp_port                   => $log_udp_port,
    log_requests                   => $log_requests,
    statsd_enabled                 => $statsd_enabled,
    log_statsd_host                => $log_statsd_host,
    log_statsd_port                => $log_statsd_port,
    log_statsd_default_sample_rate => $log_statsd_default_sample_rate,
    log_statsd_sample_rate_factor  => $log_statsd_sample_rate_factor,
    log_statsd_metric_prefix       => $log_statsd_metric_prefix,
    max_connections                => $max_connections,
    hosts_allow                    => $hosts_allow,
    hosts_deny                     => $hosts_deny,
    incoming_chmod                 => $incoming_chmod,
    outgoing_chmod                 => $outgoing_chmod,
  }

  swift::storage::server { "${account_port}":
    type     => 'account',
    pipeline => $account_pipeline,
    workers  => $account_server_workers,
  }

  swift::storage::server { "${container_port}":
    type     => 'container',
    pipeline => $container_pipeline,
    workers  => $container_server_workers,
  }

  swift::storage::server { "${object_port}":
    type                      => 'object',
    pipeline                  => $object_pipeline,
    workers                   => $object_server_workers,
    splice                    => $splice,
    object_server_mb_per_sync => $object_server_mb_per_sync,
    rsync_timeout             => $rsync_timeout,
    rsync_bwlimit             => $rsync_bwlimit,
  }
}
