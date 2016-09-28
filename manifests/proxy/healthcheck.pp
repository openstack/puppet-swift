#
# Configure swift healthcheck.
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift::proxy::healthcheck() {

  include ::swift::deps

  swift_proxy_config {
    'filter:healthcheck/use': value => 'egg:swift#healthcheck';
  }
}
