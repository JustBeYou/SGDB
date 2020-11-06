EXECUTE dbms_output.put_line(se_core.calculate_fees(5, 'AE', 100, 510));
EXECUTE se_core.capital_transaction(5, -173267900);
SELECT * FROM account WHERE id = 5;

EXECUTE dbms_output.put_line(se_core.calculate_fees(99, 'AE', 100, 510));
EXECUTE dbms_output.put_line(se_core.calculate_fees(5, 'INEXISTENT', 100, 510));

SELECT * FROM quotation;
SELECT * FROM own;

EXECUTE se_core.bid(4, 'NC', 100, 1800); -- quotation.id = 31
EXECUTE se_core.ask(1, 'NC', 1, 1); -- quotation.id = 32
EXECUTE se_core.cancel_ask(32);
-- quotation.id = 1 -> ASK for NC at price 1600

EXECUTE se_core.trade(99, 99);
EXECUTE se_core.trade(30, 31);
EXECUTE se_core.trade(3, 4);
EXECUTE se_core.trade(32, 31);

EXECUTE se_core.trade(1, 31);
SELECT * FROM trade;






CREATE TABLE TEST_SECURITY (
    temp number
);
SELECT * FROM security_type_info;













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

    
        SELECT SUM((price + spread_price) * amount) as total
        FROM (
            SELECT distinct t.id, t.price, t.amount, t.spread_price
            FROM account a
            INNER JOIN quotation q 
            ON q.account_id = 5
            INNER JOIN trade t
            ON (t.ask_id = q.id OR t.bid_id = q.id)
        );

SELECT a.table_name
            FROM all_tables a
            WHERE a.table_name LIKE '%_SECURITY'
             AND a.table_name NOT IN (
                    SELECT b.name as table_name from
                    security_type_info b
                );

EXECUTE dbms_output.put_line(se_core.calculate_fees(5, 'AE', 100, 510));
EXECUTE se_core.bid(5, 'AE', 300, 610);

EXECUTE se_core.trade(21, 33);

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