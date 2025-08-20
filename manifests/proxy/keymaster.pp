#
# Configure Swift Keymaster middleware.
#
# == Examples
#
#  include swift::proxy::keymaster
#
# == Parameters
#
# [*encryption_root_secret*]
# Encryption root secret value.
#
class swift::proxy::keymaster (
  $encryption_root_secret,
) {
  include swift::deps

  swift_proxy_config {
    'filter:keymaster/use':                    value => 'egg:swift#keymaster';
    'filter:keymaster/encryption_root_secret': value => $encryption_root_secret, secret => true;
  }
}
