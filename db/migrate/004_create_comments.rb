class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :article_id, :permission, :commenter_id
      t.string  :title, :author,  :ip_address,  :email, :website
      t.text    :body,  :body_html
      t.boolean :allow_smile, :show_signature,  :default => true
      t.boolean :is_draft, :default => false
      t.timestamps
    end
  end
  
  # def self.up
  #   create_table :comments do |t|
  #     t.integer :thread_id, :parent_id, :permission, :rank, :commenter_id,
  #     :adver,     :copyright, :recommend, :lft, :rgt
  #     t.integer :attitude,  :reply_count,   :default => 0
  #     t.integer :view_count,  :default => 1
  #     t.string  :title, :author,  :ip_address,  :limit => 40
  #     t.text    :digest,  :body,  :body_html, :extended,  :excerpt, :extended_html
  #     t.string  :text_filter, :permalink, :article_password,
  #     :cached_category_id_list, :cached_category_name_list
  #     t.boolean :allow_reply, :published, :allow_smile, :show_signature,  :default => true
  #     t.boolean :allow_ping, :is_reply,  :is_draft,  :infraction,  :default => false
  #     t.timestamps
  #     t.column  :published_at,  :datetime
  #   end
  #   add_index :articles,  :permalink
  # end

  def self.down
    drop_table :comments
  end
end
