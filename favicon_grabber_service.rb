require "uri"

class FaviconGrabberService
  def self.call(url)
    host = URI(url).host
    response = JSON.parse(
      HTTP.get("http://favicongrabber.com/api/grab/#{host}").body
    )

    response["icons"]&.first&.fetch("src")
  end
end