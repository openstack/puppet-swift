#
# This class can be set to manage keystone middleware for swift proxy
#
# == Parameters
#
#  [*operator_roles*]
#    (Optional) a list of keystone roles a user must have to gain access to Swift.
#    Defaults to ['admin', 'SwiftOperator']
#    Must be an array of strings
#    Swift operator roles must be defined in swift::keystone::auth because
#    keystone API access is usually not available on Swift proxy nodes.
#
#  [*reseller_prefix*]
#    (Optional) The prefix used for reseller URL.
#    Defaults to 'AUTH_'
#
#  [*reseller_admin_role*]
#    The reseller admin role has the ability to create and delete accounts.
#    This role defines who has the ability to manage other swift accounts.
#    (Optional)
#    Defaults to Undef.
#
# DEPRECATED PARAMETERS
# [*is_admin*]
#   Deprecated, this parameter does nothing.
#
# == Authors
#
#  Dan Bode dan@puppetlabs.com
#  Francois Charlier fcharlier@ploup.net
#
class swift::proxy::keystone(
  $operator_roles      = ['admin', 'SwiftOperator'],
  $reseller_prefix     = 'AUTH_',
  $reseller_admin_role = undef,
  # DEPRECATED PARAMETERS
  $is_admin            = undef
) {

  include ::swift::deps

  if $is_admin {
        warning('is_admin parameter is deprecated, has no effect and will be removed in a future release.')
  }

  swift_proxy_config {
    'filter:keystone/use':                 value => 'egg:swift#keystoneauth';
    'filter:keystone/operator_roles':      value => join(any2array($operator_roles), ', ');
    'filter:keystone/reseller_prefix':     value => $reseller_prefix;
    'filter:keystone/reseller_admin_role': value => $reseller_admin_role;
  }
}
