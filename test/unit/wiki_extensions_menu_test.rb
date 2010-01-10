# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2010  Haruyuki Iida
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

class WikiExtensionsMenuTest < ActiveSupport::TestCase
  fixtures :wiki_extensions_menus, :wiki_extensions_settings

  # Replace this with your real tests.
  def test_find_or_create
    menu = WikiExtensionsMenu.find_or_create(9, 3)
    assert_equal(9, menu.project_id)
    assert_equal(3, menu.menu_no)
    menu = WikiExtensionsMenu.find_or_create(9, 3)
    assert_equal(9, menu.project_id)
  end

  def test_title
    menu = WikiExtensionsMenu.find_or_create(10, 5)
    assert(!WikiExtensionsMenu.title(10, 5))
    menu.page_name = "aaa"
    menu.save!
    assert_equal("aaa", WikiExtensionsMenu.title(10, 5))
    menu.title = "bbb"
    menu.save!
    assert_equal("bbb", WikiExtensionsMenu.title(10, 5))
    assert(!WikiExtensionsMenu.title(100, 5))
  end

  def test_enabled?
    menu = WikiExtensionsMenu.find_or_create(11, 5)
    assert(!WikiExtensionsMenu.enabled?(11, 5))
    menu.enabled = true
    menu.save!
    assert(!WikiExtensionsMenu.enabled?(11, 5))
    menu.page_name = "aaa"
    menu.save!
    assert(WikiExtensionsMenu.enabled?(11, 5))
    menu.enabled = false
    menu.save!
    assert(!WikiExtensionsMenu.enabled?(11, 5))
    assert(!WikiExtensionsMenu.enabled?(111, 5))
  end
end
