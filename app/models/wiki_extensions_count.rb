# Wiki Extensions plugin for Redmine
# Copyright (C) 2009  Haruyuki Iida
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
class WikiExtensionsCount < ActiveRecord::Base
  belongs_to :project
  belongs_to :page, :foreign_key => :page_id, :class_name => 'WikiPage'
  validates_presence_of :project
  validates_presence_of :page
  validates_presence_of :date
  validates_presence_of :count
  validates_uniqueness_of :page_id, :scope => :date

  def self.countup(wiki_page_id, date = nil)
    date = Date.today unless date
    count = WikiExtensionsCount.find(:first,
      :conditions => ['date = ? and page_id = ?', date, wiki_page_id])
    unless count
      page = WikiPage.find(wiki_page_id)
      count = WikiExtensionsCount.new
      count.project = page.wiki.project
      count.page = page
      count.date = date
      count.count = 0
    end
    count.count = count.count + 1
    count.save!
  end

  def self.access_count(wiki_page_id, date = nil)
    conditions = ['page_id = ?', wiki_page_id] unless date
    conditions = ['date >= ? and page_id = ?', date, wiki_page_id] if date
    total = WikiExtensionsCount.sum(:count, :conditions => conditions)
  end

  def self.popularity(project_id, term = 0)
    conditions = ['project_id = ?', project_id] if term == 0
    conditions = ['project_id = ? and date > ?', project_id, Date.today - term.to_i] if term > 0
    WikiExtensionsCount.sum(:count, :group => :page_id,
      :conditions => conditions, :select => :count, :order => 'sum(count) desc')
  end
end
