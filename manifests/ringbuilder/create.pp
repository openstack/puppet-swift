# == Class: swift::ringbuilder::create
#
# Creates a swift ring using ringbuilder.
# It creates the associated ring file as /etc/swift/${name}.builder
# It will not create a ring if the file already exists.
#
# == Parameters
#
#  [*ring_type*]
#    Optional. The type of ring to create. Accepts object|container|account
#  [*part_power*] Number of partitions in the ring. (specified as the power of 2)
#    Optional. Defaults to 18 (2^18)
#  [*replicas*] Number of replicas to store.
#    Optional. Defaults to 3
#  [*min_part_hours*] Time before a partition can be moved.
#    Optional. Defaults to 24.
#  [*user*] User to run as
#    Optional. Defaults to 'root'
#

# == Examples
#
#   swift::ringbuilder::create { 'account':
#     part_power     => 19,
#     replicas       => 5,
#     min_part_hours => 1,
#     user           => 'root',
#   }
#
# == Authors
#
# Pupppetlabs <info@puppetlabs.com>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
define swift::ringbuilder::create(
  Swift::RingType $ring_type = $name,
  $part_power                = 18,
  $replicas                  = 3,
  $min_part_hours            = 24,
  $user                      = 'root'
) {

  include swift::deps

  exec { "create_${ring_type}":
    command => "swift-ring-builder /etc/swift/${ring_type}.builder create ${part_power} ${replicas} ${min_part_hours}",
    path    => ['/usr/bin'],
    user    => $user,
    creates => "/etc/swift/${ring_type}.builder",
    before  => Anchor['swift::config::end'],
  }

}
