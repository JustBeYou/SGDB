/**
 * Stock Exchange Utils Package
 * 
 * This file contains utilitary functions like
 * default exception handling and other boilerplate.
 */

CREATE OR REPLACE PACKAGE se_utils AS
    PROCEDURE exception_fallback;
END;
/

CREATE OR REPLACE PACKAGE BODY se_utils AS
    PROCEDURE exception_fallback IS
    BEGIN
        dbms_output.put_line(SUBSTR( DBMS_UTILITY.format_error_stack 
            || DBMS_UTILITY.format_error_backtrace, 1, 4000));
    END exception_fallback;
END;
/