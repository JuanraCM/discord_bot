require 'open-uri'

require_relative 'command_base'

# Comando de pruebas !ping
module Commands
  class Memegen
    include CommandBase

    BASE_API_URL     = 'https://api.imgflip.com'.freeze
    PARAMS_SEPARATOR = ';'.freeze

    configure do |config|
      config.min_args    = 1
      config.description = 'Genera un meme con textos personalizados'
      config.usage       = "!memegen [template_id]#{PARAMS_SEPARATOR}[texto_1]#{PARAMS_SEPARATOR}[texto_2]"
    end


    # Método principal, genera un meme con los parámetros dados o responde
    # a comandos adicionales (ver #list)
    def execute
      @event, args = @event_args[0], @event_args[1..-1].join(' ')

      query_or_command = args.split(PARAMS_SEPARATOR)

      if query_or_command.count == 1
        command = query_or_command.first
        respond_to?(command, true) ? send(command) : "Lo siento, el comando #{command} no existe" 
      else
        generate_meme(query_or_command)
      end
    end


    private

      # Genera un meme dados unos parámetros
      # TODO: Implementar parámetros dinámicos para memes con más de 2 cajas de texto
      # @param [Array] Argumentos para generar el meme
      def generate_meme(query_args)
        template_id, text_0, text_1 = query_args

        params = {
          'username': @bot_config.imgflip_account.username,
          'password': @bot_config.imgflip_account.password,
          'template_id': template_id,
          'text0': text_0,
          'text1': text_1
        }

        response = Net::HTTP.post(URI("#{BASE_API_URL}/caption_image"), URI.encode_www_form(params))
        body     = JSON.parse response.body
        
        body['success'] ? send_meme(body['data']) : "Ha habido un error al procesar tu meme :("
      end


      # Envía los memes disponibles por privado al usuario que envió el mensaje
      #
      # @return [String] Mensaje de información de proceso terminado
      def list
        current_user = @event.user
        fetch_available_memes.each { |message| current_user.dm.send_message message }

        "Te he enviado los memes disponibles por MD #{current_user.mention}"
      end


      # Método auxiliar para enviar el meme al canal
      # @param [Hash] Respuesta del API con la URL del meme generado
      def send_meme(meme_data)
        meme_url        = URI(meme_data['url'])
        attachment      = File.new(meme_url.open)
        attachment_name = meme_url.to_s.split('/').last

        @event.send_file attachment, filename: attachment_name
      end


      # TEMP: Devuelve los memes disponibles, filtra los que tienen 2 cajas de texto
      # @return [Array] Array de mensajes a enviar
      def fetch_available_memes
        response  = Net::HTTP.get(URI("#{BASE_API_URL}/get_memes"))
        meme_list = JSON.parse(response)["data"]["memes"]

        meme_list = meme_list.filter { |meme| meme["box_count"] == 2 }

        formatted_meme_list = meme_list.map { |meme_attrs| "ID: **#{meme_attrs['id']}**, Nombre: __#{meme_attrs['name']}__" }
        formatted_meme_list.each_slice(25).map do |memes_chunk|
          memes_chunk.join("\n")
        end.prepend("Aquí tienes la lista de memes disponible:")
      end
  end
end