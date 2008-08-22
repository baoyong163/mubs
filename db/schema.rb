# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080822085511) do

  create_table "articles", :force => true do |t|
    t.integer  "thread_id"
    t.integer  "parent_id"
    t.integer  "permission"
    t.integer  "rank"
    t.integer  "adver"
    t.integer  "copyright"
    t.integer  "recommend"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "attitude",                                 :default => 0
    t.integer  "reply_count",                              :default => 0
    t.integer  "view_count",                               :default => 1
    t.string   "title",                     :limit => 40
    t.string   "author",                    :limit => 40
    t.string   "ip_address",                :limit => 40
    t.text     "digest"
    t.text     "body"
    t.text     "body_html"
    t.text     "extended"
    t.text     "excerpt"
    t.text     "extended_html"
    t.string   "text_filter"
    t.string   "permalink"
    t.string   "article_password"
    t.string   "cached_category_id_list"
    t.string   "cached_category_name_list"
    t.boolean  "allow_reply",                              :default => true
    t.boolean  "published",                                :default => true
    t.boolean  "allow_smile",                              :default => true
    t.boolean  "show_signature",                           :default => true
    t.boolean  "allow_ping",                               :default => false
    t.boolean  "is_reply",                                 :default => false
    t.boolean  "is_draft",                                 :default => false
    t.boolean  "infraction",                               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "cached_tag_list",           :limit => 512
  end

  add_index "articles", ["permalink"], :name => "index_articles_on_permalink"

  create_table "articles_blogs", :id => false, :force => true do |t|
    t.integer "article_id"
    t.integer "blog_id"
  end

  add_index "articles_blogs", ["article_id", "blog_id"], :name => "index_articles_blogs_on_article_id_and_blog_id"
  add_index "articles_blogs", ["blog_id"], :name => "index_articles_blogs_on_blog_id"

  create_table "blogs", :force => true do |t|
    t.string   "name",        :limit => 40
    t.string   "subtitle",    :limit => 40
    t.integer  "status"
    t.integer  "rank"
    t.integer  "permission"
    t.integer  "adver"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subdomain",   :limit => 40
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "image"
    t.string   "description"
    t.integer  "parent_id"
    t.integer  "tree_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "color",       :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "commenters", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "remember_token"
    t.string   "activation_code",           :limit => 40
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "state",                                   :default => "passive", :null => false
    t.datetime "remember_token_expires_at"
    t.datetime "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "activated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "article_id"
    t.integer  "permission"
    t.integer  "commenter_id"
    t.string   "title"
    t.string   "author"
    t.string   "ip_address"
    t.string   "email"
    t.string   "website"
    t.text     "body"
    t.text     "body_html"
    t.boolean  "allow_smile",    :default => true
    t.boolean  "show_signature", :default => true
    t.boolean  "is_draft",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "globalize_countries", :force => true do |t|
    t.string "code",                   :limit => 2
    t.string "english_name"
    t.string "date_format"
    t.string "currency_format"
    t.string "currency_code",          :limit => 3
    t.string "thousands_sep",          :limit => 2
    t.string "decimal_sep",            :limit => 2
    t.string "currency_decimal_sep",   :limit => 2
    t.string "number_grouping_scheme"
  end

  add_index "globalize_countries", ["code"], :name => "index_globalize_countries_on_code"

  create_table "globalize_languages", :force => true do |t|
    t.string  "iso_639_1",             :limit => 2
    t.string  "iso_639_2",             :limit => 3
    t.string  "iso_639_3",             :limit => 3
    t.string  "rfc_3066"
    t.string  "english_name"
    t.string  "english_name_locale"
    t.string  "english_name_modifier"
    t.string  "native_name"
    t.string  "native_name_locale"
    t.string  "native_name_modifier"
    t.boolean "macro_language"
    t.string  "direction"
    t.string  "pluralization"
    t.string  "scope",                 :limit => 1
  end

  add_index "globalize_languages", ["iso_639_1"], :name => "index_globalize_languages_on_iso_639_1"
  add_index "globalize_languages", ["iso_639_2"], :name => "index_globalize_languages_on_iso_639_2"
  add_index "globalize_languages", ["iso_639_3"], :name => "index_globalize_languages_on_iso_639_3"
  add_index "globalize_languages", ["rfc_3066"], :name => "index_globalize_languages_on_rfc_3066"

  create_table "globalize_translations", :force => true do |t|
    t.string  "type"
    t.string  "tr_key"
    t.string  "table_name"
    t.integer "item_id"
    t.string  "facet"
    t.boolean "built_in"
    t.integer "language_id"
    t.integer "pluralization_index"
    t.text    "text"
    t.string  "namespace"
  end

  add_index "globalize_translations", ["tr_key", "language_id"], :name => "index_globalize_translations_on_tr_key_and_language_id"
  add_index "globalize_translations", ["table_name", "item_id", "language_id"], :name => "globalize_translations_table_name_and_item_and_language"

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "blog_id"
    t.string   "role"
    t.string   "permission"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["blog_id", "user_id"], :name => "index_memberships_on_blog_id_and_user_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url",                 :null => false
    t.string  "handle",     :default => "", :null => false
    t.binary  "secret",                     :null => false
    t.integer "issued",                     :null => false
    t.integer "lifetime",                   :null => false
    t.string  "assoc_type", :default => "", :null => false
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",                  :null => false
    t.string  "server_url"
    t.string  "salt",       :default => "", :null => false
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "server_url", :default => "", :null => false
    t.integer "timestamp",                  :null => false
    t.string  "salt",       :default => "", :null => false
  end

  create_table "open_ids", :force => true do |t|
    t.integer  "user_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "article_id"
    t.string   "role"
    t.string   "permission"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participations", ["article_id", "user_id"], :name => "index_participations_on_article_id_and_user_id"
  add_index "participations", ["user_id"], :name => "index_participations_on_user_id"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "states"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "remember_token"
    t.string   "friends_ids"
    t.string   "name",                      :limit => 40
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.integer  "group_id"
    t.integer  "local"
    t.integer  "avatar_id"
    t.integer  "blog_id"
    t.datetime "remember_token_expires_at"
    t.datetime "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.string   "activation_code",           :limit => 40
    t.string   "state",                                   :default => "passive"
    t.string   "time_zone",                 :limit => 40, :default => "UTC"
    t.string   "subdomain",                 :limit => 40
    t.string   "password_reset_code",       :limit => 40
  end

end
