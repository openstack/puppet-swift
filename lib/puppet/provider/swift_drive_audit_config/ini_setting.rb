Puppet::Type.type(:swift_drive_audit_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/swift/drive-audit.conf'
  end

end
