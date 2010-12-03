# Wiki Extensions plugin for Redmine
# Copyright (C) 2010  Haruyuki Iida
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
    desc "Displays pages that have specified tag.\n\n"+
      "  @{{taggedpages(tagname)}}@\n" +
      "  @{{taggedpages(tagname, project)}}@\n"
    macro :taggedpages do |obj, args|
      return nil unless WikiExtensionsUtil.is_enabled?(@project)

      return nil if args.length < 1
      tag_name = args[0].strip
      project = Project.find_by_name(args[1].strip) if args.length > 1
      project = @project unless project

      tag = WikiExtensionsTag.find(:first, :conditions => ["project_id = ? and name = ?", project.id, tag_name])
      return nil unless tag

      o = '<ul class="wikiext-taggedpages">'
      tag.pages.sort{|a, b| a.pretty_title <=> b.pretty_title}.each{|page|
        o << '<li>' + link_to("#{page.pretty_title}", {:controller => 'wiki',
              :action => 'index', :id => project, :page_title => page.title}) + '</li>'
      }
      o << '</ul>'
      return o
    end
  end
end
