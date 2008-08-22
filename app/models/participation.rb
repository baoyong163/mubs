# == Schema Information
# Schema version: 20080702052142
#
# Table name: participations
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  article_id :integer(4)
#  role       :string(255)
#  permission :string(255)
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Participation < ActiveRecord::Base
  
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :article, :class_name => "Article", :foreign_key => "article_id"

end
