# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2013  Haruyuki Iida
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

require_dependency 'wiki_controller'

class WikiController
  after_action :wiki_extensions_save, :only => [:update]
  after_action :wiki_extensions_delete, only: [:destroy_version]
  before_action :set_wiki_extensions_data, only: [:show, :edit]
end

module WikiExtensionsWikiControllerPatch
  def render(args = nil)
    if args and @project and WikiExtensionsUtil.is_enabled?(@project) and @content
      if args.class == Hash and args[:partial] == 'common/preview'
        WikiExtensionsFootnote.preview_page.wiki_extension_data[:footnotes] = []
      end
    end
    super
  end

  def respond_to(&)
    if @project and WikiExtensionsUtil.is_enabled?(@project) and @content
      if @_action_name == 'show'
        wiki_extensions_include_header
        wiki_extensions_add_fnlist
        wiki_extensions_include_footer
      end
    end
    super
  end

  def wiki_extensions_get_current_page
    @page
  end

  private

  def set_wiki_extensions_data
    return unless @project && WikiExtensionsUtil.is_enabled?(@project)

    # draft or approval must be enabled in project or plugin
    setting = WikiExtensionsSetting.find_or_create(@project.id)
    return unless WikiExtensionsUtil.approval_or_draft_enabled?(@project, setting)

    approval = WikiExtensionsApproval.for_wiki(@page.id, params[:version].nil? ? @page.version : params[:version].to_i).first

    @wiki_extension_data = {
      view_version_id: params[:version].nil? ? @page.version : params[:version].to_i,
      approval: approval,
      latest_public_approval: WikiExtensionsApproval.latest_public_version(@page.id).first,
      setting: setting,
      step_approval: WikiExtensionsApprovalSteps.first_pending_step_for(approval, User.current, @project, params[:step_id])
    }
  end

  def wiki_extensions_save
    wiki_extensions_save_tags
    wiki_extensions_save_draft
  end

  def wiki_extensions_save_draft
    status = params[:status]
    return true unless status

    status_disabled = params[:status_disabled]
    return true unless status_disabled

    @page.set_draft(status)
  end

  def wiki_extensions_save_tags
    extension = params[:extension]
    return true unless extension

    tags = extension[:tags]

    @page.set_tags(tags)
  end

  def wiki_extensions_delete
    # delete a page version, also delets all approval and approvalsteps
    WikiExtensionsApproval.for_wiki(@page.id, params[:version].to_i).first&.destroy
  end

  def wiki_extensions_add_fnlist
    text = @content.text
    text << "\n\n{{fnlist}}\n"
  end

  def wiki_extensions_include_header
    return if @page.title == 'Header' || @page.title == 'Footer'

    header = @wiki.find_page('Header')
    return unless header

    text = "\n"
    text << '<div id="wiki_extentions_header">'
    text << "\n\n"
    text << header.content.text
    text << "\n\n</div>"
    text << "\n\n"
    text << @content.text
    @content.text = text
  end

  def wiki_extensions_include_footer
    return if @page.title == 'Footer' || @page.title == 'Header'

    footer = @wiki.find_page('Footer')
    return unless footer

    text = @content.text
    text << "\n"
    text << '<div id="wiki_extentions_footer">'
    text << "\n\n"
    text << footer.content.text
    text << "\n\n</div>"
  end
end

WikiController.prepend(WikiExtensionsWikiControllerPatch)
