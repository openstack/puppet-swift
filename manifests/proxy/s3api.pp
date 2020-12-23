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
# [*dns_compliant_bucket_names*]
#   Enforce DNS-compliant bucket names
#   Defaults to $::os_service_default.
#
# [*max_bucket_listing*]
#   The default maximum nuber of objects returned in the GET Bucket response.
#   Defaults to $::os_service_default.
#
# [*max_parts_listing*]
#   The maximum number of parts returned in the List Parts operation.
#   Defaults to $::os_service_default.
#
# [*max_multi_delete_objects*]
#   The maximum number of objects deleted with the Multi-Object Delete
#   operation.
#   Defaults to $::os_service_default.
#
# [*multi_delete_concurrency*]
#   The number of objects to delete at a time with the Multi-Object Delete
#   operation.
#   Defaults to $::os_service_default.
#
# [*s3_acl*]
#   Use own metadata for ACLs.
#   Defaults to $::os_service_default.
#
# [*storage_domain*]
#   A host name of the Swift cluster
#   Defaults to $::os_service_default.
#
# [*auth_pipeline_check*]
#   Enable pipeline order check
#   Defaults to 'false'
#
# [*allow_multipart_uploads*]
#   Enable multi-part uploads.
#   Defaults to $::os_service_default.
#
# [*max_upload_part_num*]
#   Max upload per num
#   Default to $::os_service_default.
#
# [*check_bucket_owner*]
#   Enable returning only buckets which owner are the user who requested
#   GET Service operation.
#   Defaults to $::os_service_default.
#
# [*force_swift_request_proxy_log*]
#   Output Swift style log in addition to S3 style log.
#   Defaults to $::os_service_default.
#
# [*min_segment_size*]
#   Minimum size of each part in a multipart upload
#   Defaults to $::os_service_default.
#
# [*log_name*]
#   Override the default log routing for s3api middleware
#   Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
# [*ensure*]
#   Enable or not s3api middleware
#   Defaults to undef
#
class swift::proxy::s3api(
  $allow_no_owner                = $::os_service_default,
  $location                      = $::os_service_default,
  $dns_compliant_bucket_names    = $::os_service_default,
  $max_bucket_listing            = $::os_service_default,
  $max_parts_listing             = $::os_service_default,
  $max_multi_delete_objects      = $::os_service_default,
  $multi_delete_concurrency      = $::os_service_default,
  $s3_acl                        = $::os_service_default,
  $storage_domain                = $::os_service_default,
  $auth_pipeline_check           = false,
  $allow_multipart_uploads       = $::os_service_default,
  $max_upload_part_num           = $::os_service_default,
  $check_bucket_owner            = $::os_service_default,
  $force_swift_request_proxy_log = $::os_service_default,
  $min_segment_size              = $::os_service_default,
  $log_name                      = $::os_service_default,
  # DEPRECATED PARAMETERS
  $ensure                        = undef,
) {

  include swift::deps

  if $ensure != undef {
    warning('The ensure parameter has been deprecated and has no effect')
  }

  swift_proxy_config {
    'filter:s3api/use':                           value => 'egg:swift#s3api';
    'filter:s3api/allow_no_owner':                value => $allow_no_owner;
    'filter:s3api/location':                      value => $location;
    'filter:s3api/dns_compliant_bucket_names':    value => $dns_compliant_bucket_names;
    'filter:s3api/max_bucket_listing':            value => $max_bucket_listing;
    'filter:s3api/max_parts_listing':             value => $max_parts_listing;
    'filter:s3api/max_multi_delete_objects':      value => $max_multi_delete_objects;
    'filter:s3api/multi_delete_concurrency':      value => $multi_delete_concurrency;
    'filter:s3api/s3_acl':                        value => $s3_acl;
    'filter:s3api/storage_domain':                value => $storage_domain;
    'filter:s3api/allow_multipart_uploads':       value => $allow_multipart_uploads;
    'filter:s3api/auth_pipeline_check':           value => $auth_pipeline_check;
    'filter:s3api/max_upload_part_num':           value => $max_upload_part_num;
    'filter:s3api/check_bucket_owner':            value => $check_bucket_owner;
    'filter:s3api/force_swift_request_proxy_log': value => $force_swift_request_proxy_log;
    'filter:s3api/min_segment_size':              value => $min_segment_size;
    'filter:s3api/log_name':                      value => $log_name;
  }
}
