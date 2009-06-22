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
      "  @{{tags}}@\n"
    macro :tags do |obj, args|
      page = obj.page
      return unless page

      o = "<h3>Tags</h3>"
      page.tags.each{|tag|
        o << tag.name
        o << ','
      }
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Displays tagcloud.\n\n"+
      "  @{{tagcloud}}@\n"
    macro :tagcloud do |obj, args|
      page = obj.page
      return unless page
      project = page.project
      o = "<h3>Tags</h3>"
      tags = WikiExtensionsTag.find(:all, :conditions => ['project_id = ?', project.id])
      tags.sort.each{|tag|
        o << link_to("#{tag.name}(#{tag.page_count})", :controller => 'wiki_extensions',
              :action => 'tag', :id => project, :tag_id => tag.id)
        o << ' '
      }
      return o
    end
  end
end
