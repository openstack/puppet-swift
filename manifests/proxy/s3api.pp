#
# Configure swift s3api.
#
# == Dependencies
#
# == Parameters
#
# [*allow_no_owner*]
#   Whether objects without owner information should be visible or not
#   Defaults to $::os_service_default.
#
# [*location*]
#   A region name of the swift cluster.
#   Defaults to $::os_service_default.
#
# [*s3_acl*]
#   Use own metadata for ACLs.
#   Defaults to $::os_service_default.
#
# [*auth_pipeline_check*]
#   Enable pipeline order check
#   Defaults to 'false'
#
# [*max_upload_part_num*]
#   Max upload per num
#   Default to 1000.
#
# [*check_bucket_owner*]
#   Enable returning only buckets which owner are the user who requested
#   GET Service operation.
#   Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
# [*ensure*]
#   Enable or not s3api middleware
#   Defaults to undef
#
class swift::proxy::s3api(
  $allow_no_owner      = $::os_service_default,
  $location            = $::os_service_default,
  $s3_acl              = $::os_service_default,
  $auth_pipeline_check = false,
  $max_upload_part_num = 1000,
  $check_bucket_owner  = $::os_service_default,
  # DEPRECATED PARAMETERS
  $ensure              = undef,
) {

  include swift::deps

  if $ensure != undef {
    warning('The ensure parameter has been deprecated and has no effect')
  }

  swift_proxy_config {
    'filter:s3api/use':                 value => 'egg:swift#s3api';
    'filter:s3api/allow_no_owner':      value => $allow_no_owner;
    'filter:s3api/location':            value => $location;
    'filter:s3api/s3_acl':              value => $s3_acl;
    'filter:s3api/auth_pipeline_check': value => $auth_pipeline_check;
    'filter:s3api/max_upload_part_num': value => $max_upload_part_num;
    'filter:s3api/check_bucket_owner':  value => $check_bucket_owner;
  }
}
