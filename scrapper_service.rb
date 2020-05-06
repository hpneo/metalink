require "uri"
require "open_graph_reader"

require_relative "./favicon_grabber_service"
require_relative "./oembed_provider_service"
require_relative './json_ld_parser_service'

class ScrapperService
  def self.call(url, params = {})
    url = URI.parse(URI.escape(url))

    json_ld = JSON::LD::ParserService.call(url) || {}
    oembed = OEmbedProviderService.new.get(url.to_s, params) || {}
    open_graph = OpenGraphReader.fetch(url)&.og

    response = {
      url: nil,
      favicon: nil,
      title: nil,
      description: nil,
      image: nil,
      html: nil,
      type: nil,
      raw: nil,
    }

    response[:url] = json_ld.fetch("mainEntityOfPage", nil) || oembed.fetch("provider_url", nil) || open_graph&.url || url
    response[:favicon] = FaviconGrabberService.call(response[:url])
    response[:title] = json_ld.fetch("headline", nil) || oembed.fetch("title", nil) || open_graph&.title
    response[:description] = json_ld.fetch("description", nil) || open_graph&.description
    response[:image] = json_ld.fetch("image", []).first || oembed.fetch("thumbnail_url", nil) || open_graph&.children&.fetch("image", [])&.first&.content
    response[:html] = oembed.fetch("html", nil)
    response[:type] = json_ld.fetch("@type", nil) || oembed.fetch("type", nil) || open_graph&.type
    response[:raw] = {
      json_ld: json_ld,
      oembed: oembed,
      open_graph: open_graph&.properties || {},
    }

    if url.hostname == "gist.github.com"
      embed_info = JSON.parse(HTTP.get("#{url}.json").body)
      html = "<link rel=\"stylesheet\" href=\"#{embed_info['stylesheet']}\">#{embed_info['div']}"

      response[:html] ||= html
    end

    response
  end
end
