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

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays tags.\n\n"+
      "  !{{tags}}\n"
    macro :tags do |obj, args|
      return nil unless WikiExtensionsUtil.is_enabled?(@project)
      page = obj.page
      return unless page
      project = page.project

      return '' if page.tags.empty?

      o = '<ul class="wikiext-tags">'
      page.tags.each{|tag|
        o << '<li>' + link_to("#{tag.name}", {:controller => 'wiki_extensions',
              :action => 'tag', :id => project, :tag_id => tag.id}) + '</li>'
      }
      o << '</ul>'
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Displays tagcloud.\n\n"+
      "  !{{tagcloud}}\n"
    macro :tagcloud do |obj, args|
      return nil unless WikiExtensionsUtil.is_enabled?(@project)
      classes = ['tag_level1', 'tag_level2', 'tag_level3', 'tag_level4', 'tag_level5']
      page = obj.page
      return unless page
      project = page.project
      o = '<h3>' + l(:label_wikiextensions_tags) + '</h3>'
      tags = WikiExtensionsTag.find(:all, :conditions => ['project_id = ?', project.id])
      return '' if tags.empty?
      max_count = tags.sort{|a, b| a.page_count <=> b.page_count}.last.page_count.to_f
      tags.sort.each{|tag|
        index = ((tag.page_count / max_count) * (classes.size - 1)).round
        o << link_to("#{tag.name}(#{tag.page_count})", {:controller => 'wiki_extensions',
              :action => 'tag', :id => project, :tag_id => tag.id}, :class => classes[index])
        o << ' '
      }
      return o
    end
  end
end
