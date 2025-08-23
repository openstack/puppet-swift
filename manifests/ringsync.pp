# == Define: swift::ringsync
#
# [*ring_server*]
#   (required) IP or hostname of ring servers
# [*ring_type*]
#   (optional) The type of ring to create. Accepts object|container|account
#
define swift::ringsync (
  String[1] $ring_server,
  Swift::RingType $ring_type = $name,
) {
  include swift::deps

  Exec { path => '/usr/bin' }

  rsync::get { "/etc/swift/${ring_type}.ring.gz":
    source => "rsync://${ring_server}/swift_server/${ring_type}.ring.gz",
  }
}
