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

module WikiExtensionsRecentMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a list of pages that were changed recently. " + "'\n\n" +
      " !{{recent}}" + "'\n" +
      " !{{recent(number_of_days)}}"
    macro :recent do |obj, args|
      page = obj.page
      return nil unless page
      project = page.project
      return nil unless project
      days = 5
      days = args[0].strip.to_i if args.length > 0

      return nil if days < 1      
      contents = WikiContent.find(:all,
        :joins => "left join #{WikiPage.table_name} on #{WikiPage.table_name}.id = #{WikiContent.table_name}.page_id ",
        :conditions => ["wiki_id = ? and #{WikiContent.table_name}.updated_on > ?", page.wiki_id, Date.today - days],
        :order => "#{WikiContent.table_name}.updated_on desc")
      o = '<div class="wiki_extensions_recent">'
      date = nil
      contents.each {|content|
        updated_on = Date.new(content.updated_on.year, content.updated_on.month, content.updated_on.day)
        if date != updated_on
          date = updated_on
          o << "<b>" + format_date(date) + "</b><br/>"
        end
        o << link_to(content.page.pretty_title, :controller => 'wiki', :action => 'show', :project_id => content.page.project, :id => content.page.title)
        o << '<br/>'
      }
      o << '</div>'
      return o
    end
  end
end

