--- Ticker
create table ticker (
    name varchar2(5) not null,
    total_shares number(15) default 0 not null,
    last_price number(15) default 0 not null,
    
    constraint ticker_pk primary key (name)
);

--- Holder
create table holder (
    -- social security number/registration number
    legal_id varchar2(64) not null,
    
    legal_name varchar2(256) not null,
    legal_status varchar(16) not null check (legal_status in ('PERSON', 'COMPANY')),
    physical_address varchar2(512) not null,
    billing_address varchar2(512) not null,
    email varchar2(64) unique not null,
    phone varchar2(20) unique not null,
    
    constraint holder_pk primary key (legal_id)
);

--- Account
create table account (
    id integer not null,
    holder_id varchar2(64) not null,
    capital number(15) default 0 not null,
    
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

--- account Owns ticker
create table own (
    account_id integer not null,
    ticker_name varchar2(5) not null,
    amount number(15) not null,
    
    constraint own_pk primary key (account_id, ticker_name),
    
    constraint owner_fk
        foreign key (account_id)
        references account(id),
    constraint owned_fk
        foreign key (ticker_name)
        references ticker(name)
);

--- Quotation
create table quotation (
    id integer not null,

    type varchar2(3) not null check (type in ('ASK', 'BID')),
    fulfilled char default 0 not null check (fulfilled in (0, 1)),

    ticker_name varchar2(5) not null,
    account_id integer not null,
    
    amount number(15) not null,
    price number(15) not null,
    
    constraint quotation_pk primary key (id),
    
    constraint quoter_fk
        foreign key (account_id)
        references account(id),
    constraint asset_fk
        foreign key (ticker_name)
        references ticker(name)
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
    ask_id integer not null,
    bid_id integer not null,

    asker_account_id integer not null,
    bidder_account_id integer not null,
    market_maker_account_id integer not null,
    time timestamp with time zone,
    
    ticker_name varchar2(5) not null,
    amount number(15) not null,
    price number(15) not null,
    
    constraint trade_pk primary key (ask_id, bid_id),
    
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
        foreign key (ticker_name)
        references ticker(name)
);