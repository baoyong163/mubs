# == Schema Information
# Schema version: 20080702052142
#
# Table name: sites
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  states     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Site < ActiveRecord::Base

end
