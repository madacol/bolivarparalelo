require 'sinatra'
require 'sinatra/activerecord'
require './models'

POINTS_TO_SHOW_IN_GRAPH = 48

def getHumanTime(seconds)
  diff_time_in_minutes = (seconds / 60).round
  if diff_time_in_minutes == 0
    human_time = "Hace pocos segundos"
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

def getHumanRate(rate)
  num_digits = rate.round.digits.length
  if num_digits < 4 then    rate = rate.round(4-num_digits)    else rate = rate.round end
  rate_str = rate.to_s.reverse.gsub('.', ',').gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  return rate_str
end

get '/' do

  p "Getting data"
  ves_btc_rates        = VesBtc.last POINTS_TO_SHOW_IN_GRAPH
  usd_btc_current_rate = UsdBtc.last
  p 'Done!'

  ves_btc_current_rate =  ves_btc_rates.last
  ves_btc_buy_price    =  ves_btc_current_rate.buy
  ves_btc_sell_price   =  ves_btc_current_rate.sell
  usd_btc_avg_price    =  usd_btc_current_rate.bitcoinaverage

  ves_btc_avg_price    =  (ves_btc_buy_price + ves_btc_sell_price) / 2
  ves_usd_avg_price    =  ves_btc_avg_price / usd_btc_avg_price

  time_since_last_update = Time.now - usd_btc_current_rate.datetime
  time_string = getHumanTime(time_since_last_update)

  chart_rates = []
  chart_labels = []
  ves_btc_rates.each do |rate|
    ves_btc_avg = (rate.buy + rate.sell) / 2
    ves_usd_avg = ves_btc_avg / usd_btc_avg_price
    chart_rates.push( ves_usd_avg.round(2) )
    chart_labels.push rate.datetime.hour
  end

  data = {
    rates: {
      primary: {
        numerator: "Bs",
        denominator: "Dólar",
        rates: { avg: getHumanRate( ves_usd_avg_price ) },
      },
      secondary: {
        numerator: "Bs",
        denominator: "BTC",
        rates: { avg: getHumanRate( ves_btc_avg_price ) },
      },
      bitcoin: {
        rates: { avg: getHumanRate( usd_btc_avg_price ) },
      },
    },
    time: time_string,
    chart: {
      labels: chart_labels,
      rates: chart_rates,
    }
  }

  erb :index, :locals => {:data => data}

end
