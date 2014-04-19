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

begin
  require_dependency 'application'
rescue LoadError
end
require_dependency 'wiki_controller'

module WikiExtensionsWikiControllerPatch
  def self.included(base) # :nodoc:

    base.send(:include, InstanceMethodsForWikiExtensionWikiController)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      after_filter :wiki_extensions_save_tags, :only => [:edit, :update]
      alias_method_chain :respond_to, :wiki_extensions
      alias_method_chain :render, :wiki_extensions
      class << self


      end

    end

  end
end

module InstanceMethodsForWikiExtensionWikiController
  def render_with_wiki_extensions(args = nil)
    if args and @project and WikiExtensionsUtil.is_enabled?(@project) and @content
      if (args.class == Hash and args[:partial] == 'common/preview')
        WikiExtensionsFootnote.preview_page.wiki_extension_data[:footnotes] = []
      end
    end
    render_without_wiki_extensions(args)
  end

  def respond_to_with_wiki_extensions(&block)
    if @project and WikiExtensionsUtil.is_enabled?(@project) and @content
      if (@_action_name == 'show')
        wiki_extensions_include_header
        wiki_extensions_add_fnlist
        wiki_extensions_include_footer
      end
    end
    respond_to_without_wiki_extensions(&block)
  end

  def wiki_extensions_get_current_page
    @page
  end

  private

  def wiki_extensions_save_tags
    return true if request.get?

    extension = params[:extension]
    return true unless extension

    tags = extension[:tags]

    @page.set_tags(tags)
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



