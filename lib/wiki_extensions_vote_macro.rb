# Wiki Extensions plugin for Redmine
# Copyright (C) 2010  Haruyuki Iida
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

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Vote macro.\n\n"+
      "  !{{vote(key)}}\n" +
      "  !{{vote(key, label)}}\n"
    macro :vote do |obj, args|
      return nil unless WikiExtensionsUtil.is_enabled?(@project)

      return nil if args.length < 1
      key = args[0].strip
      label = l(:wiki_extensions_vote)
      label = args[1].strip if args.length > 1
      voteid = "wikiext-vote-#{rand(9999999)}"
      vote = WikiExtensionsVote.find_or_create(obj.class.name, obj.id, key)

      o = '<span class="wikiext-vote">'
      o << link_to_remote(label, :update => voteid, :url => {:controller => 'wiki_extensions', :action => 'vote',
        :id => @project, :target_class_name => obj.class.name, :target_id => obj.id,
        :key => key, :url => @_request.url})
      o << '<span id="' + voteid + '"> '
      o << " #{vote.count}"
      o << '</span>'
      o << '</span>'
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Display result of vote macro.\n\n"+
      "  !{{show_vote(key)}}\n"
    macro :show_vote do |obj, args|
      return nil unless WikiExtensionsUtil.is_enabled?(@project)

      return nil if args.length < 1
      key = args[0].strip
      vote = WikiExtensionsVote.find_or_create(obj.class.name, obj.id, key)

      o = '<span class="wikiext-show-vote">'
      o << "#{vote.count}"
      o << '</span>'
      return o
    end
  end
end
