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

class WikiExtensionsTagTest < ActiveSupport::TestCase
  fixtures :wiki_extensions_tags

  # Replace this with your real tests.
  def test_equal
    tag1 = WikiExtensionsTag.find(1)
    tag2 = WikiExtensionsTag.find(2)
    tag3 = WikiExtensionsTag.find(3)
    assert(!(tag1 == tag2))
    assert(!(tag2 == tag3))
    assert(tag1 == WikiExtensionsTag.find(1))
  end
end
