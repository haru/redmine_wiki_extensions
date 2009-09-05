class WikiExtensionsProjectSetting < ActiveRecord::Base
  belongs_to :project

  def self.find_or_create(pj_id)
    setting = WikiExtensionsProjectSetting.find(:first, :conditions => ['project_id = ?', pj_id])
    unless setting
      setting = WikiExtensionsProjectSetting.new
      setting.project_id = pj_id
      setting.save!      
    end
    5.times do |i|
      WikiExtensionsProjectMenu.find_or_create(pj_id, i + 1)
    end
    return setting
  end

  def menus
    WikiExtensionsProjectMenu.find(:all, :conditions => ['project_id = ?', project_id], :order => 'menu_no')
  end
end
