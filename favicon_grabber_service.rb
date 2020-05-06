require "agents"
require "http"
require "nokogiri"

class FaviconGrabberService
  def self.call(url)
    document = Nokogiri::HTML(
      HTTP.use(:auto_inflate).headers(JSON::LD::ParserService::HEADERS).follow.get(url).body.to_s
    )

    document.css('link[rel="icon"]').first.attributes["href"].value
  rescue
    nil
  end

  def self.fallback(url)
    host = URI(url).host
    response = JSON.parse(
      HTTP.get("http://favicongrabber.com/api/grab/#{host}").body
    )

    response["icons"]&.first&.fetch("src")
  end
end
