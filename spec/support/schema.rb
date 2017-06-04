ActiveRecord::Schema.define do
  create_table "accounts", force: :cascade do |t|
    t.string  "account_id"
    t.decimal "balance",    precision: 8, scale: 2
    t.index ["account_id"], name: "index_accounts_on_account_id", using: :btree
  end

  create_table "event_store_events", force: :cascade do |t|
    t.string   "stream",     null: false
    t.string   "event_type", null: false
    t.string   "event_id",   null: false
    t.text     "metadata"
    t.text     "data",       null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_on_created_at", using: :btree
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true, using: :btree
    t.index ["event_type"], name: "index_event_store_events_on_event_type", using: :btree
    t.index ["stream"], name: "index_event_store_events_on_stream", using: :btree
  end
end
