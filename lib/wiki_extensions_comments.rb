# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2013  Haruyuki Iida
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
      page = obj.page if obj

      num = rand(10000)
      area_id = "add_comment_area_#{num}"
      div_id = "add_comment_form_div#{num}"

      o = @_controller.send(:render_to_string, {:partial => "wiki_extensions/comment_form", :locals =>{:page => page, :area_id => area_id, :div_id => div_id}})
      o << raw(wikitoolbar_for(area_id))
      raw o.html_safe
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Display comments of the page."
    macro :comments do |obj, args|
      return '' unless obj
      unless User.current.allowed_to?({:controller => 'wiki_extensions', :action => 'show_comments'}, @project)
        return ''
      end
      page = obj.page
      return unless page

      data = page.wiki_extension_data
      comments = WikiExtensionsComment.where(:wiki_page_id => page.id).all

      raw display_comments_tree(comments,nil,page,data)

    end
  end
end
