# To change this template, choose Tools | Templates
# and open the template in the editor.

module WikiExtensions
  module RefIssues
    class Parser
      COLUMNS = [:project, :tracker, :parent, :status, :priority, :subject,
        :author, :assigned_to, :updated_on, :category, :fixed_version, 
        :start_date, :due_date, :estimated_hours, :done_ratio, :created_on]
      
      attr_reader :searchWordsS, :searchWordsD, :searchWordsW, :columns,
        :customQueryName, :customQueryId
      def initialize(args = nil)
        parse_args args if args
      end
      
      def parse_args(args)
        args ||= []
        @searchWordsS = []
        @searchWordsD = []
        @searchWordsW = []
        @columns = []
        args.each do |arg|
          arg.strip!;
          if arg=~/^\-([^\=]*)(\=.*)?$/
            case $1
            when 's','sw','Dw','sDw','Dsw'              
              @searchWordsS.push get_words(arg)
            when 'd','dw','Sw','Sdw','dSw'             
              @searchWordsD.push get_words(arg)
            when 'w','sdw'              
              @searchWordsW.push get_words(arg)
            when 'q'
              if arg=~/^[^\=]+\=(.*)$/
                @customQueryName = $1;
              else
                raise "no CustomQuery name:#{arg}"
              end
            when 'i'
              if arg=~/^[^\=]+\=(.*)$/
                @customQueryId = $1;
              else
                raise "no CustomQuery ID:#{arg}"
              end
            when 'p'
              @flgSameProject = true;
            else
              raise "unknown option:#{arg}"
            end
          else
            @columns << get_column(arg)            
          end
        end        
      end
      
      def same_project?
        @flgSameProject == true
      end
      
      def has_serch_conditions?
        return true if @customQueryId
        return true if @customQueryName 
        return true if @searchWordsS and !@searchWordsS.empty?
        return true if @searchWordsD and !@searchWordsD.empty?
        return true if @searchWordsW and !@searchWordsW.empty?
        false
      end
      
      def query(project)
        # オプションにカスタムクエリがあればカスタムクエリを名前から取得
        if @customQueryId
          @query = Query.find_by_id(@customQueryId);
          @query = nil if !@query.visible?
          raise "can not find CustomQuery ID:'#{@customQueryId}'" if !@query;
        elsif @customQueryName then
          cond = "project_id IS NULL"
          cond << " OR project_id = #{project.id}" if project
          cond = "(#{cond}) AND name = '#{@customQueryName}'";
          @query = Query.find(:first, :conditions=>cond+" AND user_id=#{User.current.id}")
          @query = Query.find(:first, :conditions=>cond+" AND is_public=TRUE") if !@query
          raise "can not find CustomQuery Name:'#{@customQueryName}'" if !@query;
        else
          @query = Query.new(:name => "_", :filters => {});
        end
      
        # Queryモデルを拡張
        overwrite_sql_for_field(@query);
        @query.available_filters["description"] = { :type => :text, :order => 8 };
        @query.available_filters["subjectdescription"] = { :type => :text, :order => 8 };

        if same_project?
          @query.project = project;
        end
        
        @query
      end
        
      private
        
      def get_words(arg)
        if arg=~/^[^\=]+\=(.*)$/
          $1.split('|')
        else
          raise "need words divided by '|':#{arg}>"
        end
      end
      
      def get_column(name)
        name_sym = name.to_sym
        return name_sym if COLUMNS.include?(name_sym)
        return :assigned_to if name_sym == :assigned
        return :updated_on if name_sym == :updated
        return :created_on if name_sym == :created
        raise "unknown column:#{name}"
      end
      
      def overwrite_sql_for_field(query)
        def query.sql_for_field(field, operator, value, db_table, db_field, is_custom_filter=false)
          sql = ''
          case operator
          when "="
            if value.any?
              case type_for(field)
              when :date, :date_past
                sql = date_clause(db_table, db_field, (Date.parse(value.first) rescue nil), (Date.parse(value.first) rescue nil))
              when :integer
                sql = "#{db_table}.#{db_field} = #{value.first.to_i}"
              when :float
                sql = "#{db_table}.#{db_field} BETWEEN #{value.first.to_f - 1e-5} AND #{value.first.to_f + 1e-5}"
              else
                sql = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
              end
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
            if [:date, :date_past].include?(type_for(field))
              sql = date_clause(db_table, db_field, (Date.parse(value.first) rescue nil), nil)
            else
              if is_custom_filter
                sql = "CAST(#{db_table}.#{db_field} AS decimal(60,3)) >= #{value.first.to_f}"
              else
                sql = "#{db_table}.#{db_field} >= #{value.first.to_f}"
              end
            end
          when "<="
            if [:date, :date_past].include?(type_for(field))
              sql = date_clause(db_table, db_field, nil, (Date.parse(value.first) rescue nil))
            else
              if is_custom_filter
                sql = "CAST(#{db_table}.#{db_field} AS decimal(60,3)) <= #{value.first.to_f}"
              else
                sql = "#{db_table}.#{db_field} <= #{value.first.to_f}"
              end
            end
          when "><"
            if [:date, :date_past].include?(type_for(field))
              sql = date_clause(db_table, db_field, (Date.parse(value[0]) rescue nil), (Date.parse(value[1]) rescue nil))
            else
              if is_custom_filter
                sql = "CAST(#{db_table}.#{db_field} AS decimal(60,3)) BETWEEN #{value[0].to_f} AND #{value[1].to_f}"
              else
                sql = "#{db_table}.#{db_field} BETWEEN #{value[0].to_f} AND #{value[1].to_f}"
              end
            end
          when "o"
            sql = "#{IssueStatus.table_name}.is_closed=#{connection.quoted_false}" if field == "status_id"
          when "c"
            sql = "#{IssueStatus.table_name}.is_closed=#{connection.quoted_true}" if field == "status_id"
          when ">t-"
            sql = relative_date_clause(db_table, db_field, - value.first.to_i, 0)
          when "<t-"
            sql = relative_date_clause(db_table, db_field, nil, - value.first.to_i)
          when "t-"
            sql = relative_date_clause(db_table, db_field, - value.first.to_i, - value.first.to_i)
          when ">t+"
            sql = relative_date_clause(db_table, db_field, value.first.to_i, nil)
          when "<t+"
            sql = relative_date_clause(db_table, db_field, 0, value.first.to_i)
          when "t+"
            sql = relative_date_clause(db_table, db_field, value.first.to_i, value.first.to_i)
          when "t"
            sql = relative_date_clause(db_table, db_field, 0, 0)
          when "w"
            first_day_of_week = l(:general_first_day_of_week).to_i
            day_of_week = Date.today.cwday
            days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
            sql = relative_date_clause(db_table, db_field, - days_ago, - days_ago + 6)
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
          else
            raise "Unknown query operator #{operator}"
          end

          return sql
        end
      end
    end    
  end
end
