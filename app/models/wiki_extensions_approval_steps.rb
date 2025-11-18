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

  belongs_to :approval, class_name: 'WikiExtensionsApproval', foreign_key: :wiki_extensions_approval_id
  belongs_to :principal, polymorphic: true

  validates :step, :typ, :status, presence: true
  validates :note, length: { maximum: 1000 }

  after_save :check_next_step

  enum :typ, {
    or: 0,
    and: 1
  }, prefix: true

  enum :status, {
    canceled: 5,    # one is rejected, all other canceled
    unstarted: 15,  # planed for
    pending: 20,    # in approval mode
    deligate: 30,   # delegate to another
    rejected: 40,   # no approved
    completed: 50,  # approved by another, with OR operator
    approved: 70,   # released
  }

  private

  def check_next_step
    case status.to_sym
    when :unstarted
      # current stepNr 1 - to pending
      update!(status: :pending) if step == 1
      approval.update!(status: :pending) unless approval.pending?
    when :pending
      approval.update!(status: :pending) unless approval.pending?
    when :rejected
      # all current to canceled
      approval.approval_steps.where(status: :pending).find_each do |step|
        step.update!(status: :canceled)
      end
      approval.update!(status: :rejected) unless approval.rejected?
    when :approved

      # OR-Logic: all pending from same stepNr to complete
      approval.approval_steps.where(step: step, status: :pending).update_all(status: :completed) if typ_or?

      # start next step if all approved
      current_step = approval.approval_steps.where(step: step)
      if current_step.all? { |s| s.completed? || s.approved? }
        approval.approval_steps.where(step: step + 1).update_all(status: :pending)
      end

      # when all steps ar approved or complete = done
      if approval.approval_steps.all? { |s| s.completed? || s.approved? }
        approval.update!(status: :released)
      end

    end
  end
end
