# Wiki Extensions plugin for Redmine
# Copyright (C) 2010-2013  Haruyuki Iida
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

module WikiExtensionsTaggedpagesMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Displays pages that have specified tag.\n\n"+
      "  !{{taggedpages(tagname)}}\n" +
      "  !{{taggedpages(tagname, tagname, project)}}\n" +
      "  !{{taggedpages(tagname, tagname, project=all, operator=AND)}}\n" +
      "  !{{taggedpages(tagname, tagname, project=proj1 proj2)}}"
    macro :taggedpages do |obj, args|
      return nil unless WikiExtensionsUtil.is_enabled?(@project)
      return nil unless WikiExtensionsUtil.tag_enabled?(@project)

      return nil if args.empty?

      args, options = extract_macro_options(args, :project, :operator)
      project_arg = options[:project]
      operator = options[:operator]

      project_arg = project_arg.split if project_arg
      operator = "OR" if operator.nil?

      tag_names = []
      if args.length == 1
        tag_names << args[0].strip
        project_arg = [@project.identifier] if project_arg.nil?
      else
        project_arg = [args.pop.strip] if project_arg.nil?
        args.each do |arg|
          tag_names << arg.strip
        end
      end

      projects = []
      # projects fill with id's
      project_arg.each do |name|
        find = Project.find_by_identifier(name)
        find = Project.find_by_name(name) if find.nil?
        find = Project.find_by_id(name.to_i) if find.nil?
        projects << find.id if find
      end

      # if no project was found
      if projects.empty?
        projects = [@project.id]
        # if last parameter was not a project, just a tag
        tag_names += project_arg if options.empty?
      end

      # find tags from all projects
      if !project_arg.empty? && project_arg[0].is_a?(String) && (project_arg[0] == "all" || project_arg[0] == "*")
        # all projects AND IN tagnames
        tags = WikiExtensionsTag.where(:name => tag_names).order(:project_id)
      else
        # IN projects AND IN tagnames
        tags = WikiExtensionsTag.where(:project_id => projects).where(:name => tag_names).order(:project_id)

      end

      tagged_pages = []
      tagged_pages_tmp = []
      last_project_id = 0

      tags.each do |tag|
        # get pages from a tag
        curr_pages = tag.pages

        # if project changes, than tmp_tagged_pages into result
        if !tagged_pages_tmp.empty? && last_project_id > 0 && last_project_id != tag.project_id
          # new project_id begins
          tagged_pages += tagged_pages_tmp
          tagged_pages_tmp = []
        end

        if tagged_pages_tmp.empty? || operator == "OR"
          tagged_pages_tmp += curr_pages
        else
          # AND Parameter, adds pages who is in both lists
          ids_in_liste = curr_pages.map { |e| e[:id] }
          tagged_pages_tmp = tagged_pages_tmp.select { |e| ids_in_liste.include?(e[:id]) }
        end

        # save for next run
        last_project_id = tag.project_id
      end

      # tagged_pages final result
      tagged_pages += tagged_pages_tmp

      o = '<ul class="wikiext-taggedpages">'
      tagged_pages.uniq.sort_by(&:pretty_title).each do |page|
        o << '<li>' + link_to(page.pretty_title, :controller => 'wiki', :action => 'show', :project_id => page.project, :id => page.title) + '</li>'
      end
      o << '</ul>'
      return o.html_safe
    end
  end
end
