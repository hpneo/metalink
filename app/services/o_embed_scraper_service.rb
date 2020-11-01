require "http"
require "json"

require_relative "./generic_scraper_service"

class OEmbedScraperService
  PROVIDERS_URL = "https://oembed.com/providers.json".freeze

  def self.providers
    @providers ||= JSON.parse(HTTP.get(PROVIDERS_URL).body)
  end

  def self.find_provider(url)
    providers.find do |provider|
      provider["endpoints"].find do |endpoint|
        endpoint["schemes"]&.find do |provider_scheme|
          if provider_url = provider_scheme_to_regexp(provider_scheme)

            provider_url =~ url
          end
        end
      end
    rescue => exception
      puts exception
    end
  end

  def self.call(url, params = {})
    if provider = find_provider(url)
      provider_endpoint = provider["endpoints"].find do |endpoint|
        return nil if endpoint.nil?

        endpoint["schemes"]&.find do |provider_scheme|
          provider_scheme_to_regexp(provider_scheme)
        end
      end

      if provider_endpoint
        JSON.parse(HTTP.follow.get(provider_endpoint["url"], params: params.merge({ url: url })).body)
      end
    elsif endpoint = endpoint_from_link(url)
      JSON.parse(HTTP.use(:auto_inflate).follow.get(endpoint).body.to_s)
    end
  end

  def self.endpoint_from_link(url)
    document = GenericScraperService.call(url)
    document.css('link[type="application/json+oembed"]').first.attr('href')
  rescue
    nil
  end

  def self.provider_scheme_to_regexp(provider_scheme)
    # From https://github.com/ruby-oembed/ruby-oembed/blob/cd3f3531e3b0d1d0dec833af6f2b5142fc35be0f/lib/oembed/provider.rb#L69
    full, scheme, domain, path = *provider_scheme.match(%r{([^:]*)://?([^/?]*)(.*)})

    if full
      domain = Regexp.escape(domain).gsub("\\*", "(.*?)").gsub("(.*?)\\.", "([^\\.]+\\.)?")
      path = Regexp.escape(path).gsub("\\*", "(.*?)")

      Regexp.new("^#{Regexp.escape(scheme)}://#{domain}#{path}")
    end
  end
end
