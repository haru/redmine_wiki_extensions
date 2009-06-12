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
end

WikiPage.send(:include, WikiExtensionsWikiPagePatch)
