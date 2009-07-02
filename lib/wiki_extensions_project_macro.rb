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
require 'redmine'

module WikiExtensionsProjectMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Creates link to other project.\n\n" +
      " \{{project(project_name)}}\n" +
      " \{{project(project_identifire}}\n" +
      " \{{project(project_name, alias)}}\n" +
      " \{{project(project_identifire, alias}}\n"
    macro :project do |obj, args|
      
      return nil if args.length < 1
      project_name = args[0].strip
      project = Project.find_by_name(project_name)
      project = Project.find_by_identifier(project_name) unless project
      return nil unless project
      return nil unless WikiExtensionsUtil.is_enabled?(@project) if @project
      if (args[1])
        alias_name = args[1].strip
      else
        alias_name = project.name
      end

      o = ""
      o << link_to(alias_name, :controller => 'projects', :action => 'show', :id => project)
      return o
    end
  end
end
