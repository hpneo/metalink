require "http"
require "json"

class OEmbedProviderService
  PROVIDERS_URL = "https://oembed.com/providers.json"

  def self.providers
    @providers ||= JSON.parse(HTTP.get(PROVIDERS_URL).body)
  end

  def find_provider(url)
    self.class.providers.find do |provider|
      begin
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
  end

  def get(url)
    if provider = find_provider(url)
      endpoint = provider["endpoints"].find do |endpoint|
        return nil if endpoint.nil?

        endpoint["schemes"]&.find do |provider_scheme|
          provider_scheme_to_regexp(provider_scheme)
        end
      end

      if endpoint
        JSON.parse(HTTP.follow.get(endpoint["url"], params: { url: url }).body)
      end
    end
  end

  private

  def provider_scheme_to_regexp(provider_scheme)
    # From https://github.com/ruby-oembed/ruby-oembed/blob/cd3f3531e3b0d1d0dec833af6f2b5142fc35be0f/lib/oembed/provider.rb#L69
    full, scheme, domain, path = *provider_scheme.match(%r{([^:]*)://?([^/?]*)(.*)})

    if full
      domain = Regexp.escape(domain).gsub("\\*", "(.*?)").gsub("(.*?)\\.", "([^\\.]+\\.)?")
      path = Regexp.escape(path).gsub("\\*", "(.*?)")
      provider_url = Regexp.new("^#{Regexp.escape(scheme)}://#{domain}#{path}")
    end
  end
end