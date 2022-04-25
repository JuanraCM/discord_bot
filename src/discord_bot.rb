require 'yaml'
require 'erb'
require 'ostruct'

# Clase principal, encargada de cargar los comandos del bot e iniciar el proceso
#
class DiscordBot

  COMMANDS_PREFIX = '!'.freeze

  # Inicializa el cliente y lanza el proceso
  def self.run!
    @client = Discordrb::Commands::CommandBot.new token: credentials.bot_token, prefix: COMMANDS_PREFIX
    read_commands

    @client.run
  end


  # Devuelve las credendiales del bot, tiene en cuenta el entorno en el que se está ejecutando
  # para buscar el fichero
  #
  # @return [OpenStruct]
  def self.credentials
    unless @credentials
      file_path    = "#{File.dirname(__FILE__)}/credentials_#{ENV['RUBY_ENV']}.yml"
      @credentials = JSON.parse YAML::load(ERB.new(File.read(file_path)).result).to_json, :object_class => OpenStruct
    end

    @credentials
  rescue Errno::ENOENT
    p "Credentials file missing! path= #{file_path}"
    exit
  end


  private

    # Procesa los comandos del bot para el cliente
    def self.read_commands
      Commands.constants.each do |command_const|
        command_class = Object.const_get("Commands::#{command_const}")
        command_name  = command_const.to_s.downcase.to_sym

        @client.command command_name, command_class.setup do |*args|
          event        = args.first
          command_args = args.drop(1)

          command_class.new(event).execute(*command_args)
        end
      end
    end
end