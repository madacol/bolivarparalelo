require 'sinatra/activerecord'
require './models'
require 'twitter'

DRY_RUN = ARGV.include?('--dry-run')
CURRENCY_FLAGS = {
  "ves" => "🇻🇪",
  "usd" => "🇺🇸",
  "eur" => "🇪🇺",
  "cop" => "🇨🇴",
  "ars" => "🇦🇷",
  "pen" => "🇵🇪",
  "clp" => "🇨🇱",
  "pab" => "🇵🇦",
  "brl" => "🇧🇷",
  "mxn" => "🇲🇽",
  "aud" => "🇦🇺",
  "gbp" => "🇬🇧",
  "chf" => "🇨🇭",
}

def getHumanRate(rate)
  num_digits = rate.round.digits.length
  if num_digits < 4 then    rate = rate.round(4-num_digits)    else rate = rate.round end
  rate_str = rate.to_s.reverse.gsub('.', ',').gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  return rate_str
end

def getBuySellAvg(rates)
  return ( rates.buy + rates.sell ) / 2
end

def generateTweet(primary_currency_code)
  currency_code_to_id = Currency.all.collect {|currency| [currency.code, currency.id] }.to_h
  rates = LobitPrice.where("created_at > ? AND created_at < ?", 1.hour.ago, Time.now).to_a
  primary_rates = rates.select {|rate| rate.currency_id == currency_code_to_id[primary_currency_code] }
  return nil if primary_rates.empty?
  primary_rates.each { |rate| rates.delete rate }
  primary_btc_avg = getBuySellAvg primary_rates.last
  timestamp = rates.last.created_at.to_time.strftime("%d/%m/%Y %I:%M %p")
  message_arr = []
  #message_arr = ["Actualizado el #{timestamp}\nPrecios en Bs.S"]
  message_arr.append "Precios en Bs.S"
  CURRENCY_FLAGS.collect do |currency_code, flag|
    secondary_rates = rates.select {|rate| rate.currency_id == currency_code_to_id[currency_code] }
    next if secondary_rates.empty?
    secondary_rates.each { |rate| rates.delete rate }
    secondary_btc_avg = getBuySellAvg secondary_rates.last
    primary_secondary_rate = getHumanRate( primary_btc_avg / secondary_btc_avg )
    message_arr.append "#{flag} ##{currency_code.upcase} #{primary_secondary_rate}"
  end
  message_arr.append "#BolivarParalelo #{timestamp}"
  return message_arr.join("\n")
end

def tweet(message)
  if DRY_RUN 
    puts message
  else
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["CONSUMER_KEY"]
      config.consumer_secret     = ENV["CONSUMER_SECRET"]
      config.access_token        = ENV["ACCESS_TOKEN"]
      config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
    end.update(message)
  end
end

if __FILE__ == $0     # Code inside this "if" will not be executed when used as a library (required from another script or irb)
  tweet generateTweet 'ves'
end