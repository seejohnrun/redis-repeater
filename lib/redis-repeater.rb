require 'yaml'
require 'redis-repeater/transfer_scheduler_job'
require 'redis-repeater/scheduler'

require 'logger'

require 'rubygems'
require 'redis'

module RedisRepeater
 
  DefaultRedisHost = 'localhost'
  DefaultRedisPort = 6380

  def self.start(config_dir = 'config')

    # Connect to redis
    config = YAML::load File.open("#{config_dir}/config.yml")
    redis_from = redis_configure(config, 'origin')
    redis_to = redis_configure(config, 'destination')

    # Load the queues from the config file
    queues = YAML::load File.open("#{config_dir}/queues.yml")

    # Logger
    logger = Logger.new(config.has_key?('log') ? config['log'] : 'log/redis-repeater.log')

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
