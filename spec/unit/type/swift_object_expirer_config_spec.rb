require 'puppet'
require 'puppet/type/swift_object_expirer_config'

describe 'Puppet::Type.type(:swift_object_expirer_config)' do
  before :each do
    # If we do not remove the type, if will only be processed once on
    # initialization, thus it will only read the fact on startup, no
    # matter how we try to stub it.
    Puppet::Type.rmtype(:swift_object_expirer_config)
    Facter.fact(:osfamily).stubs(:value).returns(platform_params[:osfamily])
    @swift_object_expirer_config = Puppet::Type.type(:swift_object_expirer_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  shared_examples_for 'swift-object-expirer' do
    it 'should autorequire the package that installs the file' do
      catalog = Puppet::Resource::Catalog.new
      package = Puppet::Type.type(:package).new(:name => platform_params[:package_name])
      catalog.add_resource package, @swift_object_expirer_config
      dependency = @swift_object_expirer_config.autorequire
      expect(dependency.size).to eq(1)
      expect(dependency[0].target).to eq(@swift_object_expirer_config)
      expect(dependency[0].source).to eq(package)
    end
  end

  context 'on Debian platforms' do
    let :platform_params do
      { :package_name => 'swift-object-expirer',
        :osfamily     => 'Debian' }
    end

    it_behaves_like 'swift-object-expirer'
  end

  context 'on RedHat platforms' do
    let :platform_params do
      { :package_name => 'openstack-swift-proxy',
        :osfamily     => 'RedHat'}
    end

    it_behaves_like 'swift-object-expirer'
  end
end
