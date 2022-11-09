# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_11_06_130542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "career_goals", force: :cascade do |t|
    t.text "description"
    t.bigint "talent_id", null: false
    t.date "target_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bio"
    t.string "pitch"
    t.string "challenges"
    t.text "image_data"
    t.index ["talent_id"], name: "index_career_goals_on_talent_id"
  end

  create_table "career_needs", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "career_goal_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["career_goal_id"], name: "index_career_needs_on_career_goal_id"
  end

  create_table "chats", force: :cascade do |t|
    t.datetime "last_message_at", null: false
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.integer "sender_unread_messages_count", default: 0
    t.integer "receiver_unread_messages_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "last_message_text_ciphertext"
    t.index ["receiver_id"], name: "index_chats_on_receiver_id"
    t.index ["sender_id", "receiver_id"], name: "index_chats_on_sender_id_and_receiver_id", unique: true
    t.index ["sender_id"], name: "index_chats_on_sender_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "post_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "connections", force: :cascade do |t|
    t.string "user_invested_amount"
    t.string "connected_user_invested_amount"
    t.integer "connection_type", null: false
    t.datetime "connected_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "connected_user_id"
    t.index ["connected_user_id"], name: "index_connections_on_connected_user_id"
    t.index ["user_id", "connected_user_id"], name: "index_connections_on_user_id_and_connected_user_id", unique: true
    t.index ["user_id"], name: "index_connections_on_user_id"
    t.check_constraint "user_id <> connected_user_id", name: "user_connections_constraint"
  end

  create_table "daily_metrics", force: :cascade do |t|
    t.date "date", null: false
    t.integer "total_users"
    t.integer "total_connected_wallets"
    t.integer "total_active_users"
    t.integer "total_dead_accounts"
    t.integer "total_talent_profiles"
    t.integer "total_engaged_users"
    t.integer "total_advocates"
    t.integer "total_scouts"
    t.integer "talent_applications"
    t.integer "total_beginner_quests_completed"
    t.integer "total_complete_profile_quests_completed"
    t.integer "total_ambassador_quests_completed"
    t.integer "total_supporter_quests_completed"
    t.integer "total_celo_tokens"
    t.integer "total_celo_supporters"
    t.integer "total_polygon_tokens"
    t.integer "total_polygon_supporters"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "discovery_rows", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "badge"
    t.string "badge_link"
    t.string "slug"
    t.text "description"
    t.bigint "partnership_id"
    t.index ["partnership_id"], name: "index_discovery_rows_on_partnership_id"
  end

  create_table "erc20_tokens", force: :cascade do |t|
    t.string "address", null: false
    t.string "name"
    t.string "symbol"
    t.string "logo"
    t.string "thumbnail"
    t.integer "decimals"
    t.string "balance"
    t.integer "chain_id", null: false
    t.boolean "show", default: false
    t.bigint "user_id", null: false
    t.datetime "last_sync_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "token_image_data"
    t.index ["user_id"], name: "index_erc20_tokens_on_user_id"
  end

  create_table "erc721_tokens", force: :cascade do |t|
    t.string "address", null: false
    t.string "name"
    t.string "symbol"
    t.string "url"
    t.json "metadata"
    t.string "token_id"
    t.string "amount"
    t.integer "chain_id", null: false
    t.boolean "show", default: false
    t.string "nft_type", null: false
    t.bigint "user_id", null: false
    t.datetime "last_sync_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.string "external_image_url"
    t.index ["user_id"], name: "index_erc721_tokens_on_user_id"
  end

  create_table "feed_posts", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "feed_id"
    t.bigint "post_id"
    t.index ["feed_id", "post_id"], name: "index_feed_posts_on_feed_id_and_post_id", unique: true
    t.index ["feed_id"], name: "index_feed_posts_on_feed_id"
    t.index ["post_id"], name: "index_feed_posts_on_post_id"
  end

  create_table "feeds", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_feeds_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "follower_id"
    t.index ["follower_id"], name: "index_follows_on_follower_id"
    t.index ["user_id", "follower_id"], name: "index_follows_on_user_id_and_follower_id", unique: true
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "goal_images", force: :cascade do |t|
    t.bigint "goal_id", null: false
    t.text "image_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["goal_id"], name: "index_goal_images_on_goal_id"
  end

  create_table "goals", force: :cascade do |t|
    t.date "due_date", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "career_goal_id"
    t.string "title"
    t.string "link"
    t.index ["career_goal_id"], name: "index_goals_on_career_goal_id"
  end

  create_table "impersonations", force: :cascade do |t|
    t.bigint "impersonator_id"
    t.bigint "impersonated_id"
    t.text "ip_ciphertext", null: false
    t.string "ip_bidx"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["impersonated_id"], name: "index_impersonations_on_impersonated_id"
    t.index ["impersonator_id"], name: "index_impersonations_on_impersonator_id"
    t.index ["ip_bidx"], name: "index_impersonations_on_ip_bidx"
  end

  create_table "invites", force: :cascade do |t|
    t.string "code", null: false
    t.integer "uses", default: 0
    t.integer "max_uses", default: 2
    t.boolean "talent_invite", default: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "partnership_id"
    t.index ["partnership_id"], name: "index_invites_on_partnership_id"
    t.index ["user_id"], name: "index_invites_on_user_id"
  end

  create_table "marketing_articles", force: :cascade do |t|
    t.string "link", null: false
    t.string "title", null: false
    t.string "description"
    t.text "image_data"
    t.date "article_created_at"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_marketing_articles_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "text_ciphertext"
    t.boolean "is_read", default: false, null: false
    t.boolean "sent_to_supporters", default: false
    t.bigint "chat_id"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "milestone_images", force: :cascade do |t|
    t.bigint "milestone_id", null: false
    t.text "image_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["milestone_id"], name: "index_milestone_images_on_milestone_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.string "title", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.string "description"
    t.string "link"
    t.string "institution"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "talent_id"
    t.string "category"
    t.boolean "in_progress", default: false
    t.index ["talent_id"], name: "index_milestones_on_talent_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.jsonb "params"
    t.datetime "read_at"
    t.datetime "emailed_at"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "partnerships", force: :cascade do |t|
    t.string "name", null: false
    t.text "logo_data"
    t.string "website_url"
    t.string "description"
    t.string "twitter_url"
    t.bigint "invite_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "banner_data"
    t.string "button_name"
    t.string "button_url"
    t.string "location"
    t.index ["invite_id"], name: "index_partnerships_on_invite_id"
  end

  create_table "perks", force: :cascade do |t|
    t.integer "price", null: false
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "talent_id"
    t.index ["talent_id"], name: "index_perks_on_talent_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "profile_page_visitors", force: :cascade do |t|
    t.text "ip_ciphertext", null: false
    t.string "ip_bidx"
    t.bigint "user_id", null: false
    t.datetime "last_visited_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ip_bidx"], name: "index_profile_page_visitors_on_ip_bidx"
    t.index ["user_id"], name: "index_profile_page_visitors_on_user_id"
  end

  create_table "quests", force: :cascade do |t|
    t.string "status", default: "pending"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
    t.index ["user_id"], name: "index_quests_on_user_id"
  end

  create_table "races", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "ends_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "reason"
    t.string "category", default: "OTHER"
    t.bigint "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "creator_id"
    t.boolean "imported", default: false
    t.string "identifier"
    t.index ["creator_id"], name: "index_rewards_on_creator_id"
    t.index ["identifier"], name: "index_rewards_on_identifier", unique: true
    t.index ["user_id"], name: "index_rewards_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "discovery_row_id"
    t.boolean "hidden", default: false
    t.integer "user_tags_count", default: 0, null: false
    t.index ["description"], name: "index_tags_on_description"
    t.index ["discovery_row_id"], name: "index_tags_on_discovery_row_id"
  end

  create_table "talent", force: :cascade do |t|
    t.string "public_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.datetime "ito_date"
    t.integer "activity_count", default: 0
    t.text "profile_picture_data"
    t.boolean "public", default: false
    t.jsonb "profile", default: {}
    t.boolean "disable_messages", default: false
    t.text "banner_data"
    t.boolean "token_launch_reminder_sent", default: false
    t.string "notion_page_id"
    t.integer "supporters_count"
    t.string "total_supply"
    t.boolean "hide_profile", default: false, null: false
    t.boolean "open_to_job_offers", default: false, null: false
    t.boolean "verified", default: false
    t.integer "experience_level", default: 0
    t.string "market_cap", default: "0"
    t.decimal "market_cap_variance", precision: 10, scale: 2, default: "0.0"
    t.index ["activity_count"], name: "index_talent_on_activity_count"
    t.index ["ito_date"], name: "index_talent_on_ito_date"
    t.index ["public_key"], name: "index_talent_on_public_key", unique: true
    t.index ["user_id"], name: "index_talent_on_user_id"
  end

  create_table "talent_supporters", force: :cascade do |t|
    t.string "amount"
    t.string "tal_amount"
    t.string "supporter_wallet_id", null: false
    t.string "talent_contract_id", null: false
    t.datetime "synced_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_time_bought_at"
    t.datetime "first_time_bought_at"
    t.index ["supporter_wallet_id", "talent_contract_id"], name: "talent_supporters_wallet_token_contract_uidx", unique: true
  end

  create_table "talent_tokens", force: :cascade do |t|
    t.string "ticker"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "talent_id"
    t.boolean "deployed", default: false
    t.string "contract_id"
    t.datetime "deployed_at"
    t.integer "chain_id"
    t.index ["chain_id"], name: "index_talent_tokens_on_chain_id"
    t.index ["talent_id"], name: "index_talent_tokens_on_talent_id"
    t.index ["ticker"], name: "index_talent_tokens_on_ticker", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.string "status", default: "pending"
    t.string "type"
    t.bigint "quest_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["quest_id"], name: "index_tasks_on_quest_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "amount"
    t.string "tx_hash"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.string "wallet_id"
    t.index ["user_id"], name: "index_transfers_on_user_id"
    t.index ["wallet_id"], name: "index_transfers_on_wallet_id"
  end

  create_table "user_profile_type_changes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "who_dunnit_id", null: false
    t.string "previous_profile_type"
    t.string "new_profile_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "note"
    t.index ["user_id"], name: "index_user_profile_type_changes_on_user_id"
    t.index ["who_dunnit_id"], name: "index_user_profile_type_changes_on_who_dunnit_id"
    t.check_constraint "(previous_profile_type)::text <> (new_profile_type)::text", name: "profile_types_check_constraint"
  end

  create_table "user_tags", force: :cascade do |t|
    t.bigint "talent_id"
    t.bigint "tag_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["tag_id"], name: "index_user_tags_on_tag_id"
    t.index ["talent_id", "tag_id"], name: "index_user_tags_on_talent_id_and_tag_id", unique: true
    t.index ["talent_id"], name: "index_user_tags_on_talent_id"
    t.index ["user_id"], name: "index_user_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email"
    t.string "encrypted_password", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.string "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "confirmation_token", limit: 128
    t.integer "sign_in_count", default: 0
    t.datetime "last_sign_in_at"
    t.string "wallet_id"
    t.string "nounce"
    t.string "email_confirmation_token", default: "", null: false
    t.datetime "email_confirmed_at"
    t.string "display_name"
    t.bigint "invite_id"
    t.boolean "tokens_purchased", default: false
    t.boolean "token_purchase_reminder_sent", default: false
    t.string "theme_preference", default: "light"
    t.boolean "disabled", default: false
    t.boolean "messaging_disabled", default: false
    t.jsonb "notification_preferences", default: {}
    t.string "user_nft_address"
    t.boolean "user_nft_minted", default: false
    t.integer "user_nft_token_id"
    t.string "user_nft_tx"
    t.string "member_nft_address"
    t.boolean "member_nft_minted", default: false
    t.integer "member_nft_token_id"
    t.string "member_nft_tx"
    t.bigint "race_id"
    t.string "profile_type", default: "supporter", null: false
    t.boolean "first_quest_popup", default: false, null: false
    t.datetime "last_access_at"
    t.datetime "complete_profile_reminder_sent_at"
    t.datetime "token_launch_reminder_sent_at"
    t.datetime "token_purchase_reminder_sent_at"
    t.datetime "digest_email_sent_at"
    t.string "ens_domain"
    t.string "linkedin_id"
    t.string "delete_account_token"
    t.datetime "delete_account_token_expires_at"
    t.string "legal_first_name"
    t.string "legal_last_name"
    t.boolean "onboarding_complete", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invite_id"], name: "index_users_on_invite_id"
    t.index ["linkedin_id"], name: "index_users_on_linkedin_id", unique: true
    t.index ["race_id"], name: "index_users_on_race_id"
    t.index ["remember_token"], name: "index_users_on_remember_token"
    t.index ["username"], name: "index_users_on_username", unique: true
    t.index ["wallet_id"], name: "index_users_on_wallet_id", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "wait_list", force: :cascade do |t|
    t.boolean "approved", default: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "talent", default: false
    t.index ["approved"], name: "index_wait_list_on_approved"
    t.index ["email"], name: "index_wait_list_on_email", unique: true
  end

  add_foreign_key "career_goals", "talent"
  add_foreign_key "career_needs", "career_goals"
  add_foreign_key "chats", "users", column: "receiver_id"
  add_foreign_key "chats", "users", column: "sender_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "connections", "users"
  add_foreign_key "connections", "users", column: "connected_user_id"
  add_foreign_key "discovery_rows", "partnerships"
  add_foreign_key "erc20_tokens", "users"
  add_foreign_key "erc721_tokens", "users"
  add_foreign_key "feed_posts", "feeds"
  add_foreign_key "feed_posts", "posts"
  add_foreign_key "feeds", "users"
  add_foreign_key "follows", "users"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "goal_images", "goals"
  add_foreign_key "goals", "career_goals"
  add_foreign_key "impersonations", "users", column: "impersonated_id"
  add_foreign_key "impersonations", "users", column: "impersonator_id"
  add_foreign_key "invites", "partnerships"
  add_foreign_key "invites", "users"
  add_foreign_key "marketing_articles", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "milestone_images", "milestones"
  add_foreign_key "milestones", "talent"
  add_foreign_key "partnerships", "invites"
  add_foreign_key "perks", "talent"
  add_foreign_key "posts", "users"
  add_foreign_key "profile_page_visitors", "users"
  add_foreign_key "quests", "users"
  add_foreign_key "rewards", "users"
  add_foreign_key "rewards", "users", column: "creator_id"
  add_foreign_key "tags", "discovery_rows"
  add_foreign_key "talent_tokens", "talent"
  add_foreign_key "tasks", "quests"
  add_foreign_key "transfers", "users"
  add_foreign_key "user_profile_type_changes", "users"
  add_foreign_key "user_profile_type_changes", "users", column: "who_dunnit_id"
  add_foreign_key "user_tags", "tags"
  add_foreign_key "user_tags", "talent"
  add_foreign_key "user_tags", "users"
end
