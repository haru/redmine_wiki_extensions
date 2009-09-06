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

require File.dirname(__FILE__) + '/../test_helper'

class WikiExtensionsProjectMenuTest < Test::Unit::TestCase
  fixtures :wiki_extensions_project_menus, :wiki_extensions_project_settings

  # Replace this with your real tests.
  def test_find_or_create
    menu = WikiExtensionsProjectMenu.find_or_create(9, 3)
    assert_equal(9, menu.project_id)
    assert_equal(3, menu.menu_no)
    menu = WikiExtensionsProjectMenu.find_or_create(9, 3)
    assert_equal(9, menu.project_id)
  end

  def test_title
    menu = WikiExtensionsProjectMenu.find_or_create(10, 5)
    assert(!WikiExtensionsProjectMenu.title(10, 5))
    menu.page_name = "aaa"
    menu.save!
    assert_equal("aaa", WikiExtensionsProjectMenu.title(10, 5))
    menu.title = "bbb"
    menu.save!
    assert_equal("bbb", WikiExtensionsProjectMenu.title(10, 5))
    assert(!WikiExtensionsProjectMenu.title(100, 5))
  end

  def test_enabled?
    menu = WikiExtensionsProjectMenu.find_or_create(11, 5)
    assert(!WikiExtensionsProjectMenu.enabled?(11, 5))
    menu.enabled = true
    menu.save!
    assert(!WikiExtensionsProjectMenu.enabled?(11, 5))
    menu.page_name = "aaa"
    menu.save!
    assert(WikiExtensionsProjectMenu.enabled?(11, 5))
    menu.enabled = false
    menu.save!
    assert(!WikiExtensionsProjectMenu.enabled?(11, 5))
    assert(!WikiExtensionsProjectMenu.enabled?(111, 5))
  end
end
