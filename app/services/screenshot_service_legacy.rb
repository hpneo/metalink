require "active_support/inflector"
require "webdrivers"
require "webdrivers/chromedriver"
require "watir"

Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_SHIM'] if ENV['GOOGLE_CHROME_SHIM']

class ScreenshotServiceLegacy
  def self.call(url)
    browser = new_browser(url)
    browser.goto(url)

    file = Tempfile.new("screenshot-#{ActiveSupport::Inflector.parameterize(url)}-#{Time.now.to_i}.png")
    file.binmode
    file.write(browser.screenshot.png)

    file.rewind

    browser.close

    file
  end

  def self.new_browser(url)
    Webdrivers.install_dir = File.expand_path("~/.webdrivers/#{url.parameterize}")
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument '--headless'
    options.add_argument '--window-size=1080x720'
    options.add_argument '--hide-scrollbars'
    options.add_argument '--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36'

    if chrome_bin = ENV['GOOGLE_CHROME_SHIM']
      options.add_argument '--no-sandbox'
      options.add_argument '--disable-dev-shm-usage'
      options.binary = chrome_bin
    end

    Watir::Browser.new(:chrome, options: options)
  end
end
