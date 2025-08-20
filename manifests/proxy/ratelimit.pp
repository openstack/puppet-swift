# == Class: swift::proxy::ratelimit
#
# Configure swift ratelimit.
#
# See Swift's ratelimit documentation for more detail about the values.
#
# === Parameters
#
# [*clock_accuracy*]
#   (optional) The accuracy of swift proxy servers' clocks.
#   1000 is 1ms max difference. No rate should be higher than this.
#   Defaults to $facts['os_service_default'].
#
# [*max_sleep_time_seconds*]
#   (optional) Time before the app returns a 498 response.
#   Defaults to $facts['os_service_default'].
#
# [*log_sleep_time_seconds*]
#   (optional) if >0, enables logging of sleeps longer than the value.
#   Defaults to $facts['os_service_default'].
#
# [*rate_buffer_seconds*]
#   (optional) Time in second the rate counter can skip.
#   Defaults to $facts['os_service_default'].
#
# [*account_ratelimit*]
#   (optional) if >0, limits PUT and DELETE requests to containers
#   Defaults to $facts['os_service_default'].
#
# [*container_ratelimit*]
#   (optional) Hash of size(keys) and requests per seconds(values).
#   Defaults to {}.
#
# [*container_listing_ratelimit*]
#   (optional) Hash of size(keys) and requests per seconds(values).
#   Defaults to {}.
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::ratelimit (
  $clock_accuracy                   = $facts['os_service_default'],
  $max_sleep_time_seconds           = $facts['os_service_default'],
  $log_sleep_time_seconds           = $facts['os_service_default'],
  $rate_buffer_seconds              = $facts['os_service_default'],
  $account_ratelimit                = $facts['os_service_default'],
  Hash $container_ratelimit         = {},
  Hash $container_listing_ratelimit = {},
) {
  include swift::deps

  swift_proxy_config {
    'filter:ratelimit/use':                    value => 'egg:swift#ratelimit';
    'filter:ratelimit/clock_accuracy':         value => $clock_accuracy;
    'filter:ratelimit/max_sleep_time_seconds': value => $max_sleep_time_seconds;
    'filter:ratelimit/log_sleep_time_seconds': value => $log_sleep_time_seconds;
    'filter:ratelimit/rate_buffer_seconds':    value => $rate_buffer_seconds;
    'filter:ratelimit/account_ratelimit':      value => $account_ratelimit;
  }

  $container_ratelimit.each | $size, $limit | {
    swift_proxy_config {
      "filter:ratelimit/container_ratelimit_${size}": value => $limit;
    }
  }

  $container_listing_ratelimit.each | $size, $limit | {
    swift_proxy_config {
      "filter:ratelimit/container_listing_ratelimit_${size}": value => $limit;
    }
  }
}
