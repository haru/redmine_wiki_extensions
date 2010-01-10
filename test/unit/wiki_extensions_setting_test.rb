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

class WikiExtensionsSettingTest < ActiveSupport::TestCase
  fixtures :wiki_extensions_settings, :wiki_extensions_menus

  def test_find_or_create
    assert(!WikiExtensionsSetting.find(:first, :conditions => 'project_id = 5'))
    setting = WikiExtensionsSetting.find_or_create(5)
    assert_equal(5, setting.project_id)
    assert(WikiExtensionsSetting.find(:first, :conditions => 'project_id = 5'))
    setting = WikiExtensionsSetting.find_or_create(5)
    assert_equal(5, setting.project_id)
  end

  def test_menus
    setting = WikiExtensionsSetting.find_or_create(6)
    assert_equal(5, setting.menus.length)
  end
end
