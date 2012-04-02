# Wiki Extensions plugin for Redmine
# Copyright (C) 2012  Haruyuki Iida
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
require "ref_issues/parser"

class RefIssuesParserTest < ActiveSupport::TestCase
  def setup
    @parser = WikiExtensions::RefIssues::Parser.new
  end
  
  context "parse_args" do
    should "raise exeption if args is nil." do
      @parser.parse_args nil
    end    
  end
  
  context "columns" do
    should ":project if args is 'project'" do
      @parser.parse_args ['project']
      assert_equal([:project], @parser.columns)

    end
    
    should "have all specified columns" do
      @parser.parse_args ['project', 'tracker', 'parent', 'status']
      assert_equal([:project, :tracker, :parent, :status], @parser.columns)
      
      @parser.parse_args ['priority', 'subject', 'author', 'assigned_to']
      assert_equal([:priority, :subject, :author, :assigned_to], @parser.columns)
      
      @parser.parse_args ['assigned', 'updated_on', 'category', 'fixed_version']
      assert_equal([:assigned_to, :updated_on, :category, :fixed_version], @parser.columns)
      
      @parser.parse_args ['updated', 'start_date', 'due_date', 'created']
      assert_equal([:updated_on, :start_date, :due_date, :created_on], @parser.columns)
      
      @parser.parse_args ['done_ratio', 'created_on', 'estimated_hours']
      assert_equal([:done_ratio, :created_on, :estimated_hours], @parser.columns)
    end
    
    should "raise exception if unknown column specified" do
      assert_raise RuntimeError do
        @parser.parse_args ['foo', 'created_on', 'estimated_hours']
      end
    end
  end
  
  context "searchWordsS" do
    should "empty if args is nil." do
      @parser.parse_args nil
      assert_equal(0, @parser.searchWordsS.size)
    end
    
    should "aaa if args is '-sw=aaa'" do
      @parser.parse_args ['-sw=aaa']
      assert_equal([['aaa']], @parser.searchWordsS)
    end
    
    should "aaa if args is '-Dw=aaa'" do
      @parser.parse_args ['-Dw=aaa']
      assert_equal([['aaa']], @parser.searchWordsS)
    end
    
    should "aaa if args is '-sDw=aaa'" do
      @parser.parse_args ['-sDw=aaa']
      assert_equal([['aaa']], @parser.searchWordsS)
    end
    
    should "aaa if args is '-Dsw=aaa'" do
      @parser.parse_args ['-Dsw=aaa']
      assert_equal([['aaa']], @parser.searchWordsS)
    end
    
    should "aaa and bbb if args is '-s=aaa|bbb'" do
      @parser.parse_args ['-s=aaa|bbb']
      assert_equal([['aaa', 'bbb']], @parser.searchWordsS)
    end
  end
  
  context "searchWordsD" do
    should "empty if args is nil." do
      @parser.parse_args nil
      assert_equal(0, @parser.searchWordsD.size)
    end
    
    should "aaa if args is '-d=aaa'" do
      @parser.parse_args ['-d=aaa']
      assert_equal([['aaa']], @parser.searchWordsD)
    end
    
    should "aaa if args is '-dw=aaa'" do
      @parser.parse_args ['-dw=aaa']
      assert_equal([['aaa']], @parser.searchWordsD)
    end
    
    should "aaa if args is '-Sw=aaa'" do
      @parser.parse_args ['-Sw=aaa']
      assert_equal([['aaa']], @parser.searchWordsD)
    end
    
    should "aaa if args is '-Sdw=aaa'" do
      @parser.parse_args ['-Sdw=aaa']
      assert_equal([['aaa']], @parser.searchWordsD)
    end
    
    should "aaa if args is '-dSw=aaa'" do
      @parser.parse_args ['-dSw=aaa']
      assert_equal([['aaa']], @parser.searchWordsD)
    end
    
    should "aaa and bbb if args is '-s=aaa|bbb'" do
      @parser.parse_args ['-d=aaa|bbb']
      assert_equal([['aaa', 'bbb']], @parser.searchWordsD)
    end
  end
  
  context "searchWordsW" do
    should "empty if args is nil." do
      @parser.parse_args nil
      assert_equal(0, @parser.searchWordsW.size)
    end
    
    should "aaa if args is '-w=aaa'" do
      @parser.parse_args ['-w=aaa']
      assert_equal([['aaa']], @parser.searchWordsW)
    end
    
    should "aaa if args is '-sdw=aaa'" do
      @parser.parse_args ['-sdw=aaa']
      assert_equal([['aaa']], @parser.searchWordsW)
    end
        
    should "aaa and bbb if args is '-w=aaa|bbb'" do
      @parser.parse_args ['-w=aaa|bbb']
      assert_equal([['aaa', 'bbb']], @parser.searchWordsW)
    end
  end
  
  context "customQueryName" do
    should "return 'name' if args is '-q=name'" do
      @parser.parse_args ['-q=name']
      assert_equal('name', @parser.customQueryName)
    end
    
    should "raise error if args is '-q'" do
      assert_raise RuntimeError do
        @parser.parse_args ['-q']
      end
    end
  end
  
  context "customQueryId" do
    should "return 100 if args is '-i=100'" do
      @parser.parse_args ['-i=100']
      assert_equal('100', @parser.customQueryId)
    end
    
    should "raise error if args is '-i'" do
      assert_raise RuntimeError do
        @parser.parse_args ['-i']
      end
    end
  end
  
  context "same_project?" do
    should "return true fi args is '-p" do
      @parser.parse_args ['-p', '-q=aaa']
      assert @parser.same_project?
    end
    
    should "return false fi -p is not specified" do
      @parser.parse_args ['-q=aaa']
      assert !@parser.same_project?
    end
  end
  
  context "has_serch_conditions?" do
    should "return false if args is empty" do
      @parser.parse_args []
      assert !@parser.has_serch_conditions?
    end
    
    should "return true if args is '-s=aaa" do
      @parser.parse_args ['-s=aaa']
      assert @parser.has_serch_conditions?
    end
    
    should "return true if args is '-d=aaa" do
      @parser.parse_args ['-d=aaa']
      assert @parser.has_serch_conditions?
    end
    
    should "return true if args is '-w=aaa" do
      @parser.parse_args ['-w=aaa']
      assert @parser.has_serch_conditions?
    end
    
    should "return true if args is '-q=aaa" do
      @parser.parse_args ['-q=aaa']
      assert @parser.has_serch_conditions?
    end
    
    should "return true if args is '-i=200" do
      @parser.parse_args ['-i=200']
      assert @parser.has_serch_conditions?
    end
  end
end
