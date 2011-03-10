require File.dirname(__FILE__) + '/redis_repeater/scheduler.rb'
require File.dirname(__FILE__) + '/redis_repeater/scheduler_job.rb'
require File.dirname(__FILE__) + '/redis_repeater/transfer_scheduler_job.rb'

require 'yaml'
require 'logger'
require 'fileutils'

require 'eventmachine'
require 'redis'

module RedisRepeater
 
  DefaultRedisHost = 'localhost'
  DefaultRedisPort = 6379
  LogDefaultFilename = File.dirname(__FILE__) + '/../log/redis_repeater.log'

  def self.start(config_dir)

    # Connect to redis
    config = YAML::load File.open("#{config_dir}/config.yml")
    redis_from = redis_configure(config, 'origin')
    redis_to = redis_configure(config, 'destination')

    # Load the queues from the config file
    queues = YAML::load File.open("#{config_dir}/queues.yml")

    # replace 'magic' resque:queues key with all resque queues, but don't overwrite otherwise configured queues
    # warning: only resolves queue names on startup, if new queue is created it will not pick it up.
    if queues.has_key?("resque:queues")
      redis_from.smembers("resque:queues").each do |queue|
        queues["resque:queue:#{queue}"] = queues["resque:queues"] unless queues.has_key?("resque:queue:#{queue}")
      end
      queues.delete("resque:queues")
    end
    
    # Logger
    if config.has_key?('log')
      log_filename = config['log']
      FileUtils.mkdir_p(File.dirname(log_filename))
      logger = Logger.new(log_filename)
    else
      logger = Logger.new(STDOUT)
    end

    # Load the queues into the scheduler
    scheduler = Scheduler.new(logger)
    EventMachine::run do
      queues.each do |name, timeout|
        puts "#{name} - #{timeout}"
        scheduler << TransferSchedulerJob.new(name, timeout, logger, redis_from, redis_to)
      end
    end

    # Perform forever
    scheduler.perform # TODO make configurable

  end

  def self.redis_configure(config, name)
    host = DefaultRedisHost
    port = DefaultRedisPort
    if config.has_key?(name)
      host = config[name]['host'] if config[name].has_key?('host')
      port = config[name]['port'] if config[name].has_key?('port')
    end
    Redis.new(:host => host, :port => port)
  end

end
