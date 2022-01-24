Puppet::Type.type(:swift_account_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def setting
    val = super
    return nil if val == ''
    val
  end

  def self.file_path
    '/etc/swift/account-server.conf'
  end

end
