#
# Configure swift backend limit
#
# == Parameters
#
# [*requests_per_device_per_second*]
#   (optional) Set the maximum rate of requests per second per device per
#   worker.
#   Defaults to $facts['os_service_default']
#
# [*delete_requests_per_device_per_second*]
#   (optional) Set the maximum rate of DELETE requests per second per device
#   per worker.
#   Defaults to $facts['os_service_default']
#
# [*get_requests_per_device_per_second*]
#   (optional) Set the maximum rate of GET requests per second per device per
#   worker.
#   Defaults to $facts['os_service_default']
#
# [*head_requests_per_device_per_second*]
#   (optional) Set the maximum rate of HEAD requests per second per device per
#   worker.
#   Defaults to $facts['os_service_default']
#
# [*post_requests_per_device_per_second*]
#   (optional) Set the maximum rate of POST requests per second per device per
#   worker.
#   Defaults to $facts['os_service_default']
#
# [*put_requests_per_device_per_second*]
#   (optional) Set the maximum rate of PUT requests per second per device per
#   worker.
#   Defaults to $facts['os_service_default']
#
# [*replicate_requests_per_device_per_second*]
#   (optional) Set the maximum rate of REPLICATE requests per second per device
#   per worker.
#   Defaults to $facts['os_service_default']
#
# [*update_requests_per_device_per_second*]
#   (optional) Set the maximum rate of UPDATE requests per second per device
#   per worker.
#   Defaults to $facts['os_service_default']
#
# [*requests_per_device_rate_buffer*]
#   (optional) Set the number of seconds of unused rate-limiting allowance that
#   can accumulate and be used to allow a subsequent burst of requests.
#   Defaults to $facts['os_service_default']
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Takashi Kajinami tkajinam@redhat.com
#
# == Copyright
#
# Copyright 2022 Red Hat, unless otherwise noted.
#
define swift::storage::filter::backend_ratelimit(
  $requests_per_device_per_second           = $facts['os_service_default'],
  $delete_requests_per_device_per_second    = $facts['os_service_default'],
  $get_requests_per_device_per_second       = $facts['os_service_default'],
  $head_requests_per_device_per_second      = $facts['os_service_default'],
  $post_requests_per_device_per_second      = $facts['os_service_default'],
  $put_requests_per_device_per_second       = $facts['os_service_default'],
  $replicate_requests_per_device_per_second = $facts['os_service_default'],
  $update_requests_per_device_per_second    = $facts['os_service_default'],
  $requests_per_device_rate_buffer          = $facts['os_service_default'],
) {

  include swift::deps

  $config_type = "swift_${name}_config"

  create_resources($config_type, {
    'filter:backend_ratelimit/use'                                      => {
      'value' => 'egg:swift#backend_ratelimit',
    },
    'filter:backend_ratelimit/requests_per_device_per_second'           => {
      'value' => $requests_per_device_per_second,
    },
    'filter:backend_ratelimit/delete_requests_per_device_per_second'    => {
      'value' => $delete_requests_per_device_per_second,
    },
    'filter:backend_ratelimit/get_requests_per_device_per_second'       => {
      'value' => $get_requests_per_device_per_second,
    },
    'filter:backend_ratelimit/head_requests_per_device_per_second'      => {
      'value' => $head_requests_per_device_per_second,
    },
    'filter:backend_ratelimit/post_requests_per_device_per_second'      => {
      'value' => $post_requests_per_device_per_second,
    },
    'filter:backend_ratelimit/put_requests_per_device_per_second'       => {
      'value' => $put_requests_per_device_per_second,
    },
    'filter:backend_ratelimit/replicate_requests_per_device_per_second' => {
      'value' => $replicate_requests_per_device_per_second,
    },
    'filter:backend_ratelimit/update_requests_per_device_per_second'    => {
      'value' => $update_requests_per_device_per_second,
    },
    'filter:backend_ratelimit/requests_per_device_rate_buffer'          => {
      'value' => $requests_per_device_rate_buffer,
    }
  })

}
