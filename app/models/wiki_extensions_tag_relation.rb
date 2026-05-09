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
class WikiExtensionsTagRelation < ApplicationRecord
  belongs_to :wiki_page
  belongs_to :tag, class_name: "WikiExtensionsTag"
  validates :wiki_page_id, :tag_id, presence: true
  validates :tag_id, uniqueness: { scope: :wiki_page_id }

  after_destroy :cleanup_orphaned_tag

  private

  def cleanup_orphaned_tag
    return unless tag_id
    target_tag = WikiExtensionsTag.find_by(id: tag_id)
    target_tag.destroy if target_tag&.page_count&.zero?
  end
end
