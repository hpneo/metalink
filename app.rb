# frozen_string_literal: true

require 'dalli'
require 'rack/cors'
require 'rack/deflater'
require 'rack-cache'
require 'bundler/setup'
require 'hanami/api'
require 'raven'

require_relative './scraper_service'
require_relative './screenshot_service'

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end

class App < Hanami::API
  use Raven::Rack
  use Rack::Cors do
    allow do
      origins '*'

      resource '*',
               headers: :any,
               methods: %i(get post delete put patch options head),
               max_age: 0
    end
  end

  use Rack::Deflater

  if ENV['MEMCACHEDCLOUD_SERVERS']
    dalli = Dalli::Client.new(
      ENV['MEMCACHEDCLOUD_SERVERS'].split(','),
      username: ENV['MEMCACHEDCLOUD_USERNAME'],
      password: ENV['MEMCACHEDCLOUD_PASSWORD']
    )

    use Rack::Cache,
        verbose: true,
        metastore: dalli,
        entitystore: dalli
  else
    use Rack::Cache,
        verbose: true
  end

  get '/' do
    url = params.delete(:url)
    expire = params.delete(:expire)

    if url
      result = ScraperService.call(url, params)

      if expire == "true"
        headers['Age'] = '604800'
      else
        headers['Cache-Control'] = 'public, max-age=604800'
      end

      json(result)
    else
      halt(422)
    end
  end

  get '/screenshot' do
    url = params.delete(:url)
    expire = params.delete(:expire)

    if url
      headers["Content-Disposition"] = "inline"
      headers["Content-Transfer-Encoding"] = "binary"
      headers["Content-Type"] = "image/png"

      file = ScreenshotService.call(url)

      file_contents = file.read
      file.unlink

      if expire == "true"
        headers['Age'] = '3600'
      else
        headers['Cache-Control'] = 'public, max-age=3600'
      end

      body file_contents
    else
      halt(422)
    end
  end
end
