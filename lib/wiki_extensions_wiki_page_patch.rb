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
require_dependency 'wiki_page'

module WikiExtensionsWikiPagePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethodsForWikiExtension)

    base.send(:include, InstanceMethodsForWikiExtension)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :wiki_extensions_tag_relations, :dependent => :destroy
      has_many :tags, :class_name => 'WikiExtensionsTag', :through => :wiki_extensions_tag_relations
      has_one :wiki_extensions_count, :foreign_key => :page_id, :dependent => :destroy
      class << self
        # I dislike alias method chain, it's not the most readable backtraces
        
      end
      
    end

  end
end
module ClassMethodsForWikiExtension
  
end

module InstanceMethodsForWikiExtension
  def wiki_extension_data
    @wiki_extension_data ||= {}
  end  

  def set_tags(tag_list = {})
    tag_array = []
    tag_list.each_value{|name|
      next if name.blank?
      tag_array << name.strip
    }

    tag_array = tag_array.uniq

    wiki_extensions_tag_relations.each {|relation|
      relation.destroy
    }
    
    tag_array.each{|name|
      tag = WikiExtensionsTag.find_or_create(self.project.id, name)
      relation = WikiExtensionsTagRelation.new
      relation.tag = tag
      relation.wiki_page_id = self.id
      relation.save
    }
    
  end
  
end

WikiPage.send(:include, WikiExtensionsWikiPagePatch)
