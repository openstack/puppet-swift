# Used to build an additional object ring for a storage policy.
# The namevar/name of this class must be an integer.
#
# Specifies the following relationship:
#  Rings should be created before any devices are added to them
#  Rings should be rebalanced if anything changes
#
# == Parameters
#  [*policy_id*]
#    (required) The id must be a positive integer. This is used to denote
#    the storage policy ID for the object ring.
#    Defaults to $name
#
#  [*part_power*]
#    (optional) The total number of partitions that should exist in the ring.
#    This is expressed as a power of 2.
#
#  [*replicas*]
#    (optional) Number of replicas that should be maintained of each stored
#    object.
#
#  [*min_part_hours*]
#    (optional) Minimum amount of time before partitions can be moved.
#
# == Dependencies
#
#   Class['swift']
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#   Adam Vinsh adam.vinsh@charter.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
define swift::ringbuilder::policy_ring (
  Pattern[/^\d+$/] $policy_id = $name,
  $part_power                 = undef,
  $replicas                   = undef,
  $min_part_hours             = undef,
) {
  include swift::deps
  Class['swift'] -> Swift::Ringbuilder::Policy_ring[$policy_id]

  if $policy_id == '0' {
    $ring_builder = 'object'
  } else {
    $ring_builder = "object-${policy_id}"
  }

  swift::ringbuilder::create { $ring_builder :
    part_power     => $part_power,
    replicas       => $replicas,
    min_part_hours => $min_part_hours,
  }
  swift::ringbuilder::rebalance { $ring_builder: }

  Swift::Ringbuilder::Create[$ring_builder] -> Ring_object_device <| |> ~> Swift::Ringbuilder::Rebalance[$ring_builder]
}
