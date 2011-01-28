module RedisRepeater
  
  class SchedulerJob

    def initialize(name, timeout, logger)
      @name = name
      @timeout = timeout
      @logger = logger
      @next_allowed_performance = Time.now + timeout
    end

    def perform
      puts "Performing #{self.name}"
    end

    def adjust_next_allowed_performance
      @next_allowed_performance = Time.now + timeout
    end

    attr_reader :name, :timeout, :next_allowed_performance

  end
 
end
