# frozen_string_literal: true

require "rack/cors"
require "bundler/setup"
require "hanami/api"

require_relative "./scrapper_service"

class App < Hanami::API
  use Rack::Cors do
    allow do
      origins "*"
    end
  end

  get "/" do
    if url = params[:url]
      result = ScrapperService.call(url)

      json(result)
    else
      halt(422)
    end
  end
end