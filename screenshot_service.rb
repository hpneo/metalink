require 'chromedriver-helper'
require 'active_support/inflector'
require 'watir'

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
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument '--headless'
    options.add_argument '--window-size=1080x720'

    if chrome_bin = ENV['GOOGLE_CHROME_SHIM']
      options.add_argument '--no-sandbox'
      options.binary = chrome_bin
    end

    Watir::Browser.new(:chrome, options: options)
  end
end
