require File.join(File.dirname(__FILE__), '..', 'swift_ring_builder')
Puppet::Type.type(:ring_object_device).provide(
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
    if policy_index.nil?
      '/etc/swift/object.builder'
    elsif policy_index == 0
      '/etc/swift/object.builder'
    else
      "/etc/swift/object-#{policy_index}.builder"
    end
  end
end
