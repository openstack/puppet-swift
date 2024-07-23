# == Class: swift::internal_client
#
# Configures internal client
#
# === Parameters
#
# [*user*]
#   (optional) User to run as
#   Defaults to $::swift::params::user.
#
#  [*pipeline*]
#    (optional) The list of elements of the internal client pipeline.
#    Defaults to ['catch_errors', 'proxy-logging', 'cache', 'proxy-server']
#
#  [*object_chunk_size*]
#    (optional) Chunk size to read from object servers.
#    Defaults to $facts['os_service_default'].
#
#  [*client_chunk_size*]
#    (optional) Chunk size to read from clients.
#    Defaults to $facts['os_service_default'].
#
#  [*sorting_method*]
#    (optional) Method to chose storage nodes during GET and HEAD requests.
#    Defaults to undef.
#
#  [*timing_expiry*]
#    (optional) If the "timing" sorting_method is used, the timings will only
#    be valid for the number of seconds configured by timing_expiry.
#    Defaults to $facts['os_service_default'].
#
#  [*request_node_count*]
#    (optional) Number of nodes to contact for a normal request.
#    Defaults to $facts['os_service_default'].
#
#  [*read_affinity*]
#    (optional) Configures the read affinity of internal client.
#    Defaults to undef.
#
#  [*write_affinity*]
#    (optional) Configures the write affinity of internal client.
#    Defaults to undef.
#
#  [*write_affinity_node_count*]
#    (optional) Configures write_affinity_node_count for internal client.
#    Optional but requires write_affinity to be set.
#    Defaults to $facts['os_service_default'].
#
#  [*write_affinity_handoff_delete_count*]
#    (optional) Configures write_affinity_handoff_delete_count for proxy-server.
#    Optional but requires write_affinity to be set.
#    Defaults to $facts['os_service_default'].
#
#  [*client_timeout*]
#    (optional) Configures client_timeout for internal client.
#    Defaults to $facts['os_service_default'].
#
#  [*node_timeout*]
#    (optional) Configures node_timeout for internal client.
#    Defaults to $facts['os_service_default'].
#
#  [*recoverable_node_timeout*]
#    (optional) Configures recoverable_node_timeout for internal client.
#    Defaults to $facts['os_service_default'].
#
#  [*purge_config*]
#    (optional) Whether to set only the specified config options in
#    the internal client config.
#    Defaults to false.
#
class swift::internal_client (
  $user                                          = $::swift::params::user,
  Swift::Pipeline $pipeline                      = ['catch_errors', 'proxy-logging', 'cache', 'proxy-server'],
  $object_chunk_size                             = $facts['os_service_default'],
  $client_chunk_size                             = $facts['os_service_default'],
  Optional[Swift::SortingMethod] $sorting_method = undef,
  $timing_expiry                                 = $facts['os_service_default'],
  $request_node_count                            = $facts['os_service_default'],
  $read_affinity                                 = undef,
  $write_affinity                                = undef,
  $write_affinity_node_count                     = $facts['os_service_default'],
  $write_affinity_handoff_delete_count           = $facts['os_service_default'],
  $client_timeout                                = $facts['os_service_default'],
  $node_timeout                                  = $facts['os_service_default'],
  $recoverable_node_timeout                      = $facts['os_service_default'],
  Boolean $purge_config                          = false,
) inherits swift::params {

  include swift::deps
  include swift::params

  if $pipeline[-1] != 'proxy-server' {
    fail('proxy-server must be the last element in pipeline')
  }

  resources { 'swift_internal_client_config':
    purge => $purge_config,
  }

  file { '/etc/swift/internal-client.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => $::swift::params::group,
    mode    => '0640',
    require => Anchor['swift::config::begin'],
    before  => Anchor['swift::config::end']
  }
  File['/etc/swift/internal-client.conf'] -> Swift_internal_client_config<||>

  swift_internal_client_config {
    'DEFAULT/user':                               value => $user;
    'pipeline:main/pipeline':                     value => join($pipeline, ' ');
    'app:proxy-server/use':                       value => 'egg:swift#proxy';
    'app:proxy-server/account_autocreate':        value => true;
    'app:proxy-server/timing_expiry':             value => $timing_expiry;
    'app:proxy-server/request_node_count':        value => $request_node_count;
    'app:proxy-server/object_chunk_size':         value => $object_chunk_size;
    'app:proxy-server/client_chunk_size':         value => $client_chunk_size;
    'app:proxy-server/client_timeout':            value => $client_timeout;
    'app:proxy-server/node_timeout':              value => $node_timeout;
    'app:proxy-server/recoverable_node_timeout':  value => $recoverable_node_timeout;
  }

  if $write_affinity {
    swift_internal_client_config {
      'app:proxy-server/write_affinity':                      value => $write_affinity;
      'app:proxy-server/write_affinity_node_count':           value => $write_affinity_node_count;
      'app:proxy-server/write_affinity_handoff_delete_count': value => $write_affinity_handoff_delete_count;
    }
  } else {
    if !is_service_default($write_affinity_node_count) {
      fail('Usage of write_affinity_node_count requires write_affinity to be set')
    }
    if !is_service_default($write_affinity_handoff_delete_count) {
      fail('Usage of write_affinity_handoff_delete_count requires write_affinity to be set')
    }
    swift_internal_client_config {
      'app:proxy-server/write_affinity':                      value => $facts['os_service_default'];
      'app:proxy-server/write_affinity_node_count':           value => $facts['os_service_default'];
      'app:proxy-server/write_affinity_handoff_delete_count': value => $facts['os_service_default'];
    }
  }

  if $read_affinity {
    if $sorting_method and $sorting_method != 'affinity' {
      fail('sorting_method should be \'affinity\' to use read affinity')
    }
    swift_internal_client_config {
      'app:proxy-server/sorting_method': value => 'affinity';
      'app:proxy-server/read_affinity':  value => $read_affinity;
    }
  } else {
    swift_internal_client_config {
      'app:proxy-server/sorting_method': value => pick($sorting_method, $facts['os_service_default']);
      'app:proxy-server/read_affinity':  value => $facts['os_service_default'];
    }
  }
}
