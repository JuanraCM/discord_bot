ENV['RUBY_ENV'] ||= 'development'

require 'bundler/setup'

Bundler.require(:default, ENV['RUBY_ENV'])
loader = Zeitwerk::Loader.for_gem
loader.push_dir("#{File.dirname(__FILE__)}/src")
loader.setup

task :bot do
  DiscordBot.run!
end
