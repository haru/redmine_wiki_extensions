# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2012  Haruyuki Iida
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

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a date that updated the page.\n\n" +
      " !{{lastupdated_at}}\n"
      " !{{lastupdated_at(project_name, wiki_page)}}\n"
      " !{{lastupdated_at(project_identifier, wiki_page)}}\n" 
    macro :lastupdated_at do |obj, args|
      return nil unless WikiExtensionsUtil.is_enabled?(@project) if @project
      if args.length == 0
        page = obj
      else
        return nil if args.length < 2
        project_name = args[0].strip
        page_name = args[1].strip
        project = Project.find_by_name(project_name)
        project = Project.find_by_identifier(project_name) unless project
        return nil unless project
        wiki = Wiki.find_by_project_id(project.id)
        return nil unless wiki
        page = wiki.find_page(page_name)
      end
      
      return nil unless page
      
      o = '<span class="wiki_extensions_lastupdated_at">'
      o << l(:label_updated_time, time_tag(page.updated_on))
      o << '</span>'
      o.html_safe
    end
  end
end
