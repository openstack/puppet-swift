Puppet::Functions.create_function(:validate_tempauth_account) do
  def validate_tempauth_account(*args)
    if args.size > 1
      raise Puppet::Error, "validate_tempauth_account takes only a single argument, #{args.size} provided"
    end
    arg = args[0]

    if not arg.kind_of?(Hash)
      raise Puppet::Error, "non-hash argument provided to validate_tempauth_account"
    end

    ['user', 'account', 'key'].each do |key|
      if arg.has_key?(key)
        key_real = key
      elsif arg.has_key?(key.to_sym)
        key_real = key.to_sym
      else
        raise Puppet::Error, "The required key #{key} is missing"
      end

      if not arg[key_real].kind_of?(String)
        raise Puppet::Error, "The key #{key} is not a string value"
      end

      if arg[key_real].length == 0
        raise Puppet::Error, "The key #{key} is empty"
      end
    end

    ['groups'].each do |key|
      if arg.has_key?(key)
        key_real = key
      elsif arg.has_key?(key.to_sym)
        key_real = key.to_sym
      else
        raise Puppet::Error, "The required key #{key} is missing"
      end

      if not arg[key_real].kind_of?(Array)
        raise Puppet::Error, "The key #{key} is not an array value"
      end
    end
  end
end
