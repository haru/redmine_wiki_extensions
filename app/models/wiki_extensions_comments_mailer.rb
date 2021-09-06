require 'mailer'

class WikiExtensionsCommentsMailer < Mailer
  def self.deliver_wiki_commented(comment, wiki_page)
    # Send notification to watchers and author of wiki page
    users = wiki_page.watchers.collect { |watcher|watcher.user} | wiki_page.content.notified_users
    users.each do |user|
      wiki_commented(user, comment, wiki_page).deliver_now
    end
  end

  def wiki_commented(user, comment, wiki_page)
    project = wiki_page.project
    author = comment.user
    text = comment.comment
    redmine_headers 'Project' => project,
                    'Wiki-Page-Id' => wiki_page.id,
                    'Author' => author
    message_id wiki_page

    subject = "[#{project.name} - Wiki - #{wiki_page.title}] commented"

    @project = project
    @author = author
    @text = text
    @wiki_page_title = wiki_page.title
    @wiki_page_url = url_for(:controller => 'wiki', :action => 'show', :project_id => project, :id => wiki_page.title)

    mail :to => user,
         :subject => subject

  end
end
