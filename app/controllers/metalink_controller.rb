class MetalinkController < ApplicationController
  before_action :check_for_url

  def analyze
    url = params.delete(:url)
    expire = params.delete(:expire)

    result = ScraperService.call(url, params)

    render json: result
  end

  def screenshot
    url = params.delete(:url)
    expire = params.delete(:expire)

    file = ScreenshotService.call(url)
    contents = file.read

    file.unlink

    send_data contents, filename: url.parameterize, type: "image/png", disposition: "inline"
  end

  private

  def check_for_url
    render status: :unprocessable_entity unless params[:url]
  end
end
