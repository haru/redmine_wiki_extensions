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
#

require File.expand_path('../test_helper', __dir__)

class WikiExtensionsApprovalControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :wikis, :wiki_pages, :wiki_contents, :wiki_extensions_settings

  def setup
    @project = Project.find(1)
    @wiki = @project.wiki
    @page = WikiPage.find_by(title: 'CookBook_documentation')
    @page.content ||= WikiContent.create!(page: @page, text: 'test')

    @user = User.find_by(login: 'jsmith')
    @request.session[:user_id] = @user.id
    User.current = @user

    manager_role = Role.find_by(name: 'Manager')
    if manager_role
      needed_permissions = [
        :approval_start, :approval_grant, :approval_forward,
        :draft_view, :draft_create
      ]
      manager_role.permissions |= needed_permissions
      manager_role.save!
    end

    member = Member.find_or_initialize_by(project: @project, user: @user)
    member.roles << manager_role unless member.roles.include?(manager_role)
    member.save!

    EnabledModule.find_or_create_by!(project: @project, name: 'wiki_extensions')
  end

  test "should render start_approval form on GET with permission" do
    @request.session[:user_id] = User.current.id
    get :start_approval, params: { id: @project.id, title: @page.title, version: @page.content.version }
    assert_response :success
    assert_match 'Start approval', @response.body
  end

  test "should return 403 on GET without permission" do
    @request.session[:user_id] = User.current.id
    Member.where(user_id: @user.id, project_id: @project.id).destroy_all
    get :start_approval, params: { id: @project.id, title: @page.title, version: @page.content.version }
    assert_response :forbidden
  end

  test "should create approval on POST" do
    @request.session[:user_id] = User.current.id
    post :start_approval, params: {
      id: @project.id,
      title: @page.title,
      version: @page.content.version,
      steps: { "1" => [{ "principal_id" => @user.id.to_s }] },
      steps_typ: { "1" => "or" },
      note: "Approval started"
    }
    assert_response :redirect
    approval = WikiExtensionsApproval.find_by(wiki_page_id: @page.id)
    assert_not_nil approval
    assert_equal "Approval started", approval.note
    assert_equal 1, approval.approval_steps.count
  end

  test "should reject approval if duplicate users" do
    @request.session[:user_id] = User.current.id
    post :start_approval, params: {
      id: @project.id,
      title: @page.title,
      version: @page.content.version,
      steps: {
        "1" => [{ "principal_id" => @user.id.to_s }],
        "2" => [{ "principal_id" => @user.id.to_s }]
      },
      steps_typ: { "1" => "or", "2" => "or" }
    }
    assert_response :success
    assert flash[:error].present?
  end

  test "should grant approval" do
    @request.session[:user_id] = User.current.id
    approval = WikiExtensionsApproval.create!(
      wiki_page_id: @page.id,
      wiki_version_id: @page.content.version,
      status: :pending,
      author_id: @user.id
    )
    principal_object = User.find_by(id: @user.id)
    step = approval.approval_steps.for_principal(principal_object).find_or_initialize_by(step: 1)
    step.status = :pending
    step.save!

    post :grant_approval, params: {
      id: @project.id,
      title: @page.title,
      version: @page.content.version,
      step_id: step.id,
      note: "Looks good",
      status: "approved"
    }

    assert_response :redirect
    step.reload
    assert_equal 'approved', step.status
    assert_equal 'Looks good', step.note
    approval.reload
    assert_equal 'released', approval.status
  end

  test "should forward approval" do
    @request.session[:user_id] = User.current.id
    approval = WikiExtensionsApproval.create!(
      wiki_page_id: @page.id,
      wiki_version_id: @page.content.version,
      status: :draft,
      author_id: @user.id
    )
    principal_object = User.find_by(id: @user.id)
    step = approval.approval_steps.for_principal(principal_object).find_or_initialize_by(step: 1)
    step.status = :pending
    step.save!

    principal_object = Group.first

    post :forward_approval, params: {
      id: @project.id,
      title: @page.title,
      version: @page.content.version,
      step_id: step.id,
      note: "forward to group",
      principal_id: principal_object.id
    }

    assert_response :redirect
    step.reload
    assert_equal 'pending', step.status
    assert_equal 'forward to group', step.note
    assert_equal 'Group', step.principal_type
    approval.reload
    assert_equal 'pending', approval.status
  end

  test "should approval multiple steps or and" do
    @request.session[:user_id] = User.current.id
    principal_object = Group.first
    user_second = User.find_by(login: 'dlopper')
    user_third = User.find_by(login: 'rhill')
    post :start_approval, params: {
      id: @project.id,
      title: @page.title,
      version: @page.content.version,
      steps: {
        "1" => [
          { "principal_id" => @user.id.to_s },
          { "principal_id" => principal_object.id.to_s }
        ],
        "2" => [
          { "principal_id" => user_second.id.to_s },
          { "principal_id" => user_third.id.to_s }
        ]
      },
      steps_typ: { "1" => "or", "2" => "and" },
      note: "multiple steps"
    }
    assert_response :redirect
    approval = WikiExtensionsApproval.find_by(wiki_page_id: @page.id)
    assert_not_nil approval
    assert_equal 'pending', approval.status
    assert_equal 4, approval.approval_steps.count
    assert_equal 'pending', approval.approval_steps[0].status
    assert_equal 'unstarted', approval.approval_steps[2].status

    # approved first step
    post :grant_approval, params: {
      id: @project.id,
      title: @page.title,
      version: @page.content.version,
      step_id: approval.approval_steps[0].id,
      note: "Looks good",
      status: "approved"
    }
    assert_response :redirect
    approval.reload
    assert_equal 3, approval.approval_steps.count
    assert_equal 'approved', approval.approval_steps[0].status
    assert_equal 'pending', approval.approval_steps[1].status
    assert_equal 'pending', approval.approval_steps[2].status

    # approved step 2 first user
    target_step = approval.approval_steps.find_by(principal_id: user_second.id)
    if target_step
      target_step.status = :approved
      target_step.save!
    end

    approval.reload
    assert_equal 3, approval.approval_steps.count
    target_step.reload
    assert_equal 'approved', target_step.status

    # approved step 2 second user
    target_step = approval.approval_steps.find_by(principal_id: user_third.id)
    if target_step
      target_step.status = :approved
      target_step.save!
    end

    approval.reload
    assert_equal 3, approval.approval_steps.count
    assert_equal 'approved', approval.approval_steps[0].status
    assert_equal 'approved', approval.approval_steps[1].status
    assert_equal 'approved', approval.approval_steps[2].status
    assert_equal 'released', approval.status
  end

  test "should reject approval" do
    @request.session[:user_id] = User.current.id
    approval = WikiExtensionsApproval.create!(
      wiki_page_id: @page.id,
      wiki_version_id: @page.content.version,
      status: :pending,
      author_id: @user.id
    )
    principal_object = User.find_by(id: @user.id)
    step = approval.approval_steps.for_principal(principal_object).find_or_initialize_by(step: 1)
    step.status = :pending
    step.save!

    post :grant_approval, params: {
      id: @project.id,
      title: @page.title,
      version: @page.content.version,
      step_id: step.id,
      note: "Looks bad",
      status: "rejected"
    }

    assert_response :redirect
    step.reload
    assert_equal 'rejected', step.status
    assert_equal 'Looks bad', step.note
    approval.reload
    assert_equal 'rejected', approval.status
  end
end
