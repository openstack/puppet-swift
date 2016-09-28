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

  swift_proxy_config {
    'filter:versioned_writes/use':                    value => 'egg:swift#versioned_writes';
    'filter:versioned_writes/allow_versioned_writes': value => $allow_versioned_writes;
  }
}
