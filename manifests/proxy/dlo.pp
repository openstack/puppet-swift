#
# Configure swift dlo.
#
# == Examples
#
#  include ::swift::proxy::dlo
#
# == Parameters
#
# [*rate_limit_after_segment*]
# Start rate-limiting DLO segment serving after the Nth segment of a segmented object.
# Default to 10.
#
# [*rate_limit_segments_per_sec*]
# Once segment rate-limiting kicks in for an object, limit segments served to N per second.
# 0 means no rate-limiting.
# Default to 1.
#
# [*max_get_time*]
# Time limit on GET requests (seconds).
# Default to 86400.
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
  $rate_limit_after_segment    = '10',
  $rate_limit_segments_per_sec = '1',
  $max_get_time                = '86400'
) {

  include ::swift::deps

  swift_proxy_config {
    'filter:dlo/use':                         value => 'egg:swift#dlo';
    'filter:dlo/rate_limit_after_segment':    value => $rate_limit_after_segment;
    'filter:dlo/rate_limit_segments_per_sec': value => $rate_limit_segments_per_sec;
    'filter:dlo/max_get_time':                value => $max_get_time;
  }
}
