require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require "sinatra/namespace"
require 'sinatra/json'
require './models'
require 'countries/global'
require 'geocoder'

POINTS_TO_SHOW_IN_GRAPH = 24*7
DEFAULT_COUNTRY = 'VE'
BITCOIN = {
  code: 'btc',
  symbol: '₿',
  name: 'Bitcoin',
  namePlural: 'Bitcoins'
}

def getHumanTime(seconds)
  diff_time_in_minutes = (seconds / 60).floor
  if diff_time_in_minutes == 0
    return "#{seconds.floor} segundos"
  else
    hours, minutes = diff_time_in_minutes.divmod 60
    days, hours    = hours.divmod                24

    time_strings = []
    time_strings.push "#{days} dia#{      's' if days    > 1}"  unless days    == 0
    time_strings.push "#{hours} hora#{    's' if hours   > 1}"  unless hours   == 0
    time_strings.push "#{minutes} minuto#{'s' if minutes > 1}"  unless minutes == 0

    return time_strings.join ", "
  end
end

def getHumanRate(rate)
  num_digits = rate.round.digits.length
  if num_digits < 4 then    rate = rate.round(4-num_digits)    else rate = rate.round end
  rate_str = rate.to_s.reverse.gsub('.', ',').gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  return rate_str
end

def getBuySellAvg(rates)
  return ( rates.buy + rates.sell ) / 2
end

def getCurrencyOrHalt(currency_code)
  currency = Currency.find_by(code: currency_code)
  halt 404, "Currency \"#{currency_code}\" not found!" if currency.nil?
  return currency
end

