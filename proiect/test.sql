select * from own;
select * from quotation;
select * from account;
select * from security;

EXECUTE stock_exchange.ask(5, 'VU', 6, 1);
EXECUTE stock_exchange.bid(5, 'VU', 100, 10);
EXECUTE stock_exchange.cancel_bid(31);
SELECT o.amount
        FROM own o
        WHERE o.account_id = 6 AND 
            o.ticker = 'VU' AND
            o.amount >= 1;