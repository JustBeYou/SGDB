CREATE OR REPLACE PACKAGE stock_exchange AS
    PROCEDURE ask(
            acc_id account.id%type, 
            tic security.ticker%type, 
            amount_to_sell own.amount%type,
            sell_price quotation.price%type
    );
END stock_exchange; 
/

CREATE OR REPLACE PACKAGE BODY stock_exchange AS  
    PROCEDURE ask(
        acc_id account.id%type, 
        tic security.ticker%type, 
        amount_to_sell own.amount%type,
        sell_price quotation.price%type
    ) IS
        current_amount own.amount%type;
        CURSOR c_own IS
            SELECT o.amount
            FROM own o
            WHERE o.account_id = acc_id AND 
                o.ticker = tic AND
                o.amount >= amount_to_sell
            FOR UPDATE OF o.amount;
            
        not_enough EXCEPTION;
    BEGIN
        OPEN c_own;
        
        FETCH c_own INTO current_amount;
        
        IF c_own%notfound THEN
            RAISE not_enough; 
        END IF;
        
        UPDATE own o
        SET o.amount = current_amount - amount_to_sell
        WHERE o.account_id = acc_id and o.ticker = tic;
       
        COMMIT;
        CLOSE c_own;
        
        INSERT INTO quotation (type, ticker, account_id, amount, price)
        VALUES ('ASK', tic, acc_id, amount_to_sell, sell_price);
    EXCEPTION
        WHEN not_enough THEN
            dbms_output.put_line('Insufficient shares of ' || tic);
        WHEN others THEN
            dbms_output.put_line(SUBSTR( DBMS_UTILITY.format_error_stack 
            || DBMS_UTILITY.format_error_backtrace, 1, 4000));
    END ask;
END stock_exchange; 
/