class CacheArticleTagList < ActiveRecord::Migration
  def self.up
    # You should make sure that the column is long enough to hold
    # the full tag list. In some situations the :text type may be more appropriate.
    add_column :articles, :cached_tag_list, :string, :limit => 512
  end

  def self.down
    remove_column :articles, :cached_tag_list
  end
end
