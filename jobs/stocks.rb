#!/usr/bin/env ruby
require 'net/http'
require 'iex-ruby-client'

# Track the Stock Value of a company by it’s stock quote shortcut using the 
# official Finnhub Ruby api
# 
# IEX Free accounts are limited to 50,000 credits

# Config
# ------
# 1. Watchlist tickers are read in from file pointed at by the environment variables $WATCHLIST_FILE
# 2. IEX API key is read in from the file point at by the environment variable $IEX_API_KEY_FILE

# Read in watchlist
watchlist_file = ENV['WATCHLIST_FILE']
watchlist_raw = File.read(watchlist_file)
watchlist = Hash.new
watchlist_raw.each_line do |line|
    line = line.strip
    if line != '' then
        watchlist[line] = {}
    end
end

# Read in API key
iex_api_key_file = ENV['IEX_API_KEY_FILE']
if iex_api_key_file != nil
    raw_contents = File.read(iex_api_key_file)
    if raw_contents != nil
        contents = raw_contents.strip.split("\n")
        iex_secret_key = contents[0]
        iex_public_key = contents[1]
    end
end
if iex_secret_key == nil
    iex_secret_key = ENV['IEX_API_SECRET_KEY']
end
if iex_public_key == nil
    iex_public_key = ENV['IEX_API_PUBLIC_KEY']
end

IEX::Api.configure do |config|
    if iex_api_key_file != ''
        config.publishable_token = iex_public_key
        config.secret_token = iex_secret_key
    end
    config.endpoint = 'https://sandbox.iexapis.com/v1'
end

client = IEX::Api::Client.new

puts("Fetching ticker info... ")
watchlist.each do |symbol, data|
    data[:widget_id] = 'stock_quote_' + symbol
    data[:company_info] = Hash.new

    # Fetch company information
    stats = client.key_stats(symbol)
    logo = client.logo(symbol)
    puts("Fetched info for " + symbol)
    
    data[:company_info] = {
        name: stats.company_name,
        logo: logo.url
    }
end

before do
    @watchlist = watchlist
end

SCHEDULER.every '1m', :first_in => 0 do |job|    
    quotes = Hash.new
    
    watchlist.each do |symbol, data|
        quote = client.quote(symbol)
        iexchart = client.chart(symbol, '1d', chart_interval: 10)
        
        # Chart data
        labels = []
        chartdata = {
           data: Array.new(),
           backgroundColor: Array.new(),
           borderColor: Array.new(),
           borderWidth: 1,
           fill: 'origin',
           pointRadius: 0
        }
        borderWidth = 1
        for dp in iexchart
            labels.append(dp.label)
            avgPrice = (dp.high + dp.low) / 2.0
            chartdata[:data].append(avgPrice)
            chartdata[:backgroundColor].append(if avgPrice >= quote.open then 'rgba(99, 255, 174, 0.2)' else 'rgba(255, 99, 132, 0.2)' end)
            chartdata[:borderColor].append(if avgPrice >= quote.open then 'rgba(99, 255, 174, 1)' else 'rgba(255, 99, 132, 1)' end)
        end
        
        widgetData = {
            current: quote.latest_price,
            labels: labels,
            datasets: [ chartdata ],
            options: {
                title: {
                    display: false
                },
                scales: {
                    y: {
                        suggestedMax: quote.open,
                        suggestedMin: quote.open
                    }
                },
                plugins: {
                    annotation: {
                        annotations: {
                            line1: {
                                type: 'line',
                                scaleID: 'y',
                                value: quote.open,
                                borderColor: 'rgba(120, 120, 120, 0.5)',
                                borderWidth: 2,
                                borderDash: [5, 5]
                            }
                        }
                    },
                    legend: {
                        display: false
                    },
                    tooltip: {
                        enabled: false
                    }
                }
            }
        }
        if quote.change != 0.0
            widgetData[:last] = quote.latest_price + quote.change
        end
        
        send_event(data[:widget_id], widgetData)
        
        quotes[symbol] = quote
    end
    
    send_event("stock-marquee", {quotes: quotes})
end

