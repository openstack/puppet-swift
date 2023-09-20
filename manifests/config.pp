# == Class: swift::config
#
# This class is used to manage arbitrary Swift configurations.
#
# === Parameters
#
# [*swift_config*]
#   (optional) Allow configuration of arbitrary Swift configurations.
#   The value is an hash of swift_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   swift_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
# [*swift_container_sync_realms_config*]
#   (optional) Allow configuration for specifying the allowable
#   clusters and their information.
#
# [*swift_proxy_config*]
#   (optional) Allow configuration of arbitrary Swift Proxy configurations.
#   The value is an hash of swift_proxy_config resources.
#
# [*swift_account_config*]
#   (optional) Allow configuration of arbitrary Swift Account configurations.
#   The value is an hash of swift_account_config resources.
#
# [*swift_container_config*]
#   (optional) Allow configuration of arbitrary Swift Container configurations.
#   The value is an hash of swift_container_config resources.
#
# [*swift_object_config*]
#   (optional) Allow configuration of arbitrary Swift Object configurations.
#   The value is an hash of swift_object_config resources.
#
# [*swift_internal_client_config*]
#   (optional) Allow configuration of arbitrary Swift internal client
#   configurations.
#   The value is an hash of swift_internal_client_config resources.
#
class swift::config (
  Hash $swift_config                       = {},
  Hash $swift_container_sync_realms_config = {},
  Hash $swift_proxy_config                 = {},
  Hash $swift_account_config               = {},
  Hash $swift_container_config             = {},
  Hash $swift_object_config                = {},
  Hash $swift_internal_client_config       = {},
) {

  include swift::deps

  create_resources('swift_config', $swift_config)
  create_resources('swift_container_sync_realms_config', $swift_container_sync_realms_config)
  create_resources('swift_proxy_config', $swift_proxy_config)
  create_resources('swift_account_config', $swift_proxy_config)
  create_resources('swift_container_config', $swift_container_config)
  create_resources('swift_object_config', $swift_object_config)
  create_resources('swift_internal_client_config', $swift_internal_client_config)
}
