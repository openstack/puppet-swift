#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
define swift::storage::filter::healthcheck(
) {

  include ::swift::deps

  concat::fragment { "swift_healthcheck_${name}":
    target  => "/etc/swift/${name}-server.conf",
    content => template('swift/healthcheck.conf.erb'),
    order   => '25',
  }
}
