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
    start_repeater
    @redis_server = Redis.new(:host => 'localhost', :port => SERVER_PORT)
    @redis_client = Redis.new(:host => 'localhost', :port => CLIENT_PORT)
  end

  before(:each) do
    @redis_client.llen(QN).should == 0
    @redis_server.llen(QN).should == 0
 end

  it 'should be able to put something into the client, and have it show up on the server' do
    @redis_client.rpush(QN, 'hello')
    sleep(0.1) # wait for the grab
    @redis_client.llen(QN).should == 0
    @redis_server.rpop(QN).should == 'hello'
  end

  it 'should be able to move 20 arbitrary keys and get them on the other side in the right order' do
    values = []
    20.times { values << "%020x" % rand(1 << 80) }
    # put them in
    values.each { |v| @redis_client.rpush(QN, v) }
    sleep(0.1) # wait for the grab
    @redis_client.llen(QN).should == 0
    # get them out
    other_values = []
    while val = @redis_server.lpop(QN)
      other_values << val
    end
    # check the quantity and equality
    other_values.size.should == 20
    other_values.should == values
  end

  it 'should be able to put something into the server, and then something from the client, in the right order' do
    @redis_server.rpush(QN, 'hello server')
    @redis_client.rpush(QN, 'hello client')
    sleep(0.1) # wait for the grab
    @redis_client.llen(QN).should == 0
    values = []; while v = @redis_server.lpop(QN) do; values << v; end
    values.should == ['hello server', 'hello client']
  end

  it 'should not be maintaining counts by default' do
    @redis_server.rpush(QN, 'hello!')
    sleep(0.1)
    @redis_server.rpop(QN).should == 'hello!'
    @redis_server.get("redis-repeater:#{QN}:count").to_i.should == 0
  end
 
end
