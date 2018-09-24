require 'open-uri'
require 'json'
require 'sinatra/activerecord'
require './models'
require 'i18n'


###############################################################
#######################   CONFIGURATIONS   ####################
###############################################################


MIN_FEEDBACK_SCORE = 99
MIN_TRADE_COUNT = 100
MIN_BTC_VOLUME_TO_GET_PRICE = 0.5
MIN_ADS_TO_GET_PRICE = 5
MAX_PAGES_TO_SAMPLE = 3


###############################################################
############################   URLS   #########################
###############################################################


BITCOINAVERAGE_USD_RATES_URL = "https://apiv2.bitcoinaverage.com/constants/exchangerates/global"
LOCALBITCOINS_BITCOINAVERAGE_URL = "https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/"
def localbitcoins_ad_list_url(ticker, buy_or_sell_str) "https://localbitcoins.com/#{buy_or_sell_str}-bitcoins-online/#{ticker}/.json" end


###############################################################
########################   TRANSLATIONS   #####################
###############################################################


KEYWORDS_TRANSLATIONS =
{
  "ves" =>
  {
    "baneco"          => "banesco",
    "bbva"            => "provincial",
    "provicial"       => "provincial",
    "provical"        => "provincial",
    "mercantin"       => "mercantil",
    "bdv"             => "venezuela",
    "occidental"      => "bod"
  }
}


###############################################################
#########################   WHITELISTS   ######################
###############################################################


KEYWORDS_WHITELIST =
{
  "ves" =>
  [
    "banesco",
    "provincial",
    "mercantil",
    "venezuela",
    "bicentenario",
    "bod",
    "bancaribe",
    "banplus",
    "bfc",
    "bnc"
  ]
}


###############################################################
#########################   FUNCTIONS   #######################
###############################################################


##########################   LEVEL 0   ########################

def getListFromUrl(url)
  p "    Fecthing: #{url}"
  json_raw = open(url).read
  p '    Done!'
  return JSON.parse json_raw
end

##########################   LEVEL 1   ########################

def getAdsFromList(list)
  return list['data']['ad_list']
end

def getNextUrlFromList(list)
  return list['pagination'].nil? ? nil : list['pagination']['next']
end

##########################   LEVEL 2   ########################

def removeUnneededParams(ad_list)
  return ad_list.collect do |ad|
    {
      "data" =>
      {
        "bank_name"            => ad['data']['bank_name'],
        "temp_price"           => ad['data']['temp_price'],
        "max_amount_available" => ad['data']['max_amount_available'],
        "profile" =>
        {
          "trade_count"    => ad['data']['profile']['trade_count'],
          "feedback_score" => ad['data']['profile']['feedback_score']
        }
      }
    }
  end
end

def getHighReputationAds(ad_list)
  ad_list.reject! do |ad|
    trade_count = ad['data']['profile']['trade_count'].tr(' +','').to_i
    feedback_score = ad['data']['profile']['feedback_score'].to_i
    (trade_count < MIN_TRADE_COUNT or feedback_score < MIN_FEEDBACK_SCORE)
  end
  return ad_list
end

def addKeywordsToAds(ad_list, ticker)
  return ad_list.collect do |ad|
    payment_method = ad['data']['bank_name']
    payment_method_normalized = I18n.transliterate payment_method.downcase
    regex1 = /[^a-zA-Z0-9.,]+/     # matches all characters that are not: a-zA-Z0-9_.,   | "a-z" translates to abcdefghij...
    regex2 = /(?<=\D)[.,]/         # matches any , or . that is preceded by a non-digit
    regex  = /#{regex1}|#{regex2}/ # matches regex1 or regex2
    payment_method_keywords_raw = payment_method_normalized.split(regex)
    if KEYWORDS_TRANSLATIONS.has_key? ticker
      payment_method_keywords_raw.collect! do |keyword|
        KEYWORDS_TRANSLATIONS[ticker].has_key?( keyword )  ?  KEYWORDS_TRANSLATIONS[ticker][keyword]  :  keyword
      end
    end
    payment_method_keywords = payment_method_keywords_raw.reject(&:empty?).uniq
    ad['data']['keywords'] = payment_method_keywords
    ad
  end
