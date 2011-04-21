module RedisRepeater

  class Repeater

    attr_reader :servers, :repeats, :logger

    def initialize(configuration, logger = nil)
      raise ConfigurationError.new 'Configuration is empty' unless configuration
      @servers = {}
      @repeats = []
      # Get the logger
      @logger = logger
      @logger ||= Logger.new(configuration['log']) if configuration['log']
      @logger ||= Logger.new(STDOUT)
      # Load the configuration and start the server
      load_hash_configuration configuration
    end

    def run_forever
      raise ConfigurationError.new('No repeat jobs specified in configuration') if @repeats.empty?
      # start the scheduler and run it forever
      EventMachine::run do
        @repeats.each do |job|
          EventMachine::add_periodic_timer(job.timeout) { job.perform }
        end
        @logger.info "Repeating #{@repeats.count} #{@repeats.count == 1 ? 'queue' : 'queues'} forever!"
      end
    end

    private

    def load_hash_configuration(hash)
      hash['servers'] && hash['servers'].each do |name, value|
        options = {}
        value.each { |k, v| options[k.to_sym] = v }
        @servers[name] = Redis.new(options)
      end
      hash['repeats'] && hash['repeats'].each do |repeat|
        options = {}
        options[:source] = find_server_by_name repeat['source']
        # Handle 'magic' queues
        if repeat['queue'] == 'resque:queues' || repeat['queue'] == 'resque:queues:*'
          options[:source].smembers('resque:queues').each do |queue|
            repeat = repeat.dup
            repeat['queue'] = "resque:queue:#{queue}"
            hash['repeats'] << repeat
          end          
          next
        end
        options[:destinations] = repeat['destinations'].map { |d| { :server => find_server_by_name(d['server']), :queue => d['queue'] || repeat['queue'] } }
        options[:queue] = repeat['queue']
        options[:timeout] = repeat['timeout'] || 0
        options[:maintain_count] = !!repeat['maintain_count'] # default false
        # Remove duplicates and add this
        @repeats.delete_if { |r| r.source == options[:source] && r.queue == options[:queue] }
        @repeats << TransferSchedulerJob.new(self, options)
      end
    end

    def find_server_by_name(name)
      server = @servers[name]
      raise ConfigurationError.new("No such server found: #{name}") if server.nil?
      server
    end

  end

end
