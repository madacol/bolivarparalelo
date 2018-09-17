require 'sinatra'
require 'sinatra/activerecord'
require './models'

def getHumanTime(time_in_seconds)
  diff_time_in_minutes = (time_in_seconds / 60).round
  if diff_time_in_minutes == 0
    human_time = "Just now"
  else
    hours, minutes = diff_time_in_minutes.divmod 60
    days, hours    = hours.divmod                24

    time_strings = []
    time_strings.push "#{days} dias"       unless (days    == 0)
    time_strings.push "#{hours} horas"     unless (hours   == 0)
    time_strings.push "#{minutes} minutos" unless (minutes == 0)

    human_time = "Hace "
    human_time.concat( time_strings.join ", " )
  end
  return human_time
end

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

  ves_usd_avg_price    =  ves_btc_avg_price    / usd_btc_avg_price
  ves_usd_avg_1h_price =  ves_btc_avg_1h_price / usd_btc_avg_price
  ves_usd_buy_price    =  ves_btc_buy_price    / usd_btc_avg_price
  ves_usd_sell_price   =  ves_btc_sell_price   / usd_btc_avg_price

  time_since_last_update = Time.now - usd_btc_current_rate.datetime
  time_string = getHumanTime(time_since_last_update)

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
    time: time_string
  }

  erb :index, :locals => {:data => data}

end
