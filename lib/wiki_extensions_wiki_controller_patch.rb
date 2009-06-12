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
require_dependency 'application'
require_dependency 'wiki_controller'

module WikiExtensionsWikiControllerPatch
  def self.included(base) # :nodoc:

    base.send(:include, InstanceMethodsForWikiExtensionWikiController)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      
      class << self
        # I dislike alias method chain, it's not the most readable backtraces
        
      end
      
    end

  end
end

module InstanceMethodsForWikiExtensionWikiController
  def render(args = {})
    if (args[:action] == 'show')
      wiki_extensions_add_fnlist
      wiki_extensions_include_sidebar
    end
    super args
  end

  private

  def wiki_extensions_add_fnlist
    text = @content.text
    text << "\n{{fnlist}}\n"
  end

  def wiki_extensions_include_sidebar
    return if @page.title == 'SideBar'
    side_bar = @wiki.find_page('SideBar')
    return unless side_bar
    text = @content.text
    text << "\n"
    text << "{{div_start_tag(wiki_extentions_sidebar)}}\n"
    text << "{{include(SideBar)}}\n"
    text << "{{div_end_tag}}\n"
    
  end
end

WikiController.send(:include, WikiExtensionsWikiControllerPatch)

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a '<div class=" + '"' + 'class_name' + '">' + "'\n\n" +
      " @{{div_start_tag(class_name)}}@"
    macro :div_start_tag do |obj, args|
      return '<div id="' + args[0].strip + '">'
    end
  end
end

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a '</div>.'"
    macro :div_end_tag do |obj, args|
      return '</div>'
    end
  end
end

