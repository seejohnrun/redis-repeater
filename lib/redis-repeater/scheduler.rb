module RedisRepeater

  class Scheduler

    def initialize(logger = nil)
      @logger = logger
    end

    # When adding, we move through the current queue, and
    # find the first one that is performing after we want to
    def <<(job)
      scheduler = self
      EventMachine.run {
        EventMachine::add_timer(job.timeout) { job.perform; scheduler << job }
      }
    end

    def perform
      @logger.info 'Running on schedule forever...'
    end

  end
 
end
