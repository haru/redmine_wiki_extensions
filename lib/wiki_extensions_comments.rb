# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2010  Haruyuki Iida
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

module WikiExtensionsComments
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a comment form."
    macro :comment_form do |obj, args|
      return unless @project
      return nil unless WikiExtensionsUtil.is_enabled?(@project)
      unless User.current.allowed_to?({:controller => 'wiki_extensions', :action => 'add_comment'}, @project)
        return ''
      end
    
      page = obj.page
      return unless page
      data = page.wiki_extension_data
      num = rand(10000)
      area_id = "add_comment_area_#{num}"
      div_id = "add_comment_form_div#{num}"

      url = url_for(:controller => 'wiki_extensions', :action => 'add_comment', :id => @project)
      o = ""
      o << '<div class="icon icon-comment">'
      o << link_to_function(l(:label_comment_add), "$('#{div_id}').show();")
      o << '</div>'
      o << '<div id="' + div_id + '" style="display:none">'
      o << '<form method="post" action="' + url + '">'
      o << "\n"
      if protect_against_forgery?
        o << hidden_field_tag(:authenticity_token, form_authenticity_token)
        o << "\n"
      end
      o << hidden_field_tag(:wiki_page_id, page.id)
      o << "\n"
      o << text_area_tag(:comment, '', :rows => 5, :cols => 70, :id => area_id,:accesskey => accesskey(:edit),
                   :class => 'wiki-edit')
      o << '<br/>'
      o << submit_tag(l(:label_comment_add))
      o << link_to_function(l(:button_cancel), "$('#{div_id}').hide();")
      o << "\n"
      o << wikitoolbar_for(area_id)
      o << '</form>'
      o << '</div>'
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Display comments of the page."
    macro :comments do |obj, args|
      unless User.current.allowed_to?({:controller => 'wiki_extensions', :action => 'show_comments'}, @project)
        return ''
      end
      page = obj.page
      return unless page
      data = page.wiki_extension_data
      comments = WikiExtensionsComment.find(:all, :conditions => ['wiki_page_id = (?)', page.id])
      o = "<h2>#{l(:field_comments)}</h2>\n"
      o << display_comments_tree(comments,nil,page,data)
      return o
    end
  end
end
