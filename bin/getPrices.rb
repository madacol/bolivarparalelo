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
MIN_ADS_COUNT_TO_GET_PRICE = 5
MAX_PAGES_TO_SAMPLE = 3
MAX_RETRIES = 3


###############################################################
############################   URLS   #########################
###############################################################


BITCOINAVERAGE_USD_RATES_URL = "https://apiv2.bitcoinaverage.com/constants/exchangerates/global"
LOCALBITCOINS_BITCOINAVERAGE_URL = "https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/"
def localbitcoins_ad_list_url(currency_code, buy_or_sell_str) "https://localbitcoins.com/#{buy_or_sell_str}-bitcoins-online/#{currency_code}/.json" end


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
    "occidental"      => "bod",
  },
  "cop" =>
  {
    "citibank"        => "colpatria",
    "bcobogota"       => "bancobogota",
    "avillas"         => "avvillas",
    "avvilla"         => "avvillas",
    "villas"          => "avvillas",
    "villa"           => "avvillas",
    "bancombia"       => "bancolombia",
  },
}


###############################################################
#########################   WHITELISTS   ######################
###############################################################


PAYMENT_METHODS_WHITELIST =
[
  "NATIONAL_BANK",
  "SPECIFIC_BANK",
  "CASH_DEPOSIT",
  "CASH_AT_ATM",
  "SEPA",
]

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
    "bnc",
  ],
  "cop" =>
  [
    "bancolombia",
    "nequi",
    "davivienda",
    "daviplata",
    "avvillas",
    "bbva",
    "colpatria",
    "bancobogota",
  ],
}


###############################################################
#########################   FUNCTIONS   #######################
###############################################################


##########################   LEVEL 0   ########################

def getListFromUrl(url)
  retries = 0
  begin
    p "    Fecthing: #{url}"
    json_raw = open(url).read
    p '    Parsing JSON'
    list = JSON.parse json_raw
    p '    Done!'
    return list
  rescue OpenURI::HTTPError, JSON::ParserError, Net::ReadTimeout => e
    sleep 5
    retries = retries + 1
    retry if retries < MAX_RETRIES
    return nil
  end
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
        "online_provider"      => ad['data']['online_provider'],
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

def getAdsWithWhitelistedPaymentMethods(ad_list)
  return ad_list.keep_if do |ad|
    payment_method = ad['data']['online_provider']
    PAYMENT_METHODS_WHITELIST.include? payment_method
  end
end

def addKeywordsToAds(ad_list, currency_code)
  return ad_list.collect do |ad|
    bank_name = ad['data']['bank_name']
    bank_name_normalized = I18n.transliterate bank_name.downcase
    regex1 = /[^a-zA-Z0-9.,]+/     # matches all characters that are not: a-zA-Z0-9_.,   | "a-z" translates to abcdefghij...
    regex2 = /(?<=\D)[.,]/         # matches any , or . that is preceded by a non-digit
    regex  = /#{regex1}|#{regex2}/ # matches regex1 or regex2
    bank_name_keywords_raw = bank_name_normalized.split(regex)
    if KEYWORDS_TRANSLATIONS.has_key? currency_code
      bank_name_keywords_raw.collect! do |keyword|
        KEYWORDS_TRANSLATIONS[currency_code].has_key?( keyword )  ?  KEYWORDS_TRANSLATIONS[currency_code][keyword]  :  keyword
      end
    end
    bank_name_keywords = bank_name_keywords_raw.reject(&:empty?).uniq
    ad['data']['keywords'] = bank_name_keywords
    ad
  end
end

