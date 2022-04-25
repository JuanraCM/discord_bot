# Módulo que actúa a modo de interfaz para definir comandos
#
module CommandBase

  attr_reader :event

  # :no-doc:
  def self.included(klass)
    klass.extend(ClassMethods)

    command_name = klass.to_s.split('::').last.downcase

    p "Command #{command_name} has been registered!"
  end


  # Constructor del comando
  # @param event [Discordrb::Commands::CommandEvent] Evento recibido
  def initialize(event)
    @event = event
  end


  # Método base a sobreescribir por todos los comandos
  # Punto de partida del proceso de ejecución del comando
  def execute(*args)
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
