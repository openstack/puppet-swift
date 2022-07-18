#
# Configure swift cache_errors.
#
# == Dependencies
#
# == Examples
#
#  include swift::internal_client::catch_errors
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::internal_client::catch_errors() {

  include swift::deps

  swift_internal_client_config {
    'filter:catch_errors/use': value => 'egg:swift#catch_errors';
  }
}
