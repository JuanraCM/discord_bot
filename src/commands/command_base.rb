# Módulo que actúa a modo de interfaz para definir comandos
#
module CommandBase

  # Notificación de comando registrado
  def self.included(klass)
    klass.extend(ClassMethods)

    command_name = klass.to_s.split('::').last.downcase

    p "Command #{command_name} has been registered!"
  end


  # Constructor del comando
  def initialize(client)
    @client = client
  end


  # Método base a sobreescribir por todos los comandos
  # Lógica principal del comando
  def execute
    raise NotImplementedError
  end


  # :no-doc:
  module ClassMethods
    
    # Hash de configuración del comando
    def config
      {}
    end
  end
end
