#!/usr/bin/env ruby
require 'net/http'
require 'iex-ruby-client'
require 'date'

# Track the value of a company by its stock ticker using the official IEX Ruby api
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
    puts("Fetched company info for " + symbol)
    
    data[:company_info] = {
        name: stats.company_name,
        logo: logo.url
    }
end

@first_data_fetch = true
@trading_today = false
@market_is_open = false

before do
    @watchlist = watchlist
end

# Fetch market calendar
SCHEDULER.every '6h', :first_in => 0 do |job|
    calendar = client.get('/ref-data/us/dates/trade/next/1/' + Date.today.prev_day.strftime('%Y%m%d'), token: iex_secret_key)
    last_trading_day = Date.parse calendar[0]['date']
    @trading_today = (Date.today == last_trading_day)
end

# Market status
SCHEDULER.every '1m', :first_in => 0 do |job|
    if @trading_today
        market_open = DateTime.parse(Date.today.to_s + " 09:30:00 -04:00")
        market_close = DateTime.parse(Date.today.to_s + " 16:00:00 -04:00")
        @market_is_open = DateTime.now.between?(market_open, market_close)
        status_string = if @market_is_open then "Market is open" else "Market is closed" end
        send_event("market-status", {text: status_string})
    end
end

# Heartbeat data
SCHEDULER.every '1m', :first_in => 0 do |job|
    if @market_is_open or @first_data_fetch
        quotes = Hash.new
        
        watchlist.each do |symbol, data|
            quote = client.quote(symbol)
            
            iexchart = Hash.new
            using_intraday = @market_is_open
            if using_intraday
                iexchart = client.get('/stock/' + symbol + '/intraday-prices', 
                    chartIEXOnly: true,
                    chartSimplify: true,
                    token: iex_secret_key
                )
            else
                iexchart = client.chart(symbol, '1d', chart_interval: 10)
            end
            
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
                avgPrice = if using_intraday then dp['average'] else (dp.high + dp.low) / 2.0 end
                if avgPrice
                    labels.append(dp['label'])
                    chartdata[:data].append(avgPrice)
                    chartdata[:backgroundColor].append(if avgPrice >= quote.open then 'rgba(99, 255, 174, 0.2)' else 'rgba(255, 99, 132, 0.2)' end)
                    chartdata[:borderColor].append(if avgPrice >= quote.open then 'rgba(99, 255, 174, 1)' else 'rgba(255, 99, 132, 1)' end)
                end
            end
            
            widgetData = {
                current: quote.latest_price,
                change: quote.change_percent.round(2),
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
            
            send_event(data[:widget_id], widgetData)
            
            quotes[symbol] = quote
        end
        
        send_event("stock-marquee", {quotes: quotes})
        
        @first_data_fetch = false
    end
end

