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
class WikiExtensionsCount < ApplicationRecord
  belongs_to :project
  belongs_to :page, class_name: "WikiPage"
  validates :project, presence: true
  validates :page, presence: true
  validates :date, presence: true
  validates :count, presence: true
  validates :page_id, uniqueness: { scope: :date }

  # Increments the access count for a wiki page on the given date.
  # @param wiki_page_id [Integer]
  # @param date [Date] defaults to today
  def self.countup(wiki_page_id, date = nil)
    date = Time.zone.today unless date
    count = WikiExtensionsCount.where(date: date).where(page_id: wiki_page_id).first
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

  # Returns the total access count for a wiki page, optionally from a start date.
  # @param wiki_page_id [Integer]
  # @param date [Date, nil] if given, only counts from this date onward
  # @return [Integer]
  def self.access_count(wiki_page_id, date = nil)
    conditions = [ "page_id = ?", wiki_page_id ] unless date
    conditions = [ "date >= ? and page_id = ?", date, wiki_page_id ] if date
    # total = WikiExtensionsCount.sum(:count, :conditions => conditions)
    WikiExtensionsCount.where(conditions).sum(:count)
  end

  # Returns pages sorted by access count descending.
  # @param project_id [Integer]
  # @param term [Integer] number of days to look back; 0 means all time
  # @return [Array<Array(Integer, Integer)>] pairs of [page_id, count]
  def self.popularity(project_id, term = 0)
    conditions = [ "project_id = ?", project_id ] if term == 0
    conditions = [ "project_id = ? and date > ?", project_id, Time.zone.today - term.to_i ] if term > 0
    WikiExtensionsCount.where(conditions).group(:page_id).sum(:count).to_a.sort_by { |x|0 - x[1] }.map { |x| [ x[0], x[1].to_i ] }
  end
end
