class Blog < ActiveRecord::Base
  has_and_belongs_to_many  :articles
  has_many :memberships
  has_many :users, :through => :memberships
  
  def new_articles
    self.articles.find(:all, :limit => 15, :order => "created_at DESC")
  end
  
end
