class Dashing.Marquee extends Dashing.Widget
    
    initialized = false
    
    round_two =(number) ->
        return +number.toFixed(2);
        
    stock_widget =(symbol) ->
        return $("""
        <span class="stock-marquee-item-#{symbol} stock-marquee-item">
            <h1>#{symbol}</h1>
            <h3>$0</h3>
            <h3>+0.00%</h3>
        </span>
        """)
        
    set_stock_widget_data =(widget, price, pct_change) ->
        elements = widget.children("h3")
        if elements?
            elements.eq(0).text("$" + price)
            change_ele = elements.eq(1)
            change_ele.removeClass();
            if pct_change == 0
                change_ele.val('0.00%')
            else if pct_change > 0
                change_ele.text('+' + pct_change + '%')
                change_ele.addClass('stock-marquee-item-changeup')
            else
                change_ele.text(pct_change + '%')
                change_ele.addClass('stock-marquee-item-changedown')
    
    onData: (data) ->        
        quotes = data.quotes            
    
        if not initialized
            marquee = $('#marquee-container')
            marquee.empty()
            
            for symbol, quote of quotes
                sw = stock_widget(symbol)
                marquee.append(sw)
                set_stock_widget_data(sw, round_two(quote.latest_price), round_two(quote.change_percent))
            
            Marquee3k.init()
            initialized = true
        else
            for symbol, quote of quotes
                console.log(symbol + ' ' + quote.latest_price + ' ' + quote.change_percent)
                $(".stock-marquee-item-#{symbol}").each ->
                    set_stock_widget_data($(this), round_two(quote.latest_price), round_two(quote.change_percent))
                
