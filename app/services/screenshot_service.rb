class ScreenshotService
  def self.call(url)
    browser = Ferrum::Browser.new(
      window_size: [1080, 720],
      browser_path: ENV['GOOGLE_CHROME_SHIM']
    )
    browser.go_to(url)

    file = Tempfile.new("screenshot-#{ActiveSupport::Inflector.parameterize(url)}-#{Time.now.to_i}.png")
    file.binmode
    file.write(browser.screenshot(encoding: :binary))

    file.rewind

    browser.quit

    file
  end
end
