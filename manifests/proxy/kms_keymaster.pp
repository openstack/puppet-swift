#
# Configure Swift KMS Keymaster middleware.
#
# == Examples
#
#  include ::swift::proxy::kms_keymaster
#
# == Parameters
#
# [*keymaster_config_path*]
# Sets the path from which the keymaster config options should be read
#
class swift::proxy::kms_keymaster (
  $keymaster_config_path = '/etc/swift/keymaster.conf'
) {

  include ::swift::deps

  swift_proxy_config {
    'filter:kms_keymaster/use':                   value => 'egg:swift#kms_keymaster';
    'filter:kms_keymaster/keymaster_config_path': value => $keymaster_config_path;
  }
}

