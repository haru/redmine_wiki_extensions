# Wiki Extensions plugin for Redmine
# Copyright (C) 2013-2025  Haruyuki Iida
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
#
#
# frozen_string_literal: true

module WikiShowOverride
  Deface::Override.new(
    virtual_path: 'wiki/show',
    name: 'overlay-wiki-show-contextual',
    insert_before: "erb[loud]:contains('actions_dropdown')",
    partial: 'wiki_extensions/view_wiki_show_contextual',
    original: '4f0fda1abd7add605aab5f2688759dc4cca312f4'
  )

  Deface::Override.new(
    virtual_path: 'wiki/show',
    name: 'overlay-wiki-show-actions-dropdown',
    insert_before: "erb[loud]:contains(\"icon-history\")",
    partial: 'wiki_extensions/view_wiki_show_actions_dropdown',
    original: 'fc27fab81025c90f072d63af36b0cc1ee32833ee'
  )
end
