#
# Configure Swift encryption.
#
# == Examples
#
#  include ::swift::proxy::encryption
#
# == Parameters
#
# [*disable_encryption*]
# By default all PUT or POST'ed object data and/or metadata will be encrypted.
# Encryption of new data and/or metadata may be disabled by setting
# disable_encryption to True. However, all encryption middleware should remain
# in the pipeline in order for existing encrypted data to be read.
#
class swift::proxy::encryption (
  $disable_encryption = false
) {

  include ::swift::deps

  swift_proxy_config {
    'filter:encryption/use':                value => 'egg:swift#encryption';
    'filter:encryption/disable_encryption': value => $disable_encryption;
  }
}

