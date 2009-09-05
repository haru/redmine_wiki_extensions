class WikiExtensionsProjectMenu < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :project_id
  validates_presence_of :menu_no
  validates_uniqueness_of :menu_no, :scope => :project_id
  #validates_uniqueness_of :page_name, :scope => :project_id
  #validates_uniqueness_of :title, :scope => :project_id

  def self.find_or_create(pj_id, no)
    menu = WikiExtensionsProjectMenu.find(:first,
      :conditions => ['project_id = ? and menu_no = ?', pj_id, no])
    unless menu
      menu = WikiExtensionsProjectMenu.new
      menu.project_id = pj_id
      menu.menu_no = no
      menu.enabled = false
      menu.save!
    end
    return menu
  end

  def self.enabled?(pj_id, no)
    menu = find_or_create(pj_id, no)
    menu.enabled
  end

  def self.title(pj_id, no)
    menu = find_or_create(pj_id, no)
    menu.title
  end
end
