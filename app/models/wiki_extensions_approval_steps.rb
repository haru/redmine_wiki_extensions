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

class WikiExtensionsApprovalSteps < ApplicationRecord
  self.table_name = 'wiki_extensions_approval_steps'

  belongs_to :wiki_extensions_approval
  belongs_to :user

  validates :step, :typ, :status, presence: true
  validates :note, length: { maximum: 1000 }

  enum :typ, {
    or: 0,
    and: 1
  }, prefix: true

  enum :status, {
    unstarted: 10,  # planed for
    pending: 20,    # in approval mode
    deligate: 30,   # delegate to another
    rejected: 40,   # no approved
    completed: 50,  # approved by another, with OR operator
    approved: 70,   # released
  }

  scope :by_user, ->(user_id) { where(user_id: user_id) }

  def soperator
    WikiExtensionsApprovalStep.soperator(operator)
  end

  def self.soperator(operator)
    operator == 1 ? l(:wiki_extensions_and) : l(:wiki_extensions_or)
  end
end
