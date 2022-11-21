Puppet::Type.newtype(:ring_account_device) do
  require 'ipaddr'
  require 'uri'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      if !value.split(/^\d+:/)[1].nil?
        raise(Puppet::Error, "Policy_index is not supported on account device")
      end
      # we have to have URI Scheme so we just add http:// and ignore it later
      uri = URI('http://' + value)
      if ['','/'].include?(uri.path)
        raise(Puppet::Error, "namevar should contain a device")
      end
      IPAddr.new(uri.host)
    end

    munge do |value|
      # we have to have URI Scheme so we just add http:// and ignore it later
      uri = URI('http://' + value)
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
