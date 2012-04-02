require 'redmine'
require 'ref_issues/parser'

module WikiExtensionsRefIssue
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a list of referer issues."
    macro :ref_issues do |obj, args|
      
      parser = nil
      
      begin
        parser = WikiExtensions::RefIssues::Parser.new args
      rescue => err_msg
        raise "parameter error: #{err_msg}<br>"+
          "[optins]<br>"+
          "-s=WORD[|WORD[|...]] : search WORDs in subject<br>"+
          "-d=WORD[|WORD[|...]] : search WORDs in description<br>"+
          "-w=WORD[|WORD[|...]] : search WORDs in subject and/or description<br>"+
          "-i=CustomQueryID : specify custom query<br>"+
          "-q=CustomQueryName : specify custom query<br>"+
          "-p : restrict project<br>"+
          "[columns]<br>"+
          "project,tracker,parent,status,priority,subject,author,assigned,updated,<br>"+
          "category,fixed_version,start_date,due_date,estimated_hours,done_ratio,created"
      end

      unless parser.has_serch_conditions? # 検索条件がなにもなかったら
        # 検索するキーワードを取得する
        if obj.class == WikiContent  # Wikiの場合はページ名および別名を検索ワードにする
          words = []
          words.push(obj.page.title); #ページ名
          redirects = WikiRedirect.find(:all, :conditions=>["redirects_to=:s", {:s=>obj.page.title}]); #別名query
          redirects.each do |redirect|
            words.push(redirect.title); #別名
          end
          parser.searchWordsW.push(words)
        elsif obj.class == Issue  # チケットの場合はチケット番号表記を検索ワードにする
          parser.searchWordsW.push(['#'+obj.id.to_s]);
        elsif obj.class == Journal && obj.journalized_type == "Issue" 
          # チケットコメントの場合もチケット番号表記を検索ワードにする
          parser.searchWordsW.push(['#'+obj.journalized_id.to_s]);
        else
          # チケットでもWikiでもない場合はどうしていいかわからないので帰る。
          return;
        end
      end
      
      @query = parser.query @project

      extend SortHelper
      extend QueriesHelper
      extend IssuesHelper
      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria);
      sort_update(@query.sortable_columns);
      @issue_count_by_group = @query.issue_count_by_group;

      parser.searchWordsS.each do |words|
        @query.add_filter("subject","~", words)
      end

      parser.searchWordsD.each do |words|
        @query.add_filter("description","~", words)
      end

      parser.searchWordsW.each do |words|
        @query.add_filter("subjectdescription","~", words)
      end
      
      @query.column_names = parser.columns unless parser.columns.empty?

      @issues = @query.issues(:order => sort_clause, 
                              :include => [:assigned_to, :tracker, :priority, :category, :fixed_version]);
      
      disp = context_menu(issues_context_menu_path);
      disp << render(:partial => 'issues/list', :locals => {:issues => @issues, :query => @query});

      return disp;
    end
  end
end
