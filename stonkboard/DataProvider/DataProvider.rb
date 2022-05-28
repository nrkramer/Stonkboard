module Stonkboard
    module DataProvider
        class DataProvider
            def market_status()
            end

            def market_movers(gainers=7, losers=7)
            end

            def ticker_info(symbol)
            end

            def quote(symbol)
            end

            def chart(symbol, period='1d', interval=10)
            end

            def intraday_chart(symbol, interval=10, tail=false)
            end
        end
    end
end