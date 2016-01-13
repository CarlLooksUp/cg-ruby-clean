# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150206215439) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blog_comments", force: true do |t|
    t.string   "name",       null: false
    t.string   "email",      null: false
    t.string   "website"
    t.text     "body",       null: false
    t.integer  "post_id",    null: false
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blog_comments", ["post_id"], name: "index_blog_comments_on_post_id", using: :btree

  create_table "blog_posts", force: true do |t|
    t.string   "title",                      null: false
    t.text     "body",                       null: false
    t.integer  "blogger_id"
    t.string   "blogger_type"
    t.integer  "comments_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blog_posts", ["blogger_type", "blogger_id"], name: "index_blog_posts_on_blogger_type_and_blogger_id", using: :btree

  create_table "bootsy_image_galleries", force: true do |t|
    t.integer  "bootsy_resource_id"
    t.string   "bootsy_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: true do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "businesses", force: true do |t|
    t.string   "location"
    t.string   "tagline"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "sic_code"
    t.string   "website"
    t.string   "phone"
    t.string   "entity_type"
    t.boolean  "in_use"
    t.date     "date_of_first_use"
    t.string   "plans_for_use"
    t.string   "proof_of_use_filename"
    t.string   "source"
    t.string   "status"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state_code"
    t.string   "zip_code"
    t.string   "full_image_filename"
    t.date     "payment_expire"
    t.string   "serial_number"
    t.integer  "price_tier_id"
    t.boolean  "is_interstate"
    t.string   "operating_region",       default: [],              array: true
    t.date     "planned_date"
    t.integer  "date_of_first_use_mask", default: 0
    t.integer  "planned_date_mask",      default: 0
    t.integer  "state_id"
    t.integer  "source_id"
  end

  add_index "businesses", ["id"], name: "idx_business_id", using: :btree
  add_index "businesses", ["serial_number"], name: "index_businesses_on_serial_number", using: :btree

  create_table "candles", force: true do |t|
    t.string   "description"
    t.string   "company"
    t.string   "collection"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total",      default: 0
  end

  create_table "coupons", force: true do |t|
    t.string  "code"
    t.string  "description"
    t.integer "percent_off"
    t.integer "amount_off"
    t.date    "expiration_date"
    t.integer "number_of_uses"
  end

  add_index "coupons", ["code"], name: "index_coupons_on_code", using: :btree

  create_table "golf_courses", force: true do |t|
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "name_objects", force: true do |t|
    t.string   "name"
    t.integer  "likes"
    t.integer  "nameable_id"
    t.string   "nameable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
    t.tsvector "tsvector_names"
    t.tsvector "name_search"
  end

  add_index "name_objects", ["name"], name: "index_name_objects_on_name", using: :btree
  add_index "name_objects", ["nameable_id", "nameable_type"], name: "index_name_objects_on_nameable_id_and_nameable_type", using: :btree
  add_index "name_objects", ["tsvector_names"], name: "idx_tsvector_test", using: :gin
  add_index "name_objects", ["user_id"], name: "index_name_objects_on_nameable_id", using: :btree

  create_table "price_tiers", force: true do |t|
    t.string   "machine_label"
    t.string   "long_label"
    t.integer  "price"
    t.integer  "months_to_expire"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_label"
    t.boolean  "is_renewal"
  end

  create_table "product_types", force: true do |t|
    t.string   "label"
    t.string   "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unspsc_id"
    t.integer  "ic_id"
  end

  add_index "product_types", ["ancestry"], name: "index_product_types_on_ancestry", using: :btree
  add_index "product_types", ["ic_id"], name: "index_product_types_on_ic_id", using: :btree

  create_table "product_types_products", id: false, force: true do |t|
    t.integer "product_id"
    t.integer "product_type_id"
  end

  add_index "product_types_products", ["product_id"], name: "index_product_types_products_on_product_id", using: :btree
  add_index "product_types_products", ["product_type_id"], name: "index_product_types_products_on_product_type_id", using: :btree

  create_table "products", force: true do |t|
    t.integer  "product_type_id"
    t.integer  "business_id"
    t.string   "logo_image_filename"
    t.string   "product_image_filename"
    t.string   "link"
    t.boolean  "is_service"
    t.text     "description"
    t.date     "date_of_first_use"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "date_of_first_use_mask", default: 0
    t.integer  "cart_id"
    t.string   "business_name"
  end

  create_table "radio_stations", force: true do |t|
    t.string   "call_sign"
    t.string   "frequency"
    t.string   "format"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
  end

  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "ski_areas", force: true do |t|
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", force: true do |t|
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", force: true do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sub_courses", force: true do |t|
    t.string   "course_name"
    t.integer  "golf_course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sub_courses", ["golf_course_id"], name: "index_sub_courses_on_golf_course_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "transactions", force: true do |t|
    t.string   "charge_id"
    t.integer  "amount"
    t.integer  "coupon_id"
    t.integer  "price_tier_id"
    t.integer  "user_id"
    t.integer  "name_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "last_name"
    t.string   "email"
    t.string   "username"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "password_digest"
    t.string   "remember_token"
    t.integer  "beta_id"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "first_name"
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
