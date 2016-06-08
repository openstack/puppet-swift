require File.join(File.dirname(__FILE__), '..', 'swift_ring_builder')
Puppet::Type.type(:ring_container_device).provide(
  :swift_ring_builder,
  :parent => Puppet::Provider::SwiftRingBuilder
) do

  optional_commands :swift_ring_builder => 'swift-ring-builder'

  def prefetch(resource)
    @my_ring = lookup_ring
  end

  def ring
    @my_ring ||= lookup_ring
  end

  def self.builder_file_path(policy_index)
      '/etc/swift/container.builder'
  end

end
