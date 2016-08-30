#
# Configure Swift versioned_writes.
#
# == Examples
#
#  include ::swift::proxy::versioned_writes
#
# == Parameters
#
# [*allow_versioned_writes*]
# Enables using versioned writes middleware and exposing configuration
# settings via HTTP GET /info.
#
class swift::proxy::versioned_writes (
  $allow_versioned_writes = false
) {

  include ::swift::deps

  concat::fragment { 'swift_versioned_writes':
    target  => '/etc/swift/proxy-server.conf',
    content => template('swift/proxy/versioned_writes.conf.erb'),
    order   => '250',
  }

}
