require 'optparse'

require_relative 'discord_bot'

options = {}

OptionParser.new do |opts|
  opts.on('--production') { options[:production_mode] = true }
end.parse!

bot = DiscordBot.new(options)
bot.run
