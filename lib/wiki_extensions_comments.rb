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
      div_id = "add_comment_area_#{num}"

      url = url_for(:controller => 'wiki_extensions', :action => 'add_comment', :id => @project)
      o = ""
      o << '<form method="post" action="' + url + '">'
      o << "\n"
      if protect_against_forgery?
        o << hidden_field_tag(:authenticity_token, form_authenticity_token)
        o << "\n"
      end
      o << hidden_field_tag(:wiki_page_id, page.id)
      o << "\n"
      o << text_area_tag(:comment, '', :rows => 5, :cols => 70, :id => div_id,:accesskey => accesskey(:edit),
                   :class => 'wiki-edit')
      o << '<br/>'
      o << submit_tag(l(:label_comment_add))
      o << "\n"
      o << wikitoolbar_for(div_id)
      o << '</form>'
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
#      comments.each{|comment|
#        div_comment_id = "wikiextensions_comment_#{comment.id}"
#        form_div_id = "wikiextensions_comment_form_#{comment.id}"
#        o << "<div>"
#        o << '<div class="contextual">'
#        if User.current.admin or User.current.id == comment.user.id
#        edit_link =  link_to_function(l(:button_edit), "$('#{div_comment_id}').hide();$('#{form_div_id}').show();", :class => 'icon icon-edit')
#        o << edit_link if User.current.allowed_to?({:controller => 'wiki_extensions', :action => 'update_comment'}, @project)
#
#        del_link =  link_to_if_authorized(l(:button_delete), {:controller => 'wiki_extensions',
#            :action => 'destroy_comment', :id => @project, :comment_id => comment.id},
#          :class => "icon icon-del", :confirm => l(:text_are_you_sure))
#        o << del_link if del_link
#        end
#        o << "\n"
#        o << "</div>\n"
#        o << "<h3>"
        
#        if l(:this_is_gloc_lib) == 'this_is_gloc_lib'
#          o << l(:label_added_time_by, comment.user, distance_of_time_in_words(Time.now, comment.updated_at))
#        else
#          o << l(:label_added_time_by, :author => comment.user, :age => distance_of_time_in_words(Time.now, comment.updated_at))
#        end
#        o << "</h3>\n"
#        
#        o << '<div id="' + div_comment_id + '">' + "\n"
#        o << textilizable(comment, :comment)
#        o << "</div>\n"
#        
#        o << '<div id="' + form_div_id + '" style="display:none;">' + "\n"

#        url = url_for(:controller => 'wiki_extensions', :action => 'update_comment', :id => @project)
        
#        o << '<form method="post" action="' + url + '">'
#        if protect_against_forgery?
#          o << hidden_field_tag(:authenticity_token, form_authenticity_token)
#          o << "\n"
#        end
#        o << "\n"
#        o << hidden_field_tag(:comment_id, comment.id)
#        o << "\n"
#        textarea_id = "wiki_extensions_comment_edit_area_#{comment.id}"
#        o << text_area_tag(:comment, comment.comment, :rows => 5, :cols => 70, :id => textarea_id,:accesskey => accesskey(:edit),
#          :class => 'wiki-edit')
#        o << '<br/>'
#        o << submit_tag(l(:button_apply))
#        o << link_to_function(l(:button_cancel), "$('#{div_comment_id}').show();$('#{form_div_id}').hide();")
#        o << "\n"
#        o << wikitoolbar_for(textarea_id)
#        o << '</form>'

#        o << '</div>'
#        o << "</div>"
#      }
      return o
    end
  end
end
