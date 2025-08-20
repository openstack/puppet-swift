#
# Configure swift formpost.
#
# == Parameters
#
#  [*allowed_digests*]
#    The digest algorithm(s) supported for generating signatures.
#    Optional. Defaults to $facts['os_service_default'].
#
# == Dependencies
#
# == Examples
#
#  include swift::proxy::formpost
#
# == Authors
#
#   Mehdi Abaakouk <sileht@sileht.net>
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::formpost (
  $allowed_digests = $facts['os_service_default'],
) {
  include swift::deps

  swift_proxy_config {
    'filter:formpost/use':             value => 'egg:swift#formpost';
    'filter:formpost/allowed_digests': value => join(any2array($allowed_digests), ' ');
  }
}
