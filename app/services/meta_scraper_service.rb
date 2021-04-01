class MetaScraperService
  def self.call(url, document)
    data = {}

    @canonical = canonical(document)
    @meta = meta_tags(document)
    @manifest = manifest(url, document)
    @search = search(document)
    @feed = feed(url, document)

    data[:canonical] = @canonical if @canonical.present?
    data[:meta] = @meta if @meta.present?
    data[:manifest] = @manifest if @manifest.present?
    data[:search] = @search if @search.present?
    data[:feed] = @feed if @feed.present?

    data
  end

  private

  def self.canonical(document)
    if canonical_link = document.css("link[rel='canonical']").first
      canonical_link.attributes["href"]&.value
    end
  end

  def self.meta_tags(document)
    document.css("meta")
    .select{ |node| node.attributes["name"] && !node.attributes["name"].value.match?("verification") }
    .inject({}) do |result, node|
      result[node.attributes["name"].value] = node.attributes["content"]&.value
      result
    end
  end

  def self.manifest(url, document)
    if manifest_link = document.css("link[rel='manifest']").first
      if manifest_url_or_path = manifest_link.attributes["href"]&.value
        if manifest_url_or_path.starts_with?("/")
          manifest_url = url.dup
          manifest_url.path = manifest_url_or_path

          manifest_url.to_s
        else
          manifest_url_or_path
        end
      end
    end
  end

  def self.search(document)
    (document.css("link[type='application/opensearchdescription+xml']") || document.css("link[rel='search']")).any?
  end

  def self.feed(url, document)
    if feed_link = document.css("link[type='application/atom+xml']").first
      if feed_url_or_path = feed_link.attributes["href"]&.value
        if feed_url_or_path.starts_with?("/")
          feed_url = url.dup
          feed_url.path = feed_url_or_path

          feed_url.to_s
        else
          feed_url_or_path
        end
      end
    end
  end
end
