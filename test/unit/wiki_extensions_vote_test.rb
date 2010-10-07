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

require File.dirname(__FILE__) + '/../test_helper'

class WikiExtensionsVoteTest < ActiveSupport::TestCase
  fixtures :wiki_extensions_votes, :projects

  context "target" do
    setup do
      @vote = WikiExtensionsVote.new
    end

    should "return nil when instance initialized." do
      assert_nil(@vote.target)
    end

    should "return nil if target_class_name is nil" do
      @vote.target_id = 1
      assert_nil(@vote.target)
    end

    should "return nil if target_id is nil" do
      @vote.target_class_name = 'Issue'
      assert_nil(@vote.target)
    end

    should "return object if target_class_name and target_id were setted." do
      project = Project.generate!
      @vote.target_class_name = project.class.name
      @vote.target_id = project.id
      project2 = @vote.target
      assert_equal(project.class.name, project2.class.name)
      assert_equal(project.id, project2.id)
    end
  end

  context "target=" do
    setup do
      @vote = WikiExtensionsVote.new
      @project = Project.generate!
    end

    should "set target_class_name" do
      @vote.target = @project
      assert_equal(@project.class.name, @vote.target_class_name)
    end

    should "set target_id" do
      @vote.target = @project
      assert_equal(@project.id, @vote.target_id)
    end
  end

  context "save" do
    setup do
      @vote = WikiExtensionsVote.new
      @project = Project.generate!
    end

    should "save" do
      @vote.target = @project
      @vote.count = 1
      @vote.keystr = "aaa"
      @vote.save!
      vote2 = WikiExtensionsVote.find(@vote.id)
      assert_equal(@vote.id, vote2.id)
      assert_equal(@project, vote2.target)
    end
  end

  context "countup" do
    setup do
      @vote = WikiExtensionsVote.new
    end

    should "return 1 if count is nil." do
      @vote.count = nil
      assert_equal(1, @vote.countup)
      assert_equal(1, @vote.count)
    end

    should "return 100 if count is 99." do
      @vote.count = 99
      assert_equal(100, @vote.countup)
      assert_equal(100, @vote.count)
    end
  end

  context "find_or_create" do
    setup do
      @project = Project.generate!
      @vote = WikiExtensionsVote.generate!(:target => @project, :count => 1, :keystr => 'aaa')
    end

    should "return new instance which count is 0 if target not found." do
      vote = WikiExtensionsVote.find_or_create('Hoge', 3, 'keystr')
      assert_not_nil(vote)
      assert_equal('Hoge', vote.target_class_name)
      assert_equal(3, vote.target_id)
      assert_equal('keystr', vote.keystr)
      assert_equal(0, vote.count)
    end

    should "find instance what has specified values." do
      vote = WikiExtensionsVote.find_or_create(@vote.target_class_name, @vote.target_id, @vote.keystr)
      assert_not_nil(vote)
      assert_equal(@vote.id, vote.id)
    end
  end
end
