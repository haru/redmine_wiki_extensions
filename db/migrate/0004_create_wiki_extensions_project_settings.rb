class CreateWikiExtensionsProjectSettings < ActiveRecord::Migration
  def self.up
    create_table :wiki_extensions_settings do |t|

      t.column :project_id, :integer

      t.column :created_at, :timestamp

      t.column :updated_at, :timestamp

      t.column :lock_version, :integer

    end
  end

  def self.down
    drop_table :wiki_extensions_settings
  end
end
