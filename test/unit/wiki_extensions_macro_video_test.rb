# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2010  Haruyuki Iida
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

require File.expand_path('../test_helper', __dir__)

class WikiExtensionsMacroVideoTest < ActiveSupport::TestCase
  include ApplicationHelper
  include ActionDispatch::Assertions::SelectorAssertions
  include ERB::Util

  def test_video_tag_macro
    with_settings :text_formatting => 'textile' do
      result = textilizable("{{video_tag(https://samplelib.com/lib/preview/mp4/sample-5s.mp4, 320, 240, controls autoplay muted)}}")

      assert_select_in result, 'video[src="https://samplelib.com/lib/preview/mp4/sample-5s.mp4"]'
      assert_select_in result, 'video[width="320"]'
      assert_select_in result, 'video[height="240"]'
      assert_select_in result, 'video[controls]'
      assert_select_in result, 'video[autoplay]'
      assert_select_in result, 'video[muted]'
    end
  end
end
