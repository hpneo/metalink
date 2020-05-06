# frozen_string_literal: true

require "rack/cors"
require "bundler/setup"
require "hanami/api"

require_relative "./scrapper_service"

class App < Hanami::API
  use Rack::Cors do
    allow do
      origins "*"

      resource '*',
        headers: :any,
        methods: [:get, :post, :delete, :put, :patch, :options, :head],
        max_age: 0
    end
  end

  get "/" do
    if url = params.delete(:url)
      result = ScrapperService.call(url, params)

      headers["Cache-Control"] = "private, max-age=2628000"

      json(result)
    else
      halt(422)
    end
  end
end
