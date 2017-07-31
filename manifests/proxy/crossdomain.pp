#
# Configure swift crossdomain.
#
# == Examples
#
#  include swift::proxy::crossdomain
#
# == Parameters
#
# [*cross_domain_policy*]
#   cross_domain_policy value according to https://docs.openstack.org/swift/latest/crossdomain.html
#   default: <allow-access-from domain="*" secure="false" />
#
class swift::proxy::crossdomain (
  $cross_domain_policy = '<allow-access-from domain="*" secure="false" />',
) {

  include ::swift::deps

  swift_proxy_config {
    'filter:crossdomain/use':                 value => 'egg:swift#crossdomain';
    'filter:crossdomain/cross_domain_policy': value => $cross_domain_policy;
  }
}
