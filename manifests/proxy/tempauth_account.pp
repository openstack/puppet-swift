# == class: swift::proxy::tempauth_account
# This class manages tempauth account_users
#
#  [*title*]
#    A string containing account data to write to proxy.conf
#    Required
#    Example: "user_<account>_<user>, <key> .<group1> .<groupx>"
#    Result in proxy.conf: user_<account>_<user> = <key> .<group1> .<groupx>
#
# == Authors
#
#   Adam Vinsh <adam.vinsh@charter.com>
#
define swift::proxy::tempauth_account() {

  include ::swift::deps

  # strip white space and split string into array elements around ','
  $account_data = strip(split($title,','))
  if $account_data[0] != '' {
    swift_proxy_config {
      "filter:tempauth/${account_data[0]}": value => "${account_data[1]}";
    }
  }
}
