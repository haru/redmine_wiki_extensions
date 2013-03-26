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

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a <pre><div id=" + '"id_name"' + " class=" + '"' + 'class_name' + '"></pre>' + "\n\n" +
      " !{{div_start_tag(id_name)}}" + "'\n" +
      " !{{div_start_tag(id_name, class_name)}}"
    macro :div_start_tag do |obj, args|
      o = '<div>' if args.length == 0
      o = '<div id="' + args[0].strip + '">' if args.length == 1
      o = '<div id="' + args[0].strip + '" class="' + args[1].strip + '">' if args.length == 2
      o.html_safe
    end
  end
end

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a <pre></div></pre>\n\n" +
      "  !{{div_end_tag}}"
    macro :div_end_tag do |obj, args|
      return '</div>'.html_safe
    end
  end
end

