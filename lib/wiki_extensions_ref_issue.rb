require 'redmine'

module WikiExtensionsRefIssue
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a list of referer issues."
    macro :ref_issues do |obj, args|
      # Wikiページ名および別名をtitlesに取得
      titles = [ obj.page.title ]; #本名
      redirects = WikiRedirect.find(:all, :conditions=>["redirects_to=:s", {:s=>obj.page.title}]); #別名query
      redirects.each do |redirect|
        titles.push(redirect.title); #別名
      end
      
      # 本Wikiページへの参照を持つIssueをdispIssuesに取得
      dispIssues = {};
      titles.each do |title|
        # ページ名を説明に含むIssueを抽出
        issues = Issue.find(:all, :conditions=>["description~*:s", {:s=>title}]);
        issues.each do |issue|
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
              refTitle=$2;
            else
              # プロジェクト指定が無い場合
              refPrj=issue.project.identifier;
              refTitle=ref;
            end
            if refPrj==obj.project.identifier || refPrj==obj.project.name then
              # プロジェクトが一致
              if refTitle.downcase==title.downcase then
                # 且つ Wikiタイトルが一致ならば
                dispIssues[issue.id] = issue; # そのIssueを表示する
              end
            end
          end
        end
      end
      
      # チケットリスト表示HTMLの作成
      disp = '<table>';
      # ヘッダ行
      disp << '<tr><th>No.</th>';
      args.each do |colum|
        # パラメータから表示列を取得
        disp << "<th>#{colum}</th>";
      end
      disp << '</tr>';
      
      # Issueの内容を表示
      dispIssues.sort.each do |key, issue|
        disp << '<tr>';
        # Issue番号
        disp << '<td>';
        disp << link_to("##{issue.id}",
                        {:controller => "issues", :action => "show", :id => issue}, 
                        :class => issue.css_classes);
        disp << '</td>';
        # パラメータに応じて列表示を構成
        args.each do |colum|
          case colum
          when 'project'
            disp << '<td>' << issue.project.name << '</td>';
          when 'tracker'
            disp << '<td>' << issue.tracker.name << '</td>';
          when 'subject'
            disp << '<td>';
            disp << link_to("#{issue.subject}",
                            {:controller => "issues", :action => "show", :id => issue}, 
                            :class => issue.css_classes) << '</td>';
            disp << '</td>';
          when 'status'
            disp << '<td>' << issue.status.name << '</td>';
          when 'author'
            disp << '<td>';
            disp << link_to_user(issue.author) if issue.author;
            disp << '</td>';
          when 'assigned_to'
            disp << '<td>';
            disp << link_to_user(issue.assigned_to) if issue.assigned_to;
            disp << '</td>';
          when 'created_on'
            disp << '<td>' << format_date(issue.created_on).to_s << '</td>';
          when 'updated_on'
            disp << '<td>' << format_date(issue.updated_on).to_s << '</td>';
          end
        end
        disp << "</tr>";
      end
      disp << '</table>';
      return disp;
    end
  end
end
