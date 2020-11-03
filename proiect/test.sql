select * from own;
select * from quotation;


EXECUTE stock_exchange.ask(6, 'VU', 1, 1);

SELECT o.amount
        FROM own o
        WHERE o.account_id = 6 AND 
            o.ticker = 'VU' AND
            o.amount >= 1;