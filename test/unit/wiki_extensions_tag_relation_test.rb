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

class WikiExtensionsTagRelationTest < ActiveSupport::TestCase
  fixtures :wiki_extensions_tag_relations

  # Replace this with your real tests.
  def test_create
    relation = WikiExtensionsTagRelation.new
    assert !relation.save
    

    tag = WikiExtensionsTag.find_or_create(1, 'bbb')
    relation.tag = tag
    relation.wiki_page_id = 1
    assert relation.save

    relation.destroy
  end

  def test_destroy
    tag_name = 'adfafdfadfafdaf'
    tag = WikiExtensionsTag.find_or_create(1, tag_name)
    relation = WikiExtensionsTagRelation.new
    relation.tag = tag
    relation.wiki_page_id = 1
    assert relation.save
    relation_id = relation.id
    tag_id = tag.id
    assert_not_nil(WikiExtensionsTag.find(:first, :conditions => ['name = ?', tag_name]))
    assert_not_nil(WikiExtensionsTagRelation.find(:first, :conditions => ['id = ?', relation_id]))
    relation.destroy
    assert_nil(WikiExtensionsTagRelation.find(:first, :conditions => ['id = ?', relation_id]))
    assert_nil(WikiExtensionsTag.find(:first, :conditions => ['name = ?', tag_name]))
  end
end
