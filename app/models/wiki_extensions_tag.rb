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
class WikiExtensionsTag < ActiveRecord::Base
  validates_presence_of :name, :project_id
  validates_uniqueness_of :name, :scope => :project_id

  def WikiExtensionsTag.find_or_create(project_id, name)
    obj = WikiExtensionsTag.find_or_create_by_name_and_project_id(name, project_id)
  end

  def ==(obj)
    return false unless self.project_id == obj.project_id
    return self.name == obj.name
  end

  def pages
    return @pages if @pages
    relations = WikiExtensionsTagRelation.find(:all, :conditions =>['tag_id = ?', id])
    @pages = []
    relations.each{|relation|
      @pages << relation.wiki_page
    }
    return @pages
  end

  def page_count
    pages.length
  end

  def <=> obj
    self.name <=> obj.name
  end
end
