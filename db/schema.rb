# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_11_165502) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "symbol"
    t.string "name"
    t.string "namePlural"
    t.string "flag"
  end

  create_table "lobit_prices", force: :cascade do |t|
    t.decimal "sell"
    t.decimal "buy"
    t.decimal "avg_1h"
    t.bigint "currency_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_lobit_prices_on_currency_id"
  end

  create_table "rates", force: :cascade do |t|
    t.decimal "usd_btc_avg"
    t.decimal "vef_btc_buy"
    t.decimal "vef_btc_sell"
    t.decimal "vef_btc_avg_1h"
    t.datetime "datetime"
  end

  create_table "usd_btcs", force: :cascade do |t|
    t.decimal "bitcoinaverage"
    t.datetime "datetime"
  end

  create_table "ves_btcs", force: :cascade do |t|
    t.decimal "buy"
    t.decimal "sell"
    t.decimal "avg_1h"
    t.datetime "datetime"
  end

end
