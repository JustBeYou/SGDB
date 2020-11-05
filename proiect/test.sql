select * from own;
select * from quotation;
select * from account;
select * from security;

EXECUTE stock_exchange.ask(6, 'VU', 1, 1);
EXECUTE stock_exchange.bid(5, 'VU', 100, 10);
EXECUTE stock_exchange.cancel_ask(1);
SELECT o.amount
        FROM own o
        WHERE o.account_id = 6 AND 
            o.ticker = 'VU' AND
            o.amount >= 1;

EXECUTE dbms_output.put_line(stock_exchange.quot_fees('FUND_SECURITY'));