end

def getPriceFromAds(ad_list)
  price = 0
  btc_volume = 0.0
  ad_list.each.with_index(1) do |ad, index|      # return price when minimum volume and minimum number of ads are reached
    p "#{ad['data']['bank_name']}  = #{ad['data']['keywords']}"
    fiat_available = ad['data']['max_amount_available'].to_f
    price = ad['data']['temp_price'].to_f
    btc_volume += fiat_available / price
    return price if btc_volume >= MIN_BTC_VOLUME_TO_GET_PRICE and index >= MIN_ADS_TO_GET_PRICE
  end
  p '  Warning: minimum volume-price not achieved'
  return price
end

##########################   LEVEL 3   ########################

def getSanitizedAdsFromAllUrls(url)
  ad_list = []
  for i in 1..MAX_PAGES_TO_SAMPLE
    list = getListFromUrl(url)
    url = getNextUrlFromList(list)
    ad_list_raw = getAdsFromList(list)
    ad_list_sanitized = getHighReputationAds( removeUnneededParams( ad_list_raw ) )
    ad_list.concat ad_list_sanitized
    break if url.nil?
  end
  return ad_list
end

def getAdsWithWhitelistedKeywords(ad_list_with_keywords, ticker)
  if KEYWORDS_WHITELIST.has_key? ticker
    return ad_list_with_keywords.reject do |ad|
      not ad['data']['keywords'].any? do |keyword|
        KEYWORDS_WHITELIST[ticker].include? keyword
      end
    end
  else return ad_list_with_keywords
  end
end

##########################   LEVEL 4   ########################

def getLobitPrice(ticker, buy_or_sell_str)
  url = localbitcoins_ad_list_url(ticker, buy_or_sell_str)
  p '  Loading sources'
  ad_list = getSanitizedAdsFromAllUrls(url)
  p '  Done!'
  ad_list.sort_by! {|ad| ad['data']['temp_price'].to_f}
  ad_list.reverse! if buy_or_sell_str == 'sell'
  ad_list = addKeywordsToAds(ad_list, ticker)
  ad_list = getAdsWithWhitelistedKeywords( ad_list, ticker )
  return getPriceFromAds(ad_list)
end

##########################   LEVEL 5   ########################

def getLobitPrices(ticker)
  p 'Getting buy price'
  buy = getLobitPrice(ticker, 'buy')
  p 'Getting sell price'
  sell = getLobitPrice(ticker, 'sell')
  p 'Getting avg_1h price'
  avg_1h = JSON.parse( open(LOCALBITCOINS_BITCOINAVERAGE_URL).read )[ticker.upcase]['avg_1h'].to_f
  p 'Done!'
  return { buy:  buy, sell: sell, avg_1h: avg_1h }
end


###############################################################
#########################   EXECUTION   #######################
###############################################################


if __FILE__ == $0     # Code inside this "if" will not be executed when used as a library (required from another script or irb)
  bolivar_ticker = 'ves'
  ves_btc_prices = getLobitPrices bolivar_ticker
  usd_btc_avg_price = 1 / JSON.parse( open(BITCOINAVERAGE_USD_RATES_URL).read )['rates']['BTC']['rate'].to_f

  p ''
  p 'Saving to Database'
  UsdBtc.create(
    bitcoinaverage: usd_btc_avg_price,
    datetime:       Time.now
  )
  VesBtc.create(
    buy:      ves_btc_prices[:buy],
    sell:     ves_btc_prices[:sell],
    avg_1h:   ves_btc_prices[:avg_1h],
    datetime: Time.now
  )
  p 'Done!'
end