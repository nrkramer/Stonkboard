#!/usr/bin/env ruby
require 'net/http'
require 'iex-ruby-client'
require '../../Colors.rb'

module Stonkboard
    module DataProvider
        module IEX
            class Client < Stonkboard::DataProvider::DataProvider
                attr_reader :iex_config_path
                attr_reader :iex_endpoint

                def initialize(iex_config_path=ENV['IEX_CONFIG_PATH'])
                    @iex_config_path = iex_config_path
                    if @iex_config_path != nil
                        raw_contents = File.read(@iex_config_path)
                        if raw_contents != nil
                            contents = raw_contents.strip.split("\n")
                            @iex_endpoint = contents[0]
                            @iex_secret_key = contents[1]
                            @iex_public_key = contents[2]
                        end
                    end
                    if @iex_endpoint == nil
                        @iex_endpoint = ENV['IEX_ENDPOINT']
                    end
                    if @iex_secret_key == nil
                        @iex_secret_key = ENV['IEX_API_SECRET_KEY']
                    end
                    if @iex_public_key == nil
                        @iex_public_key = ENV['IEX_API_PUBLIC_KEY']
                    end

                    IEX::Api.configure do |config|
                        if @iex_config_path != ''
                            config.publishable_token = iex_public_key
                            config.secret_token = iex_secret_key
                        end
                        config.endpoint = @iex_endpoint != nil ? @iex_endpoint : 'https://sandbox.iexapis.com/v1'
                    end

                    @client = IEX::Api::Client.new
                end

                def market_status()
                    calendar = @client.get('/ref-data/us/dates/trade/next/1/' + Date.today.prev_day.strftime('%Y%m%d'), token: @iex_secret_key)
                    last_trading_day = Date.parse calendar[0]['date']
                    return (Date.today == last_trading_day)
                end

                def market_movers(gainers=7, losers=7)
                    market_gainers = @client.stock_market_list(:gainers, listLimit: gainers + 1)
                    market_losers = @client.stock_market_list(:losers, listLimit: losers + 1)
                    market_movers = []
                    market_gainers.each do |quote|
                        market_movers.append({
                            symbol: quote.symbol,
                            value: quote.change_percent_s + ' ($' + quote.latest_price.to_s + ')',
                            color: Stonkboard::Colors.ticker_up
                        })
                    end
                    market_losers = market_losers.reverse
                    market_losers.each do |quote|
                        market_movers.append({
                            symbol: quote.symbol,
                            value: quote.change_percent_s + ' ($' + quote.latest_price.to_s + ')',
                            color: Stonkboard::Colors.ticker_down
                        })
                    end

                    return market_movers
                end

                def ticker_info(symbol)
                    stats = @client.key_stats(symbol)
                    logo = @client.logo(symbol)
                    return {
                        name: stats.company_name,
                        image: logo.url
                    }
                end
    
                def quote(symbol)
                    return @client.quote(symbol)
                end
    
                def chart(symbol, period='1d', interval=10)
                    return client.chart(symbol, period, chart_interval: interval)
                end

                def intraday_chart(symbol, interval=10, tail=false)
                    return iexchart = client.get('/stock/' + symbol + '/intraday-prices', 
                        chartIEXOnly: true,
                        chartSimplify: true,
                        chartInterval: interval,
                        token: iex_secret_key
                    )
                end
            end
        end
    end
end