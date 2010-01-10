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

class WikiExtensionsCountTest < ActiveSupport::TestCase
  fixtures :wiki_extensions_counts, :projects, :wikis, :wiki_pages

  def test_countup
    page_id = 2
    assert_equal(0, WikiExtensionsCount.access_count(page_id))
    WikiExtensionsCount.countup(page_id)
    assert_equal(1, WikiExtensionsCount.access_count(page_id))
    WikiExtensionsCount.countup(page_id)
    assert_equal(2, WikiExtensionsCount.access_count(page_id))
    WikiExtensionsCount.countup(page_id, Date.today - 2)
    WikiExtensionsCount.countup(page_id, Date.today - 2)
    WikiExtensionsCount.countup(page_id, Date.today - 2)
    
    assert_equal(5, WikiExtensionsCount.access_count(page_id))
    assert_equal(2, WikiExtensionsCount.access_count(page_id, Date.today))
  end

  def test_popular
    WikiExtensionsCount.countup(2)
    WikiExtensionsCount.countup(2, Date.today - 1)
    WikiExtensionsCount.countup(2, Date.today - 2)
    WikiExtensionsCount.countup(2, Date.today - 3)
    list = WikiExtensionsCount.popularity(1)
    assert_equal(2, list.length)
    assert_equal(4, list.to_a[0][1])
    assert_equal(2, list.to_a[1][1])
    list = WikiExtensionsCount.popularity(1, 2)
    assert_equal(1, list.length)
    assert_equal(2, list.to_a[0][1])
    
  end
end
