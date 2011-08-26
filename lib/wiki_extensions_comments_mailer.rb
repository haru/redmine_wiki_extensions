require 'mailer'

class WikiExtensionsCommentsMailer < Mailer
  # Modifiyng view paths to make our mail-views visible for plugin
  self.instance_variable_get("@inheritable_attributes")[:view_paths] << RAILS_ROOT + "/vendor/plugins/redmine_wiki_extensions/app/views" 

  def wiki_commented(comment, wiki_page)
    project = wiki_page.project
    author = comment.user
    text = comment.comment
    redmine_headers 'Project' => project,
                    'Wiki-Page-Id' => wiki_page.id,
                    'Author' => author
    message_id wiki_page
    # Send notification to watchers of wiki page
    recipients wiki_page.watchers.collect{|watcher| watcher.user.mail}
    subject "[#{project.name} - Wiki - #{wiki_page.title}] commented"
    body = {
      :project => project,
      :author => author,
      :text => text,
      :wiki_page_title => wiki_page.title,
      :wiki_page_url => url_for(:controller => 'wiki', :action => 'show', :project_id => project, :id => wiki_page.title)
    }
    render_multipart('wiki_commented', body)
  end
end
