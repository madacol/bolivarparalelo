require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'countries/global'
require 'geocoder'

POINTS_TO_SHOW_IN_GRAPH = 24*7
DEFAULT_COUNTRY = 'VE'

def getHumanTime(seconds)
  diff_time_in_minutes = (seconds / 60).round
  if diff_time_in_minutes == 0
    human_time = "Hace pocos segundos"
  else
    hours, minutes = diff_time_in_minutes.divmod 60
    days, hours    = hours.divmod                24

    time_strings = []
    time_strings.push "#{days} dia#{      's' if days    > 1}"  unless days    == 0
    time_strings.push "#{hours} hora#{    's' if hours   > 1}"  unless hours   == 0
    time_strings.push "#{minutes} minuto#{'s' if minutes > 1}"  unless minutes == 0

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

  ip = request.ip
  location = Geocoder.search(ip).first
  country_code = location.country unless location.nil?  # if Geocoder succeeds
  country_code ||= DEFAULT_COUNTRY
  lang = Country[country_code].data['languages_spoken'].first
  country = (country_code=='VE') ? nil : Country[country_code]
  currency_code = country.nil? ? 'btc' : country.currency.iso_code

  p "Getting data"
    ves_btc_rates        = Currency.find_by(code:'ves').LobitPrices.last POINTS_TO_SHOW_IN_GRAPH
    ves_btc_current_rate = ves_btc_rates.last
    secondary_currency   = Currency.find_by(code: currency_code.downcase)
    usd_btc_current_rate = UsdBtc.last
    if secondary_currency.nil?
      secondary_code          = 'btc'
      secondary_btc_avg_price = 1
    else
      secondary_code          = secondary_currency.code
      secondary_btc_rate      = secondary_currency.LobitPrices.last
      secondary_btc_avg_price = ( secondary_btc_rate.buy + secondary_btc_rate.sell ) / 2
    end
  p 'Done!'


  ves_btc_buy_price       = ves_btc_current_rate.buy
  ves_btc_sell_price      = ves_btc_current_rate.sell
  usd_btc_avg_price       = usd_btc_current_rate.bitcoinaverage

  ves_btc_avg_price       = (ves_btc_buy_price + ves_btc_sell_price) / 2
  ves_secondary_avg_price = ves_btc_avg_price / secondary_btc_avg_price
  ves_usd_avg_price       = ves_btc_avg_price / usd_btc_avg_price

  time_since_last_update = Time.now - ves_btc_current_rate.created_at
  time_string = getHumanTime(time_since_last_update)

  chart_data = ves_btc_rates.collect do |rate|
    ves_btc_avg = (rate.buy + rate.sell) / 2
    ves_usd_avg = ves_btc_avg / usd_btc_avg_price
    {
      x: rate.created_at.to_datetime.strftime('%Q').to_i,
      y: ves_usd_avg.round(2),
    }
  end

  data = {
    rates: {
      primary: {
        numerator: "Bs",
        denominator: "Dólar",
        rates: { avg: ves_usd_avg_price },
      },
      secondary: {
        numerator: "Bs",
        denominator: secondary_code.upcase,
        rates: { avg: ves_secondary_avg_price },
      },
      bitcoin: {
        rates: { avg: usd_btc_avg_price },
      },
    },
    time: time_string,
    chart: {data: chart_data},
    lang: lang,
    country_code: country_code,
    currency_code: currency_code,
  }

  # Invert any rate that is below 1 and convert to human-rate
  data[:rates].each do |key, rate|
    if rate[:rates][:avg] < 1
      rate[:rates][:avg] = 1 / rate[:rates][:avg]
      rate[:numerator], rate[:denominator] = rate[:denominator], rate[:numerator]     # swap vars
    end
    rate[:rates][:avg] = getHumanRate rate[:rates][:avg]
  end

  erb :index, :locals => {:data => data}

end
