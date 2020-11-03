CREATE OR REPLACE PACKAGE stock_exchange AS
    PROCEDURE ask(
            acc_id account.id%type, 
            tic security.ticker%type, 
            amount_to_sell own.amount%type,
            sell_price quotation.price%type
    );
    
    PROCEDURE bid(
        acc_id account.id%type,
        tic security.ticker%type, 
        amount_to_buy own.amount%type,
        buy_price quotation.price%type
    );
    
    PROCEDURE cancel_ask(
        quot_id quotation.id%type
    );
    
    PROCEDURE cancel_bid(
        quot_id quotation.id%type
    );
    
    PROCEDURE capital_transaction(
        acc_id account.id%type,
        amount account.capital%type
    );
    
    PROCEDURE shares_transaction(
        acc_id account.id%type,
        tic own.ticker%type,
        alter_amount own.amount%type
    );
END stock_exchange; 
/

CREATE OR REPLACE PACKAGE BODY stock_exchange AS
    PROCEDURE exception_fallback IS
    BEGIN
        dbms_output.put_line(SUBSTR( DBMS_UTILITY.format_error_stack 
            || DBMS_UTILITY.format_error_backtrace, 1, 4000));
    END exception_fallback;

    PROCEDURE ask(
        acc_id account.id%type, 
        tic security.ticker%type, 
        amount_to_sell own.amount%type,
        sell_price quotation.price%type
    ) IS
    BEGIN
        shares_transaction(acc_id, tic, -amount_to_sell);
        
        INSERT INTO quotation (type, ticker, account_id, amount, price)
        VALUES ('ASK', tic, acc_id, amount_to_sell, sell_price);
        COMMIT;
    EXCEPTION
        WHEN others THEN
            exception_fallback;
    END ask;
    
    PROCEDURE bid(
        acc_id account.id%type,
        tic security.ticker%type, 
        amount_to_buy own.amount%type,
        buy_price quotation.price%type
    ) IS
        current_capital account.capital%type;
        current_amount own.amount%type;
        to_pay account.capital%type := -(amount_to_buy * buy_price);
        
        CURSOR c_own IS
            SELECT o.amount
            FROM own o
            WHERE o.account_id = acc_id and ticker = tic;
    BEGIN
        OPEN c_own;
        
        FETCH c_own INTO current_amount;
        IF c_own%notfound THEN
            INSERT INTO own (account_id, ticker, amount)
            VALUES (acc_id, tic, 0);
            COMMIT;
        END IF;
        
        CLOSE c_own;
        
        capital_transaction(acc_id, to_pay);
        
        INSERT INTO quotation (type, ticker, account_id, amount, price)
        VALUES ('BID', tic, acc_id, amount_to_buy, buy_price);
        COMMIT;
    EXCEPTION
        WHEN others THEN
            exception_fallback;
    END bid;
    
    
    PROCEDURE cancel_ask(
        quot_id quotation.id%type
    ) IS
        to_return quotation.amount%type;
        acc_id quotation.account_id%type;
        tic quotation.ticker%type;
        selected_quot quotation%rowtype;
        
        CURSOR c_quot IS
            SELECT *
            FROM quotation q
            WHERE q.id = quot_id and q.type = 'ASK' 
                and q.deleted = 0 and q.fulfilled = 0
            FOR UPDATE OF q.deleted;
            
        not_found EXCEPTION;
    BEGIN
        OPEN c_quot;
        
        FETCH c_quot into selected_quot;
        IF c_quot%notfound THEN
            RAISE not_found;
        END IF;
        
        to_return := selected_quot.amount;
        acc_id := selected_quot.account_id;
        tic := selected_quot.ticker;
        UPDATE quotation q
        SET q.deleted = 1
        WHERE q.id = quot_id;
        
        COMMIT;
        CLOSE c_quot;
        
        shares_transaction(acc_id, tic, to_return); 
        COMMIT;
    EXCEPTION
        WHEN not_found THEN
            dbms_output.put_line('Quotation not found');
        WHEN others THEN
            exception_fallback;
    END cancel_ask;
    
    PROCEDURE cancel_bid(
        quot_id quotation.id%type
    ) IS
        to_return quotation.price%type;
        acc_id quotation.account_id%type;
        tic quotation.ticker%type;
        selected_quot quotation%rowtype;
        
        CURSOR c_quot IS
            SELECT *
            FROM quotation q
            WHERE q.id = quot_id and q.type = 'BID' 
                and q.deleted = 0 and q.fulfilled = 0
            FOR UPDATE OF q.deleted;
            
        not_found EXCEPTION;
    BEGIN
        OPEN c_quot;
        
        FETCH c_quot INTO selected_quot;
        IF c_quot%notfound THEN
            RAISE not_found;
        END IF;
        
        to_return := selected_quot.amount * selected_quot.price;
        acc_id := selected_quot.account_id;
        tic := selected_quot.ticker;
        UPDATE quotation q
        SET q.deleted = 1
        WHERE q.id = quot_id;
        
        COMMIT;
        CLOSE c_quot;
        
        capital_transaction(acc_id, to_return);
        COMMIT;
    EXCEPTION
        WHEN not_found THEN
            dbms_output.put_line('Quotation not found');
        WHEN others THEN
            exception_fallback;
    END cancel_bid;
    
    PROCEDURE capital_transaction(
        acc_id account.id%type,
        amount account.capital%type
    ) IS
        current_capital account.capital%type;
        
        CURSOR c_account IS
            SELECT a.capital
            FROM account a
            WHERE a.id = acc_id and a.capital + amount >= 0
            FOR UPDATE OF a.capital;
        
        under_zero EXCEPTION;
    BEGIN
        OPEN c_account;
    
        FETCH c_account INTO current_capital;
        IF c_account%notfound THEN
            RAISE under_zero;
        END IF;
        
        UPDATE account a
        SET a.capital = current_capital + amount
        WHERE a.id = acc_id;
    
        COMMIT;
        CLOSE c_account;
    EXCEPTION
        WHEN under_zero THEN
            dbms_output.put_line('Insufficient funds.');
        WHEN others THEN
            exception_fallback;
    END capital_transaction;
    
    PROCEDURE shares_transaction(
        acc_id account.id%type,
        tic own.ticker%type,
        alter_amount own.amount%type
    ) IS
        current_amount own.amount%type;
    
        CURSOR c_own IS
            SELECT o.amount
            FROM own o
            WHERE o.account_id = acc_id AND 
                o.ticker = tic AND
                o.amount + alter_amount >= 0
            FOR UPDATE OF o.amount;
            
        under_zero EXCEPTION;
    BEGIN
        OPEN c_own;
        
        FETCH c_own INTO current_amount;
        IF c_own%notfound THEN
            RAISE under_zero; 
        END IF;
        
        UPDATE own o
        SET o.amount = current_amount + alter_amount
        WHERE o.account_id = acc_id and o.ticker = tic;
       
        COMMIT;
        CLOSE c_own;
    EXCEPTION
        WHEN under_zero THEN
            dbms_output.put_line('Insufficient shares of ' || tic);
        WHEN others THEN
            exception_fallback;
    END shares_transaction;
END stock_exchange; 
/