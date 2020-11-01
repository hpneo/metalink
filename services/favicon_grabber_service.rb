require "agents"
require "http"
require "nokogiri"

require_relative "./generic_scraper_service"

class FaviconGrabberService
  def self.call(url, original_url)
    favicon_url = get(url)

    favicon_url = URI.parse(favicon_url)
    favicon_url.hostname ||= original_url.hostname
    favicon_url.scheme ||= original_url.scheme

    favicon_url.to_s
  rescue
    fallback(url)
  end

  def self.get(url)
    document = GenericScraperService.call(url)
    favicon = (
      document.css('link[rel="apple-touch-icon"]').first ||
      document.css('link[rel="icon"]').first ||
      document.css('link[rel="shortcut icon"]').first
    ).attributes["href"].value

    favicon || fallback(url)
  rescue
    fallback(url)
  end

  def self.fallback(url)
    host = URI(url).host
    response = JSON.parse(
      HTTP.get("http://favicongrabber.com/api/grab/#{host}").body
    )

    response["icons"]&.first&.fetch("src")
  end
end
