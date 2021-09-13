# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2017  Haruyuki Iida
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

module RedmineWikiExtensions
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method :project_settings_tabs_without_wiki_extensions, :project_settings_tabs
          alias_method :project_settings_tabs, :project_settings_tabs_with_wiki_extensions
        end
      end

      module InstanceMethods
        # include ContactsHelper

        def project_settings_tabs_with_wiki_extensions
          tabs = project_settings_tabs_without_wiki_extensions
          action = {:name => 'wiki_extensions', 
            :controller => 'wiki_extensions_settings', 
            :action => :show, 
            :partial => 'wiki_extensions_settings/show', 
            :label => :wiki_extensions}
          return tabs unless User.current.allowed_to?(action, @project)
          tabs.push(action)
          tabs
        end
      end
    end
  end
end

unless ProjectsHelper.included_modules.include?(RedmineWikiExtensions::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineWikiExtensions::Patches::ProjectsHelperPatch)
end
