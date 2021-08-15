#!/usr/bin/env ruby
require 'net/http'
require 'finnhub_ruby'

# Track the Stock Value of a company by it’s stock quote shortcut using the 
# official Finnhub Ruby api
# 
# Finnhub Free accounts are limited to 60 API requests every 60s
# This job runs 2 requests per symbol - "quote" and "candlesticks"
# Reducing frequency of the job will increase the number of symbols you can track
# Reducing the number of symbols being tracked will allow for increasing the frequency of data

# Config
# ------
# 1. List of symbols you want to track
# 2. Finnhub API key
stockquote_symbols = [
    'AAPL'
]

finnhub_api_key = 'YOUR API KEY HERE'

SCHEDULER.every '1m', :first_in => 0 do |job|
    
    FinnhubRuby.configure do |config|
        config.api_key['api_key'] = finnhub_api_key
    end
    
    finnhub_client = FinnhubRuby::DefaultApi.new
    quote = finnhub_client.quote('AAPL')
    
    current = quote.c
    change = quote.dp
  
    widgetVarname = "stock_quote_" + "AAPL".downcase
    widgetData = {
        current: current
    }
    if change != 0.0
        widgetData[:last] = current + (current * change)
    end
    
    if defined?(send_event)
        send_event(widgetVarname, widgetData)
    else
        print "current: #{symbol} #{current} #{change} #{widgetVarname}\n"
    end
end

