class CreateWikiExtensionsTags < ActiveRecord::Migration
  def self.up
    create_table :wiki_extensions_tags do |t|
      t.column :project_id, :integer

      t.column :name, :string

      t.column :created_at, :timestamp

    end
  end

  def self.down
    drop_table :wiki_extensions_tags
  end
end
