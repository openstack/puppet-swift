#
# Configure swift dlo.
#
# == Examples
#
#  include swift::proxy::dlo
#
# == Parameters
#
# [*rate_limit_after_segment*]
#  (Optional) Start rate-limiting DLO segment serving after the Nth segment of
#  a segmented object.
#  Defaults to $facts['os_service_default'].
#
# [*rate_limit_segments_per_sec*]
#  (Optional) Once segment rate-limiting kicks in for an object, limit segments
#  served to N per second. 0 means no rate-limiting.
#  Defaults to $facts['os_service_default'].
#
# [*max_get_time*]
#  (Optional) Time limit on GET requests (seconds).
#  Defaults to $facts['os_service_default'].
#
# == Authors
#
#   Aleksandr Didenko adidenko@mirantis.com
#
# == Copyright
#
# Copyright 2015 Mirantis Inc, unless otherwise noted.
#
class swift::proxy::dlo (
  $rate_limit_after_segment    = $facts['os_service_default'],
  $rate_limit_segments_per_sec = $facts['os_service_default'],
  $max_get_time                = $facts['os_service_default'],
) {

  include swift::deps

  swift_proxy_config {
    'filter:dlo/use':                         value => 'egg:swift#dlo';
    'filter:dlo/rate_limit_after_segment':    value => $rate_limit_after_segment;
    'filter:dlo/rate_limit_segments_per_sec': value => $rate_limit_segments_per_sec;
    'filter:dlo/max_get_time':                value => $max_get_time;
  }
}
