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
       WikiExtensionsUtil.is_allowed_to_show_last_version?(context[:project]) &&
       !from_update?(context[:controller])

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
          return

        end

      end

      # If the current page is in draft or approval status and there are no rights to view the draft, then this is not authorized.
      version = controller.params[:version]&.to_i || page&.version
      if version &&
         WikiExtensionsUtil.view_draft?(context[:project]) == false &&
         (WikiExtensionsApproval.for_wiki(page.id, version).first&.status_before_type_cast&.< WikiExtensionsApproval.statuses[:published])
        raise ::Unauthorized
      end

    end
  end

  private

  def from_update?(controller)
    referer = controller.request.referer
    referer.present? && referer.include?('/wiki/') && referer.include?('edit')
  end
end
