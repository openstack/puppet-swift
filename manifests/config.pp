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
class swift::config (
  $swift_config                       = {},
  $swift_container_sync_realms_config = {}
) {

  include ::swift::deps
  validate_hash($swift_config)
  validate_hash($swift_container_sync_realms_config)

  create_resources('swift_config', $swift_config)
  create_resources('swift_container_sync_realms_config', $swift_container_sync_realms_config)
}
