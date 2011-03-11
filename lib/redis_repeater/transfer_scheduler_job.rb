module RedisRepeater

  # Move jobs from One Redis queue to the same queue on a different machine

  class TransferSchedulerJob < SchedulerJob

    def initialize(name, timeout, logger, redis_from, redis_to, maintain_count)
      @redis_from = redis_from
      @redis_to = redis_to
      @maintain_count = maintain_count
      super(name, timeout, logger)
    end

    def perform
      count = 0
      while (item = @redis_from.lpop @name)
        # work the same direction resque does
        @redis_to.rpush(@name, item)
        count += 1
      end
      @redis_from.incrby("redis-repeater:#{@name}:count", count) if @maintain_count
      @logger.debug "Transported #{count} items for #{@name}"
    end

  end

end
