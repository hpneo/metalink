require "agents"
require "http"
require "json"
require "nokogiri"

class GenericScraperService
  HEADERS = {
    # user_agent: Agents.random_user_agent(:desktop),
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
    accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    accept_encoding: "gzip",
    accept_language: "es-419,es;q=0.9,de;q=0.8,en;q=0.7,gl;q=0.6,mt;q=0.5,nl;q=0.4,nb;q=0.3,pt;q=0.2",
    cache_control: "no-cache",
  }.freeze

  def self.call(url)
    Nokogiri::HTML(
      HTTP.use(:auto_inflate).headers(HEADERS).follow.get(url).body.to_s
    )
  rescue
    nil
  end
end
