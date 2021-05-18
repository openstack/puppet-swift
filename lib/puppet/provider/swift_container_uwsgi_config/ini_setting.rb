Puppet::Type.type(:swift_container_uwsgi_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do
  def self.file_path
    '/etc/swift/swift-container-server-uwsgi.ini'
  end
end
