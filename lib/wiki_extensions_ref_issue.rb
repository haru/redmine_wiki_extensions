require 'redmine'

module WikiExtensionsRefIssue
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a list of referer issues."
    macro :ref_issues do |obj, args|
      flgSameProject = false;
      searchWords = [];
      flgSearchSubject = nil;
      flgSearchDescription = nil;

      # 引数をパース
      columns = [];
      args.each do |arg|
        arg.strip!;
        if arg=~/^\-([^\=]*)(\=.*)?$/ then # オプション表記発見
          options = $1;
          options.each_byte do |c|
            case c.chr
            when 'S'
              flgSearchSubject = false;
            when 's'
              flgSearchSubject = true;
            when 'D'
              flgSearchDescription = false;
            when 'd'
              flgSearchDescription = true;
            when 'p'
              flgSameProject = true;
            when 'w'
              if arg=~/^[^\=]+\=(.*)$/ then
                searchWords.push($1);
              else
                raise "no search word:#{arg}<br>"+
                "ex. -w=SEARCH_WORD";
              end
            when 'q'
              if arg=~/^[^\=]+\=(.*)$/ then
                @customQuery = $1;
                if flgSearchSubject == nil then
                  flgSearchSubject = false;
                end
                if flgSearchDescription==nil then
                  flgSearchDescription = false;
                end
              else
                raise "no search word:#{arg}<br>"+
                "ex. -w=SEARCH_WORD";
              end
            else
              raise "unknown option:#{arg}<br>"+
              "[optins]<br>"+
              "-S : not search word in subject<br>"+
              "-s : search word in subject<br>"+
              "-D : not search word in description<br>"+
              "-d : search word in description<br>"+
              "-p : restrict project<br>"+
              "-w=[search word]: specify search word<br>"+
              "-q=[custom query name]: specify custom query";
            end
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
            raise "unknown column:#{arg}<br>";
          end
        end
      end

      if flgSearchSubject==nil then
        flgSearchSubject = true;
      end
      if flgSearchDescription==nil then
        flgSearchDescription = true;
      end

      # オプション指定がなければ検索ワードを抽出
      if searchWords.empty? then # 検索ワードの指定が無かったら
        # 検索するキーワードを取得する
        if obj.class == WikiContent then # Wikiの場合はページ名および別名を検索ワードにする
          searchWords.push(obj.page.title); #ページ名
          redirects = WikiRedirect.find(:all, :conditions=>["redirects_to=:s", {:s=>obj.page.title}]); #別名query
          redirects.each do |redirect|
            searchWords.push(redirect.title); #別名
          end
        elsif obj.class == Issue then # チケットの場合はチケット番号表記を検索ワードにする
          searchWords.push('#'+obj.id.to_s);
        elsif obj.class == Journal && obj.journalized_type == "Issue" then
          # チケットコメントの場合もチケット番号表記を検索ワードにする
          searchWords.push('#'+obj.journalized_id.to_s);
        else
          # チケットでもWikiでもない場合はどうしていいかわからないので帰る。
          return;
        end
      end

      extend SortHelper
      extend QueriesHelper
      extend IssuesHelper

      if defined?(@customQuery) then
        cond = "project_id IS NULL"
        cond << " OR project_id = #{@project.id}" if @project
        cond = "(#{cond}) AND name = '#{@customQuery}'";
        @query = Query.find(:first, :conditions=>cond);
      else
        @query = Query.new(:name => "_", :filters => {});
      end
      WikiExtensionsRefIssue.overwrite_sql_for_field(@query);
      WikiExtensionsRefIssue.overwrite_statement(@query);

      if flgSameProject then
        @query.project = @project;
      end

      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria);
      sort_update(@query.sortable_columns);

      if flgSearchSubject then
        @query.add_filter("subject", "~", searchWords);
      end

      if flgSearchDescription then
        @query.available_filters["description"] = { :type => :text, :order => 8 };
        @query.add_filter("description", "~", searchWords);
      end

      if !columns.empty? then
        @query.column_names = columns;
      end

      @issues = @query.issues(:order => sort_clause);
      
      disp = context_menu(issues_context_menu_path);
      disp << render(:partial => 'issues/list', :locals => {:issues => @issues, :query => @query});

      return disp;
    end
  end

  def WikiExtensionsRefIssue.overwrite_sql_for_field(query)
    def query.sql_for_field(field, operator, value, db_table, db_field, is_custom_filter=false);
      sql = '';
      case operator
      when "="
        sql = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
      when "!"
        sql = "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
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
        from = l(:general_first_day_of_week) == '7' ?
        # week starts on sunday
        ((Date.today.cwday == 7) ? Time.now.at_beginning_of_day : Time.now.at_beginning_of_week - 1.day) :
        # week starts on monday (Rails default)
        Time.now.at_beginning_of_week
        sql = "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [connection.quoted_date(from), connection.quoted_date(from + 7.days)]
      when "~"
        sql = "(";
        value.each do |v|
          sql << " OR " if sql != "(";
          sql << "LOWER(#{db_table}.#{db_field}) LIKE '%#{connection.quote_string(v.to_s.downcase)}%'";
        end
        sql << ")";
      when "!~"
        sql = "LOWER(#{db_table}.#{db_field}) NOT LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
      end
      return sql
    end
  end

  def WikiExtensionsRefIssue.overwrite_statement(query)
    def query.statement
      # filters clauses
      filters_clauses = []
      filters_key_words = []
      filters.each_key do |field|
        next if field == "subproject_id"
        v = values_for(field).clone
        next unless v and !v.empty?
        operator = operator_for(field)

        # "me" value subsitution
        if %w(assigned_to_id author_id watcher_id).include?(field)
          v.push(User.current.logged? ? User.current.id.to_s : "0") if v.delete("me")
        end

        sql = ''
        if field =~ /^cf_(\d+)$/
          # custom field
          db_table = CustomValue.table_name
          db_field = 'value'
          is_custom_filter = true
          sql << "#{Issue.table_name}.id IN (SELECT #{Issue.table_name}.id FROM #{Issue.table_name} LEFT OUTER JOIN #{db_table} ON #{db_table}.customized_type='Issue' AND #{db_table}.customized_id=#{Issue.table_name}.id AND #{db_table}.custom_field_id=#{$1} WHERE "
          sql << sql_for_field(field, operator, v, db_table, db_field, true) + ')'
        elsif field == 'watcher_id'
          db_table = Watcher.table_name
          db_field = 'user_id'
          sql << "#{Issue.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } (SELECT #{db_table}.watchable_id FROM #{db_table} WHERE #{db_table}.watchable_type='Issue' AND "
          sql << sql_for_field(field, '=', v, db_table, db_field) + ')'
        else
          # regular field
          db_table = Issue.table_name
          db_field = field
          sql << '(' + sql_for_field(field, operator, v, db_table, db_field) + ')'
        end
        if field == 'subject' || field == 'description' then
          filters_key_words << sql;
        else
          filters_clauses << sql
        end

      end if filters and valid?
      
      if !filters_key_words.empty? then
        filters_clauses << '(' + filters_key_words.join(' OR ') + ')';
      end
      return (filters_clauses << project_statement).join(' AND ')
    end
  end
end
