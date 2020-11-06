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
    
    FUNCTION calculate_fees(
        acc_id se_types.id,
        tic    se_types.abbreviation,
        amount se_types.quantity,
        price  se_types.quantity
    ) RETURN se_types.quantity;
    
    PROCEDURE trade(
        ask_id se_types.id,
        bid_id se_types.id
    );
END se_core; 
/

CREATE OR REPLACE PACKAGE BODY se_core AS
    default_market_acc_id se_types.id := 1;

    PROCEDURE ask(
        acc_id         se_types.id, 
        tic            se_types.abbreviation, 
        amount_to_sell se_types.quantity,
        sell_price     se_types.quantity
    ) IS
        fees            se_types.quantity;
    BEGIN
        fees := calculate_fees(acc_id, tic, amount_to_sell, sell_price);
        capital_transaction(acc_id, -fees);
        capital_transaction(default_market_acc_id, fees);
        
        shares_transaction(acc_id, tic, -amount_to_sell);
        
        INSERT INTO quotation (type, ticker, account_id, amount, price, remaining)
        VALUES ('ASK', tic, acc_id, amount_to_sell, sell_price, amount_to_sell);
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
        fees            se_types.quantity;
        
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
        
        fees := calculate_fees(acc_id, tic, amount_to_buy, buy_price);
        capital_transaction(acc_id, -fees);
        capital_transaction(default_market_acc_id, fees);
        
        capital_transaction(acc_id, to_pay);
        
        INSERT INTO quotation (type, ticker, account_id, amount, price, remaining)
        VALUES ('BID', tic, acc_id, amount_to_buy, buy_price, amount_to_buy);
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
    
    FUNCTION calculate_fees(
        acc_id se_types.id,
        tic    se_types.abbreviation,
        amount se_types.quantity,
        price  se_types.quantity
    ) RETURN se_types.quantity IS
        thresholds se_types.thresholds_array;
        fee        se_types.percentage;
        fee_factor se_types.percentage;
        volume     se_types.quantity;
        acc        account%rowtype;
    BEGIN
        -- fee to pay = standard security fee increased by threshold level
        thresholds := se_types.thresholds_array(
            threshold_fee_pair(se_utils.dollars_to_points(0), 0.25),
            threshold_fee_pair(se_utils.dollars_to_points(1000), 0.20),
            threshold_fee_pair(se_utils.dollars_to_points(5000), 0.15),
            threshold_fee_pair(se_utils.dollars_to_points(10000), 0.10),
            threshold_fee_pair(se_utils.dollars_to_points(50000), 0.5),
            threshold_fee_pair(se_utils.dollars_to_points(100000), 0.1)
        );
        
        SELECT * INTO acc
        FROM account a
        WHERE a.id = acc_id;
        
        SELECT COALESCE(SUM((price + spread_price) * amount), 0) INTO volume
        FROM (
            SELECT distinct t.id, t.price, t.amount, t.spread_price
            FROM account a
            INNER JOIN quotation q 
            ON q.account_id = acc_id
            INNER JOIN trade t
            ON (t.ask_id = q.id OR t.bid_id = q.id)
        );
        
        FOR i IN 1 .. thresholds.count LOOP
            IF (thresholds(i).above(volume) = 1) THEN
                fee_factor := thresholds(i).fee_factor;
            END IF;
        END LOOP;
        
        SELECT sti.fee INTO fee
        FROM security_type_info sti, security s
        WHERE sti.name = s.type AND s.ticker = tic;
        
        RETURN CEIL(
            se_utils.increase_by_percent(
                fee * price * amount,
                fee_factor
            )
        );
    EXCEPTION
        WHEN no_data_found THEN 
            dbms_output.put_line('Ticker or account not found.');
        WHEN others THEN
            se_utils.exception_fallback;
    END calculate_fees;

    PROCEDURE trade(
        ask_id se_types.id,
        bid_id se_types.id
    ) IS
        ask                quotation%rowtype;
        bid                quotation%rowtype;
        ask_would_fulfill  se_types.status := 0;
        bid_would_fulfill  se_types.status := 0;
        spread             se_types.quantity;
        shares_to_transfer se_types.quantity;
        trade_price        se_types.quantity;
        
        
        CURSOR c_ask IS
            SELECT *
            FROM quotation q
            WHERE q.id = ask_id
            FOR UPDATE OF fulfilled, remaining;
            
        CURSOR c_bid IS
            SELECT *
            FROM quotation q
            WHERE q.id = bid_id
            FOR UPDATE OF fulfilled, remaining;
            
        not_found EXCEPTION;
        wrong_ticker EXCEPTION;
        invalid_type EXCEPTION;
        not_available EXCEPTION;
        cant_match EXCEPTION;
    BEGIN
        OPEN c_ask;
        OPEN c_bid;
        
        FETCH c_ask INTO ask;
        FETCH c_bid INTO bid;
        IF (c_ask%notfound OR c_bid%notfound) THEN
            RAISE not_found;
        END IF;
        
        IF (ask.type != 'ASK' or bid.type != 'BID') THEN
            RAISE invalid_type;
        END IF;
        
        IF (ask.ticker != bid.ticker) THEN
            RAISE wrong_ticker;
        END IF;
        
        IF (ask.price > bid.price) THEN
            RAISE cant_match;
        END IF;
        
        IF (ask.fulfilled = 1 OR 
            bid.fulfilled = 1 OR 
            ask.deleted = 1 OR 
            bid.deleted = 1) THEN
            RAISE not_available;
        END IF;
        
        spread := bid.price - ask.price;
        trade_price := ask.price;
        shares_to_transfer := LEAST(ask.remaining, bid.remaining);
        
        dbms_output.put_line('Trade ' || shares_to_transfer || 
            ' ' || ask.ticker || ' at price ' || trade_price 
            || ' from ' || ask.account_id || ' to ' || bid.account_id ||
            ' with spread of ' || spread);
            
        IF (shares_to_transfer = ask.remaining) THEN
            ask_would_fulfill := 1;
        END IF;
        
        IF (shares_to_transfer = bid.remaining) THEN
            bid_would_fulfill := 1;
        END IF;
        
        UPDATE quotation q
        SET q.fulfilled = ask_would_fulfill,
            q.remaining = ask.remaining - shares_to_transfer
        WHERE q.id = ask.id;
        
        UPDATE quotation q
        SET q.fulfilled = bid_would_fulfill,
            q.remaining = bid.remaining - shares_to_transfer
        WHERE q.id = bid.id;
        
        capital_transaction(ask.account_id, trade_price * shares_to_transfer);
        shares_transaction(bid.account_id, bid.ticker, shares_to_transfer);
        
        capital_transaction(default_market_acc_id, spread * shares_to_transfer);
        
        INSERT INTO trade (
            ask_id, 
            bid_id, 
            market_maker_account_id,
            time,
            amount,
            price,
            spread_price
        ) VALUES (
            ask.id,
            bid.id,
            default_market_acc_id,
            CURRENT_TIMESTAMP,
            shares_to_transfer,
            trade_price,    
            spread
        );
        
        UPDATE security s
        SET s.last_ask_price = ask.price,
            s.last_bid_price = bid.price
        WHERE s.ticker = bid.ticker;
        
        COMMIT;
        CLOSE c_ask;
        CLOSE c_bid;
    EXCEPTION
        WHEN not_found THEN
            dbms_output.put_line('Could not find quotations');
        WHEN wrong_ticker THEN
            dbms_output.put_line('Ticker is not the same');
        WHEN not_available THEN
            dbms_output.put_line('Quotations not available anymore');
        WHEN invalid_type THEN
            dbms_output.put_line('Quotations have the wrong type');
        WHEN cant_match THEN
            dbms_output.put_line('ASK > BID');
        WHEN others THEN
            se_utils.exception_fallback;
    END;
END se_core; 
/