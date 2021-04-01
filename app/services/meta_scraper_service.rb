class MetaScraperService
  def self.call(document)
    data = {}

    data[:meta] = meta_tags(document)
    data[:manifest] = manifest(document)
    data[:search] = search(document)

    data
  end

  private

  def self.meta_tags(document)
    document.css("meta")
    .select{ |node| node.attributes["name"] && !node.attributes["name"].value.match?("verification") }
    .inject({}) do |result, node|
      result[node.attributes["name"].value] = node.attributes["content"]&.value
      result
    end
  end

  def self.manifest(document)
    if manifest_link = document.css("link[rel='manifest']").first
      manifest_link.attributes["href"]&.value.present?
    end
  end

  def self.search(document)
    (document.css("link[type='application/opensearchdescription+xml']") || document.css("link[rel='search']")).any?
  end
end
