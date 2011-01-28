require File.dirname(__FILE__) + '/../lib/redis_repeater'

SERVER_PORT = 6391
CLIENT_PORT = 6392
QN = 'queue-1234'

SERVERS = ['client', 'server']

def start_servers
  SERVERS.each do |s|
    print "starting a #{s}.. "
    `redis-server #{File.dirname(__FILE__) + "/support/#{s}.conf"}`
    puts 'DONE'
  end
end

def stop_servers
  SERVERS.each do |s|
    pid = `cat #{s}.pidfile`.chop
    print "stopping #{s} (PID:#{pid}).. "
    `kill #{pid}`
    puts 'DONE'
  end
end

def start_repeater
  print 'starting the repeater.. '
  # TODO deamonize
  @rthread = Thread.start do
    RedisRepeater.start(File.dirname(__FILE__) + '/support/config')
  end
  puts 'DONE'
end

def stop_repeater
  print 'stopping the repeater.. '
  @rthread.kill
  puts 'DONE'
end
