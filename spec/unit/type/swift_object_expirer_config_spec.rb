require 'puppet'
require 'puppet/type/swift_object_expirer_config'

describe 'Puppet::Type.type(:swift_object_expirer_config)' do
  before :each do
    @swift_object_expirer_config = Puppet::Type.type(:swift_object_expirer_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that installs the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'swift::install::end')
    catalog.add_resource anchor, @swift_object_expirer_config
    dependency = @swift_object_expirer_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@swift_object_expirer_config)
    expect(dependency[0].source).to eq(anchor)
  end

end
