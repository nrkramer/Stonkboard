#!/usr/bin/env ruby
require 'date'

require './Watchlist.rb'
require './DataProvider/IEX/Client.rb'

# 1. Read watchlist
# 2. Configure IEX
# 3. Setup DS for tracking
# 4. Begin heartbeat
#   a. Get market hours (every 24h)
#   b. Get market status (every 6h)
#   c. Get company info (once, then if watchlist.json is updated using DirectoryWatcher)
#   d. Get market movers (every 3h)
#   e. Get quote 
#   f. Get chart data (when market open, once when market closed (last trading day) )
#      Fetch interval defined in watchlist, in minutes
#   g. Keep screen on (every 1m using system commands)

module Stonkboard
    module DataProviderBackend
        IEX = 0
    end

    class Stonkboard
        def initialize(data_backend)
            @watchlist = Stonkboard::Watchlist.new
            case data_backend
            when DataProviderBackend::IEX
                @client = Stonkboard::DataProvider::IEX.new
            end

            @heart_beating = false

            @watchlist_data = Hash.new
            @market_status = Hash.new
        end

        def company_data_change(&block)
            @company_data_change_cb = block

        def market_status_change(&block)
            @market_status_change_cb = block
        end

        def movers_data_change(&block)
            @movers_data_change_cb = block
        end

        def watchlist_data_change(&block)
            @watchlist_data_change_cb = block
        end

        def begin_heartbeat()
            if !@heart_beating
                @heart_beating = true

                # Initialize
                @watchlist_data = @watchlist.tickers()
                self.update_company_data()
                self.update_market_status()

                # Update company data
                SCHEDULER.every '24h', :first_in => 0 do |job|
                    self.update_company_data()
                end
                # Update market status
                SCHEDULER.every '6h', :first_in => 0 do |job|
                    self.update_market_status()
                end
                # Update movers
                SCHEDULER.every '3h', :first_in => 0 do |job|
                    self.update_movers()
                end
                # Update watchlist data
                SCHEDULER.every (@watchlist.chart_update_interval() + 'm'), :first_in => 0 do |job|
                    self.update_watchlist_data()
                end
            else
                puts "Stonkboard heart already beating."
            end
        end

        private

        # Update immediately at start
        # Update during market open
        # Update once after market closes
        def do_market_open_based_update(key)
            if (!@market_status.key?(key))
                @market_status[:key] = Hash.new 
            end
            truthiness = @market_status[:open] || (@market_status[:key][lastStatus] != @market_status[:open])
            @market_status[:key][lastStatus] = @market_status[:open]

            return truthiness
        end

        def update_company_data()
            @watchlist_data.each do |symbol|
                @watchlist_data[:symbol][:info] = @client.ticker_info(symbol)
            end
            @company_data_change_cb(@watchlist_data)
        end

        def update_market_status()
            @market_status[:open] = @client.market_status()
            @market_status_change_cb(@market_status)
        end

        def update_movers()
            if (self.do_market_open_based_update(:movers))
                movers_data = @client.market_movers()
                @movers_data_change_cb(movers_data)
            end
        end

        def update_watchlist_data()
            if (self.do_market_open_based_update(:watchlist))
                @watchlist_data.each do |symbol|
                    
                end
            end
        end
    end
end