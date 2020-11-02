class CreateAnalyzedUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzed_urls do |t|
      t.string :url, null: false
      t.jsonb :content

      t.timestamps
    end
  end
end
