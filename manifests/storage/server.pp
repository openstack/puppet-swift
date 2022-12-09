# == Define: swift::storage::server
#
# Configures an account, container or object server
#
# === Parameters:
#
# [*title*] The port the server will be exposed to
#   Mandatory. Usually 6000, 6001 and 6002 for respectively
#   object, container and account.
#
# [*type*]
#   (required) The type of device, e.g. account, object, or container.
#
# [*storage_local_net_ip*]
#   (required) This is the ip that the storage service will bind to when it starts.
#
# [*devices*]
#   (optional) The directory where the physical storage device will be mounted.
#   Defaults to '/srv/node'.
#
# [*rsync_module_per_device*]
#   (optional) Define one rsync module per device. If this is set to true, then
#   the device_names must be set with an array of device names.
#   Defaults to false.
#
# [*device_names*]
#   (optional) List of devices to set as an rsync module list in rsyncd.conf.
#   Defaults to an empty array.
#
# [*owner*]
#   (optional) Owner (uid) of rsync server.
#   Defaults to $::swift::params::user.
#
# [*group*]
#   (optional) Group (gid) of rsync server.
#   Defaults to $::swift::params::group.
#
# [*max_connections*]
#   (optional) maximum number of simultaneous connections allowed.
#   Defaults to 25.
#
# [*incoming_chmod*] Incoming chmod to set in the rsync server.
#   Optional. Defaults to 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r'
#   This mask translates to 0755 for directories and 0644 for files.
#
# [*outgoing_chmod*] Outgoing chmod to set in the rsync server.
#   Optional. Defaults to 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r'
#   This mask translates to 0755 for directories and 0644 for files.
#
# [*pipeline*]
#   (optional) Pipeline of applications.
#   Defaults to ["${type}-server"].
#
# [*mount_check*]
#   (optional) Whether or not check if the devices are mounted to prevent accidentally
#   writing to the root device.
#   Defaults to true.
#
# [*servers_per_port*]
#   (optional) Spawn multiple servers per device on different ports.
#   Make object-server run this many worker processes per unique port of
#   "local" ring devices across all storage policies.  This can help provide
#   the isolation of threads_per_disk without the severe overhead.  The default
#   value of 0 disables this feature.
#   Default to $::os_service_default.
#
# [*user*]
#   (optional) User to run as
#   Defaults to $::swift::params::user.
#
# [*workers*]
#   (optional) Override the number of pre-forked workers that will accept
#   connections. If set it should be an integer, zero means no fork. If unset,
#   it will try to default to the number of effective cpu cores and fallback to
#   one. Increasing the number of workers may reduce the possibility of slow file
#   system operations in one request from negatively impacting other requests.
#   See https://docs.openstack.org/swift/latest/deployment_guide.html#general-service-tuning
#   Defaults to $::os_workers.
#
# [*replicator_concurrency*]
#   (optional) Number of replicator workers to spawn.
#   Defaults to 1.
#
# [*replicator_interval*]
#   (optional) Minimum time for a pass to take, in seconds.
#   Default to $::os_service_default.
#
# [*updater_concurrency*]
#   (optional) Number of updater workers to spawn.
#   Defaults to 1.
#
# [*reaper_concurrency*]
#   (optional) Number of reaper workers to spawn.
#   Defaults to 1.
#
# [*log_facility*]
#   (optional) Syslog log facility.
#   Defaults to 'LOG_LOCAL2'.
#
# [*log_level*]
#   (optional) Logging level.
#   Defaults to 'INFO'.
#
# [*log_address*]
#   Deprecated, this parameter does nothing.
#
# [*log_name*]
#   (optional) Label used when logging.
#   Defaults to "${type}-server".
#
# [*log_udp_host*]
#   (optional) If not set, the UDP receiver for syslog is disabled.
#   Defaults to undef.
#
# [*log_udp_port*]
#   (optional) Port value for UDP receiver, if enabled.
#   Defaults to undef.
#
# [*log_requests*]
#   (optional) Whether or not log every request. reduces logging output if false,
#   good for seeing errors if true
#   Defaults to true.
#
# [*config_file_path*]
#   (optional) The configuration file name.
#   Starting at the path "/etc/swift/"
#   Defaults to "${type}-server.conf"
#
# [*statsd_enabled*]
#   (optional) Should statsd configuration items be writen out to config files
#   Defaults to false.
#
# [*log_statsd_host*]
#   (optional) statsd host to send data to.
#   Defaults to 'localhost'
#
# [*log_statsd_port*]
#   (optional) statsd port to send data to.
#   Defaults to $::os_service_default.
#
# [*log_statsd_default_sample_rate*]
#   (optional) Default sample rate for data. This should be a number between 0
#   and 1. According to the documentation this should be set to 1 and the
#   sample rate factor should be adjusted.
#   Defaults to $::os_service_default.
#
# [*log_statsd_sample_rate_factor*]
#   (optional) sample rate factor for data.
#   Defaults to $::os_service_default.
#
# [*log_statsd_metric_prefix*]
#   (optional) Prefix for data being sent to statsd.
#   Defaults to $::os_service_default
#
# [*network_chunk_size*]
#   (optional) Size of chunks to read/write over the network.
#   Default to $::os_service_default.
#
# [*disk_chunk_size*]
#   (optional) Size of chunks to read/write to disk.
#   Default to $::os_service_default.
#
# [*auditor_disk_chunk_size*]
#   (optional) Object-auditor size of chunks to read/write to disk.
#   Default to $::os_service_default.
#
# [*client_timeout*]
#   (optional) Object-server timeout in seconds to read one chunk from a client
#   external services.
#   Default to $::os_service_default.
#
# [*rsync_timeout*]
#   (optional) Max duration of a partition rsync.
#   Default to $::os_service_default.
#
# [*rsync_bwlimit*]
#   (optional) Bandwidth limit for rsync in kB/s. 0 means unlimited.
#   Default to $::os_service_default.
#
# [*splice*]
#   (optional) Use splice for zero-copy object GETs. This requires Linux Kernel
#   version 3.0 or greater.
#   Default to $::os_service_default.
#
# [*object_server_mb_per_sync*]
#   (optional) Number of MB allocated for the cache.
#   Default to $::os_service_default.
#
# [*container_sharder_auto_shard*]
#   (optional) If the auto_shard option is true then the sharder will
#   automatically select containers to shard, scan for shard ranges,
#   and select shards to shrink.
#   Default to $::os_service_default.
#
# [*container_sharder_concurrency*]
#   (optional) Number of replication workers to spawn.
#   Default to $::os_service_default.
#
# [*container_sharder_interval*]
#   (optional) Time in seconds to wait between sharder cycles.
#   Default to $::os_service_default.
#
define swift::storage::server(
  $type,
  $storage_local_net_ip,
  $devices                        = '/srv/node',
  $rsync_module_per_device        = false,
  $device_names                   = [],
  $owner                          = undef,
  $group                          = undef,
  $incoming_chmod                 = 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
  $outgoing_chmod                 = 'Du=rwx,g=rx,o=rx,Fu=rw,g=r,o=r',
  $max_connections                = 25,
  $pipeline                       = ["${type}-server"],
  $mount_check                    = true,
  $servers_per_port               = $::os_service_default,
  $user                           = undef,
  $workers                        = $::os_workers,
  $replicator_concurrency         = 1,
  $replicator_interval            = $::os_service_default,
  $updater_concurrency            = 1,
  $reaper_concurrency             = 1,
  $log_facility                   = 'LOG_LOCAL2',
  $log_level                      = 'INFO',
  $log_address                    = '/dev/log',
  $log_name                       = "${type}-server",
  $log_udp_host                   = undef,
  $log_udp_port                   = undef,
  $log_requests                   = true,
  # this parameters needs to be specified after type and name
  $config_file_path               = "${type}-server.conf",
  $statsd_enabled                 = false,
  $log_statsd_host                = 'localhost',
  $log_statsd_port                = $::os_service_default,
  $log_statsd_default_sample_rate = $::os_service_default,
  $log_statsd_sample_rate_factor  = $::os_service_default,
  $log_statsd_metric_prefix       = $::os_service_default,
  $network_chunk_size             = $::os_service_default,
  $disk_chunk_size                = $::os_service_default,
  $client_timeout                 = $::os_service_default,
  $auditor_disk_chunk_size        = $::os_service_default,
  $rsync_timeout                  = $::os_service_default,
  $rsync_bwlimit                  = $::os_service_default,
  $splice                         = $::os_service_default,
  $object_server_mb_per_sync      = $::os_service_default,
  # These parameters only apply to container-server.conf,
  # and define options for the container-sharder service.
  $container_sharder_auto_shard   = $::os_service_default,
  $container_sharder_concurrency  = $::os_service_default,
  $container_sharder_interval     = $::os_service_default,
){

  include swift::deps
  include swift::params

  $user_real = pick($user, $::swift::params::user)

  # Warn if ${type-server} isn't included in the pipeline
  $pipeline_array = any2array($pipeline)
  if empty($pipeline_array) or $pipeline_array[-1] != "${type}-server" {
    fail("${type}-server must be the last element in pipeline")
  }


  if ($log_udp_port and !$log_udp_host) {
    fail ('log_udp_port requires log_udp_host to be set')
  }

  include "::swift::storage::${type}"

  validate_legacy(Pattern[/^\d+$/], 'validate_re', $name, ['^\d+$'])
  validate_legacy(Enum['object', 'container', 'account'], 'validate_re',
    $type, ['^object|container|account$'])
  validate_legacy(Array, 'validate_array', $pipeline)
  validate_legacy(Array, 'validate_array', $device_names)

  if ! is_service_default($splice) {
    validate_legacy(Boolean, 'validate_bool', $splice)
  }

  $bind_port = $name

  # rsync::server should be included before rsync::server::module
  include swift::storage
  if $rsync_module_per_device {
    if empty($device_names) {
      fail('device_names is required when rsync_module_per_device is true')
    }

    $device_names.each |String $device_name| {
      rsync::server::module { "${type}_${device_name}":
        path            => $devices,
        lock_file       => "/var/lock/${type}_${device_name}.lock",
        uid             => pick($owner, $::swift::params::user),
        gid             => pick($group, $::swift::params::group),
        incoming_chmod  => $incoming_chmod,
        outgoing_chmod  => $outgoing_chmod,
        max_connections => $max_connections,
        read_only       => false,
      }
    }
    $rsync_module = "{replication_ip}::${type}_{device}"
  } else {
    rsync::server::module { $type:
      path            => $devices,
      lock_file       => "/var/lock/${type}.lock",
      uid             => pick($owner, $::swift::params::user),
      gid             => pick($group, $::swift::params::group),
      incoming_chmod  => $incoming_chmod,
      outgoing_chmod  => $outgoing_chmod,
      max_connections => $max_connections,
      read_only       => false,
    }
    $rsync_module = $::os_service_default
  }

  $config_file_full_path = "/etc/swift/${config_file_path}"


  $required_middlewares = split(
    inline_template(
      "<%=
        (@pipeline - ['${type}-server']).collect do |x|
          'Swift::Storage::Filter::' + x.capitalize + '[${type}]'
        end.join(',')
      %>"), ',')

  file { $config_file_full_path:
    ensure  => present,
    owner   => pick($owner, $::swift::params::user),
    group   => pick($group, $::swift::params::group),
    replace => false,
    tag     => 'swift-config-file',
    before  => $required_middlewares,
  }

  # common settings
  $common_opts = {
    'DEFAULT/devices'                     => {'value'  => $devices},
    'DEFAULT/bind_ip'                     => {'value'  => $storage_local_net_ip},
    'DEFAULT/bind_port'                   => {'value'  => $bind_port},
    'DEFAULT/mount_check'                 => {'value'  => $mount_check},
    'DEFAULT/user'                        => {'value'  => $user_real},
    'DEFAULT/workers'                     => {'value'  => $workers},
    'DEFAULT/log_name'                    => {'value'  => $log_name},
    'DEFAULT/log_facility'                => {'value'  => $log_facility},
    'DEFAULT/log_level'                   => {'value'  => $log_level},
    'DEFAULT/log_address'                 => {'value'  => $log_address},
    # pipeline
    'pipeline:main/pipeline'              => {'value'  => join($pipeline, ' ')},
    # server
    "app:${type}-server/use"              => {'value'  => "egg:swift#${type}"},
    "app:${type}-server/set log_name"     => {'value'  => $log_name},
    "app:${type}-server/set log_facility" => {'value'  => $log_facility},
    "app:${type}-server/set log_level"    => {'value'  => $log_level},
    "app:${type}-server/set log_requests" => {'value'  => $log_requests},
    "app:${type}-server/set log_address"  => {'value'  => $log_address},
    # auditor
    # replicator
    "${type}-replicator/rsync_module"     => {'value'  => $rsync_module},
  }

  file_line { "${type}-auditor":
    path => $config_file_full_path,
    line => "[${type}-auditor]",
    tag  => 'swift-config-file',
  }

  file_line { "${type}-replicator":
    path => $config_file_full_path,
    line => "[${type}-replicator]",
    tag  => 'swift-config-file',
  }

  Anchor['swift::config::begin']
    -> File[$config_file_full_path]
    -> File_line<| path == $config_file_full_path |>
    ~> Anchor['swift::config::end']

  # udp log transfer
  if $log_udp_host {
    $log_udp_opts = {
      'DEFAULT/log_udp_host' => {'value' => $log_udp_host},
      'DEFAULT/log_udp_port' => {'value' => pick($log_udp_port, $::os_service_default)},
    }
  } else {
    $log_udp_opts = {
      'DEFAULT/log_udp_host' => {'value' => $::os_service_default},
      'DEFAULT/log_udp_port' => {'value' => $::os_service_default},
    }
  }

  # statsd
  if $statsd_enabled {
    $log_statsd_opts = {
      'DEFAULT/log_statsd_host'                => {'value' => $log_statsd_host},
      'DEFAULT/log_statsd_port'                => {'value' => $log_statsd_port},
      'DEFAULT/log_statsd_default_sample_rate' => {'value' => $log_statsd_default_sample_rate},
      'DEFAULT/log_statsd_sample_rate_factor'  => {'value' => $log_statsd_sample_rate_factor},
      'DEFAULT/log_statsd_metric_prefix'       => {'value' => $log_statsd_metric_prefix},
    }
  } else {
    $log_statsd_opts = {
      'DEFAULT/log_statsd_host'                => {'value' => $::os_service_default},
      'DEFAULT/log_statsd_port'                => {'value' => $::os_service_default},
      'DEFAULT/log_statsd_default_sample_rate' => {'value' => $::os_service_default},
      'DEFAULT/log_statsd_sample_rate_factor'  => {'value' => $::os_service_default},
      'DEFAULT/log_statsd_metric_prefix'       => {'value' => $::os_service_default},
    }
  }

  case $type {
    'account': {
      $type_opts = {
        # account-server
        # account-auditor
        # account-replicator
        'account-replicator/concurrency' => {'value'  => $replicator_concurrency},
        'account-replicator/interval'    => {'value'  => $replicator_interval},
        # account-reaper
        'account-reaper/concurrency'     => {'value'  => $reaper_concurrency},
      }

      file_line { 'account-reaper':
        path => $config_file_full_path,
        line => '[account-reaper]',
        tag  => 'swift-config-file',
      }
    }
    'container': {
      $type_opts = {
        'DEFAULT/allowed_sync_hosts'       => {'value'  => join($::swift::storage::container::allowed_sync_hosts, ',')},
        # container-server
        # container-auditor
        # container-replicator
        'container-replicator/concurrency' => {'value'  => $replicator_concurrency},
        'container-replicator/interval'    => {'value'  => $replicator_interval},
        # container-updater
        'container-updater/concurrency'    => {'value'  => $updater_concurrency},
        # container-sync
        # container-sharder
        'container-sharder/auto_shard'     => {'value'  => $container_sharder_auto_shard},
        'container-sharder/concurrency'    => {'value'  => $container_sharder_concurrency},
        'container-sharder/interval'       => {'value'  => $container_sharder_interval},
      }

      file_line { 'container-updater':
        path => $config_file_full_path,
        line => '[container-updater]',
        tag  => 'swift-config-file',
      }
      file_line { 'container-sync':
        path => $config_file_full_path,
        line => '[container-sync]',
        tag  => 'swift-config-file',
      }
      file_line { 'container-sharder':
        path => $config_file_full_path,
        line => '[container-sharder]',
        tag  => 'swift-config-file',
      }
    }
    'object': {
      $type_opts = {
        'DEFAULT/servers_per_port'        => {'value'  => $servers_per_port},
        'DEFAULT/network_chunk_size'      => {'value'  => $network_chunk_size},
        'DEFAULT/disk_chunk_size'         => {'value'  => $disk_chunk_size},
        'DEFAULT/client_timeout'          => {'value'  => $client_timeout},
        # object-server
        'app:object-server/splice'        => {'value'  => $splice},
        'app:object-server/mb_per_sync'   => {'value'  => $object_server_mb_per_sync},
        # object-auditor
        'object-auditor/disk_chunk_size'  => {'value'  => $auditor_disk_chunk_size},
        # object-replicator
        'object-replicator/concurrency'   => {'value'  => $replicator_concurrency},
        'object-replicator/rsync_timeout' => {'value'  => $rsync_timeout},
        'object-replicator/rsync_bwlimit' => {'value'  => $rsync_bwlimit},
        # object-updater
        'object-updater/concurrency'      => {'value'  => $updater_concurrency},
        # object-reconstructor
      }

      file_line { 'object-updater':
        path => $config_file_full_path,
        line => '[object-updater]',
        tag  => 'swift-config-file',
      }
      file_line { 'object-reconstructor':
        path => $config_file_full_path,
        line => '[object-reconstructor]',
        tag  => 'swift-config-file',
      }
    }
    default: {
      # nothing to do
    }
  }

  create_resources("swift_${type}_config", merge(
    $common_opts,
    $log_udp_opts,
    $log_statsd_opts,
    $type_opts,
  ), {
    #'path'    => $config_file_full_path,
    'require' => File[$config_file_full_path]
  })
}
