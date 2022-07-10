require 'spec_helper_acceptance'

describe 'basic swift_config resource' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      File <||> -> Swift_config <||>
      File <||> -> Swift_account_config <||>
      File <||> -> Swift_bench_config <||>
      File <||> -> Swift_container_config <||>
      File <||> -> Swift_dispersion_config <||>
      File <||> -> Swift_object_config <||>
      File <||> -> Swift_proxy_config <||>
      File <||> -> Swift_container_sync_realms_config <||>

      file { '/etc/swift' :
        ensure => directory,
      }

      $swift_files = [ '/etc/swift/swift.conf',
                       '/etc/swift/account-server.conf',
                       '/etc/swift/swift-bench.conf',
                       '/etc/swift/container-server.conf',
                       '/etc/swift/dispersion.conf',
                       '/etc/swift/object-server.conf',
                       '/etc/swift/proxy-server.conf',
                       '/etc/swift/container-sync-realms.conf']

      file { $swift_files  :
        ensure => file,
      }

      swift_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      swift_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      swift_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      swift_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      swift_account_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      swift_account_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      swift_account_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      swift_account_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      swift_bench_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      swift_bench_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      swift_bench_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      swift_bench_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      swift_container_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      swift_container_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      swift_container_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      swift_container_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      swift_dispersion_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      swift_dispersion_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      swift_dispersion_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      swift_dispersion_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      swift_object_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      swift_object_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      swift_object_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      swift_object_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      swift_proxy_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      swift_proxy_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      swift_proxy_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      swift_proxy_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      swift_container_sync_realms_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      swift_container_sync_realms_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      swift_container_sync_realms_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      swift_container_sync_realms_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    $swift_files = [ '/etc/swift/swift.conf',
                     '/etc/swift/account-server.conf',
                     '/etc/swift/swift-bench.conf',
                     '/etc/swift/container-server.conf',
                     '/etc/swift/dispersion.conf',
                     '/etc/swift/object-server.conf',
                     '/etc/swift/proxy-server.conf',
                     '/etc/swift/container-sync-realms.conf']

    $swift_files.each do |swift_conf_file|
      describe file(swift_conf_file) do
        it { is_expected.to exist }
        it { is_expected.to contain('thisshouldexist=foo') }
        it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }

        describe '#content' do
          subject { super().content }
          it { is_expected.to_not match /thisshouldnotexist/ }
        end
      end
    end

  end
end
