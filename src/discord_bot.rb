require 'discordrb'
require 'yaml'
require 'ostruct'

Dir.glob("#{File.dirname(__FILE__)}/commands/*").each do |file_path|
  require_relative file_path
end

# Clase principal, encargada de cargar los comandos del bot e iniciar el proceso
#
class DiscordBot


  # Constructor principal del bot
  # Inicializa el cliente y carga los comandos
  def initialize(opts = {})
    prefix  = opts.fetch(:prefix, '!')
    @client = Discordrb::Commands::CommandBot.new token: credentials.bot_token, prefix: prefix

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

        @client.command command_name, command_class.config do |event|
          command_class.new(@client).execute
        end
      end
    end


    # Devuelve las credenciales para autenticar el bot
    #
    # @return [String]
    def credentials
      @credentials ||= OpenStruct.new YAML::load(File.read("#{File.dirname(__FILE__)}/credentials.yml"))
    end
end