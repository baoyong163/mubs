# == Schema Information
# Schema version: 20080702052142
#
# Table name: categories
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  image       :string(255)
#  description :string(255)
#  parent_id   :integer(4)
#  tree_id     :integer(4)
#  lft         :integer(4)
#  rgt         :integer(4)
#  color       :string(16)
#  created_at  :datetime
#  updated_at  :datetime
#

class Category < ActiveRecord::Base
  acts_as_nested_set :scope => :tree_id
  has_and_belongs_to_many(:articles,:order => "published_at DESC, created_at DESC",:uniq => true)
  has_and_belongs_to_many :lists, :order => :position 

  validates_presence_of :name
  validates_uniqueness_of :name, :on => :create

  def leaf?  
    if self.rgt - self.lft == 1  
      return true  
    else  
      return false  
    end   
  end

end
