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
    desc "Displays a string 'new'.\n\n" +
      "  !{{new(yyyy-mm-dd)}}\n" +
      "  !{{new(yyyy-mm-dd, expire)}}\n\n" +
      "Default of expire is 5."
    macro :new do |obj, args|
      return nil if args.length < 1
      return nil unless WikiExtensionsUtil.is_enabled?(@project)
      date_string = args[0].strip
      expire = args[1].strip.to_i if args[1]
      expire = 5 unless expire
      date = Date.parse(date_string)
      today = Date.today
      
      o = '<span class="wiki_ext_new_date">'
      o << '[' + format_date(date) + ']'
      if (today - date < expire)
        o << '<span class="wiki_ext_new_mark">' + l(:label_wikiextensions_new)
        case today - date
        when -100 .. 0
          o << '!!!'
        when 1
          o << '!!'
        when 2
          o << '!'
        end
        o << '</span>'
      end
      o << '</span>'
      return o
    end
  end
end
