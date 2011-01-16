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

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Insert an iframe tag" + "\n\n" +
      "  !{{iframe(url, width, height)}}" + "\n\n"
    "  !{{iframe(url,  width, height, scroll)}}"
    macro :iframe do |obj, args|
      width = '100%'
      width = args[1].strip if args[1]
      height = '400pt'
      height = args[2].strip if args[2]

      scrolling = 'auto'
      scrolling = args[3].strip if args.length > 3
      url = /([a-zA-Z0-9]+:\/\/[-a-zA-Z0-9.?&=+@:_~\#%\/]+)/.match(args[0]).to_a[1]
      o = ''
      o << '<iframe src="' + url + '" style="border: 0" width="' + width +
        '" height="' + height + '" frameborder="0" scrolling="' + scrolling + '"></iframe>'

      return o
    end
  end
end

