Puppet::Type.type(:swift_account_uwsgi_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do
  def self.file_path
    '/etc/swift/swift-account-server-uwsgi.ini'
  end
end
