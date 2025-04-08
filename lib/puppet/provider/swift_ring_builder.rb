class Puppet::Provider::SwiftRingBuilder < Puppet::Provider

  def self.instances
    # TODO iterate through the databases
    # and add the database that we used a property
    ring.keys.collect do |name|
      new(:name => name)
    end
  end

  def address_string(address)
    ip = IPAddr.new(address)
    if ip.ipv6?
      '[' + ip.to_s + ']'
    else
      ip.to_s
    end
  end

  def lookup_ring
    object_hash = {}
    if File.exist?(builder_file_path(policy_index))
      if rows = swift_ring_builder(builder_file_path(policy_index)).split("\n")
        while row = rows.shift do
          if row.start_with?('Devices:')
            break
          end
        end
        rows.each do |row|
          # Swift 2.9.1+ output example:
          # /etc/swift/object.builder, build version 1
          # 262144 partitions, 1.000000 replicas, 1 regions, 1 zones, 1 devices, 0.00 balance, 0.00 dispersion
          # The minimum number of hours before a partition can be reassigned is 1
          # The overload factor is 0.00% (0.000000)
          # Ring file /etc/swift/object.ring.gz is up-to-date
          # Devices:    id  region  zone      ip address:port  replication ip:replication port      name weight partitions balance meta
          #              0       1     2       127.0.0.1:6021       127.0.0.1:6021                     2   1.00     262144    0.00
          if row =~ /^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\S+):(\d+)\s+\S+:\d+\s+(\S+)\s+(\d+\.\d+)\s+(\d+)\s*((-|\s-?)?\d+\.\d+)\s*(\S*)/
            address = address_string("#{$4}")
            if !policy_index.nil?
              policy = "#{policy_index}:"
            else
              policy = ''
            end
            object_hash["#{policy}#{address}:#{$5}/#{$6}"] = {
              :id           => $1,
              :region       => $2,
              :zone         => $3,
              :weight       => $7,
              :partitions   => $8,
              :balance      => $9,
              :meta         => $11,
              :policy_index => "#{policy_index}"
            }
          else
            Puppet.warning("Unexpected line: #{row}")
          end
        end
      end
    end
    object_hash
  end

  def builder_file_path(policy_index)
    self.class.builder_file_path(policy_index)
  end

  def exists?
    ring[resource[:name]]
  end

  def create
    [:zone, :weight].each do |param|
      raise(Puppet::Error, "#{param} is required") unless resource[param]
    end
    if :region == 'none'
      # Prior to Swift 1.8.0, regions did not exist.
      swift_ring_builder(
        builder_file_path(policy_index),
        'add',
        "z#{resource[:zone]}-#{device_path}_#{resource[:meta]}",
        resource[:weight]
      )
    else
      # Swift 1.8+
      # Region defaults to 1 if unspecified
      resource[:region] ||= 1
      swift_ring_builder(
        builder_file_path(policy_index),
        'add',
        "r#{resource[:region]}z#{resource[:zone]}-#{device_path}_#{resource[:meta]}",
        resource[:weight]
      )
    end
  end

  def device_path
    if resource[:name].split(/^\d+:/)[1].nil?
      return resource[:name]
    else
      return resource[:name].split(/^\d+:/)[1]
    end
  end

  def policy_index
    if resource[:name].split(/^\d+:/)[1].nil?
      return nil
    else
      Integer("#{resource[:name].match(/^\d+/)}")
    end
  end

  def id
    ring[resource[:name]][:id]
  end

  def id=(id)
    raise(Puppet::Error, "Cannot assign id, it is immutable")
  end

  def region
    ring[resource[:name]][:region]
  end

  def region=(region)
    raise(Puppet::Error, "Changing the region of a device is not yet supported.")
  end

  def zone
    ring[resource[:name]][:zone]
  end

  def zone=(zone)
    raise(Puppet::Error, "Changing the zone of a device is not yet supported.")
  end

  def weight
    ring[resource[:name]][:weight]
    # get the weight
  end

  def weight=(weight)
    swift_ring_builder(
      builder_file_path(policy_index),
      'set_weight',
      "d#{ring[device_path][:id]}",
      resource[:weight]
    )
    # requires a rebalance
  end

  def partitions
    ring[resource[:name]][:partitions]
  end

  def partitions=(part)
    raise(Puppet::Error, "Cannot set partitions, it is set by rebalancing")
  end

  def balance
    ring[resource[:name]][:balance]
  end

  def balance=(balance)
    raise(Puppet::Error, "Cannot set balance, it is set by rebalancing")
  end

  def meta
    ring[resource[:name]][:meta]
  end

  def meta=(meta)
    swift_ring_builder(
      builder_file_path(policy_index),
      'set_info',
      "d#{ring[device_path][:id]}",
      "_#{resource[:meta]}"
    )
  end

end
