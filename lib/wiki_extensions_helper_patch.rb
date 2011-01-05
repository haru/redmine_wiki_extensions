

require_dependency "redmine/wiki_formatting/textile/helper"

module WikiExtensionsHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, HelperMethodsWikiExtensions)
    
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method_chain :wikitoolbar_for, :wiki_smiles
      
    end

  end
end

module HelperMethodsWikiExtensions
    
  def wikitoolbar_for_with_wiki_smiles(field_id)
    # Is there a simple way to link to a public resource?
    url = "#{Redmine::Utils.relative_url_root}/help/wiki_syntax.html"
          
    help_link = l(:setting_text_formatting) + ': ' +
      link_to(l(:label_help), url,
      :onclick => "window.open(\"#{ url }\", \"\", \"resizable=yes, location=no, width=900, height=640, menubar=no, status=no, scrollbars=yes\" ); return false;")
      
    baseurl = url_for(:controller => 'wiki_extensions', :action => 'index', :id => @project) + '/../../..'
    imageurl = baseurl + "/plugin_assets/redmine_wiki_extensions/images"
    o = ""
    o << stylesheet_link_tag(baseurl + "/plugin_assets/redmine_wiki_extensions/stylesheets/wiki_smiles.css") +javascript_include_tag('jstoolbar/jstoolbar')
    o << javascript_include_tag('jstoolbar/textile')
      #here added a new js tag#
    o << javascript_include_tag(baseurl + "/plugin_assets/redmine_wiki_extensions/javascripts/wiki_smiles.js")
    emoticons = WikiExtensions::Emoticons.new
    o << '<script type="text/javascript">'
    o << "\n"
    o << "redmine_base_url = '#{baseurl}';\n"
    o << 'var buttons = [];'
    emoticons.emoticons.each{|emoticon|
      o << "buttons.push(['#{emoticon['emoticon'].gsub("'", "\\'")}', '#{emoticon['image']}', '#{emoticon['title']}']);\n"
    }
    o << "setEmoticonButtons(buttons, '#{imageurl}');\n"
    o << '</script>'
    o << javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}")
    o << javascript_tag("var wikiToolbar = new jsToolBar($('#{field_id}')); wikiToolbar.setHelpLink('#{help_link}'); wikiToolbar.draw();")
    o
  end

end

Redmine::WikiFormatting::Textile::Helper.send(:include, WikiExtensionsHelperPatch)
