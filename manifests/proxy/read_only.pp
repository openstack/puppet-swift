# == Class: swift::proxy::read_only
#
# Configure read_only middleware
#
# === Parameters
#
# [*read_only*]
#   (optional) Turn on global read only.
#   Defauls to $facts['os_service_default']
#
# [*allow_deletes*]
#   (optional) Allow deletes.
#   Defauls to $facts['os_service_default']
#
class swift::proxy::read_only(
  $read_only     = $facts['os_service_default'],
  $allow_deletes = $facts['os_service_default']
) {

  include swift::deps

  swift_proxy_config {
    'filter:read_only/use':           value => 'egg:swift#read_only';
    'filter:read_only/read_only':     value => $read_only;
    'filter:read_only/allow_deletes': value => $allow_deletes;
  }
}
