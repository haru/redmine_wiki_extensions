# Wiki Extensions plugin for Redmine
# Copyright (C) 2011-2015  Haruyuki Iida
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
class WikiExtensionsSetting < ActiveRecord::Base
  unloadable
  belongs_to :project
  attr_accessible :auto_preview_enabled

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

  def menus
    WikiExtensionsMenu.where(:project_id => project_id).order('menu_no')
  end
end
