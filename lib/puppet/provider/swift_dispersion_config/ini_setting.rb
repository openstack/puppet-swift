Puppet::Type.type(:swift_dispersion_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/swift/dispersion.conf'
  end

end
