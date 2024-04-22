Puppet::Type.type(:swift_ceilometer_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/swift/ceilometer.conf'
  end

end
