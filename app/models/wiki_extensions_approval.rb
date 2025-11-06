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

  # before_create :cancel_old_approvals

  enum :status, {
    draft: 10,
    pending: 20,
    rejected: 40,
    published: 60,
    released: 70,
    canceled: 99
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

  def cancel_old_approvals
    WikiExtensionsApproval.where(
      wiki_page_id: wiki_page_id
    )
    .where(wiki_version_id: ...wiki_version_id)
    .where(status: ...(WikiExtensionsApproval.statuses[:published]))
    .update_all(status: WikiExtensionsApproval.statuses[:canceled], updated_at: Time.current)
  end
end
