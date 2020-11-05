/**
 * Stock Exchange Types Package
 * 
 * This file contains all generic types used for our 
 * computations. They are used to reduce the confusion and 
 * redundancy of using base types like varchar2(XXX) and number(X, Y)
 */
 
CREATE OR REPLACE TYPE threshold_fee_pair AS OBJECT (
    threshold  number(15),
    fee_factor number(5, 3),
    MEMBER FUNCTION above(to_test number) RETURN char
);
/

CREATE OR REPLACE TYPE BODY threshold_fee_pair AS
    MEMBER FUNCTION above(to_test number) RETURN char IS
    BEGIN
        IF (self.threshold <= to_test) THEN
            RETURN 1;
        END IF;
        
        RETURN 0;
    END above;
END;
/
 
CREATE OR REPLACE PACKAGE se_types AS
    SUBTYPE id IS integer;
    SUBTYPE quantity IS number(15);       -- for prices/shares
    SUBTYPE type_string IS varchar2(16);  -- for statuses and row types
    SUBTYPE abbreviation IS varchar2(10); -- for abbreviated names like tickers
    SUBTYPE thing_name IS varchar2(64);  -- common names like legal name
    SUBTYPE long_thing_name IS varchar2(256); -- long names like companies
    SUBTYPE status IS char; -- for statuses, from 0 to 255
    SUBTYPE percentage IS number(5, 3); -- for numbers expressing percentages (ex. 0.1 = 10%)
    TYPE thresholds_array IS TABLE OF threshold_fee_pair; 
END se_types;
/