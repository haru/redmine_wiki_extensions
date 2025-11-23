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
  belongs_to :principal, :polymorphic => true

  validates :step, :step_type, :status, presence: true
  validates :note, length: { maximum: 1000 }
  validates :note, presence: true, if: :rejected?

  after_save :check_next_step

  enum :step_type, {
    or: 0,
    and: 1
  }, prefix: true

  enum :status, {
    canceled: 5,    # one is rejected, all other canceled
    unstarted: 15,  # planed for
    pending: 20,    # in approval mode
    rejected: 40,   # no approved
    approved: 70,   # released
  }

  scope :for_principal, ->(principal) {
    where(principal_id: principal.id, principal_type: principal.class.name)
  }

  def principal=(obj)
    super
    self.principal_type = obj.class.name if obj
  end

  # Find the first step number for a given approval where:
  # - The principal is the given user OR one of their groups
  # - The status is pending
  # - Returns the smallest step number (or nil if none found)
  def self.first_pending_step_for(approval, user, project, id = nil)
    return nil unless approval.present?

    # Build base query for approval steps
    query = approval.approval_steps.where(status: statuses[:pending])
    query = query.where(id: id) if id.present? # Filter by step if provided

    # 1. Check for steps assigned directly to the user
    step_found = query.where(principal_id: user.id, principal_type: 'User')
                         .order(:id)
                         .first
    return step_found if step_found.present?

    # 2. If no user step found, check for steps assigned to any of the user's groups
    group_ids = user.groups.pluck(:id)
    return nil if group_ids.empty?

    query.where(principal_id: group_ids, principal_type: 'Group')
         .order(:step)
         .first
  end

  def self.check_all_steps_approved(approval)
    # when all steps ar approved or complete = done
    if approval.approval_steps.all? { |s| s.approved? }
      approval.update!(status: :released)
    end
  end

  private

  def check_next_step
    case status.to_sym
    when :unstarted
      # current stepNr 1 - to pending
      update!(status: :pending) if step == find_current_step_for_pending
      current_step_delete_or
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

      current_step_delete_or

      # start next step if all approved
      current_step = approval.approval_steps.where(step: step)
      if current_step.all? { |s| s.approved? }
        approval.approval_steps.where(step: step + 1).update_all(status: :pending, updated_at: Time.current)
      end

      approval.approval_steps.check_all_steps_approved(approval)

    end
  end

  def find_current_step_for_pending
    WikiExtensionsApprovalSteps
       .where(wiki_extensions_approval_id: wiki_extensions_approval_id)
       .where('status <= ?', WikiExtensionsApprovalSteps.statuses[:pending])
       .where('step <= ?', step)
       .order(step: :asc)
       .limit(1)
       .pluck(:step)
       .first
  end

  def current_step_delete_or
    # OR-Logic: delete all <= pending from same stepNr
    if step_type_or? && (approved? || approval.approval_steps.where(step: step, status: :approved).exists?)
      approval.approval_steps.where(step: step)
                             .where('status <= ?', WikiExtensionsApprovalSteps.statuses[:pending])
                             .delete_all
    end
  end
end
