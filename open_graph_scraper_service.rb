require "uri"
require "open_graph_reader"

OpenGraphReader.configure do |config|
  config.synthesize_title = true
  config.synthesize_url = true
end

OpenGraphReader::Fetcher::HEADERS = {
  Accept: "text/html",
  "User-Agent": "facebookexternalhit/1.1",
}.freeze

class OpenGraphScraperService
  def self.call(url)
    target = OpenGraphReader::Fetcher.new(url)

    OpenGraphReader.parse!(target.body, target.url)
  rescue
    nil
  end
end
