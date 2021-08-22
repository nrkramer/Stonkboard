# Stonkboard
Buy high, sell low.

![stonkboard](https://user-images.githubusercontent.com/11186620/130344362-ac8eb874-425b-4a56-8099-a61456a28b69.png)

## Description
Stonkboard is a stock dashboard developed to look similar to the iOS stocks app. It includes four widgets:
- The "marquee" ticker-tape at the top
- An individual stock widget, that displays a minute graph of the stock
- A market status widget, that displays if the US stock market is open or not (could easily be adapted for other markets)
- A "market movers" widget, that displays the top 5 gainers and top 5 losers

Stonkboard uses [Smashing](https://github.com/Smashing/smashing/wiki) as its dashboard generator/webserver.

Stonkboard uses [IEX Cloud](https://iexcloud.io/) data for its backend. It also tries to save as many credits as possible. It does this by optimizing when data is queried to during market hours, and only fetches company information and a historic graph once during start-up. It limits grabbing market movers to every 3 hours, and checks the market status every 6 hours.

The overall goal of this project was to create a stock dashboard I could use to load onto a Raspberry Pi, plug into a TV, and have the ticker roll by as I work on other stuff. As a result the project does not only include the smashing stonkboard implementation, but a few other configuration goodies that make it easier to use.

## Requirements

1. [Smashing](https://github.com/Smashing/smashing/wiki)
2. systemd (if using the default `install.sh`)
3. Chromium (if using the default `start.sh`)

## Installing

To install the needed dependencies

```bash
# Install bundler
$ gem install bundler
# Install smashing
$ gem install smashing
# Install the bundle of project specific gems
$ bundle
# Starts stonkboard (also launches chromium)
$ ./start.sh
# Install stonkboard as a service
$ sudo ./install.sh
```

`install.sh` installs `stonkboard.service` into systemd and enables the service. The service is configured to run on boot, when the graphical interface is ready (graphical.target). For installation to work, the script must be run as root.

## Configuration

### API Keys

First, you need to get an IEX secret and publishable API key from [IEX Cloud](https://iexcloud.io/). They have a free 50,000 credits, and a sandbox mode that can be used to test out the dashboard and profile data usage. To use the API keys, you can either include them in a file **or** in environment variables.

#### File

Secret key must be on line 1, and publishable key on line 2:
```
<SECRET_KEY>
<PUBLISHABLE_KEY>
```
Then set the environment variable `IEX_API_KEY_FILE` to point towards the file location.

#### Environment Variables

Simply set the two environment variables correspondingly:
```
IEX_API_SECRET_KEY=<SECRET_KEY>
IEX_API_PUBLIC_KEY=<PUBLISHABLE_KEY>
```

### Watchlist

Second, change the `watchlist.json` to include whatever tickers you're interested in. The more tickers, the more quote data is pulled every minute during market hours. Any ticker with `"chart": true` set will pull chart data during market hours. The empty dictionary for tickers not using chart data is mandatory. Example:
```json
{
    "AAPL" : {},
    "AMD" : { "chart" : true },
    "MSFT" : {}
}
```

## Contributing

Contributions are welcome! Please issue a pull request or write up an issue and I'll try to get to it as soon as I, or other members of the community can.
