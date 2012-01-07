# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2011  Haruyuki Iida
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
class WikiExtensionsComment < ActiveRecord::Base
  unloadable
  belongs_to :user
  belongs_to :wiki_page
  validates_presence_of :comment, :wiki_page_id, :user_id
  
  def children(comments)
    comments.select{|comment| comment.parent_id == id}
  end
  
  def project
    wiki_page.wiki.project
  end
  
  acts_as_event :title => Proc.new {|o| "Wiki comment: #{o.wiki_page.title}"},
    :author => :user,
    :description => :comment,
    :datetime => :updated_at,
    :url => Proc.new {|o| {:controller =>'wiki', :action => 'show', :id => o.wiki_page.title, :project_id => o.project}}
  
  acts_as_activity_provider :type => 'wiki_comment',
    :timestamp => "updated_at",
    :author_key => "user_id",
    :find_options => {:include => {:wiki_page => {:wiki => :project}}}

end
