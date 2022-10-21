class ScreenshotService
  MAX_REQUEST_TIMEOUT = 10

  def self.call(url)
    options = {
      window_size: [1080, 720],
      timeout: 45,
      process_timeout: 45
    }

    if ENV['GOOGLE_CHROME_SHIM'].present?
      options = options.merge(
        browser_path: ENV['GOOGLE_CHROME_SHIM'],
        browser_options: { 'no-sandbox': nil }
      )
    end

    start_time = Time.now.to_i

    browser = Ferrum::Browser.new(options)
    browser.go_to(url)
    browser.network.wait_for_idle

    end_time = Time.now.to_i

    sleep_during = end_time - start_time

    if sleep_during < MAX_REQUEST_TIMEOUT
      sleep_during = MAX_REQUEST_TIMEOUT - sleep_during

      sleep sleep_during
    end

    file = Tempfile.new("screenshot-#{ActiveSupport::Inflector.parameterize(url)}-#{Time.now.to_i}.jpeg")
    file.binmode
    file.write(browser.screenshot(format: "jpeg", quality: 100, encoding: :binary))

    file.rewind

    browser.reset
    browser.quit

    file
  end
end
