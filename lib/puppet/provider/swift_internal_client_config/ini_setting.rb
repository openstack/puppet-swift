Puppet::Type.type(:swift_internal_client_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/swift/internal-client.conf'
  end

end
