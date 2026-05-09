# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2024  Haruyuki Iida
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
class WikiExtensionsTag < ApplicationRecord
  # attr_accessible :name, :project_id
  validates :name, :project_id, presence: true
  validates :name, uniqueness: { scope: :project_id }

  # Finds or creates a tag by name within a project.
  # @param project_id [Integer]
  # @param name [String]
  # @return [WikiExtensionsTag]
  def WikiExtensionsTag.find_or_create(project_id, name)
    WikiExtensionsTag.find_or_create_by(name: name, project_id: project_id)
  end

  # Returns true if both tags share the same project and name.
  def ==(obj)
    return false unless self.project_id == obj.project_id
    self.name == obj.name
  end

  # Returns all wiki pages that have this tag.
  # @return [Array<WikiPage>]
  def pages
    return @pages if @pages
    relations = WikiExtensionsTagRelation.where(tag_id: id).all
    @pages = []
    relations.each { |relation|
      @pages << relation.wiki_page
    }
    @pages
  end

  # Returns the number of wiki pages using this tag.
  # @return [Integer]
  def page_count
    pages.length
  end

  # Compares tags by name for sorting.
  def <=>(obj)
    self.name <=> obj.name
  end
end
