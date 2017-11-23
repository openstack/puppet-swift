#
# Configure swift gatekeeper.
#
# == Examples
#
#  include swift::proxy::gatekeeper
#
# == Parameters
#
# [*log_name*]
# The log name of gatekeeper.
# Default to gatekeeper.
#
# [*log_facility*]
# The log facility of gatekeeper.
# Default to LOG_LOCAL2.
#
# [*log_level*]
# The log level of gatekeeper.
# Default to INFO.
#
# [*log_headers*]
# The log headers of gatekeeper.
# Default to false.
#
# [*log_address*]
# The log address of gatekeeper.
# Default to '/dev/log'.
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
  $log_name     = 'gatekeeper',
  $log_facility = 'LOG_LOCAL2',
  $log_level    = 'INFO',
  $log_headers  = false,
  $log_address  = '/dev/log'
) {

  include ::swift::deps

  swift_proxy_config {
    'filter:gatekeeper/use':              value => 'egg:swift#gatekeeper';
    'filter:gatekeeper/set log_name':     value => $log_name;
    'filter:gatekeeper/set log_facility': value => $log_facility;
    'filter:gatekeeper/set log_level':    value => $log_level;
    'filter:gatekeeper/set log_headers':  value => $log_headers;
    'filter:gatekeeper/set log_address':  value => $log_address;
  }
}
