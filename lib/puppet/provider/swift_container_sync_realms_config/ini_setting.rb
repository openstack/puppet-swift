Puppet::Type.type(:swift_container_sync_realms_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/swift/container-sync-realms.conf'
  end

end
