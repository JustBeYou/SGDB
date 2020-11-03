INSERT ALL
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('202435493', 'VOLUPTATEM MODI', 'PERSON', 'ALIQUAM LABORE QUIQUIA', 'TEMPORA ALIQUAM VELIT', 'company0@email.com', '+99-222-0')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('686667799', 'PORRO LABORE NEQUE', 'COMPANY', 'NUMQUAM SIT DOLOREM LABORE LABORE', 'DOLOREM DOLOREM PORRO', 'company1@email.com', '+99-222-1')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('949192552', 'VOLUPTATEM ADIPISCI PORRO', 'COMPANY', 'ETINCIDUNT UT QUAERAT', 'DOLORE DOLOR MODI MODI DOLORE', 'company2@email.com', '+99-222-2')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('947986045', 'ALIQUAM NUMQUAM QUISQUAM', 'COMPANY', 'SIT NEQUE NEQUE EIUS NUMQUAM', 'PORRO MAGNAM AMET', 'company3@email.com', '+99-222-3')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('621165078', 'NUMQUAM DOLOREM', 'COMPANY', 'SIT ADIPISCI', 'ALIQUAM SED LABORE ALIQUAM AMET CONSECTETUR', 'company4@email.com', '+99-222-4')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('123456789', 'FAKE STOCK EXCHANGE LTD.', 'COMPANY', 'MARIUS LACATUS NO. 7', 'STEPHAN THE GREAT NO 1453', 'michaeljackson@obama.gov', '07222222')
SELECT * FROM dual;


INSERT ALL
INTO account (holder_id, capital) VALUES ('202435493', 525151300)
INTO account (holder_id, capital) VALUES ('686667799', 549706700)
INTO account (holder_id, capital) VALUES ('949192552', 765544200)
INTO account (holder_id, capital) VALUES ('947986045', 507507100)
INTO account (holder_id, capital) VALUES ('621165078', 252824600)
INTO account (holder_id, capital) VALUES ('123456789', 152861000)
SELECT * FROM dual;


INSERT ALL
INTO ticker (name, total_shares, last_price) VALUES ('GRH', 6397791, 5300)
INTO ticker (name, total_shares, last_price) VALUES ('WAL', 4347179, 18900)
INTO ticker (name, total_shares, last_price) VALUES ('CLC', 3430845, 7200)
INTO ticker (name, total_shares, last_price) VALUES ('WUJ', 251671, 4000)
INTO ticker (name, total_shares, last_price) VALUES ('XYZ', 5208219, 14000)
INTO ticker (name, total_shares, last_price) VALUES ('WHX', 4312267, 100)
INTO ticker (name, total_shares, last_price) VALUES ('DHG', 9505716, 6600)
INTO ticker (name, total_shares, last_price) VALUES ('YLO', 4477336, 19200)
INTO ticker (name, total_shares, last_price) VALUES ('EID', 3296240, 8000)
INTO ticker (name, total_shares, last_price) VALUES ('JUP', 9998224, 3600)
SELECT * FROM dual;


INSERT ALL
INTO own (account_id, ticker_name, amount) VALUES (6, 'GRH', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'WAL', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'CLC', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'WUJ', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'XYZ', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'WHX', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'DHG', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'YLO', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'EID', 0)
INTO own (account_id, ticker_name, amount) VALUES (6, 'JUP', 0)
SELECT * FROM dual;


INSERT ALL
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'GRH', 6, 6397791, 5300)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'WAL', 6, 4347179, 18900)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'CLC', 6, 3430845, 7200)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'WUJ', 6, 251671, 4000)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'XYZ', 6, 5208219, 14000)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'WHX', 6, 4312267, 100)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'DHG', 6, 9505716, 6600)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'YLO', 6, 4477336, 19200)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'EID', 6, 3296240, 8000)
INTO quotation (type, ticker_name, account_id, amount, price) VALUES ('ASK', 'JUP', 6, 9998224, 3600)
SELECT * FROM dual;

