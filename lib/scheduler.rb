module RedisRepeater

  class Scheduler

    def initialize(logger = nil)
      @logger = logger
      @last_action = Time.now
      @upcoming = []
    end

    # When adding, we move through the current queue, and
    # find the first one that is performing after we want to
    def <<(job)
      appropriate_index = 0
      @upcoming.each do |other_job|
        break if (other_job.next_allowed_performance - Time.now) > job.timeout
        appropriate_index += 1
      end
      @upcoming.insert(appropriate_index, job)
    end

    def perform(until_when = nil)
      @logger.info "Running on schedule #{until_when.nil? ? 'forever' : "until #{until_when}"}..."

      while until_when.nil? || until_when > Time.now # TODO be smarter about how fast we loop
        next if @upcoming.empty? # TODO be smarter about this - threadsafe

        next if @upcoming[0].next_allowed_performance > Time.now 
        job = @upcoming.delete_at(0)

        job.perform
        job.adjust_next_allowed_performance

        # put the job back in the queue
        self << job
      end
      @logger.info 'All done!'
    end

  end
 
end
