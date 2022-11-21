Puppet::Type.newtype(:ring_object_device) do
  require 'ipaddr'
  require 'uri'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      # If storage policy_index is specified first strip that off.
      # Resource name is not required to start with a policy_index
      if !value.split(/^\d+:/)[1].nil?
        value = value.split(/^\d+:/)[1]
      end
      # we have to have URI Scheme so we just add http:// and ignore it later
      uri = URI('http://' + value)
      address = uri.host
      if ['','/'].include?(uri.path)
        raise(Puppet::Error, "namevar should contain a device")
      end
      IPAddr.new(address)
    end

    munge do |value|
      # If storage policy_index is specified first strip that off.
      # Resource name is not required to start with a policy_index
      if !value.split(/^\d+:/)[1].nil?
        value_without_policy = value.split(/^\d+:/)[1]
      else
        value_without_policy = value
      end
      # we have to have URI Scheme so we just add http:// and ignore it later
      uri = URI('http://' + value_without_policy)
      ip = IPAddr.new(uri.host)
      if ip.ipv6?
        value.gsub(uri.host, '[' + ip.to_s + ']')
      else
        value
      end
    end
  end

  newproperty(:region)

  newproperty(:zone)

  newproperty(:weight) do
    munge do |value|
      "%.2f" % value
    end
  end
  
  newproperty(:meta)

  [:id, :partitions, :balance].each do |param|
    newproperty(param) do
      validate do |value|
        raise(Puppet::Error, "#{param} is a read only property, cannot be assigned")
      end
    end
  end

end
