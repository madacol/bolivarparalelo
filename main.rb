require 'sinatra'
require 'open-uri'
require 'json'

MIN_FEEDBACK_SCORE = 99
MIN_TRADE_COUNT = 100
MIN_BTC_VOLUME = 0.1

get '/' do

  buy_list_raw = JSON.parse open('https://localbitcoins.com/buy-bitcoins-online/vef/.json').read
  buy_list = buy_list_raw['data']['ad_list'].reject do |tx|
    trade_count = tx['data']['profile']['trade_count'].tr(' +','').to_i
    feedback_score = tx['data']['profile']['feedback_score'].to_i
    trade_count < MIN_TRADE_COUNT or feedback_score < MIN_FEEDBACK_SCORE
  end
  btc_volume = 0.0
  vef_btc_buy_price = buy_list.each do |tx|
    fiat_available = tx['data']['max_amount_available'].to_f
    price = tx['data']['temp_price'].to_f
    btc_volume = btc_volume + fiat_available / price
    break price if btc_volume > MIN_BTC_VOLUME
  end

  sell_list_raw = JSON.parse open('https://localbitcoins.com/sell-bitcoins-online/vef/.json').read
  sell_list = sell_list_raw['data']['ad_list'].reject do |tx|
    trade_count = tx['data']['profile']['trade_count'].tr(' +','').to_i
    feedback_score = tx['data']['profile']['feedback_score'].to_i
    trade_count < MIN_TRADE_COUNT or feedback_score > MIN_FEEDBACK_SCORE
  end
  btc_volume = 0.0
  vef_btc_sell_price = sell_list.each do |tx|
    fiat_available = tx['data']['max_amount_available'].to_f
    price = tx['data']['temp_price'].to_f
    btc_volume = btc_volume + fiat_available / price
    break price if btc_volume > MIN_BTC_VOLUME
  end

  usd_btc_avg_price = 1 / JSON.parse( open("https://apiv2.bitcoinaverage.com/constants/exchangerates/global").read )['rates']['BTC']['rate'].to_f

  vef_btc_avg_price = (vef_btc_buy_price + vef_btc_sell_price) / 2
  vef_usd_avg_price = vef_btc_avg_price / usd_btc_avg_price
  vef_usd_buy_price = vef_btc_buy_price / usd_btc_avg_price
  vef_usd_sell_price = vef_btc_sell_price / usd_btc_avg_price

  data = {
    "VEF/USD" => { buy: vef_usd_buy_price, avg: vef_usd_avg_price, sell: vef_usd_sell_price },
    "VEF/BTC" => { buy: vef_btc_buy_price, avg: vef_btc_avg_price, sell: vef_btc_sell_price },
    "USD/BTC" => { avg: usd_btc_avg_price },
  }

  erb :index, :locals => {:data => data}

end
