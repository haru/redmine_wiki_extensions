module WikiExtensionsNotifiablePatch
  def self.included(base) # :nodoc:
    @is_wrap = false 
    base.extend NotifiableMethods
    base.class_eval do
      unloadable
      class << self
        if !@is_wrap
          alias_method_chain :all, :wiki_comments
          @is_wrap = true
        end
      end
    end
  end
end

module NotifiableMethods
  def all_with_wiki_comments
    notifications = all_without_wiki_comments
    notifications << Redmine::Notifiable.new('wiki_comment_added')
    notifications
  end
end


