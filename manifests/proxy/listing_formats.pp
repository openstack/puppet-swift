#
# Configure swift listing_formats.
#
# == Parameters
#
# == Examples
#
#  include swift::proxy::listing_formats
#
# == Authors
#
#   Takashi Kajinami <tkajinam@redhat.com>
#
# == Copyright
#
# Copyright (C) 2021 Red Hat
#
class swift::proxy::listing_formats (
) {

  include swift::deps

  swift_proxy_config {
    'filter:listing_formats/use': value => 'egg:swift#listing_formats';
  }
}
