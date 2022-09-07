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
#   Defaults to $::os_service_default.
#
# [*max_sleep_time_seconds*]
#   (optional) Time before the app returns a 498 response.
#   Defaults to $::os_service_default.
#
# [*log_sleep_time_seconds*]
#   (optional) if >0, enables logging of sleeps longer than the value.
#   Defaults to $::os_service_default.
#
# [*rate_buffer_seconds*]
#   (optional) Time in second the rate counter can skip.
#   Defaults to $::os_service_default.
#
# [*account_ratelimit*]
#   (optional) if >0, limits PUT and DELETE requests to containers
#   Defaults to $::os_service_default.
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
class swift::proxy::ratelimit(
  $clock_accuracy         = $::os_service_default,
  $max_sleep_time_seconds = $::os_service_default,
  $log_sleep_time_seconds = $::os_service_default,
  $rate_buffer_seconds    = $::os_service_default,
  $account_ratelimit      = $::os_service_default
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
}
