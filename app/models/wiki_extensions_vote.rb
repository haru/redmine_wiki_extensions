# Wiki Extensions plugin for Redmine
# Copyright (C) 2010  Haruyuki Iida
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

class WikiExtensionsVote < ActiveRecord::Base
  unloadable
  validates_presence_of :target_class_name, :target_id, :keystr, :count
  validates_uniqueness_of :keystr, :scope => [:target_class_name, :target_id]

  def target
    return nil unless self.target_class_name
    return nil unless self.target_id
    targetclass = eval self.target_class_name
    targetclass.find(self.target_id)
  end

  def target=(obj)
    self.target_class_name = obj.class.name
    self.target_id = obj.id
  end

  def countup
    self.count = 0 unless self.count
    self.count = self.count + 1
  end

  def self.find_or_create(class_name, obj_id, key_str)
    vote = WikiExtensionsVote.find(:first,
      :conditions => ['target_class_name = ? and target_id = ? and keystr = ?',
        class_name, obj_id, key_str])
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
 