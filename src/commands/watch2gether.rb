require 'net/http'
require 'json'

require_relative 'command_base'

# Comando !watchtogether
# Crea una sala de Watch2Gether dada una URL
module Commands
  class Watch2gether
    include CommandBase

    BASE_API_URL    = 'https://w2g.tv/rooms'.freeze
    ROOM_BG_COLOR   = '#808080'.freeze
    ROOM_BG_OPACITY = '100'.freeze

    configure do |config|
      config.min_args    = 1
      config.max_args    = 1
      config.description = 'Crea una sala de Watch2Gether dada la URL de un vídeo'
      config.usage       = '!watchtogether [url]'
    end

    # Genera una sala de Watch2Gether con la URL dada
    def execute
      event, url = @event_args

      if valid_url?(url)
        "Aqui tienes tu sala de Watch2Gether: #{create_room(url)}"
      else
        "Introduce una URL válida"
      end
    end


    private

      # Valida el formato de la URL dada como parámetro
      # @param [String] Url del vídeo
      def valid_url?(video_url)
        video_url =~ URI::regexp
      end


      # Crea una sala de Watch2Gether
      # @param [String] Url del vídeo
      #
      # @return [String] Url de la sala creada
      def create_room(video_url)
        headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        }

        data = {
          'w2g_api_key': @bot_config.watch2gether_token,
          'share': video_url,
          'bg_color': '#808080',
          'bg_opacity': '100'
        }

        response = Net::HTTP.post(URI("#{BASE_API_URL}/create.json"), data.to_json, headers)
        body     = JSON.parse response.body

        "#{BASE_API_URL}/#{body['streamkey']}"
      end
  end
end