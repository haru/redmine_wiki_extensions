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

class WikiExtensionsApproval < ApplicationRecord
  self.table_name = 'wiki_extensions_approval'

  belongs_to :wiki_page
  belongs_to :wiki_version
  belongs_to :author, class_name: 'User'

  has_many :approval_steps, class_name: '::WikiExtensionsApprovalSteps', dependent: :destroy

  validates :status, presence: true

  enum :status, {
    draft: 10,
    pending: 20,
    rejected: 40,
    published: 60,
    released: 70,
  }

  scope :by_author, ->(user_id) { where(author_id: user_id) }
  scope :for_wiki, ->(page_id, version_id) {
    where(wiki_page_id: page_id, wiki_version_id: version_id)
  }
  scope :latest_public_version, ->(page_id) {
    where(wiki_page_id: page_id, status: [statuses[:published], statuses[:released]])
      .order(id: :desc)
      .limit(1)
  }

  def steps_grouped_with_default
    grouped = approval_steps.group_by(&:step)

    # when step 1 is not there, default value
    grouped[1] ||= [approval_steps.build(step: 1, typ: :or)]

    grouped
  end

  def self.latest_public_from_version(page_id, from_version)
    where(
      wiki_page_id: page_id,
      status: [statuses[:published], statuses[:released]],
      wiki_version_id: ...from_version
    )
    .order(id: :desc)
    .limit(1)
    .pick(:wiki_version_id) || 1
  end
end
