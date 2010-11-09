require 'lib/redis-repeater/version'
 
task :build do
  system "gem build redis-repeater.gemspec"
end

task :release => :build do
  # tag and push
  system "git tag v#{RedisRepeater::VERSION.join('.')}"
  system "git push origin --tags"
  # push the gem
  system "gem push redis-repeater-#{RedisRepeater::VERSION.join('.')}.gem"
end
