require File.dirname(__FILE__) + '/../spec_helper'

describe RedisRepeater do

  after(:all) do
    puts 
    stop_repeater
    stop_servers
    sleep 1
    puts '---'
  end

  before(:all) do
    start_servers
    start_repeater('combined/config.yml')
    @redis_server = Redis.new(:host => 'localhost', :port => SERVER_PORT)
    @redis_client = Redis.new(:host => 'localhost', :port => CLIENT_PORT)
  end

  before(:each) do
    @redis_client.llen(QN).should == 0
    @redis_server.llen(QN).should == 0
  end

  it 'should work at transferring items with the combined config' do
    10.times { @redis_client.rpush(QN, 'hello') }
    sleep 0.2
    10.times { @redis_server.lpop(QN).should == 'hello' }
  end

end
