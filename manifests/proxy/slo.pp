#
# Configure swift slo.
#
# == Examples
#
#  include swift::proxy::slo
#
# == Parameters
#
# [*max_manifest_segments*]
#  (Optional) Max manifest segments.
#  Defaults to $::os_service_default.
#
# [*max_manifest_size*]
#  (Optional) Max manifest size.
#  Defaults to $::os_service_default.
#
# [*rate_limit_under_size*]
#  (Optional) Rate limiting applies only to segments smaller than this size.
#  Defaults to $::os_service_default.
#
# [*rate_limit_after_segment*]
#  (Optional) Start rate-limiting SLO segment serving after the Nth segment of
#  a segmented object.
#  Defaults to $::os_service_default.
#
# [*rate_limit_segments_per_sec*]
#  (Optional) Once segment rate-limiting kicks in for an object, limit segments
#  served to N per second. 0 means no rate-limiting.
#  Defaults to $::os_service_default.
#
# [*max_get_time*]
#  (Optional) Time limit on GET requests (seconds).
#  Defaults to $::os_service_default.
#
# [*concurrency*]
#  (Optional) Limit how many subrequests may be executed concurrently.
#  Defaults to $::os_service_default.
#
# [*delete_concurrency*]
#  (Optional) Limit how many delete subrequests may be executed concurrently.
#  This may be used to separately tune validation and delete concurrency
#  values.
#  Defaults to $::os_service_default.
#
# [*yield_frequency*]
#  (Optional) Frequency, in seconds, to yield whitespace ahead of the final
#  response.
#  Defaults to $::os_service_default.
#
# [*allow_async_delete*]
#  (Optional) Allow clients to request the object-expirer handle the deletion
#  of segments using query params like `?multipart-manifest=delete&async=on`.
#  Defaults to $::os_service_default.
#
# == Authors
#
#   Xingchao Yu  yuxcer@gmail.com
#
# == Copyright
#
# Copyright 2014 UnitedStack licensing@unitedstack.com
#
class swift::proxy::slo (
  $max_manifest_segments       = $::os_service_default,
  $max_manifest_size           = $::os_service_default,
  $rate_limit_under_size       = $::os_service_default,
  $rate_limit_after_segment    = $::os_service_default,
  $rate_limit_segments_per_sec = $::os_service_default,
  $max_get_time                = $::os_service_default,
  $concurrency                 = $::os_service_default,
  $delete_concurrency          = $::os_service_default,
  $yield_frequency             = $::os_service_default,
  $allow_async_delete          = $::os_service_default,
) {

  include swift::deps

  swift_proxy_config {
    'filter:slo/use':                         value => 'egg:swift#slo';
    'filter:slo/max_manifest_segments':       value => $max_manifest_segments;
    'filter:slo/max_manifest_size':           value => $max_manifest_size;
    'filter:slo/rate_limit_under_size':       value => $rate_limit_under_size;
    'filter:slo/rate_limit_after_segment':    value => $rate_limit_after_segment;
    'filter:slo/rate_limit_segments_per_sec': value => $rate_limit_segments_per_sec;
    'filter:slo/max_get_time':                value => $max_get_time;
    'filter:slo/concurrency':                 value => $concurrency;
    'filter:slo/delete_concurrency':          value => $delete_concurrency;
    'filter:slo/yield_frequency':             value => $yield_frequency;
    'filter:slo/allow_async_delete':          value => $allow_async_delete;
  }
}
