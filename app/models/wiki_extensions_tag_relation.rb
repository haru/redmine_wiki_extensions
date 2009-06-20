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
class WikiExtensionsTagRelation < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :tag, :class_name => 'WikiExtensionsTag', :foreign_key => :tag_id
  validates_presence_of :wiki_page_id, :tag_id
  validates_uniqueness_of :tag_id, :scope => :wiki_page_id

  def destroy
    target_tag_id = tag_id
    super
    target_tag = WikiExtensionsTag.find(tag_id) if tag_id
    target_tag.destroy if target_tag.page_count == 0
  end

end
