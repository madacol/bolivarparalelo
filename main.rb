require 'sinatra'
require 'sinatra/activerecord'
require './models'

get '/' do

  p "Getting data"
  usd_btc_rates = UsdBtc.last
  ves_btc_rates = VesBtc.last
  p 'Done!'

  ves_btc_buy_price    =  ves_btc_rates.buy
  ves_btc_sell_price   =  ves_btc_rates.sell
  ves_btc_avg_1h_price =  ves_btc_rates.avg_1h
  usd_btc_avg_price    =  usd_btc_rates.bitcoinaverage

  ves_btc_avg_price    =  (ves_btc_buy_price + ves_btc_sell_price) / 2
  ves_usd_avg_price    =  ves_btc_avg_price / usd_btc_avg_price
  ves_usd_avg_1h_price =  ves_btc_avg_1h_price / usd_btc_avg_price
  ves_usd_buy_price    =  ves_btc_buy_price / usd_btc_avg_price
  ves_usd_sell_price   =  ves_btc_sell_price / usd_btc_avg_price

  data = {
    rates: {
      "VESUSD" => {
        numerator: "VES",
        denominator: "USD",
        rates: { buy: ves_usd_buy_price, avg: ves_usd_avg_price, sell: ves_usd_sell_price, avg1h: ves_usd_avg_1h_price },
      },
      "VESBTC" => {
        numerator: "VES",
        denominator: "BTC",
        rates: { buy: ves_btc_buy_price, avg: ves_btc_avg_price, sell: ves_btc_sell_price },
      },
      "USDBTC" => {
        numerator: "USD",
        denominator: "BTC",
        rates: { avg: usd_btc_avg_price },
      },
    },
    datetime: usd_btc_rates.datetime
  }

  erb :index, :locals => {:data => data}

end
