# == Schema Information
# Schema version: 20080702052142
#
# Table name: comments
#
#  id             :integer(4)      not null, primary key
#  article_id     :integer(4)
#  permission     :integer(4)
#  commenter_id   :integer(4)
#  title          :string(255)
#  author         :string(255)
#  ip_address     :string(255)
#  email          :string(255)
#  website        :string(255)
#  body           :text
#  body_html      :text
#  allow_smile    :boolean(1)      default(TRUE)
#  show_signature :boolean(1)      default(TRUE)
#  is_draft       :boolean(1)
#  created_at     :datetime
#  updated_at     :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :article
end