def getMainData(request)
  ip = request.ip
  location = Geocoder.search(ip).first
  country_code = location.country unless location.nil?  # if Geocoder succeeds
  country_code ||= DEFAULT_COUNTRY
  lang = Country[country_code].data['languages_spoken'].first
  country = (country_code=='VE') ? nil : Country[country_code]
  currency_code = country.nil? ? 'btc' : country.currency_code

  p "Getting data"
    ved_btc_rates        = Currency.find_by(code:'ved').LobitPrices.last POINTS_TO_SHOW_IN_GRAPH
    usd_btc_rates        = Currency.find_by(code:'usd').LobitPrices.last POINTS_TO_SHOW_IN_GRAPH
    secondary_currency   = Currency.find_by(code: currency_code.downcase)
    if secondary_currency.nil?
      secondary_code          = 'btc'
      secondary_btc_avg_price = 1
    else
      secondary_code          = secondary_currency.code
      secondary_btc_rate      = secondary_currency.LobitPrices.last
      secondary_btc_avg_price = getBuySellAvg secondary_btc_rate
    end
  p 'Done!'

  ved_btc_current_rate    = ved_btc_rates.last
  ved_btc_avg_price       = getBuySellAvg ved_btc_current_rate

  usd_btc_current_rate    = usd_btc_rates.last
  usd_btc_avg_price       = getBuySellAvg usd_btc_current_rate

  ved_secondary_avg_price = ved_btc_avg_price / secondary_btc_avg_price
  ved_usd_avg_price       = ved_btc_avg_price / usd_btc_avg_price

  time_since_last_update = Time.now - ved_btc_current_rate.created_at
  time_string = getHumanTime(time_since_last_update)

  usd_btc_rates_hourstamped = {}
  usd_btc_rates.collect do |rate|
    hourstamp = rate.created_at.strftime("%D %H")
    usd_btc_rates_hourstamped[ hourstamp ] = getBuySellAvg rate
  end

  chart_data = ved_btc_rates.collect do |rate|
    ved_btc_avg = getBuySellAvg rate
    hourstamp = rate.created_at.strftime("%D %H")
    usd_btc_rate = usd_btc_rates_hourstamped[ hourstamp ]
    next if usd_btc_rate.nil?
    ved_usd_avg = ved_btc_avg / usd_btc_rate
    {
      x: rate.created_at.to_i*1000,   # unix miliseconds
      y: ved_usd_avg.round(2),
    }
  end.compact

  data = {
    rates: {
      primary: {
        numerator: "Bs",
        denominator: "Dólar",
        rates: { avg: ved_usd_avg_price },
      },
      secondary: {
        numerator: "Bs",
        denominator: secondary_code.upcase,
        rates: { avg: ved_secondary_avg_price },
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
  return data
end

def filterCurrencyAttr(currency)
  return {
    code: currency.code,
    symbol: currency.symbol,
    name: currency.name,
    namePlural: currency.namePlural,
    flag: currency.flag,
  }
end


get '/classic' do
  erb :index, :locals => {:data => getMainData(request)}
end

get '/' do
  send_file 'public/index.html'
end
get '/beta' do
  redirect '/'
end

namespace '/api' do
  get '/?' do
    json getMainData(request)
  end
  get '/currencies/?' do
    json Currency.all
  end
  namespace '/rate/:counter_currency(/:base_currency)?' do
    get '/?' do
      counter_currency = getCurrencyOrHalt params[:counter_currency]
      counter_currency_lastest_rates = counter_currency.LobitPrices.last
      counter_btc_avg = getBuySellAvg counter_currency_lastest_rates
      params[:base_currency] ||= 'btc'
      if params[:base_currency] == 'btc'
        rate = counter_btc_avg
        buy_rate = counter_currency_lastest_rates.buy
        sell_rate = counter_currency_lastest_rates.sell
      else
        base_currency = getCurrencyOrHalt params[:base_currency]
        base_currency_latest_rates = base_currency.LobitPrices.last
        base_btc_avg = getBuySellAvg base_currency_latest_rates
        rate = ( counter_btc_avg / base_btc_avg )
        buy_rate = counter_currency_lastest_rates.buy / base_currency_latest_rates.sell
        sell_rate = counter_currency_lastest_rates.sell / base_currency_latest_rates.buy
      end
      json ({
        :counter_currency => filterCurrencyAttr(counter_currency),
        :base_currency => base_currency.nil? ? BITCOIN : filterCurrencyAttr(base_currency),
        :avg => rate,
        :buy  => buy_rate,
        :sell => sell_rate,
        :unix_time_ms => counter_currency_lastest_rates.created_at.to_i * 1000,
      })
    end
    namespace '/time' do
      get '/:start(/:end)?/?' do
        start_time = Time.at params[:start].to_i/1000
        if params[:end]
          end_time = Time.at params[:end].to_i/1000
        else
          end_time = start_time + 1.hour
        end
        counter_currency = getCurrencyOrHalt params[:counter_currency]
        counter_btc_rates = counter_currency.LobitPrices.where("created_at > ? AND created_at < ?", start_time, end_time)
        counter_rates_hourstamped = {}
        counter_btc_rates.each do |rate|
          hourstamp = rate.created_at.strftime("%D %H")
          counter_rates_hourstamped[ hourstamp ]={}
          counter_rates_hourstamped[ hourstamp ][:avg] = getBuySellAvg rate
          counter_rates_hourstamped[ hourstamp ][:buy] =  rate.buy
          counter_rates_hourstamped[ hourstamp ][:sell] = rate.sell
          counter_rates_hourstamped[ hourstamp ][:unix_time_ms] = rate.created_at.to_i * 1000
        end
        params[:base_currency] ||= 'btc'
        if params[:base_currency] == 'btc'
          json_rates = counter_rates_hourstamped
        else
          base_currency = getCurrencyOrHalt params[:base_currency]
          base_btc_rates = base_currency.LobitPrices.where("created_at > ? AND created_at < ?", start_time, end_time)
          rates_hourstamped = {}
          base_btc_rates.each do |rate|
            hourstamp = rate.created_at.strftime("%D %H")
            counter_btc = counter_rates_hourstamped[ hourstamp ]
            next if counter_btc.nil?
            counter_btc_avg = counter_btc[:avg]
            counter_btc_buy = counter_btc[:buy]
            counter_btc_sell = counter_btc[:sell]
            next if counter_btc_avg.nil?
            base_btc_avg = getBuySellAvg rate
            rates_hourstamped[ hourstamp ]={}
            rates_hourstamped[ hourstamp ][:avg] = counter_btc_avg / base_btc_avg
            rates_hourstamped[ hourstamp ][:buy] =   counter_btc_buy / rate.sell
            rates_hourstamped[ hourstamp ][:sell] =  counter_btc_sell / rate.buy
            rates_hourstamped[ hourstamp ][:unix_time_ms] = counter_rates_hourstamped[ hourstamp ][:unix_time_ms]
          end
          json_rates = rates_hourstamped
        end
        json ({
          :counter_currency => filterCurrencyAttr(counter_currency),
          :base_currency => base_currency.nil? ? BITCOIN : filterCurrencyAttr(base_currency),
          :rates => json_rates
        })
      end
    end
  end
end
