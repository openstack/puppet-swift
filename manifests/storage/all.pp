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
#  [*allow_versions*] Boolean to enable the versioning in swift container
#    Optional. Default to false.
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
#  [*allow_versions*]
#    (optional) Enable/Disable object versioning feature
#    Defaults to false
#
#  [*mount_check*]
#    (optional) Whether or not check if the devices are mounted
#    to prevent accidentally writing to the root device
#    Defaults to true.
#
#  [*account_pipeline*]
#    (optional) Specify the account pipeline
#    Defaults to undef
#
#  [*log_facility*]
#    (optional) Syslog log facility
#    Defaults to 'LOG_LOCAL2'
#
#  [*log_level*]
#    (optional) Log level.
#    Defaults to 'INFO'.
#
#  [*log_udp_host*]
#    (optional) If not set, the UDP receiver for syslog is disabled.
#    Defaults to undef.
#
#  [*log_udp_port*]
#    (optional) Port value for UDP receiver, if enabled.
#    Defaults to undef.
#
# [*log_requests*]
#   (optional) Whether or not log every request. reduces logging output if false,
#   good for seeing errors if true
#   Defaults to true.
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
#   Defaults to 8125
#
# [*log_statsd_default_sample_rate*]
#   (optional) Default sample rate for data. This should be a number between 0
#   and 1. According to the documentation this should be set to 1 and the
#   sample rate factor should be adjusted.
#   Defaults to '1.0'
#
# [*log_statsd_sample_rate_factor*]
#   (optional) sample rate factor for data.
#   Defaults to '1.0'
#
# [*log_statsd_metric_prefix*]
#   (optional) Prefix for data being sent to statsd.
#   Defaults to ''
#
# [*account_server_workers*]
#   (optional) Number of account server workers.
#   Defaults to undef.
#
# [*container_server_workers*]
#   (optional) Number of container server workers.
#   Defaults to undef.
#
# [*object_server_workers*]
#   (optional) Number of account server workers.
#   Defaults to undef.
#
class swift::storage::all(
  $storage_local_net_ip,
  $devices                        = '/srv/node',
  $object_port                    = '6000',
  $container_port                 = '6001',
  $account_port                   = '6002',
  $object_pipeline                = undef,
  $container_pipeline             = undef,
  $allow_versions                 = false,
  $mount_check                    = true,
  $account_pipeline               = undef,
  $log_facility                   = 'LOG_LOCAL2',
  $log_level                      = 'INFO',
  $log_udp_host                   = undef,
  $log_udp_port                   = undef,
  $log_requests                   = true,
  $incoming_chmod                 = 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
  $outgoing_chmod                 = 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
  $statsd_enabled                 = false,
  $log_statsd_host                = 'localhost',
  $log_statsd_port                = 8125,
  $log_statsd_default_sample_rate = '1.0',
  $log_statsd_sample_rate_factor  = '1.0',
  $log_statsd_metric_prefix       = '',
  $account_server_workers         = undef,
  $container_server_workers       = undef,
  $object_server_workers          = undef,
) {

  include ::swift::deps

  if ($object_port == '6000') {
    warning('The default port for the object storage server has changed from 6000 to 6200 and will be changed in a later release')
  }

  if ($container_port == '6001') {
    warning('The default port for the container storage server has changed from 6001 to 6201 and will be changed in a later release')
  }

  if ($account_port == '6002') {
    warning('The default port for the account storage server has changed from 6002 to 6202 and will be changed in a later release')
  }

  class { '::swift::storage':
    storage_local_net_ip => $storage_local_net_ip,
  }

  Swift::Storage::Server {
    devices                        => $devices,
    storage_local_net_ip           => $storage_local_net_ip,
    mount_check                    => $mount_check,
    log_level                      => $log_level,
    log_udp_host                   => $log_udp_host,
    log_udp_port                   => $log_udp_port,
    statsd_enabled                 => $statsd_enabled,
    log_statsd_host                => $log_statsd_host,
    log_statsd_port                => $log_statsd_port,
    log_statsd_default_sample_rate => $log_statsd_default_sample_rate,
    log_statsd_sample_rate_factor  => $log_statsd_sample_rate_factor,
    log_statsd_metric_prefix       => $log_statsd_metric_prefix,
  }

  swift::storage::server { $account_port:
    type             => 'account',
    config_file_path => 'account-server.conf',
    pipeline         => $account_pipeline,
    log_facility     => $log_facility,
    log_requests     => $log_requests,
    incoming_chmod   => $incoming_chmod,
    outgoing_chmod   => $outgoing_chmod,
    workers          => $account_server_workers,
  }

  swift::storage::server { $container_port:
    type             => 'container',
    config_file_path => 'container-server.conf',
    pipeline         => $container_pipeline,
    log_facility     => $log_facility,
    allow_versions   => $allow_versions,
    log_requests     => $log_requests,
    incoming_chmod   => $incoming_chmod,
    outgoing_chmod   => $outgoing_chmod,
    workers          => $container_server_workers,
  }

  swift::storage::server { $object_port:
    type             => 'object',
    config_file_path => 'object-server.conf',
    pipeline         => $object_pipeline,
    log_facility     => $log_facility,
    log_requests     => $log_requests,
    incoming_chmod   => $incoming_chmod,
    outgoing_chmod   => $outgoing_chmod,
    workers          => $object_server_workers,
  }
}
