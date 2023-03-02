#
# Configure swift etag quoter.
#
# == Parameters
#
#  [*enabled_by_default*]
#    Enable quoting ETag header cluster-wide by default.
#    Defaults to $facts['os_service_default'].
#
# == Examples
#
#  class {'swift::proxy::etag_quoter':
#    enable_by_default => true,
#  }
#
# == Authors
#
#   Takashi Kajinami <tkajinam@redhat.com>
#
# == Copyright
#
# Copyright (C) 2020 Red Hat
#
class swift::proxy::etag_quoter (
  $enabled_by_default      = $facts['os_service_default']
) {

  include swift::deps

  swift_proxy_config {
    'filter:etag-quoter/use':                value => 'egg:swift#etag_quoter';
    'filter:etag-quoter/enabled_by_default': value => $enabled_by_default;
  }
}
