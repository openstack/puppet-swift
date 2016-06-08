# provider for swift_storage_policy resource.
#
Puppet::Type.type(:swift_storage_policy).provide(:ruby) do
  mk_resource_methods

  # Policy indexes must be unique, the storage policy resource name is its ID.
  # Storage policy section headings in swift.conf are of the format "storage-policy:<policy ID>
  def policy_title
    "storage-policy:#{name}"
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def exists?
    # If a storage policy exists if it is ensured absent and is also found in swift.conf.
    if (resource[:ensure] == :absent) &&
       (self.class.storage_policies.include? policy_title)
      return true
    end
    if self.class.storage_policies.include? policy_title
      # Return false if settings are removed from swift.conf that do not exist in the puppet resource.
      # This resource will then update swift.conf in flush.
      return false if remove_storage_policy_settings?
    end
    @property_hash[:ensure] == :present
  end

  def flush
    # flush is called when policy state in swift.conf does not match what is defined in puppet.
    # get all resource settings and store in @property_flush for use in write_policy
    #  @property_flush is the state the policy should be in.
    #  @property_hash is the state of the policy in swift.conf
    self.class.policy_settings.each do |property_name, _|
      @property_flush[property_name] = resource[property_name]
    end
    # If this policy is set to absent, call write_policy to remove it from swift.conf.
    if @property_flush[:ensure] == :absent
      write_policy
      return
    end
    # At this point, this is a new policy to write to disk. Or this is a policy
    # containing a setting that needs to be updated on disk.
    # Write this policy unless:
    #  - a policy on disk already has this same policy_name or aliases.
    #  or a policy default setting conflict is found.
    if !self.class.instances.empty?
      write_policy unless policy_names_conflict? ||
                          default_policy_defined?
    else
      write_policy
    end
    @property_hash = self.class.storage_policy_properties(policy_title)
  end

  # A hash of property_name => setting_name.  property_name used to access
  # resource properties. setting_name used in swift.conf storage policy setting.
  def self.policy_settings
    settings_hash = { policy_name:             'name',
                      aliases:                 'aliases',
                      policy_type:             'policy_type',
                      deprecated:              'deprecated',
                      default:                 'default',
                      ec_type:                 'ec_type',
                      ec_num_data_fragments:   'ec_num_data_fragments',
                      ec_num_parity_fragments: 'ec_num_parity_fragments',
                      ec_object_segment_size:  'ec_object_segment_size' }
    settings_hash
  end

  # Read storage policies from disk found in swift.conf
  def self.storage_policies
    policies = []
    config.section_names.each do |section_name|
      policies.push(section_name) if section_name.start_with?('storage-policy')
    end
    policies.sort
    policies
  end

  # Read storage policy settings and values found swift.conf
  def self.storage_policy_properties(policy)
    policy_properties = {}
    policy_properties[:provider] = :ruby
    policy_properties[:name]     = policy.split(':')[1]
    policy_properties[:ensure]   = :present
    policy_settings.each do |property_name, setting_name|
      unless config.get_value(policy, setting_name).nil?
        policy_properties[property_name] = config.get_value(policy, setting_name)
      end
    end
    policy_properties
  end

  def write_policy
    if @property_flush[:ensure] == :absent
      remove_storage_policy_section
      return
    end
    self.class.policy_settings.each do |property_name, setting_name|
      unless @property_flush[property_name].nil?
        config.set_value(policy_title, setting_name, @property_flush[property_name])
      end
    end
    config.save
    @config = nil
  end

  # Removes the entire storage policy section header and settings for this instance.
  # TODO push a 'remove_section' method into puppet inifile module for the ini_file util.
  def remove_storage_policy_section
    # Get all settings for this storage policy section and remove them.
    @sections = config.instance_variable_get(:@sections_hash)
    @sections[policy_title].instance_variable_get(:@existing_settings).each do |setting, _|
      config.remove_setting(policy_title, setting)
    end
    # ini_file tracks an array of section names 'section_names' and a hash of sections 'sections_hash'
    # get array of section names and delete this storage policy from it.
    @section_names = config.instance_variable_get(:@section_names)
    @section_names.delete(policy_title)
    # delete the entire section from the sections_hash then save swift.conf
    @sections.delete(policy_title)
    config.save
  end

  # Check for storage policy settings found in swift.conf that are not defined
  # in puppet and should be removed from the policy.  Return True if settings
  # were removed. Removing a setting from a policy declaration will remove that
  # setting from swift.conf
  def remove_storage_policy_settings?
    settings_removed = false
    # If storage policy settings are found in swift.conf that are not defined,
    # remove the setting line.
    self.class.storage_policy_properties(policy_title).each do |key, value|
      next unless @resource[key] != value
      config.remove_setting(policy_title, key.to_s.delete(':'))
      config.save
      settings_removed = true
    end
    @config = nil
    settings_removed
  end

  # Compare current policy alias against existing storage policies in swift.conf
  # Duplicate alias are not allowed.
  def policy_names_conflict?
    self.class.instances.each do |policy|
      next if policy.policy_title.eql? "storage-policy:#{name}"
      # Split policy aliases into an array and add policy name.
      # Split resource aliases into an array and add resource policy_name.
      # If any intersecting elements exist raise an error alerting on the
      # attempt to set a duplicate name/alias.
      policy_names = policy.policy_name.split
      unless policy.aliases == :absent
        policy_names = policy.aliases.split(', ').concat policy.policy_name.split
      end
      resource_names = resource[:policy_name].split
      unless resource[:aliases].nil?
        resource_names = resource[:aliases].split(', ').concat resource[:policy_name].split
      end
      alias_intersection = policy_names & resource_names
      next if alias_intersection.empty?
      raise Puppet::Error, "Swift_storage_policy[#{resource[:name]}] trying "\
                           "to set a duplicate name/alias:#{alias_intersection},"\
                           "this name/alias exists in #{policy.policy_title}\n"
    end
    false
  end

  # Check storage policy default settings across resources to verify that:
  # - If any policies are defined, exactly one policy must be declared default.
  # - Only one policy can be declared the default.
  def default_policy_defined?
    self.class.instances.each do |policy|
      # Don't compare this instance with its copy found on disk.
      next if (policy.policy_title.eql? "storage-policy:#{name}") ||
              (policy.default == 'false')
      case resource[:default]
      when 'true'
        raise Puppet::Error, "Swift_storage_policy[#{resource[:name]}] can "\
                             'not set default = true. '\
                             "default=true already set in a policy #{policy.policy_title}\n"
      when 'false'
        return false
      end
    end
    return unless resource[:default] == 'false'
    raise Puppet::Error, 'All storage policies have set default = false.. '\
                         'exactly one policy must be declared default = true'
  end

  def self.instances
    storage_policies.collect do |policy|
      policy_properties = storage_policy_properties(policy)
      new(policy_properties)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  private

  def self.get_swift_conf_file
    if File.exists? '/etc/swift/swift.conf'
      file = '/etc/swift/swift.conf'
    else
      file = '/etc/swift/swift.conf'
    end
    file
  end

  def config
    self.class.config
  end

  def self.config
    @config ||= Puppet::Util::IniFile.new(get_swift_conf_file)
  end
end
