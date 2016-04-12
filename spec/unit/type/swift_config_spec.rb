require 'puppet'
require 'puppet/type/swift_config'

describe 'Puppet::Type.type(:swift_config)' do
  before :each do
    @swift_config = Puppet::Type.type(:swift_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:swift_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:swift_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:swift_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:swift_config).new(:name => 'DEFAULT/foo', :ensure => :absent)
  end

  it 'should accept a valid value' do
    @swift_config[:value] = 'bar'
    expect(@swift_config[:value]).to eq('bar')
  end

  it 'should not accept a value with whitespace' do
    @swift_config[:value] = 'b ar'
    expect(@swift_config[:value]).to eq('b ar')
  end

  it 'should accept valid ensure values' do
    @swift_config[:ensure] = :present
    expect(@swift_config[:ensure]).to eq(:present)
    @swift_config[:ensure] = :absent
    expect(@swift_config[:ensure]).to eq(:absent)
  end

  it 'should not accept invalid ensure values' do
    expect {
      @swift_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'swift')
    catalog.add_resource package, @swift_config
    dependency = @swift_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@swift_config)
    expect(dependency[0].source).to eq(package)
  end

end
