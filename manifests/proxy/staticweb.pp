#
# Configure swift staticweb, see documentation for Swift staticweb middleware
# to understand more about configuration.
#
# == Dependencies
#
# == Examples
#
#  include 'swift::proxy::staticweb'
#
# == Authors
#
#   Mehdi Abaakouk <sileht@sileht.net>
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::staticweb() {

  include ::swift::deps

  swift_proxy_config {
    'filter:staticweb/use':              value => 'egg:swift#staticweb';
  }
}
