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
    "docs.google.com" => :docs_google,
  }.freeze

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

    meta = MetaScraperService.call(@url, @document)

    @data = {}

    @data[:url] = fetch_url
    @data[:favicon] = fetch_favicon
    @data[:title] = fetch_title
    @data[:site_name] = fetch_site_name
    @data[:description] = fetch_description
    @data[:image] = fetch_image
    @data[:video] = fetch_video
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
    url = find_in_json_ld("mainEntityOfPage") if @json_ld && find_in_json_ld("mainEntityOfPage").is_a?(String) # rubocop:todo Airbnb/SimpleModifierConditional
    url ||= @oembed.fetch("url", nil) if @oembed
    url ||= @open_graph.url if @open_graph
    url ||= @url.to_s

    url
  end

  def fetch_favicon
    FaviconGrabberService.call(@data[:url], @url, @document)
  end

  def fetch_title
    title = find_in_json_ld("headline") if @json_ld
    title ||= @oembed.fetch("title", nil) if @oembed
    title ||= @open_graph.title if @open_graph
    title ||= @document.css("title").first&.content

    title
  end

  def fetch_site_name
    site_name = find_in_json_ld("publisher", "name") if @json_ld
    site_name ||= @oembed.fetch("provider_name", nil) if @oembed
    site_name ||= @open_graph.site_name if @open_graph

    site_name
  end

  def fetch_description
    description = find_in_json_ld("description") if @json_ld
    description ||= @open_graph.description if @open_graph

    description
  end

  def fetch_image
    image = find_in_json_ld("image")&.first if @json_ld
    image ||= @oembed.fetch("thumbnail_url", nil) if @oembed
    image ||= @open_graph.image&.content if @open_graph

    image
  end

  def fetch_video
    @open_graph.video&.content if @open_graph
  end

  def fetch_html
    @oembed.fetch("html", nil) if @oembed
  end

  def fetch_type
    type = find_in_json_ld("@type") if @json_ld
    type ||= @oembed.fetch("type", nil) if @oembed
    type ||= @open_graph.type if @open_graph

    type
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

    if video = twitter_data.dig("extended_entities", "media")&.find { |media| media["type"] == "video" }
      video_url = video["video_info"]["variants"].
        select { |variant| variant["bitrate"] && variant["content_type"] == "video/mp4" }.
        sort_by { |variant| variant["bitrate"] }.
        last["url"]

      @data[:video] = video_url if video_url
    end

    @data
  rescue => exception
    puts "Exception in Twitter: #{exception}"
    @data
  end

  def docs_google
    @data[:html] ||= "<iframe src=\"#{@url}\" frameborder=\"0\" allowfullscreen=\"true\" mozallowfullscreen=\"true\" webkitallowfullscreen=\"true\"></iframe>"

    @data
  end

  private

  def find_in_json_ld(*keys)
    if @json_ld.is_a?(Array)
      found_item = @json_ld.find { |item| item.dig(*keys) }
      found_item.dig(*keys) if found_item
    elsif @json_ld.is_a?(Hash)
      @json_ld.dig(*keys)
    end
  end
end
