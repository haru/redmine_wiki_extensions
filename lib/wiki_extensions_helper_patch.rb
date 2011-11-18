# Wiki Extensions plugin for Redmine
# Copyright (C) 2011  Haruyuki Iida
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require_dependency "redmine/wiki_formatting/textile/helper"

module WikiExtensionsHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, HelperMethodsWikiExtensions)
    
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      if WikiExtensionsHelperPatch::has_heads_for_wiki_formatter?
        alias_method_chain :heads_for_wiki_formatter, :wiki_smiles
      else
        alias_method_chain :wikitoolbar_for, :wiki_smiles
      end      
    end
  end
  def self.has_heads_for_wiki_formatter?
    major, minor = Redmine::VERSION.to_a
    if Redmine::Info.app_name == 'Redmine'
      if major > 1
        return true
      end
      if major == 1 and minor > 1
        return true
      end
    else
      if major > 1
        return true
      end
    end
    false
  end
end

module HelperMethodsWikiExtensions
  def heads_for_wiki_formatter_with_wiki_smiles
    heads_for_wiki_formatter_without_wiki_smiles
    return if ie6_or_ie7?
    unless @heads_for_wiki_smiles_included
      baseurl = Redmine::Utils.relative_url_root
      imageurl = baseurl + "/plugin_assets/redmine_wiki_extensions/images"
      content_for :header_tags do
        o = stylesheet_link_tag("wiki_smiles.css", :plugin => "redmine_wiki_extensions")
        o << javascript_include_tag("wiki_smiles.js", :plugin => "redmine_wiki_extensions")
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
        o
      end
      @heads_for_wiki_smiles_included = true
    end
  end
    
  def wikitoolbar_for_with_wiki_smiles(field_id)
    # Is there a simple way to link to a public resource?
    return wikitoolbar_for_without_wiki_smiles(field_id) if ie6_or_ie7?
    url = "#{Redmine::Utils.relative_url_root}/help/wiki_syntax.html"
          
    help_link = l(:setting_text_formatting) + ': ' +
      link_to(l(:label_help), url,
      :onclick => "window.open(\"#{ url }\", \"\", \"resizable=yes, location=no, width=900, height=640, menubar=no, status=no, scrollbars=yes\" ); return false;")
      
    baseurl = Redmine::Utils.relative_url_root
    imageurl = baseurl + "/plugin_assets/redmine_wiki_extensions/images"
    o = ""
    o << stylesheet_link_tag("wiki_smiles.css", :plugin => "redmine_wiki_extensions") +javascript_include_tag('jstoolbar/jstoolbar')
    o << javascript_include_tag('jstoolbar/textile')
    #here added a new js tag#
    o << javascript_include_tag("wiki_smiles.js", :plugin => "redmine_wiki_extensions")
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

  private
  def ie6_or_ie7?
    useragent = request.env['HTTP_USER_AGENT']
    return useragent.match(/IE[ ]+[67]./) != nil
  end
  
 
end

