require 'discordrb'
require 'yaml'
require 'erb'
require 'ostruct'
require 'bundler/setup'
Bundler.require(:development)

Dir.glob("#{File.dirname(__FILE__)}/commands/*").each do |file_path|
  require_relative file_path
end

# Clase principal, encargada de cargar los comandos del bot e iniciar el proceso
#
class DiscordBot

  # Constructor principal del bot
  # Inicializa el cliente y carga los comandos
  def initialize(opts = {})
    @production_mode = opts.fetch(:production_mode, false)

    prefix  = opts.fetch(:prefix, '!')
    @client = Discordrb::Commands::CommandBot.new token: config.bot_token, prefix: prefix

    read_commands
  end


  # Lanza el bot
  def run
    @client.run
  end


  private

    # Procesa los comandos del bot para el cliente
    def read_commands
      Commands.constants.each do |command_const|
        command_class = Object.const_get("Commands::#{command_const}")
        command_name  = command_const.to_s.downcase.to_sym

        @client.command command_name, command_class.setup do |*args|
          command_class.new(args, config).execute
        end
      end
    end


    # Devuelve la configuración del bot
    #
    # @return [OpenStruct]
    def config
      unless @config
        file_path = "#{File.dirname(__FILE__)}/config_#{@production_mode ? 'production' : 'development'}.yml"
        @config   = JSON.parse YAML::load(ERB.new(File.read(file_path)).result).to_json, :object_class => OpenStruct
      end

      @config
    rescue Errno::ENOENT
      p "Config file missing! path= #{file_path}"
      exit
    end
end