#!/usr/bin/env ruby
require 'net/http'
require 'iex-ruby-client'

# Track the Stock Value of a company by it’s stock quote shortcut using the 
# official Finnhub Ruby api
# 
# IEX Free accounts are limited to 50,000 credits

# Config
# ------
# 1. List of symbols you want to track
# 2. IEX API key is read in from the file point at by the environment variable $IEX_API_KEY_FILE
watchlist_symbols = [
    'AAPL',
    'TSLA',
    'MSFT'
]
iex_api_key_file = ENV['IEX_API_KEY_FILE']
if iex_api_key_file != ''
    contents = File.read(iex_api_key_file).strip.split("\n")
    iex_secret_key = contents[0]
    iex_public_key = contents[1]
end

IEX::Api.configure do |config|
    if iex_api_key_file != ''
        config.publishable_token = iex_public_key
        config.secret_token = iex_secret_key
    end
    config.endpoint = 'https://sandbox.iexapis.com/v1'
end

client = IEX::Api::Client.new

def widget_id_for_symbol(symbol)
    return "stock_quote_" + symbol.downcase
end

# Fetch stock data
before do
    @company_info = Hash.new
    watchlist_symbols.each { |symbol|
        widget_id = widget_id_for_symbol(symbol)

        # Fetch company information
        stats = client.key_stats(symbol)
        logo = client.logo(symbol)
        
        @company_info[symbol] = {
            symbol: symbol,
            name: stats.company_name,
            logo: logo.url
        }
    }
end

SCHEDULER.every '1m', :first_in => 0 do |job|
    
    watchlist_symbols.each { |symbol|
        quote = client.quote(symbol)
        
        widget_id = widget_id_for_symbol(symbol)
        widgetData = {
            current: quote.latest_price
        }
        if quote.change != 0.0
            widgetData[:last] = quote.latest_price + quote.change
        end
        
        send_event(widget_id, widgetData)
    }    
end

