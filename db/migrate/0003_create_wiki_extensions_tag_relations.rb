class CreateWikiExtensionsTagRelations < ActiveRecord::Migration
  def self.up
    create_table :wiki_extensions_tag_relations do |t|

      t.column :tag_id, :integer

      t.column :wiki_page_id, :integer

      t.column :created_at, :timestamp

    end

    add_index :wiki_extensions_tag_relations, :tag_id
    add_index :wiki_extensions_tag_relations, :wiki_page_id
  end

  def self.down
    drop_table :wiki_extensions_tag_relations
  end
end
