require 'rubygems'
require 'lib/redis-repeater/version'

spec = Gem::Specification.new do |s|
  
  s.name = 'redis-repeater'  
  s.author = 'John Crepezzi'
  s.add_development_dependency('rspec')
  s.add_dependency('eventmachine')
  s.description = 'Automatically move events from one redis queue to the same queue on another server'
  s.email = 'john@crepezzi.com'
  s.executables = ['redis-repeater']
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = true
  s.homepage = 'http://seejohnrun.github.com/redis-repeater/'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'Redis Repeater'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = RedisRepeater::VERSION.join('.')
  s.rubyforge_project = "redis-repeater"

end
