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
class WikiExtensionsApplicationHooks < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context = {})
    project = context[:project]
    controller = context[:controller]
    return unless controller.class.name == 'WikiController'
    action_name = controller.action_name
    return unless action_name == 'index' or action_name == 'edit'
    baseurl = url_for(:controller => 'wiki_extensions', :action => 'index', :id => project) + '/../../..'

    
    o = ""
    o << javascript_include_tag(baseurl + "/plugin_assets/redmine_wiki_extensions/javascripts/wiki_extensions.js")
    o << "\n"
    o << stylesheet_link_tag(baseurl + "/plugin_assets/redmine_wiki_extensions/stylesheets/wiki_extensions.css")
     
    return o
  end
  
  def view_layouts_base_body_bottom(context = { })
    project = context[:project]
    controller = context[:controller]
    return unless controller.class.name == 'WikiController'
    action_name = controller.action_name
    if action_name == 'edit'
      return add_wiki_ext_tags_form context
    end
    return unless action_name == 'index'
    @wiki = project.wiki
    return unless @wiki
    @side_bar = @wiki.find_page('SideBar')
    o = ''
    
    if @side_bar
      o << javascript_tag('add_wiki_extension_sidebar();')
    end

    return o
  end

  private

  def add_wiki_ext_tags_form(context)
    project = context[:project]
    controller = context[:controller]
    page = controller.wiki_extensions_get_current_page
    tags = page.tags

    o = '<div id="wiki_extensions_tag_form"><p>'
    o << "\n"
    o << "<label>#{l(:label_wikiextensions_tags)}</label><br/>"
    i = 0
    5.times{|line|
      style = ''
      style = 'style="display:none;"' if line > 0
      o << "<div #{style}>"
      4.times {
        value = ''
        value = 'value="' + tags[i].name  + '"' if tags[i]
        o << '<span class="tag_field">'
        o << '<input id="extension_tags[' + i.to_s + ']" type="text" size="20" name="extension[tags][' + i.to_s + ']" ' +
          value + '/>'
        o << '</span>'
        i = i + 1
      }
      o << '</div>'
    }
    o << "</p></div>\n"
    o << javascript_tag('add_wiki_extensions_tags_form();')
    return o
  end
end
