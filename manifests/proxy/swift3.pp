#
# DEPRECATED!
# Configure swift swift3.
#
# == Dependencies
#
# == Parameters
#
# [*ensure*]
#   Enable or not swift3 middleware
#   Defaults to undef
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#   Joe Topjian joe@topjian.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::swift3(
  $ensure = undef
) {

  warning('swift::proxy::swift3 is deprecated and has no effect. \
Use swift::proxy::s3api to use s3api middleware implemented in swift.')

}
