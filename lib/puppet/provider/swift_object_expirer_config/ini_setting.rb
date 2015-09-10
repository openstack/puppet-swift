Puppet::Type.type(:swift_object_expirer_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/swift/object-expirer.conf'
  end

end
