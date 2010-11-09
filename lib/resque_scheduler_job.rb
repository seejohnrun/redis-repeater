require 'lib/scheduler_job'
require 'rubygems'
require 'redis'

module RedisRepeater

  class ResqueSchedulerJob < SchedulerJob

    def initialize(name, timeout, logger, redis_from, redis_to)
      @redis_from = redis_from
      @redis_to = redis_to
      super(name, timeout, logger)
    end

    def perform
      count = 0
      while (item = @redis_from.lpop @name)
        @redis_to.rpush(@name, item)
        count += 1
      end
      @logger.debug "Transported #{count} items for #{@name}"
    end

  end

end
