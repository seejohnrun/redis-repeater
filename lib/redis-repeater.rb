require File.dirname(__FILE__) + '/redis-repeater/scheduler.rb'
require File.dirname(__FILE__) + '/redis-repeater/scheduler_job.rb'
require File.dirname(__FILE__) + '/redis-repeater/transfer_scheduler_job.rb'

require 'yaml'
require 'logger'
require 'fileutils'

require 'rubygems'
require 'redis'
require 'eventmachine'

module RedisRepeater
 
  DefaultRedisHost = 'localhost'
  DefaultRedisPort = 6380
  LogDefaultFilename = File.dirname(__FILE__) + '/../log/redis-repeater.log'

  def self.start(config_dir)

    # Connect to redis
    config = YAML::load File.open("#{config_dir}/config.yml")
    redis_from = redis_configure(config, 'origin')
    redis_to = redis_configure(config, 'destination')

    # Load the queues from the config file
    queues = YAML::load File.open("#{config_dir}/queues.yml")

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
    queues.each do |name, timeout|
      scheduler << TransferSchedulerJob.new(name, timeout, logger, redis_from, redis_to)
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
