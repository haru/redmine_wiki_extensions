class WikiExtensionsMenu < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :project_id
  validates_presence_of :menu_no
  validates_uniqueness_of :menu_no, :scope => :project_id
  #validates_uniqueness_of :page_name, :scope => :project_id
  #validates_uniqueness_of :title, :scope => :project_id

  def self.find_or_create(pj_id, no)
    menu = WikiExtensionsMenu.find(:first,
      :conditions => ['project_id = ? and menu_no = ?', pj_id, no])
    unless menu
      menu = WikiExtensionsMenu.new
      menu.project_id = pj_id
      menu.menu_no = no
      menu.enabled = false
      menu.save!
    end
    return menu
  end

  def self.enabled?(pj_id, no)
    begin
      menu = find_or_create(pj_id, no)
      return false if menu.page_name.blank?
      menu.enabled
    rescue
      return false
    end
  end

  def self.title(pj_id, no)
    begin
      menu = find_or_create(pj_id, no)
      return menu.title unless menu.title.blank?
      return menu.page_name unless menu.page_name.blank?
      return nil
    rescue
      return nil
    end
  end

  def validate
    return true unless enabled
    #errors.add("title", "is empty") unless attribute_present?("title")
    #errors.add("page_name", "is empty") unless attribute_present?("page_name")

  end
end
