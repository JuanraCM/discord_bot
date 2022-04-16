require_relative 'command_base'

# Comando de pruebas !ping
module Commands
  class Ping
    include CommandBase

    # :no-doc:
    def execute
      'Pong!'
    end
  end
end