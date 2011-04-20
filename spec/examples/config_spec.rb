require File.dirname(__FILE__) + '/../spec_helper'

describe RedisRepeater::Repeater do

  it 'should be able to replace a magic queue portion with an override' do
    while REDIS_ONE.spop 'resque:queues'; end

    3.times do |idx|
      REDIS_ONE.sadd 'resque:queues', "john#{idx}"
    end

    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [
      { 'queue' => 'resque:queues:*', 'source' => 'one', 'destinations' => [] },
      { 'queue' => 'resque:queue:john0', 'source' => 'one', 'destinations' => [ { 'server' => 'one', 'queue' => 'john_bam' } ] }
    ]

    repeater.repeats.count.should == 3
    repeater.repeats.each_with_index do |repeat, idx|
      repeat.queue.should == "resque:queue:john#{idx}"
      repeat.queue == 'john0' ? repeat.destinations.count.should == 1 : repeat.destinations.count.should == 0
    end
  end

  it 'should be able to get its version' do
    RedisRepeater::VERSION.should be_a Array
  end
  
  it 'should get an error when the configuration is empty' do
    lambda do
      repeater = RedisRepeater::Repeater.new nil
    end.should raise_error RedisRepeater::ConfigurationError
  end

  it 'should be able to pick up magic queues for resque' do
    while REDIS_ONE.spop 'resque:queues'; end

    3.times do |idx|
      REDIS_ONE.sadd 'resque:queues', "john#{idx}"
    end

    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'queue' => 'resque:queues:*', 'source' => 'one', 'destinations' => [] } ]
    repeater.repeats.count.should == 3

    repeater.repeats.each_with_index do |repeat, idx|
      repeat.queue.should == "resque:queue:john#{idx}"
    end
  end

  it 'should be able to pick up magic queues for resque (old style)' do
    while REDIS_ONE.spop 'resque:queues'; end

    3.times do |idx|
      REDIS_ONE.sadd 'resque:queues', "john#{idx}"
    end

    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'queue' => 'resque:queues', 'source' => 'one', 'destinations' => [] } ]
    repeater.repeats.count.should == 3

    repeater.repeats.each_with_index do |repeat, idx|
      repeat.queue.should == "resque:queue:john#{idx}"
    end
  end

  it 'should get an error when trying to start with no repeats' do
    lambda do
      repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => []
      repeater.run_forever
    end.should raise_error RedisRepeater::ConfigurationError
  end

  it 'should be able to not specify host on a redis connection' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => { 'port' => 6380 } }, 'repeats' => []
    repeater.servers['one'].client.instance_variable_get(:@host).should == '127.0.0.1'
    repeater.servers['one'].client.instance_variable_get(:@port).should == 6380
  end

  it 'should be able to not specify port on a redis connection' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => { 'host' => 'localhost' } }, 'repeats' => []
    repeater.servers['one'].client.instance_variable_get(:@port).should == 6379
    repeater.servers['one'].client.instance_variable_get(:@host).should == 'localhost'
  end

  it 'should be able to load a configuration with a server' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => []
    repeater.servers.count.should == 1
    server = repeater.servers['one']
    server.should be_a Redis
  end

  it 'should be able to load a configuration with two servers' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE, 'two' => SERVER_TWO }, 'repeats' => []
    repeater.servers.count.should == 2
  end

  it 'should get an error when trying to load a configuration with a bad server reference' do
    lambda do
      repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'source' => 'one_bad' } ]
    end.should raise_error RedisRepeater::ConfigurationError
  end

  it 'should be able to load a simple repeat' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE, 'two' => SERVER_TWO }, 'repeats' => [ { 'source' => 'one', 'destinations' => [{ 'server' => 'two' }] } ]
    repeater.repeats.first.destinations.first[:server].should be_a Redis
    repeater.repeats.first.source.should be_a Redis
  end

  it 'should be able to guess a repeat queue name from the source name' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE, 'two' => SERVER_TWO }, 'repeats' => [ { 'source' => 'one', 'queue' => 'john', 'destinations' => [{ 'server' => 'two' }] } ]
    repeater.repeats.first.queue.should == 'john'
    repeater.repeats.first.destinations.first[:queue].should == 'john'
  end

  it 'should be able to override the queue name for the destination' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE, 'two' => SERVER_TWO }, 'repeats' => [ { 'source' => 'one', 'queue' => 'john', 'destinations' => [{ 'server' => 'two', 'queue' => 'john2' }] } ]
    repeater.repeats.first.queue.should == 'john'
    repeater.repeats.first.destinations.first[:queue].should == 'john2'
  end

  it 'should be able to have the same origin and destination servers' do
    lambda do
      repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'source' => 'one', 'queue' => 'john', 'destinations' => [{ 'server' => 'one' }] } ]
    end.should_not raise_error
  end

  it 'should have a default timeout for a repeat' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'source' => 'one', 'queue' => 'john', 'destinations' => [] } ]
    repeater.repeats.first.timeout.should == 0
  end

  it 'should be able to override the default timeout for a repeat' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'source' => 'one', 'queue' => 'john', 'timeout' => 10, 'destinations' => [] } ]
    repeater.repeats.first.timeout.should == 10
  end

  it 'should have a default maintain_count set to false' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'source' => 'one', 'queue' => 'john', 'destinations' => [] } ]
    repeater.repeats.first.maintain_count.should be false
  end

  it 'should be able to override the default maintain_count to make it true' do
    repeater = RedisRepeater::Repeater.new 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'source' => 'one', 'queue' => 'john', 'maintain_count' => true, 'destinations' => [] } ]
    repeater.repeats.first.maintain_count.should be true
  end

end
