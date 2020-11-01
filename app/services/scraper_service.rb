require_relative "./favicon_grabber_service"
require_relative "./o_embed_scraper_service"
require_relative "./open_graph_scraper_service"
require_relative './json_ld_scraper_service'

class ScraperService
  def self.call(url, params = {})
    begin
      url = URI.parse(url)
    rescue
      url = URI.parse(URI.escape(url))
    end

    json_ld = JsonLdScraperService.call(url) || {}
    oembed = OEmbedScraperService.call(url.to_s, params) || {}
    open_graph = OpenGraphScraperService.call(url)&.og

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
    response[:favicon] = FaviconGrabberService.call(response[:url], url)
    response[:title] = json_ld.fetch("headline", nil) || oembed.fetch("title", nil) || open_graph&.title
    response[:site_name] = json_ld.dig("publisher", "name") || oembed.fetch("provider_name", nil) || open_graph&.site_name
    response[:description] = json_ld.fetch("description", nil) || open_graph&.description
    response[:image] = json_ld.fetch("image", []).first || oembed.fetch("thumbnail_url", nil) || open_graph&.children&.fetch("image", [])&.first&.content
    response[:html] = oembed.fetch("html", nil) || custom_embed(response[:url])
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

  def self.custom_embed(url)
    url = url.is_a?(String) ? URI.parse(URI.escape(url)) : url

    if url.host === "docs.google.com"
      # return "<iframe src=\"#{url}\" frameborder=\"0\" width=\"960\" height=\"569\" allowfullscreen=\"true\" mozallowfullscreen=\"true\" webkitallowfullscreen=\"true\"></iframe>"
      return "<iframe src=\"#{url}\" frameborder=\"0\" allowfullscreen=\"true\" mozallowfullscreen=\"true\" webkitallowfullscreen=\"true\"></iframe>"
    end
  end
end
