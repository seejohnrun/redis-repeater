module RedisRepeater

  class TransferSchedulerJob

    attr_reader :source, :destinations, :queue, :timeout, :maintain_count

    def initialize(repeater, config)
      @source = config[:source]
      @destinations = config[:destinations]
      @queue = config[:queue]
      @timeout = config[:timeout]
      @maintain_count = config[:maintain_count]
      @logger = repeater.logger
    end

    def perform
      # Transport everything we can
      count = 0
      while (item = @source.lpop @queue)
        @destinations.each do |destination|
          destination[:server].rpush destination[:queue], item
        end
        count += 1
      end
      # Keep the count and log a debug message
      @source.incrby("redis-repeater:#{@queue}:count", count) if @maintain_count
      @logger.debug "Transported #{count} items from #{@queue} to #{@destinations.count} #{@destinations.count == 1 ? 'destination' : 'destinations'}"
    end

  end

end
