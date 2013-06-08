# Configure swift-bench.conf for swift performance bench
class swift::bench (
  $auth_url          = 'http://localhost:8080/auth/v1.0',
  $swift_user        = 'test:tester',
  $swift_key         = 'testing',
  $auth_version      = '1.0',
  $log_level         = 'INFO',
  $test_timeout      = '10',
  $put_concurrency   = '10',
  $get_concurrency   = '10',
  $del_concurrency   = '10',
  $lower_object_size = '10',
  $upper_object_size = '10',
  $object_size       = '1',
  $num_objects       = '1000',
  $num_gets          = '10000',
  $num_containers    = '20',
  $delete            = 'yes',
){

    file {'/etc/swift/swift-bench.conf':
        ensure  => present,
        mode    => '0644',
        content => template('swift/swift-bench.conf.erb')
    }
}
