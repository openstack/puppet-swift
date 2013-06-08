require 'spec_helper'

describe 'swift::bench' do

  let :default_params do
    {:auth_url   => 'http://localhost:8080/auth/v1.0'}
  end

  describe 'with defaults' do

    let :params do
      default_params
    end

    it 'should create a reasonable swift-bench file' do
      verify_contents(subject, '/etc/swift/swift-bench.conf',
        [
         "auth = http://localhost:8080/auth/v1.0",
         "user = test:tester",
         "key = testing",
         "auth_version = 1.0",
         "log-level = INFO",
         "timeout = 10",
         "put_concurrency = 10",
         "get_concurrency = 10",
         "del_concurrency = 10",
         "lower_object_size = 10",
         "upper_object_size = 10",
         "object_size = 1",
         "num_objects = 1000",
         "num_gets = 10000",
         "num_containers = 20",
         "delete = yes"
        ]
      )
    end

  end

  describe 'when overridding' do

    let :params do
      default_params.merge({
        :auth_url        => 'http://127.0.0.1:8080/auth/v1.0',
        :swift_user      => 'admin:admin',
        :swift_key       => 'admin',
        :put_concurrency => '20'
      })
    end

    it 'should create a configured swift-bench file' do
      verify_contents(subject, '/etc/swift/swift-bench.conf',
        [
         "auth = http://127.0.0.1:8080/auth/v1.0",
         "user = admin:admin",
         "key = admin",
         "auth_version = 1.0",
         "log-level = INFO",
         "timeout = 10",
         "put_concurrency = 20",
         "get_concurrency = 10",
         "del_concurrency = 10",
         "lower_object_size = 10",
         "upper_object_size = 10",
         "object_size = 1",
         "num_objects = 1000",
         "num_gets = 10000",
         "num_containers = 20",
         "delete = yes"
        ]
      )
    end

  end
end
