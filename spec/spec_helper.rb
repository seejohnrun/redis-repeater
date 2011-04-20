require File.dirname(__FILE__) + '/../lib/redis_repeater'

SERVER_ONE = { 'hostname' => 'localhost', 'port' => 6379 }
SERVER_TWO = { 'hostname' => 'localhost', 'port' => 6380 }

REDIS_ONE = Redis.new SERVER_ONE
TEST_FILENAME = 'spec/test.log'
