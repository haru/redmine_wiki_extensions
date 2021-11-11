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
    module NotifiablePatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          class << self
            alias_method :all_without_extensions, :all
            alias_method :all, :all_with_extensions
          end
        end
      end

      module ClassMethods
        def all_with_extensions
          notifications = all_without_extensions
          notifications << Redmine::Notifiable.new('wiki_comment_added')
          notifications
        end
      end
    end
  end
end

unless Redmine::Notifiable.included_modules.include?(RedmineWikiExtensions::Patches::NotifiablePatch)
  Redmine::Notifiable.send(:include, RedmineWikiExtensions::Patches::NotifiablePatch)
end
