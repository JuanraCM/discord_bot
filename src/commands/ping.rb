# Comando de pruebas !ping
module Commands
  class Ping
    include CommandBase

    configure do |config|
      config.description = 'Comando de prueba'
    end


    # :no-doc:
    def execute
      'Pong!'
    end
  end
end