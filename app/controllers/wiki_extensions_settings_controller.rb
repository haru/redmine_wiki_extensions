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
# frozen_string_literal: true

class WikiExtensionsSettingsController < ApplicationController
  layout 'base'

  before_action :find_project, :authorize, :find_user

  def update
    menus = params[:menus]

    setting = WikiExtensionsSetting.find_or_create @project.id
    begin
      setting.transaction do
        menus.each_pair do |menu_no, menu|
          menu_setting = WikiExtensionsMenu.find_or_create(@project.id, menu[:menu_no].to_i)
          menu_setting.enabled = false
          menu_setting.attributes = menu.permit(:enabled, :menu_no, :title, :page_name)
          menu_setting.save!
        end

        setting.update!(
          comment_required: params[:comment_required],
          draft_enabled: params[:draft_enabled],
          approval_enabled: params[:approval_enabled],
          approval_required: params[:approval_required],
          approval_version_required: params[:approval_version_required],
          tag_disabled: params[:tag_disabled]
        )
      end
      flash[:notice] = l(:notice_successful_update)
    rescue => e
      flash[:error] = "Updating failed." + e.message
      throw e
    end

    redirect_to :controller => 'projects', :action => "settings", :id => @project, :tab => 'wiki_extensions'
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  end

  def find_user
    @user = User.current
  end
end
