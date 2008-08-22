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

class Reply < ActiveRecord::Base
  self.table_name="articles"

  validates_presence_of :body

  acts_as_taggable

  belongs_to :article,
             :class_name => "Article",
             :foreign_key => "parent_id",
             :conditions => "is_reply is true"

  def self.find_new(per)
    self.find(:all,:limit => per,:conditions => {:is_reply => TRUE}, :order => "created_at DESC")
  end
end
