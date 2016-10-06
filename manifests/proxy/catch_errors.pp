#
# Configure swift cache_errors.
#
# == Dependencies
#
# == Examples
#
#  include swift::proxy::catch_errors
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::catch_errors() {

  include ::swift::deps

  swift_proxy_config {
    'filter:catch_errors/use': value => 'egg:swift#catch_errors';
  }
}
