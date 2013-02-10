require 'mailer'

class WikiExtensionsCommentsMailer < Mailer
  def wiki_commented(comment, wiki_page)
    project = wiki_page.project
    author = comment.user
    text = comment.comment
    redmine_headers 'Project' => project,
                    'Wiki-Page-Id' => wiki_page.id,
                    'Author' => author
    message_id wiki_page
    # Send notification to watchers of wiki page
    recipients = wiki_page.watchers.collect { |watcher| watcher.user.mail }

    subject = "[#{project.name} - Wiki - #{wiki_page.title}] commented"

    @project = project
    @author = author
    @text = text
    @wiki_page_title = wiki_page.title
    @wiki_page_url = url_for(:controller => 'wiki', :action => 'show', :project_id => project, :id => wiki_page.title)

    mail :to => recipients,
         :subject => subject

  end
end
