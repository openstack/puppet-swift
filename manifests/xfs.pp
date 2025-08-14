#
# package dependencies for creating
# xfs partitions
class swift::xfs {

  include swift::deps

  $packages = ['xfsprogs', 'parted']
  stdlib::ensure_packages($packages)

}
