# Wiki Extensions plugin for Redmine
# Copyright (C) 2009  Haruyuki Iida
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
require 'redmine'

module WikiExtensionsFootnote

  def WikiExtensionsFootnote.preview_page
    @@preview_page ||= WikiPage.new
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Create a footnote.\n\n" +
      " \{{fn(word, description}}"
    macro :fn do |obj, args|
      return nil if args.length < 2
      return nil unless WikiExtensionsUtil.is_enabled?(@project)
      word = args[0]
      description = args[1]
      page = obj.page if obj
      page = WikiExtensionsFootnote.preview_page unless page
      data = page.wiki_extension_data
      data[:footnotes] ||= []
      data[:footnotes] << {'word' => word, 'description' => description}
      

      o = ""
      o << word
      o << '<a href="#wiki_extensins_fn_' +"#{data[:footnotes].length}" + '" class="wiki_extensions_fn" title="' + description + '" name="wiki_extensins_fn_src_' +"#{data[:footnotes].length}" + '">'
      o << "*#{data[:footnotes].length}"
      o << '</a>'
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Displays footnotes of the page."
    macro :fnlist do |obj, args|
      return nil unless WikiExtensionsUtil.is_enabled?(@project)
      page = obj.page if obj
      page = WikiExtensionsFootnote.preview_page unless page
      data = page.wiki_extension_data
      return '' if data[:footnotes].blank? or data[:footnotes].empty?
      o = '<div class="wiki_extensions_fnlist">'
      o << "<hr/>\n"
      o << '<ul>'
      cnt = 0
      data[:footnotes].each {|fn|
        cnt += 1
        o << '<li><span class="wiki_extensions_fn">'+ "*#{cnt}</span> " +'<a name="wiki_extensins_fn_' + "#{cnt}" + '" href="#wiki_extensins_fn_src_' + "#{cnt}" + '"' + ">#{fn['word']}</a>:#{fn['description']}</li>"
      }
      o << '</ul>'
      o << '</div>'
      WikiExtensionsFootnote.preview_page.wiki_extension_data[:footnotes] = []
      return o
    end
  end
end
