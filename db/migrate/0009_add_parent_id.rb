class AddParentId < ActiveRecord::Migration
 
  def self.up
    add_column(:wiki_extensions_comments, "parent_id", :integer)
  end

  def self.down
    remove_column(:wiki_extensions_comments, "parent_id")
  end
end