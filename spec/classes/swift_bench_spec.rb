require 'spec_helper'

describe 'swift::bench' do

  let :default_params do
    { :auth_url          => 'http://localhost:8080/auth/v1.0',
      :swift_user        => 'test:tester',
      :swift_key         => 'testing',
      :auth_version      => '1.0',
      :log_level         => 'INFO',
      :test_timeout      => '10',
      :put_concurrency   => '10',
      :get_concurrency   => '10',
      :del_concurrency   => '10',
      :lower_object_size => '10',
      :upper_object_size => '10',
      :object_size       => '1',
      :num_objects       => '1000',
      :num_gets          => '10000',
      :num_containers    => '20',
      :delete            => 'yes' }
  end

  let :pre_condition do
    "class { 'swift': swift_hash_path_suffix => 'string' }"
  end

  let :params do
    default_params
  end

  shared_examples 'swift::bench' do
    describe 'with defaults' do
      it 'configures swift-bench.conf' do
        is_expected.to contain_swift_bench_config(
          'bench/auth').with_value(params[:auth_url])
        is_expected.to contain_swift_bench_config(
          'bench/user').with_value(params[:swift_user])
        is_expected.to contain_swift_bench_config(
          'bench/key').with_value(params[:swift_key])
        is_expected.to contain_swift_bench_config(
          'bench/auth_version').with_value(params[:auth_version])
        is_expected.to contain_swift_bench_config(
          'bench/log-level').with_value(params[:log_level])
        is_expected.to contain_swift_bench_config(
          'bench/timeout').with_value(params[:test_timeout])
        is_expected.to contain_swift_bench_config(
          'bench/put_concurrency').with_value(params[:put_concurrency])
        is_expected.to contain_swift_bench_config(
          'bench/get_concurrency').with_value(params[:get_concurrency])
        is_expected.to contain_swift_bench_config(
          'bench/get_concurrency').with_value(params[:get_concurrency])
        is_expected.to contain_swift_bench_config(
          'bench/lower_object_size').with_value(params[:lower_object_size])
        is_expected.to contain_swift_bench_config(
          'bench/upper_object_size').with_value(params[:upper_object_size])
        is_expected.to contain_swift_bench_config(
          'bench/object_size').with_value(params[:object_size])
        is_expected.to contain_swift_bench_config(
          'bench/num_objects').with_value(params[:num_objects])
        is_expected.to contain_swift_bench_config(
          'bench/num_gets').with_value(params[:num_gets])
        is_expected.to contain_swift_bench_config(
          'bench/num_containers').with_value(params[:num_containers])
        is_expected.to contain_swift_bench_config(
          'bench/delete').with_value(params[:delete])
      end
    end

    describe 'with overridden' do
      before do
        params.merge!(
          :auth_url        => 'http://127.0.0.1:8080/auth/v1.0',
          :swift_user      => 'admin:admin',
          :swift_key       => 'admin',
          :put_concurrency => '20'
        )
      end

      it 'configures swift-bench.conf' do
        is_expected.to contain_swift_bench_config(
          'bench/auth').with_value(params[:auth_url])
        is_expected.to contain_swift_bench_config(
          'bench/user').with_value(params[:swift_user])
        is_expected.to contain_swift_bench_config(
          'bench/key').with_value(params[:swift_key])
        is_expected.to contain_swift_bench_config(
          'bench/put_concurrency').with_value(params[:put_concurrency])
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::bench'
    end
  end
end
