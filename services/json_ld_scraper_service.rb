require "agents"
require "http"
require "json"
require "nokogiri"

require_relative "./generic_scraper_service"

module JSON::LD
  class ScraperService
    def self.call(url)
      document = GenericScraperService.call(url)
      JSON.parse(document.css('script[type="application/ld+json"]').first.text.strip)
    rescue
      nil
    end
  end
end
