require "agents"
require "http"
require "json"
require "nokogiri"

require_relative "./generic_scraper_service"

class JsonLdScraperService
  def self.call(url, document = GenericScraperService.call(url))
    document.css('script[type="application/ld+json"]').map(&:text).map(&:strip).map do |json|
      JSON.parse(json)
    rescue
      {}
    end
  rescue
    nil
  end
end
