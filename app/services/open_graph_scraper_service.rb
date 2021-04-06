require "uri"
require "open_graph_reader"

OpenGraphReader.configure do |config|
  config.synthesize_title = true
  config.synthesize_url = true
end

OpenGraphReader::Fetcher::HEADERS = {
  Accept: "text/html",
  "User-Agent": "facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)",
}.freeze

class OpenGraphScraperService
  def self.call(url)
    target = OpenGraphReader::Fetcher.new(url)

    OpenGraphReader.parse!(target.body, target.url)
  rescue
    fallback(url)
  end

  def self.fallback(url)
    body = HTTP.use(:auto_inflate).headers(GenericScraperService::HEADERS).follow.get(url).body.to_s

    OpenGraphReader.parse!(body, url)
  rescue
    nil
  end
end
