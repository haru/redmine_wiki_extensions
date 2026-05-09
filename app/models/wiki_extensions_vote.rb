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

class WikiExtensionsVote < ApplicationRecord
  validates_presence_of :target_class_name, :target_id, :keystr, :count
  validates_uniqueness_of :keystr, :scope => [:target_class_name, :target_id]

  # Returns the voted-on ActiveRecord object.
  # @return [Object, nil]
  def target
    return nil unless self.target_class_name
    return nil unless self.target_id
    targetclass = eval self.target_class_name
    targetclass.find(self.target_id)
  end

  # Sets the voted-on object by recording its class name and id.
  # @param obj [Object] any ActiveRecord object
  def target=(obj)
    self.target_class_name = obj.class.name
    self.target_id = obj.id
  end

  # Increments the vote count by one.
  def countup
    self.count = 0 unless self.count
    self.count = self.count + 1
  end

  # Finds or creates a vote record for the given target object and key.
  # @param class_name [String] target class name
  # @param obj_id [Integer] target object id
  # @param key_str [String] vote key (allows multiple vote types per object)
  # @return [WikiExtensionsVote]
  def self.find_or_create(class_name, obj_id, key_str)
    vote = WikiExtensionsVote.where(:target_class_name => class_name).where(:target_id => obj_id).where(:keystr => key_str).first
    unless vote
      vote = WikiExtensionsVote.new
      vote.count = 0
      vote.target_class_name = class_name
      vote.target_id = obj_id
      vote.keystr = key_str
    end
    return vote
  end
end
