#
# Configure swift gatekeeper.
#
# == Examples
#
#  include swift::proxy::gatekeeper
#
# == Parameters
#
# [*shunt_inbound_x_timestamp*]
#  (Optional) Disallow clients to set arbitrary X-Timestamps on uploaded objects.
#  Defaults to $facts['os_service_default'].
#
# [*allow_reserved_names_header*]
#  (Optional) Allow clients to access and manipulate the null namespace by
#  including a header like
#     X-Allow-Reserved-Names: true
#  Defaults to $facts['os_service_default'].
#
# [*log_name*]
#  (Optional) The log name of gatekeeper.
#  Defaults to gatekeeper.
#
# [*log_facility*]
#  (Optional) The log facility of gatekeeper.
#  Defaults to LOG_LOCAL2.
#
# [*log_level*]
#  (Optional) The log level of gatekeeper.
#  Defaults to INFO.
#
# [*log_headers*]
#  (Optional) The log headers of gatekeeper.
#  Defaults to $facts['os_service_default'].
#
# [*log_address*]
#  (Optional) The log address of gatekeeper.
#  Defaults to '/dev/log'.
#
# == Authors
#
#   Xingchao Yu yuxcer@gmail.com
#
# == Copyright
#
# Copyright 2014 UnitedStack licensing@unitedstack.com
#
class swift::proxy::gatekeeper(
  $shunt_inbound_x_timestamp   = $facts['os_service_default'],
  $allow_reserved_names_header = $facts['os_service_default'],
  $log_name                    = 'gatekeeper',
  $log_facility                = 'LOG_LOCAL2',
  $log_level                   = 'INFO',
  $log_headers                 = $facts['os_service_default'],
  $log_address                 = '/dev/log'
) {

  include swift::deps

  swift_proxy_config {
    'filter:gatekeeper/use':                         value => 'egg:swift#gatekeeper';
    'filter:gatekeeper/shunt_inbound_x_timestamp':   value => $shunt_inbound_x_timestamp;
    'filter:gatekeeper/allow_reserved_names_header': value => $allow_reserved_names_header;
    'filter:gatekeeper/set log_name':                value => $log_name;
    'filter:gatekeeper/set log_facility':            value => $log_facility;
    'filter:gatekeeper/set log_level':               value => $log_level;
    'filter:gatekeeper/set log_headers':             value => $log_headers;
    'filter:gatekeeper/set log_address':             value => $log_address;
  }
}
