# Wiki Extensions plugin for Redmine
# Copyright (C) 2011-2017  Haruyuki Iida
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

require_dependency "redmine/wiki_formatting/textile/formatter"

module WikiExtensionsFormatterPatch
  private

  def inline_smiles(text)
    emoticon_path = WikiExtentionEmoticonPath.new

    @emoticons = WikiExtensionsEmoticons::Emoticons.new
    @emoticons.emoticons.each { |emoticon|
      src = emoticon_path.get_emoticon_path(emoticon["image"])
      text.gsub!(Regexp.new("#{Regexp.escape(emoticon["emoticon"])}(\\s|<br/>|</p>)"),
                 "<img src=\"#{src}\" alt=\"#{emoticon["emoticon"]}\">\\1")
    }
  end

  class WikiExtentionEmoticonPath
    include Rails.application.routes.url_helpers

    def get_emoticon_path(emoticon)
      wiki_extensions_emoticon_path(emoticon)
    end
  end
end

# Redmine refactored textile formatting in master (Jan 2026, commit f7f585a6d).
# Before: Formatter < RedCloth3 (RULES defined in Formatter)
# After:  Filter < RedCloth3 (RULES defined in Filter), Formatter is a wrapper
#
# Use direct constant reference (triggers autoload) instead of defined?() which
# does not trigger Zeitwerk autoloading and can cause incorrect fallback.
filter_class = begin
  Redmine::WikiFormatting::Textile::Filter
rescue NameError
  nil
end

if filter_class
  filter_class::RULES << :inline_smiles
  filter_class.prepend(WikiExtensionsFormatterPatch)
else
  Redmine::WikiFormatting::Textile::Formatter::RULES << :inline_smiles
  Redmine::WikiFormatting::Textile::Formatter.prepend(WikiExtensionsFormatterPatch)
end
