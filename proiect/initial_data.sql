INSERT ALL
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('292441875', 'DOLORE MODI', 'COMPANY', 'MODI UT VELIT AMET NEQUE', 'EST EST MAGNAM QUISQUAM EST', 'company0@email.com', '+99-222-0')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('406558098', 'PORRO IPSUM VOLUPTATEM PORRO', 'COMPANY', 'LABORE NON UT', 'QUISQUAM SED', 'company1@email.com', '+99-222-1')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('159003943', 'VELIT QUAERAT MAGNAM EIUS', 'COMPANY', 'MAGNAM NEQUE LABORE', 'MAGNAM NEQUE LABORE UT', 'company2@email.com', '+99-222-2')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('045014404', 'PORRO AMET UT QUIQUIA', 'PERSON', 'VOLUPTATEM CONSECTETUR DOLOR', 'EST NEQUE PORRO ADIPISCI AMET', 'company3@email.com', '+99-222-3')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('630399984', 'AMET LABORE TEMPORA', 'PERSON', 'IPSUM NUMQUAM QUAERAT NEQUE', 'ALIQUAM UT VOLUPTATEM', 'company4@email.com', '+99-222-4')
INTO holder (legal_id, legal_name, legal_status, physical_address, billing_address, email, phone) VALUES ('123456789', 'FAKE STOCK EXCHANGE LTD.', 'COMPANY', 'MARIUS LACATUS NO. 7', 'STEPHAN THE GREAT NO 1453', 'michaeljackson@obama.gov', '07222222')
SELECT * FROM dual;


INSERT ALL
INTO account (holder_id, capital) VALUES ('292441875', 676085700)
INTO account (holder_id, capital) VALUES ('406558098', 541031500)
INTO account (holder_id, capital) VALUES ('159003943', 273866300)
INTO account (holder_id, capital) VALUES ('045014404', 471746000)
INTO account (holder_id, capital) VALUES ('630399984', 52970300)
INTO account (holder_id, capital) VALUES ('123456789', 859847600)
SELECT * FROM dual;


INSERT ALL
INTO security (ticker, name, total_shares, last_price) VALUES ('NMNQD', 'NUMQUAM MAGNAM NEQUE QUAERAT DOLORE', 1529994, 12200)
INTO security (ticker, name, total_shares, last_price) VALUES ('PNDSM', 'PORRO NON DOLOR SIT MODI', 2304192, 9700)
INTO security (ticker, name, total_shares, last_price) VALUES ('VU', 'VOLUPTATEM UT', 4921101, 16600)
INTO security (ticker, name, total_shares, last_price) VALUES ('PPQ', 'PORRO PORRO QUIQUIA', 5737366, 8400)
INTO security (ticker, name, total_shares, last_price) VALUES ('SAS', 'SED ADIPISCI SED', 4596413, 14500)
INTO security (ticker, name, total_shares, last_price) VALUES ('MNVC', 'MAGNAM NUMQUAM VOLUPTATEM CONSECTETUR', 4159389, 10700)
INTO security (ticker, name, total_shares, last_price) VALUES ('AVVQD', 'ALIQUAM VELIT VOLUPTATEM QUAERAT DOLOR', 5051790, 7300)
INTO security (ticker, name, total_shares, last_price) VALUES ('EQ', 'ETINCIDUNT QUIQUIA', 2257247, 2700)
INTO security (ticker, name, total_shares, last_price) VALUES ('IQMEM', 'IPSUM QUISQUAM MODI EIUS MODI', 7133898, 14100)
INTO security (ticker, name, total_shares, last_price) VALUES ('DM', 'DOLORE MODI', 8844956, 3200)
SELECT * FROM dual;


INSERT ALL
INTO own (account_id, ticker, amount) VALUES (6, 'NMNQD', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'PNDSM', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'VU', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'PPQ', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'SAS', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'MNVC', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'AVVQD', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'EQ', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'IQMEM', 1)
INTO own (account_id, ticker, amount) VALUES (6, 'DM', 1)
SELECT * FROM dual;


INSERT ALL
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'NMNQD', 6, 1529993, 12200)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'PNDSM', 6, 2304191, 9700)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'VU', 6, 4921100, 16600)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'PPQ', 6, 5737365, 8400)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'SAS', 6, 4596412, 14500)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'MNVC', 6, 4159388, 10700)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'AVVQD', 6, 5051789, 7300)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'EQ', 6, 2257246, 2700)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'IQMEM', 6, 7133897, 14100)
INTO quotation (type, ticker, account_id, amount, price) VALUES ('ASK', 'DM', 6, 8844955, 3200)
SELECT * FROM dual;

