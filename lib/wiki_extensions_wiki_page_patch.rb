# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2025  Haruyuki Iida
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
require_dependency 'wiki_page'

class WikiPage
  has_many :wiki_extensions_tag_relations, :dependent => :destroy
  has_many :wiki_ext_tags, :class_name => 'WikiExtensionsTag', :through => :wiki_extensions_tag_relations, :source => :tag
  has_one :wiki_extensions_count, :foreign_key => :page_id, :dependent => :destroy
  has_one :wiki_extensions_approval_for_version, ->(page) {
    where(wiki_version_id: page.version)
  }, class_name: 'WikiExtensionsApproval', foreign_key: :wiki_page_id
end

module WikiExtensionsWikiPagePatch
  def wiki_extension_data
    @wiki_extension_data ||= {}
  end

  def set_tags(tag_list = {})
    tag_array = []
    tag_list.each_pair do |num, name|
      next if name.blank?

      tag_array << name.strip
    end

    tag_array = tag_array.uniq

    wiki_extensions_tag_relations.each do |relation|
      relation.destroy
    end

    tag_array.each do |name|
      tag = WikiExtensionsTag.find_or_create(self.project.id, name)
      relation = WikiExtensionsTagRelation.new
      relation.tag = tag
      relation.wiki_page_id = self.id
      relation.save
    end
  end

  def set_draft(status)
    approval = WikiExtensionsApproval.find_or_initialize_by(
      wiki_page_id: self.id,
      wiki_version_id: self.version
    )

    # if the record already exists and it is in approval
    return if approval.present? && approval.status == 'pending'

    # if new record and it is not a draft, no record
    # return if status_disabled == "false" && approval.new_record? && status == 'published'

    approval.status = status
    approval.author_id ||= User.current.id
    approval.save!
  end
end

WikiPage.prepend(WikiExtensionsWikiPagePatch)
