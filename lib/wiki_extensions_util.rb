# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2014  Haruyuki Iida
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

class WikiExtensionsUtil
  def self.is_enabled?(project)
    return false unless project

    project.module_enabled? 'wiki_extensions'
  end

  def self.tag_enabled?(project, setting = nil)
    return false unless project

    setting ||= WikiExtensionsSetting.find_or_create(project.id)
    !setting.tag_disabled
  end

  def self.draft_create?(project, setting = nil)
    return false unless project

    setting ||= WikiExtensionsSetting.find_or_create(project.id)
    return true if setting.approval_required

    user = User.current.logged? ? User.current : User.anonymous
    user.allowed_to?(:draft_create, project)
  end

  def self.is_allowed_to_show_last_version?(project)
    return false unless is_enabled?(project)

    user = User.current.logged? ? User.current : User.anonymous
    user.allowed_to?(:view_wiki_edits, project)
  end

  def self.wiki_extensions_approval_badge(status)
    case status
    when 'draft'
      return 'badge-status-locked'
    when 'pending'
      return 'badge-status-open'
    when 'rejected'
      return 'badge-private'
    when 'released'
      return 'badge-status-closed'
    when 'published'
      return 'badge-status-closed'
    when 'canceled'
      return 'badge-status-locked'
    else
      return 'badge-count'
    end
  end
end
