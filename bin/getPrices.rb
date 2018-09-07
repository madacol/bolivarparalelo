require 'open-uri'
require 'json'
require 'sinatra/activerecord'
require './models'

MIN_FEEDBACK_SCORE = 99
MIN_TRADE_COUNT = 100
MIN_BTC_VOLUME_TO_SAMPLE = 1
MIN_BTC_VOLUME_TO_GET_PRICE = 0.5

ASCENDING_ORDER = false
DESCENDING_ORDER = true

def localbitcoins_buy_list_url(currency) "https://localbitcoins.com/buy-bitcoins-online/#{currency}/.json" end
def localbitcoins_sell_list_url(currency) "https://localbitcoins.com/sell-bitcoins-online/#{currency}/.json" end
localbitcoins_bitcoinaverage_url = "https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/"
bitcoinaverage_usd_rates_url = "https://apiv2.bitcoinaverage.com/constants/exchangerates/global"

def getPrice(url, sort_order)
  tx_list = []
  price = 0
  btc_volume = 0.0
  while url and btc_volume < MIN_BTC_VOLUME_TO_SAMPLE
    p "  Fecthing: #{url}"
    list_raw = JSON.parse open(url).read
    p '  Done!'
    url = list_raw['pagination']['next']
    list_raw['data']['ad_list'].each do |tx|
      trade_count = tx['data']['profile']['trade_count'].tr(' +','').to_i
      feedback_score = tx['data']['profile']['feedback_score'].to_i
      tx_list.push tx unless trade_count < MIN_TRADE_COUNT or feedback_score < MIN_FEEDBACK_SCORE
    end
    btc_volume = 0.0
    tx_list.sort_by! {|tx| tx['data']['temp_price'].to_f}
    tx_list.reverse! if sort_order == DESCENDING_ORDER
    tx_list.each do |tx|
      fiat_available = tx['data']['max_amount_available'].to_f
      price = tx['data']['temp_price'].to_f
      btc_volume += fiat_available / price
      break unless btc_volume < MIN_BTC_VOLUME_TO_SAMPLE
    end
  end
  btc_volume = 0.0
  tx_list.each do |tx|
    fiat_available = tx['data']['max_amount_available'].to_f
    price = tx['data']['temp_price'].to_f
    btc_volume += fiat_available / price
    return price if btc_volume >= MIN_BTC_VOLUME_TO_GET_PRICE
  end
  p '  Warning: minimum volume not achieved'
  return price
end

bolivar_ticker = 'ves'
p 'Getting prices'
ves_btc_buy_price = getPrice( localbitcoins_buy_list_url(bolivar_ticker), ASCENDING_ORDER )
ves_btc_sell_price = getPrice( localbitcoins_sell_list_url(bolivar_ticker), DESCENDING_ORDER )
ves_btc_avg_1h_price = JSON.parse( open(localbitcoins_bitcoinaverage_url).read )[bolivar_ticker.upcase]['avg_1h'].to_f
usd_btc_avg_price = 1 / JSON.parse( open(bitcoinaverage_usd_rates_url).read )['rates']['BTC']['rate'].to_f

ves_btc_avg_price = (ves_btc_buy_price + ves_btc_sell_price) / 2
ves_usd_avg_price = ves_btc_avg_price / usd_btc_avg_price
ves_usd_avg_1h_price = ves_btc_avg_1h_price / usd_btc_avg_price
ves_usd_buy_price = ves_btc_buy_price / usd_btc_avg_price
ves_usd_sell_price = ves_btc_sell_price / usd_btc_avg_price
p 'Done!'

p 'Saving to Database'

UsdBtc.create(
  bitcoinaverage: usd_btc_avg_price,
  datetime: Time.now
)
VesBtc.create(
  buy:      ves_btc_buy_price,
  sell:     ves_btc_sell_price,
  avg_1h:   ves_btc_avg_1h_price,
  datetime: Time.now
)

p 'Done!'