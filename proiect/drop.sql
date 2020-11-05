/* Just drop everything we ever made */

drop sequence account_ids;
drop sequence quotation_ids;
drop sequence trade_ids;

drop trigger account_auto_id;
drop trigger quotation_auto_id;
drop trigger new_security_type;
drop trigger trade_auto_id;

drop table own;
drop table trade;
drop table quotation;
drop table security_type_info;
drop table stock_security;
drop table fund_security;
drop table bond_security;
drop table security;
drop table account;
drop table holder;

drop package se_core;
drop package se_utils;
drop package se_types;
