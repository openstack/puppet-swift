#
# Configure swift s3api.
#
# == Dependencies
#
# == Parameters
#
# [*ensure*]
#   Enable or not s3api middleware
#   Defaults to 'present'
#
# [*auth_pipeline_check*]
#   Enable pipeline order check
#   Defaults to 'false'
#
# [*max_upload_part_num*]
#   Max upload per num
#   Default to 1000.
#
class swift::proxy::s3api(
  $ensure = 'present',
  $auth_pipeline_check = false,
  $max_upload_part_num = 1000,
) {

  include swift::deps

  swift_proxy_config {
    'filter:s3api/use': value => 'egg:swift#s3api';
    'filter:s3api/auth_pipeline_check': value => $auth_pipeline_check;
    'filter:s3api/max_upload_part_num': value => $max_upload_part_num;
  }
}
