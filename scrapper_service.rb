require "uri"
require "open_graph_reader"

require_relative "./favicon_grabber_service"
require_relative "./oembed_provider_service"

class ScrapperService
  def self.call(url)
    url = URI.parse(URI.escape(url))

    if resource = OEmbedProviderService.new.get(url.to_s)
      {
        url: resource["provider_url"],
        favicon: FaviconGrabberService.call(resource["provider_url"]),
        title: resource["title"],
        image: resource["thumbnail_url"],
        html: resource["html"],
        type: resource["type"],
        raw: resource
      }
    elsif resource = OpenGraphReader.fetch(url)
      result = {
        url: resource.og.url,
        favicon: FaviconGrabberService.call(resource.og.url),
        title: resource.og.title,
        description: resource.og.description,
        image: resource.og.children["image"]&.first&.content,
        type: resource.og.type,
        raw: resource.og.properties
      }

      if url.hostname == "gist.github.com"
        embed_info = JSON.parse(HTTP.get("#{url}.json").body)

        result[:html] = "<link rel=\"stylesheet\" href=\"#{embed_info['stylesheet']}\">#{embed_info['div']}"
      end

      result
    end
  end
end