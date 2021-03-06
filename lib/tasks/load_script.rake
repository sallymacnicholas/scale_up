unless Rails.env.production?
  require "load_script/session"
  namespace :load_script do
    desc "Run a load testing script against the app. Accepts 'HOST' as an ENV argument. Defaults to 'localhost:3000'."
    task :run => :environment do
      if `which phantomjs`.empty?
        raise "PhantomJS not found. Make sure you have it installed. Try: 'brew install phantomjs'"
      end
      LoadScript::Session.new(ARGV[1]).run
      4.times.map do
        Thread.new do
          LoadScript::Session.new(ARGV[1]).run
        end
      end.map(&:join)
    end
  end
end

# TODO: Add concurrency factor:
#if __FILE__ == $0
#1.times.map do
#Thread.new do
#if ARGV[0] #host
#Session.new(ARGV[0]).run
#else
#Session.new.run
#end
#end
#end.map(&:join)
#end
