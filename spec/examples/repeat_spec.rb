require File.dirname(__FILE__) + '/../spec_helper'

describe RedisRepeater do

  # Clear the things we use
  before :all do
    ['john', 'kate', 'john2', 'kate2', 'john3'].each do |name|
      while REDIS_ONE.lpop(name)
      end
    end
  end

  it 'should be able to repeat a single queue' do
    repeater = RedisRepeater::Repeater.new 'log' => TEST_FILENAME, 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [ { 'source' => 'one', 'queue' => 'john', 'destinations' => [ { 'server' => 'one', 'queue' => 'john2' } ] } ]
    thread = Thread.new { repeater.run_forever }
    # repeat
    10.times { REDIS_ONE.rpush('john', 'hello') }; sleep 0.2
    10.times { REDIS_ONE.lpop('john2').should == 'hello' }
    REDIS_ONE.llen('john').should == 0
    REDIS_ONE.llen('john2').should == 0
    thread.kill
  end

  it 'should be able to repeat two queues at once' do
    repeater = RedisRepeater::Repeater.new 'log' => TEST_FILENAME, 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [
      { 'source' => 'one', 'queue' => 'john', 'destinations' => [ { 'server' => 'one', 'queue' => 'john2' } ] },
      { 'source' => 'one', 'queue' => 'kate', 'destinations' => [ { 'server' => 'one', 'queue' => 'kate2' } ] }
    ]
    thread = Thread.new { repeater.run_forever }
    # repeat
    10.times { REDIS_ONE.rpush('john', 'hellojohn') }
    10.times { REDIS_ONE.rpush('kate', 'hellokate') }; sleep 0.2
    10.times { REDIS_ONE.lpop('john2').should == 'hellojohn' }
    10.times { REDIS_ONE.lpop('kate2').should == 'hellokate' }
    REDIS_ONE.llen('john').should == 0
    REDIS_ONE.llen('kate').should == 0
    REDIS_ONE.llen('john2').should == 0
    REDIS_ONE.llen('kate2').should == 0
    thread.kill
  end

  it 'should be able to repeat one thing to two places at once' do
    repeater = RedisRepeater::Repeater.new 'log' => TEST_FILENAME, 'servers' => { 'one' => SERVER_ONE }, 'repeats' => [
      { 'source' => 'one', 'queue' => 'john', 'destinations' => [ { 'server' => 'one', 'queue' => 'john2' }, { 'server' => 'one', 'queue' => 'john3' } ] }
    ]
    thread = Thread.new { repeater.run_forever }
    # repeat
    10.times { REDIS_ONE.rpush('john', 'hellojohn') }; sleep 0.2
    10.times { REDIS_ONE.lpop('john2').should == 'hellojohn' }
    10.times { REDIS_ONE.lpop('john3').should == 'hellojohn' }
    REDIS_ONE.llen('john').should == 0
    REDIS_ONE.llen('john2').should == 0
    REDIS_ONE.llen('john3').should == 0
    thread.kill
  end

end
