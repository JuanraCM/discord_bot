require 'open-uri'

require_relative 'command_base'

# Comando de pruebas !ping
module Commands
  class Memegen
    include CommandBase

    BASE_API_URL = 'https://api.imgflip.com'.freeze

    configure do |config|
      config.min_args    = 1
      config.description = 'Genera un meme con textos personalizados'
      config.usage       = '!memegen [template_id],[texto_1],[texto_2]'
    end


    # :no-doc:
    def execute
      event, query_args = @event_args[0], @event_args[1..-1].join(' ')

      template_id, text_0, text_1 = query_args.split(',')

      params = {
        'username': @bot_config.imgflip_account.username,
        'password': @bot_config.imgflip_account.password,
        'template_id': template_id,
        'text0': text_0,
        'text1': text_1
      }

      response = Net::HTTP.post(URI("#{BASE_API_URL}/caption_image"), URI.encode_www_form(params))
      body     = JSON.parse response.body

      meme_url        = URI(body['data']['url'])
      attachment      = File.new(meme_url.open)
      attachment_name = meme_url.to_s.split('/').last

      event.send_file attachment, filename: attachment_name
    end
  end
end