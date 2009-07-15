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
    return unless WikiExtensionsUtil.is_enabled?(project)
    wiki = project.wiki
    style_sheet = wiki.find_page('StyleSheet') if wiki
    o = ""
    if style_sheet
      o << "\n"
      o << '<style type="text/css">'
      o << style_sheet.text

      o << '</style>'
      o << "\n"

    end
    
    controller = context[:controller]
    baseurl = url_for(:controller => 'wiki_extensions', :action => 'index', :id => project) + '/../../..'
    
    o << stylesheet_link_tag(baseurl + "/plugin_assets/redmine_wiki_extensions/stylesheets/wiki_extensions.css")
   
    return o unless controller.class.name == 'WikiController'
    action_name = controller.action_name
    return o unless action_name == 'index' or action_name == 'edit'
       
    o << javascript_include_tag(baseurl + "/plugin_assets/redmine_wiki_extensions/javascripts/wiki_extensions.js")

    
          
    return o
  end
  
  def view_layouts_base_body_bottom(context = { })
    project = context[:project]
    return unless WikiExtensionsUtil.is_enabled?(project)
    controller = context[:controller]
    return unless controller.class.name == 'WikiController'
    action_name = controller.action_name
    request = context[:request]
    params = request.parameters if request
    page_name = params[:page] if params
    wiki = project.wiki
    return unless wiki
    page = wiki.find_page(page_name) if page_name
    o = ''
    if action_name == 'edit' or (action_name == 'index' and page_name and page == nil)
      return add_wiki_ext_tags_form context
    end
    return unless action_name == 'index'
    
    @side_bar = wiki.find_page('SideBar')
    
    
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
    tags = page.tags.sort{|a, b|a.name <=> b.name}
    baseurl = url_for(:controller => 'wiki_extensions', :action => 'index', :id => project) + '/../../..'
    img = baseurl + "/images/add.png"

    o = '<div id="wiki_extensions_tag_form"><p>'
    o << "\n"
    o << "<label>#{l(:label_wikiextensions_tags)}</label><br/>"
    i = 0
    maxline = 5
    maxline.times{|line|
      style = ''
      style = 'style="display:none;"' if line != 0 and line > (tags.length - 1) / 4
      o << "<div #{style}" + ' id="tag_line_' + line.to_s + '" >'
      4.times {
        value = ''
        value = 'value="' + tags[i].name  + '"' if tags[i]
        o << '<span class="tag_field">'
        o << '<input id="extension_tags[' + i.to_s + ']" type="text" size="20" name="extension[tags][' + i.to_s + ']" ' +
          value + ' class="wikiext_tag_inputs"/>'
        o << '</span>'
        i = i + 1
      }
      nextline = line + 1
      if (line < maxline - 1)
        o << '<span style="cursor:pointer;">'
        o << image_tag(img, :onclick => '$("tag_line_' + nextline.to_s + '").show()')
        o << '</span>'
      end
     
      o << '</div>'
    }
    o << '<div id="wikiext_taglist_complete"></div>'
    o << "</p></div>\n"
    #o << javascript_tag('add_wiki_extensions_tags_form();')
    o << '<script type="text/javascript"> '
    o << "\n"
    o << '//<![CDATA'
    o << "\n"
    o << 'add_wiki_extensions_tags_form();'
    o << "\n"
    o << 'var taglist = [];'
    o << "\n"
    i = 0;
    all_tags = WikiExtensionsTag.find(:all, :conditions => ['project_id = ?', project.id])
    all_tags.each {|tag|
      o << "taglist[#{i}] = '#{tag.name.gsub(/'/, "\\\\'")}';"
      o << "\n"
      i = i+1
    }
    o << 'set_tag_atuto_complete(taglist);'
    o << "\n"
    o << '//]]>'
    o << "\n"
    o << '</script>'
    return o
  end
end
