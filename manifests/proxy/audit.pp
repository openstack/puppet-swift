# == Class: swift::proxy::audit
#
# Configure audit middleware for Swift proxy.
#
# === Parameters
#
# [*filter_factory*]
#   (Optional) The audit filter factory.
#   Defaults to 'keystonemiddleware.audit:filter_factory'
#
# [*audit_map_file*]
#   (Optional) The audit map file.
#   Defaults to '/etc/pycadf/swift_api_audit_map.conf'
#
# == Authors
#
# Christian Schwede <cschwede@redhat.com>
# Tobias Urdin <tobias.urdin@binero.se>
#
class swift::proxy::audit (
  $filter_factory = 'keystonemiddleware.audit:filter_factory',
  $audit_map_file = '/etc/pycadf/swift_api_audit_map.conf',
) {

  include swift::deps

  swift_proxy_config {
    'filter:audit/paste.filter_factory': value => $filter_factory;
    'filter:audit/audit_map_file':       value => $audit_map_file;
  }
}
