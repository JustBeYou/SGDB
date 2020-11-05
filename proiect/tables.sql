/**
 * Stock Exchange Tables
 *
 * This file contains all table definitions and their mandatory
 * triggers like auto-incrementing and default imformation generating.
 *
 * Note: As SQL is no aware of custom type we will annotate each
 * column with a comment to specify the PL/SQL scalar type
 */

--- Security
create table security (
    ticker         /*abbreviation*/    varchar2(10) not null,
    name           /*long_thing_name*/ varchar2(256) not null,
    total_shares   /*quantity*/        number(15) default 0 not null check (total_shares > 0),
    last_ask_price /*quantity*/        number(15) default 0 not null,
    last_bid_price /*quantity*/        number(15) default 0 not null,
    type           /*type_string*/     varchar2(16) not null,
    
    constraint security_pk primary key (ticker)
);

--- Holder
create table holder (
    -- social security number/registration number
    legal_id         /*thing_name*/      varchar2(64) not null,
    legal_name       /*long_thing_name*/ varchar2(256) not null,
    legal_status     /*type_string*/     varchar2(16) not null check (legal_status in ('PERSON', 'COMPANY')),
    physical_address /*long_thing_name*/ varchar2(256) not null,
    billing_address  /*long_thing_name*/ varchar2(256) not null,
    email            /*thing_name*/      varchar2(64) unique not null,
    phone            /*thing_name*/      varchar2(64) unique not null,
    
    constraint holder_pk primary key (legal_id)
);

--- Account
create table account (
    id        /*id*/         integer not null,
    holder_id /*thing_name*/ varchar2(64) not null,
    capital  /*quantity*/    number(15) default 0 not null,
    
    constraint account_pk primary key (id),
    constraint holder_fk 
        foreign key (holder_id)
        references holder(legal_id)
);

create sequence account_ids start with 1;
create or replace trigger account_auto_id 
before insert on account
for each row
begin
  select account_ids.nextval
  into   :new.id
  from   dual;
end;
/

--- account Owns security
create table own (
    account_id /*id*/           integer not null,
    ticker     /*abbreviation*/ varchar2(10) not null,
    amount     /*quantity*/     number(15) not null,
    
    constraint own_pk primary key (account_id, ticker),
    
    constraint owner_fk
        foreign key (account_id)
        references account(id),
    constraint owned_fk
        foreign key (ticker)
        references security(ticker)
);

--- Quotation
create table quotation (
    id /*id*/ integer not null,

    type      /*type_string*/ varchar2(16) not null check (type in ('ASK', 'BID')),
    fulfilled /*status*/      char default 0 not null check (fulfilled in (0, 1)),
    deleted   /*status*/      char default 0 not null check (deleted in (0, 1)),

    ticker     /*abbreviation*/ varchar2(10) not null,
    account_id /*id*/           integer not null,
    
    amount    /*quantity*/ number(15) not null,
    remaining /*quantity*/ number(15) not null,
    price     /*quantity*/ number(15) not null,
    
    constraint quotation_pk primary key (id),
    
    constraint quoter_fk
        foreign key (account_id)
        references account(id),
    constraint asset_fk
        foreign key (ticker)
        references security(ticker)
);

create sequence quotation_ids start with 1;
create or replace trigger quotation_auto_id 
before insert on quotation
for each row
begin
  select quotation_ids.nextval
  into   :new.id
  from   dual;
end;
/

--- Trade
create table trade (
    id     /*id*/ integer not null,
    ask_id /*id*/ integer not null,
    bid_id /*id*/ integer not null,

    asker_account_id        /*id*/ integer not null,
    bidder_account_id       /*id*/ integer not null,
    market_maker_account_id /*id*/ integer not null,
    time timestamp with time zone,
    
    ticker       /*abbreviation*/ varchar2(10) not null,
    amount       /*quantity*/     number(15) not null,
    price        /*quantity*/     number(15) not null,
    spread_price /*quantity*/     number(15) not null,
    
    constraint trade_pk primary key (id, ask_id, bid_id),
    
    constraint ask_fk
        foreign key (ask_id)
        references quotation(id),
    constraint bid_fk
        foreign key (bid_id)
        references quotation(id),
        
    constraint asker_account_fk
        foreign key (asker_account_id)
        references account(id),
    constraint bidder_account_fk
        foreign key (bidder_account_id)
        references account(id),
    constraint market_maker_account_fk
        foreign key (market_maker_account_id)
        references account(id),
    
    constraint traded_asset_fk
        foreign key (ticker)
        references security(ticker)
);

create sequence trade_ids start with 1;
create or replace trigger trade_auto_id 
before insert on trade
for each row
begin
  select trade_ids.nextval
  into   :new.id
  from   dual;
end;
/

--- Security Types

create table security_type_info (
    name /*thing_name*/ varchar2(64) not null,
    fee  /*percentage*/ number(5, 3) default 0.02 not null,
    
    constraint security_type_info_pk primary key (name)
);

CREATE TRIGGER new_security_type AFTER CREATE
    ON SCHEMA
    DECLARE
    BEGIN
        FOR ctable IN (
            SELECT a.table_name
            FROM all_tables a
            WHERE a.table_name LIKE '%_SECURITY'
             AND a.table_name NOT IN (
                    SELECT b.name as table_name from
                    security_type_info b
                )
        ) LOOP
            INSERT INTO security_type_info (name)
            VALUES (ctable.table_name);
        END LOOP;
    END;
/

create table stock_security (
    ticker /*abbreviation*/ varchar2(10) not null,
    constraint stock_security_pk primary key (ticker),
    constraint stock_security_fk
        foreign key (ticker)
        references security(ticker),
    
    type           /*type_string*/ varchar2(16) not null check (type in ('COMMON', 'PREFERRED')),
    pays_dividents /*status*/      char default 0 not null check (pays_dividents in (0, 1))
);

create table fund_security (
    ticker /*abbreviation*/ varchar2(10) not null,
    constraint fund_security_pk primary key (ticker),
    constraint fund_security_fk
        foreign key (ticker)
        references security(ticker),
    
    type /*type_string*/ varchar2(16) not null check (type in ('HEDGE', 'MUTUAL', 'BOND'))
);

create table bond_security (
    ticker /*abbreviation*/ varchar2(10) not null,
    constraint bond_security_pk primary key (ticker),
    constraint bond_security_fk
        foreign key (ticker)
        references security(ticker),
    
    interest_rate /*percentage*/ number(5, 3) not null check (interest_rate >= 0.01)
);