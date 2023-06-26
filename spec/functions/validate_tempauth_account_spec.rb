require 'spec_helper'

describe 'validate_tempauth_account' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'works with valid entries (string keys)' do
    is_expected.to run.with_params({
      'user'    => 'swiftuser',
      'account' => 'swiftaccount',
      'key'     => 'secret',
      'groups'  => ['swiftgroup'],
    })
  end

  it 'works with valid entries (sym keys)' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => 'swiftaccount',
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    })
  end

  it 'throws error with more than one argument' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => 'swiftaccount',
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    }, {
      :user    => 'swiftuser',
      :account => 'swiftaccount',
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end

  it 'fails with no arguments' do
    is_expected.to run.with_params.and_raise_error(Puppet::Error)
  end

  # missing keys
  it 'fails when user is missing' do
    is_expected.to run.with_params({
      :account => 'swiftaccount',
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
  it 'fails when account is missing' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
  it 'fails when key is missing' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => 'swiftaccount',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
  it 'fails when groups is missing' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => 'swiftaccount',
      :key     => 'secret',
    }).and_raise_error(Puppet::Error)
  end

  # wrong type
  it 'fails when user is not a string' do
    is_expected.to run.with_params({
      :user    => ['swiftuser'],
      :account => 'swiftaccount',
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
  it 'fails when account is not a string' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => ['swiftaccount'],
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
  it 'fails when key is not a string' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => 'swiftaccount',
      :key     => ['secret'],
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
  it 'fails when group is not an array' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => 'swiftaccount',
      :key     => 'secret',
      :groups  => 'swiftgroup',
    }).and_raise_error(Puppet::Error)
  end

  # empty
  it 'fails when user is empty' do
    is_expected.to run.with_params({
      :user    => '',
      :account => 'swiftaccount',
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
  it 'fails when account is empty' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => '',
      :key     => 'secret',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
  it 'fails when key is empty' do
    is_expected.to run.with_params({
      :user    => 'swiftuser',
      :account => 'swiftaccount',
      :key     => '',
      :groups  => ['swiftgroup'],
    }).and_raise_error(Puppet::Error)
  end
end
