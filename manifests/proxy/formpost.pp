#
# Configure swift formpost.
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
class swift::proxy::formpost() {

  include ::swift::deps

  swift_proxy_config {
    'filter:formpost/use': value => 'egg:swift#formpost';
  }
}
