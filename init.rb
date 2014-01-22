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
require 'redmine'
begin
require 'config/initializers/session_store.rb'
rescue LoadError
end
require 'redcloth3'

require_dependency 'wiki_extensions_notifiable_patch'
Dir::foreach(File.join(File.dirname(__FILE__), 'lib')) do |file|
  next unless /\.rb$/ =~ file
  require file
end
ActionView::Base.class_eval do
  include ActionView::Helpers::WikiExtensionsHelper
end

Rails.configuration.to_prepare do
  require_dependency 'projects_helper'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless ProjectsHelper.included_modules.include? WikiExtensionsProjectsHelperPatch
    ProjectsHelper.send(:include, WikiExtensionsProjectsHelperPatch)
  end
  
  unless Redmine::WikiFormatting::Textile::Formatter.included_modules.include? WikiExtensionsFormatterPatch
    Redmine::WikiFormatting::Textile::Formatter.send(:include, WikiExtensionsFormatterPatch)
  end
  
  unless Redmine::WikiFormatting::Textile::Helper.included_modules.include? WikiExtensionsHelperPatch
    Redmine::WikiFormatting::Textile::Helper.send(:include, WikiExtensionsHelperPatch)
  end
  
  unless Redmine::Notifiable.included_modules.include? WikiExtensionsNotifiablePatch
    Redmine::Notifiable.send(:include, WikiExtensionsNotifiablePatch)
  end
  
  unless WikiController.included_modules.include? WikiExtensionsWikiControllerPatch
    WikiController.send(:include, WikiExtensionsWikiControllerPatch)
  end
  
  unless WikiPage.included_modules.include? WikiExtensionsWikiPagePatch
    WikiPage.send(:include, WikiExtensionsWikiPagePatch)
  end
end

Redmine::Plugin.register :redmine_wiki_extensions do
  name 'Redmine Wiki Extensions plugin'
  author 'Haruyuki Iida'
  author_url 'http://twitter.com/haru_iida'
  description 'This is a Wiki Extensions plugin for Redmine'
  url "http://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en"
  version '0.6.5'
  requires_redmine :version_or_higher => '2.2.0'

  project_module :wiki_extensions do
    permission :wiki_extensions_vote, {:wiki_extensions => [:vote, :show_vote]}, :public => true
    permission :add_wiki_comment, {:wiki_extensions => [:add_comment, :reply_comment]}
    permission :delete_wiki_comments, {:wiki_extensions => [:destroy_comment]}
    permission :edit_wiki_comments, {:wiki_extensions => [:update_comment]}
    permission :show_wiki_extension_tabs, {:wiki_extensions => [:forward_wiki_page]}, :public => true
    permission :view_wiki_comment, {:wiki_extensions => [:show_comments]}, :public => true
    permission :show_wiki_tags, {:wiki_extensions => [:tag]}, :public => true
    permission :wiki_extensions_settings, {:wiki_extensions_settings => [:show, :update]}
  end

  menulist = [:wiki_extensions1,:wiki_extensions2,:wiki_extensions3,:wiki_extensions4,:wiki_extensions5]
  menulist.length.times{|i|
    no = i + 1
    before = :wiki
    before = menulist[i - 1] if i > 0

    menu :project_menu, menulist[i], { :controller => 'wiki_extensions', :action => 'forward_wiki_page', :menu_id => no },:after => before,
    :caption => Proc.new{|proj| WikiExtensionsMenu.title(proj.id, no)},
    :if => Proc.new{|proj| WikiExtensionsMenu.enabled?(proj.id, no)}
  }

  RedCloth3::ALLOWED_TAGS << "div"
    
  activity_provider :wiki_comment, :class_name => 'WikiExtensionsComment', :default => false
end

