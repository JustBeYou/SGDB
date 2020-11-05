select * from own;
select * from quotation;
select * from account;
select * from security;
select * from security_type_info;
select * from trade;

SELECT SUM((t.price + t.spread_price) * t.amount)
        FROM trade t
        WHERE t.asker_account_id = 5 OR t.bidder_account_id = 5;

SELECT sti.fee
        FROM security_type_info sti, security s
        WHERE sti.name = s.type AND s.ticker = 'AV';

SELECT a.table_name
            FROM all_tables a
            WHERE a.table_name LIKE '%_SECURITY'
             AND a.table_name NOT IN (
                    SELECT b.name as table_name from
                    security_type_info b
                );

EXECUTE dbms_output.put_line(se_core.calculate_fees(5, 'AE', 100, 510));
EXECUTE se_core.bid(5, 'AE', 300, 510);

EXECUTE se_core.trade(2, 12);

EXECUTE se_core.shares_transaction(5, 'EA', 100);

EXECUTE stock_exchange.ask(6, 'VU', 1, 1);
EXECUTE stock_exchange.bid(5, 'VU', 100, 10);
EXECUTE stock_exchange.cancel_ask(1);
SELECT o.amount
        FROM own o
        WHERE o.account_id = 6 AND 
            o.ticker = 'VU' AND
            o.amount >= 1;

EXECUTE dbms_output.put_line(stock_exchange.quot_fees('FUND_SECURITY'));