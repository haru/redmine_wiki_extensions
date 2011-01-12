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

class WikiExtensionsIssueHooks < Redmine::Hook::ViewListener
  
  
  def view_issues_form_details_bottom(context = { })
    project = context[:project]
    return unless WikiExtensionsUtil.is_enabled?(project)
    setting = WikiExtensionsSetting.find_or_create(project.id)
    return '' unless setting.auto_preview_enabled

    request = context[:request]
    parameters = request.parameters
    issue = context[:issue]

    url = preview_issue_path(:project_id => project)
    o =<<EOF
<script type="text/javascript">
document.observe('dom:loaded', function() {
    setIssueAutoPreview('#{url}');
});
</script>
EOF
    return o
  end

  def view_issues_edit_notes_bottom(context = { })
    project = context[:project]
    return unless WikiExtensionsUtil.is_enabled?(project)
    setting = WikiExtensionsSetting.find_or_create(project.id)
    return '' unless setting.auto_preview_enabled

    request = context[:request]
    parameters = request.parameters
    issue = context[:issue]

    url = preview_issue_path(:id => issue.id, :project_id => project)
    o =<<EOF
<script type="text/javascript">
document.observe('dom:loaded', function() {
    setIssueNotesAutoPreview('#{url}');
});
</script>
EOF
    return o
  end
  
end
