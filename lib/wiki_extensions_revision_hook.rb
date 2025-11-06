# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2025  Haruyuki Iida
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

class WikiExtensionsRevisionHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    if context[:controller].is_a?(WikiController) &&
       context[:controller].action_name == 'show' &&
       WikiExtensionsUtil.is_allowed_to_show_last_version?(context[:project])

      controller = context[:controller]
      page = controller.instance_variable_get(:@page)

      # when accessing the current wiki page
      if controller.params[:version].nil? && page&.version
        version = WikiExtensionsApproval.latest_public_version(page.id).first

        # Redirect only if the last public versions differ
        if version && version.wiki_version_id != page.version

          context[:controller].redirect_to(
            controller: 'wiki',
            action: 'show',
            project_id: context[:controller].params[:project_id],
            id: page.title,
            version: version.wiki_version_id
          )

        end

      end

    end
  end
end
