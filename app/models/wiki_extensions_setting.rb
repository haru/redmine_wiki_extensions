class WikiExtensionsSetting < ActiveRecord::Base
  belongs_to :project

  def self.find_or_create(pj_id)
    setting = WikiExtensionsSetting.find(:first, :conditions => ['project_id = ?', pj_id])
    unless setting
      setting = WikiExtensionsSetting.new
      setting.project_id = pj_id
      setting.save!      
    end
    5.times do |i|
      WikiExtensionsMenu.find_or_create(pj_id, i + 1)
    end
    return setting
  end

  def menus
    WikiExtensionsMenu.find(:all, :conditions => ['project_id = ?', project_id], :order => 'menu_no')
  end
end
