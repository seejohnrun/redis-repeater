require 'bundler/setup'
require 'redis'
require 'logger'
require 'eventmachine'

require File.dirname(__FILE__) + '/redis_repeater/configuration_error'
require File.dirname(__FILE__) + '/redis_repeater/repeater'

module RedisRepeater

  autoload :VERSION, File.dirname(__FILE__) + '/redis_repeater/version'
  autoload :TransferSchedulerJob, File.dirname(__FILE__) + '/redis_repeater/transfer_scheduler_job'

end
