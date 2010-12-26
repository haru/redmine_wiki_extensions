require 'redmine'

module WikiExtensionsRefIssue
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a list of referer issues."
    macro :ref_issues do |obj, args|
      flgNoSubject = false;
      flgNoDescription = false;
      flgLinkOnly = false;
      flgSameProject = false;
      flgReverse = false;
      searchWords = [];
      
      # オプション表記を検索
      args.each do |arg|
        if arg=~/^\-([^\=]*)(\=.*)?$/ then # オプション表記発見
          options = $1;
          options.each_byte do |c|
            case c.chr
            when 'S'
              flgNoSubject = true;
            when 'D'
              flgNoDescription = true;
            when 'l'
              flgLinkOnly = true;
            when 'p'
              flgSameProject = true;
            when 'r'
              flgReverse = true;
            when 'w'
              if arg=~/^[^\=]+\=(.*)$/ then
                searchWords.push($1);
              else
                raise "no search word:#{arg}<br>"+
                      "ex. -w=SEARCH_WORD";
              end
            else
              raise "unknown option:#{arg}<br>"+
                    "[optins]<br>"+
                    "-S : not search subject<br>"+
                    "-D : not search description<br>"+
                    "-l : search only wiki link<br>"+
                    "-p : search in same project<br>"+
                    "-r : sort reverse<br>"+
                    "-w=[search word]: specify search word";
            end
          end
        end
      end
      
      # オプション指定がなければ検索ワードを抽出
      if searchWords.empty? then # 検索ワードの指定が無かったら
        # 検索するキーワードを取得する
        if obj.class == WikiContent then # Wikiの場合はページ名および別名を検索ワードにする
          searchWords = [ obj.page.title ]; #ページ名
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
      
      # 本Wikiページへの参照を持つIssueをdispIssuesに取得
      dispIssues = {};
      searchWords.each do |searchWord|
        # 検索ワードを含むIssueを抽出
        if flgNoSubject then
          if flgNoDescription then
            raise "option error: can not use -S and -D in same time";
          else
            cond = "description~*'#{searchWord}'";
          end
        else
          if flgNoDescription then
            cond = "subject~*'#{searchWord}'";
          else
            cond = "subject~*'#{searchWord}' or description~*'#{searchWord}'";
          end
        end
        if flgSameProject then
          cond = "(#{cond}) and project_id=#{obj.project.id.to_s}";
        end
        
        issues = Issue.find(:all, :conditions=>[cond]);
        issues.each do |issue|
          if flgLinkOnly then
            # Issueの説明に含まれるWikiへの参照[[*]]を抽出
            refs = issue.description.scan(/\[\[(.*)\]\]/);
            refs.each do |ref|
              # 各Wiki参照が当該Wikiページであることを判定
              ref = ref.shift;
              if ref=~/^(.*)\|(.*)$/ then
                # リンク表示文字列指定の場合は文字列指定を削除
                ref=$1;
              end
              if ref=~/^(.*)\:(.*)$/ then
                # プロジェクト指定の場合
                refPrj=$1;
                refKeyword=$2;
              else
                # プロジェクト指定が無い場合
                refPrj=issue.project.identifier;
                refKeyword=ref;
              end
              if refPrj==obj.project.identifier || refPrj==obj.project.name then
                # プロジェクトが一致
                if refKeyword.downcase==searchWord.downcase then
                  # 且つ Wikiタイトルが一致ならば
                  dispIssues[issue.id] = issue; # そのIssueを表示する
                end
              end
            end
          else
            # only wiki linkでなければリンクでなくても表示
            dispIssues[issue.id] = issue; # そのIssueを表示する
          end
        end
      end
      
      # チケットリスト表示HTMLの作成
      disp = '<table>';
      # ヘッダ行
      disp << '<tr><th>No.</th>';
      args.each do |colum|
        # パラメータから表示列を取得
        if colum=~/^[^-]/ then
          disp << "<th>#{colum}</th>";
        end
      end
      disp << '</tr>';
      
      # Issueの内容を表示
      if flgReverse then
        dispLine = dispIssues.sort_by{|k,v| -k};
      else
        dispLine = dispIssues.sort;
      end
      dispLine.each do |key, issue|
        disp << '<tr>';
        # Issue番号
        disp << '<td>';
        disp << link_to("##{issue.id}",
                        {:controller => "issues", :action => "show", :id => issue},:class => issue.css_classes
                       );
        disp << '</td>';
        # パラメータに応じて列表示を構成
        args.each do |colum|
          colum.strip!;
          case colum
          when 'project'
            disp << '<td>' << issue.project.name << '</td>';
          when 'tracker'
              disp << '<td>' << issue.tracker.name << '</td>';
          when 'subject'
            disp << '<td>';
            disp << link_to("#{issue.subject}",
                            {:controller => "issues", :action => "show", :id => issue},:class => issue.css_classes
                           );
            disp << '</td>';
          when 'status'
            disp << '<td>' << issue.status.name << '</td>';
          when 'author'
            disp << '<td>';
            disp << link_to_user(issue.author) if issue.author;
            disp << '</td>';
          when 'assigned_to', 'assigned'
            disp << '<td>';
            disp << link_to_user(issue.assigned_to) if issue.assigned_to;
            disp << '</td>';
          when 'created_on', 'created'
            disp << '<td>' << format_date(issue.created_on).to_s << '</td>';
          when 'updated_on', 'updated'
            disp << '<td>' << format_date(issue.updated_on).to_s << '</td>';
          else
            if colum=~/^[^-]/ then
              raise "unknown column:#{colum}<br>";
            end
          end
        end
        disp << "</tr>";
      end
      disp << '</table>';
      return disp;
    end
  end
end
