require 'redmine'

module WikiExtensionsRefIssue
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a list of referer issues."
    macro :ref_issues do |obj, args|
      flgSameProject = false;
      searchWordsS = [];
      searchWordsD = [];
      searchWordsW = [];
      customQueryId = nil;
      customQueryName = nil;

      # 引数をパース
      columns = [];
      begin
        args.each do |arg|
          arg.strip!;
          if arg=~/^\-([^\=]*)(\=.*)?$/ then # オプション表記発見
            case $1
            when 's','sw','Dw','sDw','Dsw'
              searchWordsS.push WikiExtensionsRefIssue.getWords(arg)
            when 'd','dw','Sw','Sdw','dSw'
              searchWordsD.push WikiExtensionsRefIssue.getWords(arg)
            when 'w','sdw'
              searchWordsW.push WikiExtensionsRefIssue.getWords(arg)
            when 'q'
              if arg=~/^[^\=]+\=(.*)$/ then
                customQueryName = $1;
              else
                raise "no CustomQuery name:#{arg}"
              end
            when 'i'
              if arg=~/^[^\=]+\=(.*)$/ then
                customQueryId = $1;
              else
                raise "no CustomQuery ID:#{arg}"
              end
            when 'p'
              flgSameProject = true;
            else
              raise "unknown option:#{arg}"
            end
          else
            case arg
            when 'project'
              columns.push(:project);
            when 'tracker'
              columns.push(:tracker);
            when 'parent'
              columns.push(:parent);
            when 'status'
              columns.push(:status);
            when 'priority'
              columns.push(:priority);
            when 'subject'
              columns.push(:subject);
            when 'author'
              columns.push(:author);
            when 'assigned_to', 'assigned'
              columns.push(:assigned_to);
            when 'updated_on', 'updated'
              columns.push(:updated_on);
            when 'category'
              columns.push(:category);
            when 'fixed_version'
              columns.push(:fixed_version);
            when 'start_date'
              columns.push(:start_date);
            when 'due_date'
              columns.push(:due_date);
            when 'estimated_hours'
              columns.push(:estimated_hours);
            when 'done_ratio'
              columns.push(:done_ratio);
            when 'created_on', 'created'
              columns.push(:created_on);
            else
              raise "unknown column:#{arg}"
            end
          end
        end
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

      if customQueryId==nil && 
          customQueryName==nil &&
          searchWordsS.size==0 &&
          searchWordsD.size==0 &&
          searchWordsW.size==0 then # 検索条件がなにもなかったら
        # 検索するキーワードを取得する
        if obj.class == WikiContent then # Wikiの場合はページ名および別名を検索ワードにする
          words = []
          words.push(obj.page.title); #ページ名
          redirects = WikiRedirect.find(:all, :conditions=>["redirects_to=:s", {:s=>obj.page.title}]); #別名query
          redirects.each do |redirect|
            words.push(redirect.title); #別名
          end
          searchWordsW.push(words)
        elsif obj.class == Issue then # チケットの場合はチケット番号表記を検索ワードにする
          searchWordsW.push(['#'+obj.id.to_s]);
        elsif obj.class == Journal && obj.journalized_type == "Issue" then
          # チケットコメントの場合もチケット番号表記を検索ワードにする
          searchWordsW.push(['#'+obj.journalized_id.to_s]);
        else
          # チケットでもWikiでもない場合はどうしていいかわからないので帰る。
          return;
        end
      end
      
      # オプションにカスタムクエリがあればカスタムクエリを名前から取得
      if customQueryId then
        @query = Query.find_by_id(customQueryId);
        @query = nil if !@query.visible?
        raise "can not find CustomQuery ID:'#{customQueryId}'" if !@query;
      elsif customQueryName then
        cond = "project_id IS NULL"
        cond << " OR project_id = #{@project.id}" if @project
        cond = "(#{cond}) AND name = '#{customQueryName}'";
        @query = Query.find(:first, :conditions=>cond+" AND user_id=#{User.current.id}")
        @query = Query.find(:first, :conditions=>cond+" AND is_public=TRUE") if !@query
        raise "can not find CustomQuery Name:'#{customQueryName}'" if !@query;
      else
        @query = Query.new(:name => "_", :filters => {});
      end
      
      # Queryモデルを拡張
      WikiExtensionsRefIssue.overwrite_sql_for_field(@query);
      @query.available_filters["description"] = { :type => :text, :order => 8 };
      @query.available_filters["subjectdescription"] = { :type => :text, :order => 8 };

      if flgSameProject then
        @query.project = @project;
      end

      extend SortHelper
      extend QueriesHelper
      extend IssuesHelper
      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria);
      sort_update(@query.sortable_columns);
      @issue_count_by_group = @query.issue_count_by_group;

      searchWordsS.each do |words|
        @query.add_filter("subject","~", words)
      end

      searchWordsD.each do |words|
        @query.add_filter("description","~", words)
      end

      searchWordsW.each do |words|
        @query.add_filter("subjectdescription","~", words)
      end

      if !columns.empty? then
        @query.column_names = columns;
      end

      @issues = @query.issues(:order => sort_clause, 
                              :include => [:assigned_to, :tracker, :priority, :category, :fixed_version]);
      
      disp = context_menu(issues_context_menu_path);
      disp << render(:partial => 'issues/list', :locals => {:issues => @issues, :query => @query});

      return disp;
    end
  end

  def WikiExtensionsRefIssue.overwrite_sql_for_field(query)
    def query.sql_for_field(field, operator, value, db_table, db_field, is_custom_filter=false);
      sql = ''
      case operator
      when "="
        if value.any?
          sql = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
        else
          # IN an empty set
          sql = "1=0"
        end
      when "!"
        if value.any?
          sql = "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
        else
          # NOT IN an empty set
          sql = "1=1"
        end
      when "!*"
        sql = "#{db_table}.#{db_field} IS NULL"
        sql << " OR #{db_table}.#{db_field} = ''" if is_custom_filter
      when "*"
        sql = "#{db_table}.#{db_field} IS NOT NULL"
        sql << " AND #{db_table}.#{db_field} <> ''" if is_custom_filter
      when ">="
        sql = "#{db_table}.#{db_field} >= #{value.first.to_i}"
      when "<="
        sql = "#{db_table}.#{db_field} <= #{value.first.to_i}"
      when "o"
        sql = "#{IssueStatus.table_name}.is_closed=#{connection.quoted_false}" if field == "status_id"
      when "c"
        sql = "#{IssueStatus.table_name}.is_closed=#{connection.quoted_true}" if field == "status_id"
      when ">t-"
        sql = date_range_clause(db_table, db_field, - value.first.to_i, 0)
      when "<t-"
        sql = date_range_clause(db_table, db_field, nil, - value.first.to_i)
      when "t-"
        sql = date_range_clause(db_table, db_field, - value.first.to_i, - value.first.to_i)
      when ">t+"
        sql = date_range_clause(db_table, db_field, value.first.to_i, nil)
      when "<t+"
        sql = date_range_clause(db_table, db_field, 0, value.first.to_i)
      when "t+"
        sql = date_range_clause(db_table, db_field, value.first.to_i, value.first.to_i)
      when "t"
        sql = date_range_clause(db_table, db_field, 0, 0)
      when "w"
        first_day_of_week = l(:general_first_day_of_week).to_i
        day_of_week = Date.today.cwday
        days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
        sql = date_range_clause(db_table, db_field, - days_ago, - days_ago + 6)
      when "~" # monkey patched for ref_issues: originally treat single value  -> extend multiple value
        if db_field=='subjectdescription' then
          sql = "(";
          value.each do |v|
            sql << " OR " if sql != "(";
            sql << "LOWER(#{db_table}.subject) LIKE '%#{connection.quote_string(v.to_s.downcase)}%'";
            sql << " OR LOWER(#{db_table}.description) LIKE '%#{connection.quote_string(v.to_s.downcase)}%'";
          end
          sql << ")";
        else
          sql = "(";
          value.each do |v|
            sql << " OR " if sql != "(";
            sql << "LOWER(#{db_table}.#{db_field}) LIKE '%#{connection.quote_string(v.to_s.downcase)}%'";
          end
          sql << ")";
        end
      when "!~"
        sql = "LOWER(#{db_table}.#{db_field}) NOT LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
      end
      return sql
    end
  end

  def WikiExtensionsRefIssue.getWords(arg)
    if arg=~/^[^\=]+\=(.*)$/ then
      $1.split('|')
    else
      raise "need words divided by '|':#{arg}>"
    end
  end
end
