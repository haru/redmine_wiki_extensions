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
#

class WikiExtensionsApprovalController < ApplicationController
  include WikiExtensionsWikiControllerPatch

  menu_item :wiki
  before_action :find_project, :find_user
  before_action :check_module_enabled, :authorize
  before_action :find_page
  before_action :set_wiki_extensions_data, only: [:start_approval]

  def start_approval
    # just if no approval is in the db
    @wiki_extension_data[:approval] ||= WikiExtensionsApproval.find_or_initialize_by(
      wiki_page_id: @page.id,
      wiki_version_id: @page.content.version,
      status: :pending,
      author_id: User.current.id
    )

    # get
    if request.get?
      @steps_grouped = @wiki_extension_data[:approval].steps_grouped_with_default if @wiki_extension_data[:approval]
      @approval_user_options = approval_user_options(@project)
      return
    end

    # update
    approval = @wiki_extension_data[:approval]

    # status check
    if approval.released?
      flash[:error] = l(:wiki_extensions_approval_unable_start_status, :status => l("wiki_extensions_approval.status.#{approval.status}"))
      redirect_to project_wiki_page_path(@project.identifier, @page.title, :version => @page.content.version)
      return
    end

    # 2. no empty users
    steps_params = params[:steps].transform_values { |users| users.reject { |u| u["principal_id"].blank? } }

    # 3. Globale doublicat users
    if duplicate_users?(steps_params)
      flash.now[:error] = l(:wiki_extensions_approval_unable_start_user)
      restore_form_data
      render :start_approval
      return
    end

    # if approval is not saved
    @wiki_extension_data[:approval].save! if @wiki_extension_data[:approval].new_record?

    # save Steps
    steps_params.each do |step_nr, users|
      # Collect all user_ids for this step group
      user_ids = users.map { |u| u[:principal_id].to_i }
      # Delete all steps for this step_nr that are not in the submitted user_ids
      approval.approval_steps.where(step: step_nr).where.not(principal: user_ids).destroy_all
      # create new users for this step
      users.each do |user_data|
        principal_object = User.find_by(id: user_data[:principal_id]) || Group.find_by(id: user_data[:principal_id])
        step_record = approval.approval_steps.find_or_initialize_by(
          step: step_nr,
          principal: principal_object
        )
        # Only set status to :unstarted if current status is less than completed (50)
        step_record.status = :unstarted if step_record.status.nil? || (!step_record.completed? && !step_record.approved?)
        step_record.typ = params[:steps_typ][step_nr] || 'or'
        step_record.save!
        # end
      end
    end

    redirect_to project_wiki_page_path(@project.identifier, @page.title, :version => @page.content.version)
  end

  def grant_approval
  end

  def forward_approval
  end

  def view_draft
  end

  def set_draft
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id]) unless params[:id].blank?
  end

  def find_user
    @user = User.current
  end

  def find_page
    unless params[:title] && params[:version]
      render_404
      return
    end

    if params[:version] && params[:title]
      @page = WikiPage.joins(:wiki, :content)
                      .find_by(wikis: { project_id: @project.id }, title: params[:title], wiki_contents: { version: params[:version] })
    end

    if @page.nil?
      render_404
      return
    end
  end

  def check_module_enabled
    render_403 unless WikiExtensionsUtil.is_enabled? @project
  end

  def approval_user_options(project)
    # (Users + groups)
    users = @project.memberships.map(&:user).compact.select do |u|
      !u.admin? && u.id != User.current.id && u.roles_for_project(@project).any? { |r| r.permissions.include?(:approval_grant) }
    end

    groups = @project.memberships.map(&:principal).select do |g|
      g.is_a?(Group) && g.memberships.where(project_id: @project.id).any? do |m|
        m.roles.any? { |r| r.permissions.include?(:approval_grant) }
      end
    end

    users + groups
  end

  def duplicate_users?(steps_params)
    seen_users = Set.new
    steps_params.each_value do |users|
      users.each do |u|
        user_id = u["principal_id"].to_i
        return true if seen_users.include?(user_id)

        seen_users.add(user_id)
      end
    end
    false
  end

  def restore_form_data
    @steps_grouped = build_steps_from_params
    @approval_user_options = approval_user_options(@project)
  end

  def build_steps_from_params
    grouped = {}
    params[:steps].each do |step_nr, users|
      grouped[step_nr.to_i] = users.map do |u|
        principal_id = u["principal_id"]
        principal_object = User.find_by(id: principal_id) || Group.find_by(id: principal_id)

        WikiExtensionsApprovalSteps.new(
          step: step_nr,
          principal: principal_object,
          typ: params[:steps_typ][step_nr]
        )
      end
    end
    grouped
  end
end
