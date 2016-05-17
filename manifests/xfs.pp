#
# package dependencies for creating
# xfs partitions
class swift::xfs {

  include ::swift::deps

  $packages = ['xfsprogs', 'parted']
  ensure_packages($packages)

}
