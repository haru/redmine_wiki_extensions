

require_dependency "redmine/wiki_formatting/textile/formatter"

module WikiExtensionsFormatterPatch
  def self.included(base) # :nodoc:
    base.send(:include, FormatterMethodsWikiExtensions)
    
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      
    end
  end
end

module FormatterMethodsWikiExtensions
  
  Redmine::WikiFormatting::Textile::Formatter::RULES << :inline_smiles


  private
  
  def inline_smiles(text)
    baseurl = Redmine::Utils.relative_url_root
    src = baseurl + "/plugin_assets/redmine_wiki_extensions/images/"
    @emoticons = WikiExtensions::Emoticons.new
    @emoticons.emoticons.each{|emoticon|
      text.gsub!(emoticon['emoticon'], "<img src=\""+src+"#{emoticon['image']}\">")
    }      
  end
end

Redmine::WikiFormatting::Textile::Formatter.send(:include, WikiExtensionsFormatterPatch)