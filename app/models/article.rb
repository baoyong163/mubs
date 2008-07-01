class Article < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :body
  validates_uniqueness_of :title

  acts_as_taggable
  
  has_and_belongs_to_many :blogs
  has_many :participations
  has_many :users, :through => :participations
  has_many :replies,
           :class_name  => "Article",
           :foreign_key => "parent_id"
  has_many :comments
  
  named_scope :recent, :limit => 15, :order => "created_at DESC"
    
  def self.find_new(per)
    self.find(:all, :limit => per, 
              :conditions => ['parent_id is null'],
              :order => "created_at DESC")
  end
  
  def view!
    self.class.increment_counter :view_count, id
  end
  
  def reply_count!
    self.class.increment_counter :reply_count, id
    # self.reply_count = self.replies.size+1
  end
  
end
