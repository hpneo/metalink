# frozen_string_literal: true

require "dalli"
require "rack/cors"
require "rack-cache"
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

  if ENV["MEMCACHEDCLOUD_SERVERS"].present?
    dalli = Dalli::Client.new(
      ENV["MEMCACHEDCLOUD_SERVERS"].split(','),
      username: ENV["MEMCACHEDCLOUD_USERNAME"],
      password: ENV["MEMCACHEDCLOUD_PASSWORD"]
    )

    use Rack::Cache,
        verbose: true,
        metastore: dalli,
        entitystore: dalli
  end

  get "/" do
    if url = params.delete(:url)
      result = ScrapperService.call(url, params)

      headers["Cache-Control"] = "public, max-age=2628000"

      json(result)
    else
      halt(422)
    end
  end
end
