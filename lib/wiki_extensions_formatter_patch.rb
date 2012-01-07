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
      text.gsub!(Regexp.new("#{Regexp.escape(emoticon['emoticon'])}(\\s|<br/>|</p>)"),
        "<img src=\""+src+"#{emoticon['image']}\" alt=\"#{emoticon['emoticon']}\">\\1")
    }
  end
end

