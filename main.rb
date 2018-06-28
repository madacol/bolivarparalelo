require 'sinatra'
require 'open-uri'
require 'json'

MIN_FEEDBACK_SCORE = 99
MIN_TRADE_COUNT = 100
MIN_BTC_VOLUME = 0.5

ASCENDING_ORDER = false
DESCENDING_ORDER = true

def getPrice(url, descending_order)
  tx_list = []
  price = 0
  btc_volume = 0.0
  while url and btc_volume < MIN_BTC_VOLUME
    p "Fecthing: #{url}"
    list_raw = JSON.parse open(url).read
    p 'Done!'
    url = list_raw['pagination']['next']
    list_raw['data']['ad_list'].each do |tx|
      trade_count = tx['data']['profile']['trade_count'].tr(' +','').to_i
      feedback_score = tx['data']['profile']['feedback_score'].to_i
      tx_list.push tx unless trade_count < MIN_TRADE_COUNT or feedback_score < MIN_FEEDBACK_SCORE
    end
    btc_volume = 0.0
    tx_list.sort_by! {|tx| tx['data']['temp_price'].to_f}
    tx_list.reverse! if descending_order
    tx_list.each do |tx|
      fiat_available = tx['data']['max_amount_available'].to_f
      price = tx['data']['temp_price'].to_f
      btc_volume += fiat_available / price
      break unless btc_volume < MIN_BTC_VOLUME
    end
  end
  return price
end

get '/' do

  buy_list = []
  sell_list = []
  buy_list_url = 'https://localbitcoins.com/buy-bitcoins-online/vef/.json'
  sell_list_url = 'https://localbitcoins.com/sell-bitcoins-online/vef/.json'

  vef_btc_buy_price = getPrice( buy_list_url, ASCENDING_ORDER )
  vef_btc_sell_price = getPrice( sell_list_url, DESCENDING_ORDER )

  usd_btc_avg_price = 1 / JSON.parse( open("https://apiv2.bitcoinaverage.com/constants/exchangerates/global").read )['rates']['BTC']['rate'].to_f

  vef_btc_avg_price = (vef_btc_buy_price + vef_btc_sell_price) / 2
  vef_usd_avg_price = vef_btc_avg_price / usd_btc_avg_price
  vef_usd_buy_price = vef_btc_buy_price / usd_btc_avg_price
  vef_usd_sell_price = vef_btc_sell_price / usd_btc_avg_price

  data = {
    "VEFUSD" => {
      numerator: "VEF",
      denominator: "USD",
      rates: { buy: vef_usd_buy_price, avg: vef_usd_avg_price, sell: vef_usd_sell_price },
    },
    "VEFBTC" => {
      numerator: "VEF",
      denominator: "BTC",
      rates: { buy: vef_btc_buy_price, avg: vef_btc_avg_price, sell: vef_btc_sell_price },
    },
    "USDBTC" => {
      numerator: "USD",
      denominator: "BTC",
      rates: { avg: usd_btc_avg_price },
    },
  }

  erb :index, :locals => {:data => data}

end
