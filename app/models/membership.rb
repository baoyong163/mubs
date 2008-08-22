# == Schema Information
# Schema version: 20080702052142
#
# Table name: memberships
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  blog_id    :integer(4)
#  role       :string(255)
#  permission :string(255)
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Membership < ActiveRecord::Base
  
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :blog, :class_name => "Blog", :foreign_key => "blog_id"
end
