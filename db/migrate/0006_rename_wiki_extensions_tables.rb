class RenameWikiExtensionsTables < ActiveRecord::Migration
  def self.up
    rename_table :wiki_extensions_project_menus, :wiki_extensions_menus if table_exists? :wiki_extensions_project_menus
    rename_table :wiki_extensions_project_settings, :wiki_extensions_settings if table_exists? :wiki_extensions_project_settings
  end

  def self.down
    
  end
end
