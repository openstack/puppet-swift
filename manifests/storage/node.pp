#
# Builds out a default storage node
#   a storage node is a device that contains
#   a storage endpoint for account, container, and object
#   on the same mount point
#
# === Parameters:
#
# [*mnt_base_dir*]
#   (optional) The directory where the flat files that store the file system
#   to be loop back mounted are actually mounted at.
#   Defaults to '/srv/node', base directory where disks are mounted to
#
# [*zone*]
#   (required) Zone is the number of the zone this device is in.
#   The zone parameter must be an integer.
#
# [*weight*]
#   (optional) Weight is a float weight that determines how many partitions are
#   put on the device relative to the rest of the devices in the cluster (a good
#   starting point is 100.0xTB on the drive).
#   Add each device that will be initially in the cluster.
#   Defaults to 1.
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
# [*storage_local_net_ip*]
#   (optional) The IP address of the storage server.
#   Defaults to '127.0.0.1'.
#
#  [*policy_index*]
#    (optional) storage policy index
#    Defaults to undef
define swift::storage::node(
  $mnt_base_dir,
  Variant[Integer, Pattern[/^\d+$/]] $zone,
  $weight               = 1,
  $owner                = undef,
  $group                = undef,
  $max_connections      = 25,
  $storage_local_net_ip = '127.0.0.1',
  $policy_index         = undef,
) {

  include swift::deps

  Swift::Storage::Server {
    storage_local_net_ip => $storage_local_net_ip,
    devices              => $mnt_base_dir,
    max_connections      => $max_connections,
    owner                => pick($owner, $::swift::params::user),
    group                => pick($group, $::swift::params::group),
  }

  swift::storage::server { "60${name}0":
    type => 'object',
  }

  $ring_host = normalize_ip_for_uri($storage_local_net_ip)

  if !$policy_index {
    $ring_device = "${ring_host}:60${name}0/${name}"
  } else {
    $ring_device = "${policy_index}:${ring_host}:60${name}0/${name}"
  }

  ring_object_device { $ring_device:
    zone   => $zone,
    weight => $weight,
  }

  swift::storage::server { "60${name}1":
    type => 'container',
  }
  ring_container_device { "${ring_host}:60${name}1/${name}":
    zone   => $zone,
    weight => $weight,
  }

  swift::storage::server { "60${name}2":
    type => 'account',
  }
  ring_account_device { "${ring_host}:60${name}2/${name}":
    zone   => $zone,
    weight => $weight,
  }

}
