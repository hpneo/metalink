class AnalyzedUrl < ApplicationRecord
  validates :url, presence: true
end
