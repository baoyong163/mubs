# == Schema Information
# Schema version: 20080702052142
#
# Table name: articles
#
#  id                        :integer(4)      not null, primary key
#  thread_id                 :integer(4)
#  parent_id                 :integer(4)
#  permission                :integer(4)
#  rank                      :integer(4)
#  adver                     :integer(4)
#  copyright                 :integer(4)
#  recommend                 :integer(4)
#  lft                       :integer(4)
#  rgt                       :integer(4)
#  attitude                  :integer(4)      default(0)
#  reply_count               :integer(4)      default(0)
#  view_count                :integer(4)      default(1)
#  title                     :string(40)
#  author                    :string(40)
#  ip_address                :string(40)
#  digest                    :text
#  body                      :text
#  body_html                 :text
#  extended                  :text
#  excerpt                   :text
#  extended_html             :text
#  text_filter               :string(255)
#  permalink                 :string(255)
#  article_password          :string(255)
#  cached_category_id_list   :string(255)
#  cached_category_name_list :string(255)
#  allow_reply               :boolean(1)      default(TRUE)
#  published                 :boolean(1)      default(TRUE)
#  allow_smile               :boolean(1)      default(TRUE)
#  show_signature            :boolean(1)      default(TRUE)
#  allow_ping                :boolean(1)
#  is_reply                  :boolean(1)
#  is_draft                  :boolean(1)
#  infraction                :boolean(1)
#  created_at                :datetime
#  updated_at                :datetime
#  published_at              :datetime
#  cached_tag_list           :string(512)
#

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
  
  def is_updatable_by(user)
    user.eql?(author)
  end

  def is_deletable_by(user)
    user.eql?(author)
  end

  def self.is_readable_by(user, object = nil)
    true
  end

  def self.is_creatable_by(user)
    user.logged_in?
  end
  
end
