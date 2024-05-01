require 'spec_helper'

describe 'Swift::MountDevice' do
  describe 'valid types' do
    context 'with valid types' do
      [
        '/dev',
        '/dev/sda',
        '/opt/swift/diskfile',
        'LABEL=foo',
        '50e68500-9920-4ffa-a4cd-34fd2a893530',
        'UUID=50e68500-9920-4ffa-a4cd-34fd2a893530',
      ].each do |value|
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'invalid types' do
    context 'with invalid types' do
      [
        1,
        true,
        {},
        ['/dev/sda'],
        'dev',
        'dev/sda',
        'LABEL=',
        'LABELfoo',
        '50e6850099204ffaa4cd34fd2a893530',
        '50e68500-9920-3ffa-a4cd-34fd2a893530',
        'UUID=',
        'UUID=foo',
        'UUID=50e6850099204ffaa4cd34fd2a893530',
        'UUID=50e68500-9920-3ffa-a4cd-34fd2a893530',
      ].each do |value|
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
