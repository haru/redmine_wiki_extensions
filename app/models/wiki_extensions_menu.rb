# Wiki Extensions plugin for Redmine
# Copyright (C) 2024  Haruyuki Iida
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
class WikiExtensionsMenu < ApplicationRecord
  include Redmine::SafeAttributes
  belongs_to :project
  validates :project_id, presence: true
  validates :menu_no, presence: true

  # attr_accessible 'enabled', 'menu_no', 'title', 'page_name'

  def self.find_or_create(pj_id, no)
    menu = WikiExtensionsMenu.where(project_id: pj_id).where(menu_no: no).first
    unless menu
      menu = WikiExtensionsMenu.new
      menu.project_id = pj_id
      menu.menu_no = no
      menu.enabled = false
      menu.save!
    end
    menu
  end

  def self.enabled?(pj_id, no)
    begin
      menu = find_or_create(pj_id, no)
      return false if menu.page_name.blank?
      menu.enabled
    rescue
      false
    end
  end

  # Returns the display title for a menu item, falling back to page name.
  # @param pj_id [Integer]
  # @param no [Integer] menu item number (1–5)
  # @return [String, nil]
  def self.title(pj_id, no)
    begin
      menu = find_or_create(pj_id, no)
      return menu.title if menu.title.present?
      return menu.page_name if menu.page_name.present?
      nil
    rescue
      nil
    end
  end

  # Validates that an enabled menu item is properly configured.
  def validate
    true unless enabled
    # errors.add("title", "is empty") unless attribute_present?("title")
    # errors.add("page_name", "is empty") unless attribute_present?("page_name")
  end
end
