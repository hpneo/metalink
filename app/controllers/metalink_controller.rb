class MetalinkController < ApplicationController
  before_action :check_for_url

  def analyze
    unsafe_params = params.to_unsafe_h
    url = unsafe_params.delete(:url)
    expire = unsafe_params.delete(:expire)

    cached_result = AnalyzedUrl.find_by(url: url)

    if cached_result.nil? || expire == "true"
      result = ScraperService.call(url, unsafe_params)

      cached_result ||= AnalyzedUrl.find_or_initialize_by(url: url)
      cached_result.content = result
      cached_result.save
    else
      result = cached_result.content
    end

    render json: result
  end

  def screenshot
    unsafe_params = params.to_unsafe_h
    url = unsafe_params.delete(:url)
    expire = unsafe_params.delete(:expire)

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
