# frozen_string_literal: true

require "bundler/setup"
require "hanami/api"

require_relative "./scrapper_service"

class App < Hanami::API
  get "/" do
    if url = params[:url]
      result = ScrapperService.call(url)

      json(result)
    else
      halt(422)
    end
  end
end