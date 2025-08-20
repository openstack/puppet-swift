# == Class: swift::ringbuilder::rebalance
#
#   Reblances the specified ring. Assumes that the ring already exists
#   and is stored at /etc/swift/${name}.builder
#
# == Parameters
#
# [*ring_type*]
#   Optional. Type of ring to rebalance. The ring file is assumed to be at
#   the path /etc/swift/${ring_type}.builder
#
# [*seed*]
#   Optional. Seed value used to seed pythons pseudo-random for ringbuilding.
#
define swift::ringbuilder::rebalance (
  Swift::RingType $ring_type                            = $name,
  Optional[Variant[Integer[0], Pattern[/^\d+$/]]] $seed = undef
) {
  include swift::deps

  exec { "rebalance_${ring_type}":
    command     => strip("swift-ring-builder /etc/swift/${ring_type}.builder rebalance ${seed}"),
    path        => ['/usr/bin'],
    refreshonly => true,
    before      => Anchor['swift::config::end'],
    returns     => [0, 1],
  }
}
