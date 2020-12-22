#
# Configure swift s3api.
#
# == Dependencies
#
# == Parameters
#
# [*auth_pipeline_check*]
#   Enable pipeline order check
#   Defaults to 'false'
#
# [*max_upload_part_num*]
#   Max upload per num
#   Default to 1000.
#
# DEPRECATED PARAMETERS
#
# [*ensure*]
#   Enable or not s3api middleware
#   Defaults to undef
#
class swift::proxy::s3api(
  $auth_pipeline_check = false,
  $max_upload_part_num = 1000,
  # DEPRECATED PARAMETERS
  $ensure              = undef,
) {

  include swift::deps

  if $ensure != undef {
    warning('The ensure parameter has been deprecated and has no effect')
  }

  swift_proxy_config {
    'filter:s3api/use':                 value => 'egg:swift#s3api';
    'filter:s3api/auth_pipeline_check': value => $auth_pipeline_check;
    'filter:s3api/max_upload_part_num': value => $max_upload_part_num;
  }
}
