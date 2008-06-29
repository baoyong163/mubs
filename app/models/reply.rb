class Reply < ActiveRecord::Base
  self.table_name="articles"

  validates_presence_of :body

  acts_as_taggable

  belongs_to :article,
             :class_name => "Article",
             :foreign_key => "parent_id",:conditions => "is_reply is true"

  def self.find_new(per)
    self.find(:all,:limit => per,:conditions => {:is_reply => TRUE}, :order => "created_at DESC")
  end
end
