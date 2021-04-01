require_relative './generic_scraper_service'
require_relative './meta_scraper_service'
require_relative "./favicon_grabber_service"
require_relative "./o_embed_scraper_service"
require_relative "./open_graph_scraper_service"
require_relative './json_ld_scraper_service'

class ScraperService
  EXTRA_INFO_PROVIDERS = {
    "gist.github.com" => :gist_github,
    "twitter.com" => :twitter,
    "docs.google.com" => :docs_google
  }

  attr_accessor :url, :params, :document, :json_ld, :oembed, :open_graph, :data

  def self.call(url, params = {})
    new(url, params).call
  end

  def initialize(url, params = {})
    @url = url
    @params = params
  end

  def call
    begin
      @url = URI.parse(@url)
    rescue
      @url = URI.parse(URI.escape(@url))
    end

    @document = GenericScraperService.call(@url)
    @json_ld = JsonLdScraperService.call(@url, @document)
    @oembed = OEmbedScraperService.call(@url.to_s, @params, @document)
    @open_graph = OpenGraphScraperService.call(@url)&.og

    meta = MetaScraperService.call(@document)

    @data = {}

    @data[:url] = fetch_url
    @data[:favicon] = fetch_favicon
    @data[:title] = fetch_title
    @data[:site_name] = fetch_site_name
    @data[:description] = fetch_description
    @data[:image] = fetch_image
    @data[:html] = fetch_html
    @data[:type] = fetch_type
    @data[:lang] = fetch_lang
    @data[:raw] = {}

    @data[:raw][:json_ld] = @json_ld if @json_ld
    @data[:raw][:oembed] = @oembed if @oembed
    @data[:raw][:open_graph] = @open_graph.properties if @open_graph

    if extra_info_method = EXTRA_INFO_PROVIDERS[@url.hostname]
      send(extra_info_method)
    end

    @data = @data.merge(meta)

    @data
  end

  def fetch_url
    return @json_ld.fetch("mainEntityOfPage", nil) if @json_ld
    return @oembed.fetch("url", nil) if @oembed
    return @open_graph.url if @open_graph

    @url
  end

  def fetch_favicon
    FaviconGrabberService.call(@data[:url], @url, @document)
  end

  def fetch_title
    return @json_ld.fetch("headline", nil) if @json_ld
    return @oembed.fetch("title", nil) if @oembed
    return @open_graph.title if @open_graph

    @document.css("title").first&.content
  end

  def fetch_site_name
    return @json_ld.dig("publisher", "name") if @json_ld
    return @oembed.fetch("provider_name", nil) if @oembed
    return @open_graph.site_name if @open_graph

    nil
  end

  def fetch_description
    return @json_ld.fetch("description", nil) if @json_ld
    return @open_graph.description if @open_graph

    nil
  end

  def fetch_image
    return @json_ld.fetch("image", []).first if @json_ld
    return @oembed.fetch("thumbnail_url", nil) if @oembed
    return @open_graph.children&.fetch("image", [])&.first&.content if @open_graph

    nil
  end

  def fetch_html
    return @oembed.fetch("html", nil) if @oembed

    nil
  end

  def fetch_type
    return @json_ld.fetch("@type", nil) if @json_ld
    return @oembed.fetch("type", nil) if @oembed
    return @open_graph.type if @open_graph

    nil
  end

  def fetch_lang
    @document.css("html").first&.attributes["lang"]&.value
  end

  def gist_github
    embed_info = JSON.parse(HTTP.get("#{@url}.json").body)

    @data[:html] ||= "<link rel=\"stylesheet\" href=\"#{embed_info['stylesheet']}\">#{embed_info['div']}"

    @data
  rescue
    @data
  end

  def twitter
    id = @url.to_s.split("/").pop
    twitter_data = TwitterService.call(id)

    video = twitter_data["extended_entities"]["media"].find { |media| media["type"] == "video" }
    video_url = video["video_info"]["variants"]
      .select { |variant| variant["bitrate"] && variant["content_type"] == "video/mp4" }
      .sort_by { |variant| variant["bitrate"] }
      .last["url"]

    @data[:video] = video_url

    @data
  rescue Exception => error
    puts error
    @data
  end

  def docs_google
    @data[:html] ||= "<iframe src=\"#{@url}\" frameborder=\"0\" allowfullscreen=\"true\" mozallowfullscreen=\"true\" webkitallowfullscreen=\"true\"></iframe>"

    @data
  end
end
