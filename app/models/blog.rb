# == Schema Information
# Schema version: 20080702052142
#
# Table name: blogs
#
#  id          :integer(4)      not null, primary key
#  name        :string(40)
#  subtitle    :string(40)
#  status      :integer(4)
#  rank        :integer(4)
#  permission  :integer(4)
#  adver       :integer(4)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  subdomain   :string(40)
#

class Blog < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_uniqueness_of :subdomain

  has_and_belongs_to_many  :articles
  has_many :memberships
  has_many :users, :through => :memberships

  def new_articles
    self.articles.find(:all, :limit => 15, :order => "created_at DESC")
  end

  protected

  def validate
    if sub = self.subdomain
      if User.find_by_subdomain(sub)
        errors.add :subdomain, 'has been tanken! Choose another one.'
      end
    end
  end
end