def getPriceFromAds(ad_list)
  price = nil
  btc_volume = 0.0
  ad_list.each.with_index(1) do |ad, index|      # return price when minimum volume and minimum number of ads are reached
    p "#{ad['data']['bank_name']}  = #{ad['data']['keywords']}"
    fiat_available = ad['data']['max_amount_available'].to_f
    price = ad['data']['temp_price'].to_f
    btc_volume += fiat_available / price
    return price if btc_volume >= MIN_BTC_VOLUME_TO_GET_PRICE and index >= MIN_ADS_COUNT_TO_GET_PRICE
  end
  if price.nil? then  p "  Couldn't get a price"
  else                p "  Warning: minimum volume-price or ad-counts not achieved"
  end
  return price
end

##########################   LEVEL 3   ########################

def getSanitizedAdsFromAllUrls(url)
  ad_list = []
  for i in 1..MAX_PAGES_TO_SAMPLE
    list = getListFromUrl(url)
    break if list.nil?
    url = getNextUrlFromList(list)
    ad_list_raw = getAdsFromList(list)
    ad_list_sanitized = getHighReputationAds( removeUnneededParams( ad_list_raw ) )
    ad_list.concat ad_list_sanitized
    break if url.nil?
  end
  return nil if ad_list.empty?
  return ad_list
end

def getAdsWithWhitelistedKeywords(ad_list_with_keywords, currency_code)
  if KEYWORDS_WHITELIST.has_key? currency_code
    return ad_list_with_keywords.reject do |ad|
      not ad['data']['keywords'].any? do |keyword|
        KEYWORDS_WHITELIST[currency_code].include? keyword
      end
    end
  else return ad_list_with_keywords
  end
end

##########################   LEVEL 4   ########################

def getLobitPrice(currency_code, buy_or_sell_str)
  url = localbitcoins_ad_list_url(currency_code, buy_or_sell_str)
  p '  Loading sources'
  ad_list = getSanitizedAdsFromAllUrls(url)
  return nil if ad_list.nil?
  p '  Done!'
  ad_list = getAdsWithWhitelistedPaymentMethods ad_list
  ad_list.sort_by! {|ad| ad['data']['temp_price'].to_f}
  ad_list.reverse! if buy_or_sell_str == 'sell'
  ad_list = addKeywordsToAds(ad_list, currency_code)
  ad_list = getAdsWithWhitelistedKeywords( ad_list, currency_code )
  return getPriceFromAds(ad_list)
end

##########################   LEVEL 5   ########################

def getLobitPrices(currency_code)
  p 'Getting buy price'
  buy = getLobitPrice(currency_code, 'buy')
  p 'Getting sell price'
  sell = getLobitPrice(currency_code, 'sell')
  return nil if buy.nil? or sell.nil?
  return { buy:  buy, sell: sell }
end


###############################################################
#########################   EXECUTION   #######################
###############################################################


if __FILE__ == $0     # Code inside this "if" will not be executed when used as a library (required from another script or irb)
  p 'Getting avg_1h list'
  avg_1h_list = getListFromUrl(LOCALBITCOINS_BITCOINAVERAGE_URL)
  p 'Done!'
  p "Getting BitcoinAverage's USD/BTC rate"
    usd_btc_avg_price = 1 / JSON.parse( open(BITCOINAVERAGE_USD_RATES_URL).read )['rates']['BTC']['rate'].to_f
  p 'Done!'
  p ''
  p "Saving BitcoinAverage's USD/BTC to Database"
    UsdBtc.create(
      bitcoinaverage: usd_btc_avg_price,
      datetime:       Time.now
    )
  p 'Done!'
  Currency.all.each do |currency|
    btc_prices = getLobitPrices currency.code
    next if btc_prices.nil? # Couldn't get a price
    btc_prices[:avg_1h] = avg_1h_list.nil? ? nil : avg_1h_list[currency.code.upcase]['avg_1h'].to_f
    p ''
    p "Saving Lobit's #{currency.code.upcase}/BTC to Database"
      LobitPrice.create(
        currency: currency,
        buy:      btc_prices[:buy],
        sell:     btc_prices[:sell],
        avg_1h:   btc_prices[:avg_1h],
      )
    p 'Done!'
  end
end