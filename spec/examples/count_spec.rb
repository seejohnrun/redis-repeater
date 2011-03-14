require File.dirname(__FILE__) + '/../spec_helper'

describe RedisRepeater do

  after(:all) do
    puts # clear for tests
    stop_repeater
    stop_servers
    sleep 1
    puts '---'
  end

  before(:all) do
    start_servers
    start_repeater(:count)
    @redis_server = Redis.new(:host => 'localhost', :port => SERVER_PORT)
    @redis_client = Redis.new(:host => 'localhost', :port => CLIENT_PORT)
  end

  before(:each) do
    @redis_client.llen(QN).should == 0
    @redis_server.llen(QN).should == 0
  end

  after(:each) do
    @redis_client.set("redis-repeater:#{QN}:count", nil)
  end

  it 'should maintain a count when transferring items' do
    @redis_client.rpush(QN, 'hello!')
    sleep(0.2)
    @redis_server.lpop(QN).should == 'hello!'
    @redis_client.get("redis-repeater:#{QN}:count").to_i.should == 1
  end

  it 'should quick to track many things atomically' do
    1000.times { @redis_client.rpush(QN, 'hello!') }; sleep(0.2)
    1000.times { @redis_server.lpop(QN).should == 'hello!' }; sleep(0.2)
    @redis_client.get("redis-repeater:#{QN}:count").to_i.should == 1000
  end

end
