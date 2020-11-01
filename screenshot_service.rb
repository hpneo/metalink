require "active_support/inflector"
require "webdrivers"
require "webdrivers/chromedriver"
require "watir"

Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_SHIM'] if ENV['GOOGLE_CHROME_SHIM']

class ScreenshotService
  def self.call(url)
    browser = new_browser
    browser.goto(url)

    file = Tempfile.new("screenshot-#{ActiveSupport::Inflector.parameterize(url)}-#{Time.now.to_i}.png")
    file.binmode
    file.write(browser.screenshot.png)

    file.rewind

    browser.close

    file
  end

  def self.new_browser
    Webdrivers.install_dir = File.expand_path("~/.webdrivers/#{property.url.parameterize}")
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument '--headless'
    options.add_argument '--window-size=1080x720'
    options.add_argument '--hide-scrollbars'
    options.add_argument '--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'

    if chrome_bin = ENV['GOOGLE_CHROME_SHIM'] # rubocop:todo Lint/AssignmentInCondition
      options.add_argument '--no-sandbox'
      options.add_argument '--disable-dev-shm-usage'
      options.binary = chrome_bin
    end

    Watir::Browser.new(:chrome, options: options)
  end
end
