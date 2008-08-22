# == Schema Information
# Schema version: 20080702052142
#
# Table name: open_ids
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class OpenId < ActiveRecord::Base
  validates_presence_of     :url
  validates_uniqueness_of   :url, :case_sensitive => false

  belongs_to :user #, :class_name => "User", :foreign_key => "user_id"

  protected

  def validate
    begin
      if self.url
        # 将unicode字符编码URI为符合IDN标准的ascii punycode URI
        idn = "http://" + Idna.toASCII(self.url.gsub(/[a-zA-Z]+:\/\//,''))
        # 将OpenID标准化
        self.url= OpenIdAuthentication.normalize_url(idn)
      end
    rescue
      errors.add :url, '(OpenID) invalid! It should be a normal URI.'
    end
  end
  
end
