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

module WikiExtensionsCountMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Count access to the pages.\n\n"+
      "  @{{count}}@\n" 
    macro :count do |obj, args|
      return nil unless obj
      page = obj.page
      session[:access_count_table] = Hash.new unless session[:access_count_table]
      unless session[:access_count_table][page.id]
        WikiExtensionsCount.countup(page.id)
        session[:access_count_table][page.id] = 1
      end
      
      return ''
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Displays an access count of the page.\n\n"+
      "  @{{show_count}}@\n"
    macro :show_count do |obj, args|
      return nil unless obj
      page = obj.page
      count = WikiExtensionsCount.access_count(page.id)

      return "#{count}"
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Displays list of the popular pages.\n\n"+
      "  @{{popular}}@\n"
    macro :popular do |obj, args|
      
      count = WikiExtensionsCount.access_count(page.id)

      return "#{count}"
    end
  end
end
