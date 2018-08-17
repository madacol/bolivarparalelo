require 'sinatra'

require './models'

get '/' do

  p "Getting data"
  last_rates = Rate.last
  p 'Done!'

  vef_btc_buy_price =     last_rates.vef_btc_buy
  vef_btc_sell_price =    last_rates.vef_btc_sell
  vef_btc_avg_1h_price =  last_rates.vef_btc_avg_1h
  usd_btc_avg_price =     last_rates.usd_btc_avg

  vef_btc_avg_price =     (vef_btc_buy_price + vef_btc_sell_price) / 2
  vef_usd_avg_price =     vef_btc_avg_price / usd_btc_avg_price
  vef_usd_avg_1h_price =  vef_btc_avg_1h_price / usd_btc_avg_price
  vef_usd_buy_price =     vef_btc_buy_price / usd_btc_avg_price
  vef_usd_sell_price =    vef_btc_sell_price / usd_btc_avg_price

  data = {
    rates: {
      "VEFUSD" => {
        numerator: "VEF",
        denominator: "USD",
        rates: { buy: vef_usd_buy_price, avg: vef_usd_avg_price, sell: vef_usd_sell_price, avg1h: vef_usd_avg_1h_price },
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
    },
    datetime: last_rates.datetime
  }

  erb :index, :locals => {:data => data}

end
