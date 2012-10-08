# Wiki Extensions plugin for Redmine
# Copyright (C) 2011-2012  Haruyuki Iida
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

module WikiExtensionsNewPageMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Create new page.\n\n"
    macro :new_page do |obj, args|
      @_controller.send(:render_to_string, {:partial => "wiki_extensions/new_page_macro"}).html_safe
    end
  end
end
