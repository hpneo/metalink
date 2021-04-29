class ScreenshotService
  def self.call(url)
    options = {
      window_size: [1080, 720]
    }

    if ENV['GOOGLE_CHROME_SHIM'].present?
      options = options.merge(
        browser_path: ENV['GOOGLE_CHROME_SHIM'],
        browser_options: { 'no-sandbox': nil }
      )
    end

    browser = Ferrum::Browser.new(options)
    browser.go_to(url)

    file = Tempfile.new("screenshot-#{ActiveSupport::Inflector.parameterize(url)}-#{Time.now.to_i}.jpeg")
    file.binmode
    file.write(browser.screenshot(format: "jpeg", quality: 100, encoding: :binary))

    file.rewind

    browser.quit

    file
  end
end
