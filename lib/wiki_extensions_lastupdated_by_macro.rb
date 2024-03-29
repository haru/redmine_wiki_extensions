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

module WikiExtensionsLastupdatedByMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a user who updated the page.\n\n" +
      " !{{lastupdated_by}}" 
    macro :lastupdated_by do |obj, args|
      o = '<span class="wiki_extensions_lastupdated_by">'
      o << "#{avatar(obj.author, :size => "14")}"
      o << link_to_user(obj.author)
      o << '</span>'
      o.html_safe
    end
  end
end
