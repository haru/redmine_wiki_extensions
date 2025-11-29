# Wiki Extensions plugin for Redmine
# Copyright (C) 2011-2024  Haruyuki Iida
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

class WikiExtensionsSetting < ApplicationRecord
  belongs_to :project
  before_save :sync_data_hash_to_json

  def self.find_or_create(pj_id)
    setting = WikiExtensionsSetting.find_by(project_id: pj_id)
    unless setting
      setting = WikiExtensionsSetting.new
      setting.project_id = pj_id
      setting.save!
    end
    5.times do |i|
      WikiExtensionsMenu.find_or_create(pj_id, i + 1)
    end
    return setting
  end

  def auto_preview_enabled
    false
  end

  def menus
    WikiExtensionsMenu.where(:project_id => project_id).order("menu_no")
  end

  def data_hash
    @data_hash ||= begin
      parsed = JSON.parse(json_data.presence || '{}', symbolize_names: true)
      parsed.is_a?(Hash) ? parsed.deep_dup : {}
    rescue JSON::ParserError
      {}
    end
  end

  def data_hash=(hash)
    self.json_data = hash.to_json
    @data_hash = hash
  end

  # Getter with default value, or setting from projecct
  def comment_required
    if Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_comment'] == SettingsHelper::PROJECT
      ActiveModel::Type::Boolean.new.cast(data_hash[:comment_required])
    else
      ActiveModel::Type::Boolean.new.cast(Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_comment'])
    end
  end

  def comment_required=(value)
    data_hash[:comment_required] = ActiveModel::Type::Boolean.new.cast(value)
  end

  def draft_enabled
    if Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_draft_enabled'] == SettingsHelper::PROJECT
      ActiveModel::Type::Boolean.new.cast(data_hash[:draft_enabled])
    else
      ActiveModel::Type::Boolean.new.cast(Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_draft_enabled'])
    end
  end

  def draft_enabled=(value)
    data_hash[:draft_enabled] = ActiveModel::Type::Boolean.new.cast(value)
  end

  def approval_enabled
    if Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval_enabled'] == SettingsHelper::PROJECT
      ActiveModel::Type::Boolean.new.cast(data_hash[:approval_enabled])
    else
      ActiveModel::Type::Boolean.new.cast(Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval_enabled'])
    end
  end

  def approval_enabled=(value)
    data_hash[:approval_enabled] = ActiveModel::Type::Boolean.new.cast(value)
  end

  def approval_required
    if Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval'] == SettingsHelper::PROJECT
      ActiveModel::Type::Boolean.new.cast(data_hash[:approval_required])
    else
      ActiveModel::Type::Boolean.new.cast(Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval'])
    end
  end

  def approval_required=(value)
    data_hash[:approval_required] = ActiveModel::Type::Boolean.new.cast(value)
  end

  def approval_version_required
    if Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval_version'] == SettingsHelper::PROJECT
      ActiveModel::Type::Boolean.new.cast(data_hash[:approval_version_required])
    else
      ActiveModel::Type::Boolean.new.cast(Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval_version'])
    end
  end

  def approval_version_required=(value)
    data_hash[:approval_version_required] = ActiveModel::Type::Boolean.new.cast(value)
  end

  def tag_disabled
    if Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_tags'] == SettingsHelper::PROJECT
      :tag_disabled
    else
      ActiveModel::Type::Boolean.new.cast(Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_tags'])
    end
  end

  private

  def sync_data_hash_to_json
    self.json_data = @data_hash.to_json if @data_hash
  end

  def wiki_extensions_setting_params
    params.require(:wiki_extensions_setting).permit(:tag_disabled, :comment_required, :draft_enabled, :approval_enabled, :approval_required, :approval_version_required)
  end
end
