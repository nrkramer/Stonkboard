#!/usr/bin/env ruby

module Stonkboard
    class Watchlist
        attr_reader :watchlist_path
        attr_reader :watchlist

        def initialize(watchlist_path=ENV['WATCHLIST_PATH'])
            @watchlist_path = watchlist_path
            @watchlist = JSON.parse(File.read(@watchlist_path))
        end

        def tickers()
            return @watchlist.stocks.keys
        end

        def chart_tickers()
            return @watchlist.stocks.select { |item| item.has_key('chart') }
        end

        def chart_update_interval()
            if @watchlist.chartUpdateInterval < 1
                return 1
            end
            
            return @watchlist.chartUpdateInterval
        end
    end
end
