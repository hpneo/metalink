class TwitterService
  HEADERS = {
    Authorization: "Bearer #{ENV['TWITTER_BEARER_TOKEN']}",
  }.freeze

  def self.call(id)
    output = HTTP.use(:auto_inflate).headers(HEADERS).follow.get("https://api.twitter.com/1.1/statuses/show.json?id=#{id}&tweet_mode=extended").body.to_s
    JSON.parse(output)
  rescue
    nil
  end
end
