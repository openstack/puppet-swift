#
# Example file for building a storage server with 
# distinct storage and replication networks
#
# This example creates nodes of the following roles:
#   swift_storage - nodes that host storage servers
#
# This example assumes a few things:
#   * the multi-node scenario requires a puppetmaster
#   * it assumes that networking is correctly configured
#
# This exmaple builds on site.pp, so a complete deployment
# requires the addition components described there. In this
# file we cover deployment of:
#
# 1. storage nodes


# swift specific configurations
$swift_shared_secret = hiera('swift_shared_secret', 'changeme')

# networks
$swift_storage_net_ip = hiera('swift_storage_net_ip', $ipaddress_eth1)
$swift_replication_net_ip = hiera('swift_replication_net_ip', $ipaddress_eth2)

# Swift storage configurations
$rings = [
  'account',
  'object',
  'container']
$account_pipeline = [
  'healthcheck',
  'recon',
  'account-server']
$container_pipeline = [
  'healthcheck',
  'recon',
  'container-server']
$object_pipeline = [
  'healthcheck',
  'recon',
  'object-server']


$swift_zone = hiera('swift_zone', 1)
$swift_region = hiera('swift_region', 1)

#
# The example below is used to model swift storage nodes that
# manage 2 endpoints.
#
# The endpoints are actually just loopback devices. For real deployments
# they would need to be replaced with something that create and mounts xfs
# partitions
#
node /swift-storage/ {

  class { '::swift':
    # not sure how I want to deal with this shared secret
    swift_hash_suffix => $swift_shared_secret,
    package_ensure    => latest,
  }

  # create xfs partitions on a loopback device and mount them
  swift::storage::loopback { ['1', '2']:
    base_dir     => '/srv/loopback-device',
    mnt_base_dir => '/srv/node',
    require      => Class['swift'],
  }

  # configure account/container/object server middlewares
  swift::storage::filter::recon { $rings: }
  swift::storage::filter::healthcheck { $rings: }

  # install all swift storage servers together
  class { '::swift::storage::all':
    storage_local_net_ip => $swift_storage_net_ip,
    object_pipeline      => $object_pipeline,
    container_pipeline   => $container_pipeline,
    account_pipeline     => $account_pipeline,
  }

  # specify endpoints per device to be added to the ring specification
  @@ring_object_device { "${swift_storage_net_ip}:6000R${swift_replication_net_ip}:6010/1":
    region => $swift_region,
    zone   => $swift_zone,
    weight => 1,
  }

  @@ring_object_device { "${swift_storage_net_ip}:6000R${swift_replication_net_ip}:6010/2":
    region => $swift_region,
    zone   => $swift_zone,
    weight => 1,
  }

  @@ring_container_device { "${swift_storage_net_ip}:6001R${swift_replication_net_ip}:6011/1":
    region => $swift_region,
    zone   => $swift_zone,
    weight => 1,
  }

  @@ring_container_device { "${swift_storage_net_ip}:6001R${swift_replication_net_ip}:6011/2":
    region => $swift_region,
    zone   => $swift_zone,
    weight => 1,
  }
  @@ring_account_device { "${swift_storage_net_ip}:6002R${swift_replication_net_ip}:6012/1":
    region => $swift_region,
    zone   => $swift_zone,
    weight => 1,
  }

  @@ring_account_device { "${swift_storage_net_ip}:6002R${swift_replication_net_ip}:6012/2":
    region => $swift_region,
    zone   => $swift_zone,
    weight => 1,
  }

  # collect resources for synchronizing the ring databases
  Swift::Ringsync<<||>>

}
