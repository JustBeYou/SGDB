/**
 * Stock Exchange Core Package
 * 
 * This file contains all core functionalities for:
 * - bidding 
 * - asking
 * - cancelation
 * - calculating fees
 * - capital and asset transfers
 * - logging trades
 */

CREATE OR REPLACE PACKAGE se_core AS
    PROCEDURE ask(
            acc_id         se_types.id, 
            tic            se_types.abbreviation, 
            amount_to_sell se_types.quantity,
            sell_price     se_types.quantity
    );
    
    PROCEDURE bid(
        acc_id        se_types.id,
        tic           se_types.abbreviation, 
        amount_to_buy se_types.quantity,
        buy_price     se_types.quantity
    );
    
    PROCEDURE cancel_ask(
        quot_id se_types.id
    );
    
    PROCEDURE cancel_bid(
        quot_id se_types.id
    );
    
    PROCEDURE capital_transaction(
        acc_id se_types.id,
        amount se_types.quantity
    );
    
    PROCEDURE shares_transaction(
        acc_id       se_types.id,
        tic          se_types.abbreviation,
        alter_amount se_types.quantity
    );
    
    /*FUNCTION calculate_fees(
        tic se_types.abbreviation,
        amount se_types.quantity,
        price security.last_price%type,
    ) RETURN number;*/
END se_core; 
/

CREATE OR REPLACE PACKAGE BODY se_core AS
    PROCEDURE ask(
        acc_id         se_types.id, 
        tic            se_types.abbreviation, 
        amount_to_sell se_types.quantity,
        sell_price     se_types.quantity
    ) IS
    BEGIN
        shares_transaction(acc_id, tic, -amount_to_sell);
        
        INSERT INTO quotation (type, ticker, account_id, amount, price)
        VALUES ('ASK', tic, acc_id, amount_to_sell, sell_price);
        COMMIT;
    EXCEPTION
        WHEN others THEN
            se_utils.exception_fallback;
    END ask;
    
    PROCEDURE bid(
        acc_id        se_types.id,
        tic           se_types.abbreviation, 
        amount_to_buy se_types.quantity,
        buy_price     se_types.quantity
    ) IS
        current_capital se_types.quantity;
        current_amount  se_types.quantity;
        to_pay          se_types.quantity := -(amount_to_buy * buy_price);
        
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
            se_utils.exception_fallback;
    END bid;
    
    
    PROCEDURE cancel_ask(
        quot_id se_types.id
    ) IS
        to_return     se_types.quantity;
        acc_id        se_types.id;
        tic           se_types.abbreviation;
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
            se_utils.exception_fallback;
    END cancel_ask;
    
    PROCEDURE cancel_bid(
        quot_id se_types.id
    ) IS
        to_return     se_types.quantity;
        acc_id        se_types.id;
        tic           se_types.abbreviation;
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
            se_utils.exception_fallback;
    END cancel_bid;
    
    PROCEDURE capital_transaction(
        acc_id se_types.id,
        amount se_types.quantity
    ) IS
        current_capital se_types.quantity;
        
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
            se_utils.exception_fallback;
    END capital_transaction;
    
    PROCEDURE shares_transaction(
        acc_id       se_types.id,
        tic          se_types.abbreviation,
        alter_amount se_types.quantity
    ) IS
        current_amount se_types.quantity;
    
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
            se_utils.exception_fallback;
    END shares_transaction;
END se_core; 
/