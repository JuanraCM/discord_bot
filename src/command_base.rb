# Módulo que actúa a modo de interfaz para definir comandos
#
module CommandBase

  # :no-doc:
  def self.included(klass)
    klass.extend(ClassMethods)

    command_name = klass.to_s.split('::').last.downcase

    p "Command #{command_name} has been registered!"
  end


  # Constructor del comando
  # @param event_args [Array] Argumentos de la llamada al bot
  # @param bot_config [OpenStruct] Objeto con los parámetros de configuración del bot
  def initialize(event_args, bot_config)
    @event_args = event_args
    @bot_config = bot_config
  end


  # Método base a sobreescribir por todos los comandos
  # Lógica principal del comando
  def execute
    raise NotImplementedError
  end


  # :no-doc:
  module ClassMethods
    
    # Macro para configurar el comando
    def configure
      config_to_merge = OpenStruct.new
      yield config_to_merge

      setup.merge! config_to_merge.to_h
    end


    # Hash de configuración del comando
    #
    # @return [Hash]
    def setup
      @setup ||= {}
    end
  end
end
