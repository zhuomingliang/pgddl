\pset null _null_
\pset format unaligned

SET client_min_messages = warning;
SET ROLE postgres;

select ddlx_create(oid) from pg_cast where castsource = 'text'::regtype order by casttarget;
select ddlx_drop(oid) from pg_cast where castsource = 'text'::regtype order by casttarget;

CREATE COLLATION "POSIX++" (
  LC_COLLATE = 'POSIX',
  LC_CTYPE = 'POSIX'
);
COMMENT ON COLLATION "POSIX++" IS 'standard POSIX++ collation';

select ddlx_create(oid) from pg_collation where collname in ('POSIX++') order by collname;
select ddlx_drop(oid) from pg_collation where collname in ('POSIX++') order by collname;

CREATE DEFAULT CONVERSION "ascii_to_utf8++"
  FOR 'SQL_ASCII' TO 'UTF8' FROM ascii_to_utf8;
COMMENT ON CONVERSION "ascii_to_utf8++" IS 'conversion++ for SQL_ASCII to UTF8';

select ddlx_create(oid) from pg_conversion where conname in ('ascii_to_utf8++') order by conname;
select ddlx_drop(oid) from pg_conversion where conname in ('ascii_to_utf8++') order by conname;

select ddlx_grants('test_class_r'::regclass::oid);

create operator family opf1 using btree;
comment on operator family opf1 using btree is 'A comment';
select ddlx_create(oid) from pg_opfamily where opfname='opf1';
select ddlx_drop(oid) from pg_opfamily where opfname='opf1';

select ddlx_create_language(oid) from pg_language 
 where lanname in ('internal','c','sql') 
 order by lanname;

-- database
create database ddlx_testdb with encoding=UTF8 template=template0 lc_collate="POSIX" lc_ctype="POSIX";
comment on database ddlx_testdb is 'DDLX Test Database';
alter database ddlx_testdb owner to postgres;
alter database ddlx_testdb connection limit 1234;
begin;
create user ddlx_test_user4;
grant create on database ddlx_testdb to ddlx_test_user4 with grant option;
select ddlx_create(oid) from pg_database where datname='ddlx_testdb';
abort;
drop database ddlx_testdb;

select ddlx_script(oid) from pg_tablespace where spcname='pg_default';

-- schema
create schema ddlx_test_schema1;
comment on schema ddlx_test_schema1 is 'DDLX Test Schema';
grant usage on schema ddlx_test_schema1 to public;
select ddlx_create(oid) from pg_namespace where nspname='ddlx_test_schema1';

-- look for unidentified objects
select classid::regclass,count(*)
  from (
select classid,objid,ddlx_identify(objid) as obj
  from ddlx_get_dependants((select oid from pg_namespace where nspname='public')) d
) a
 where (a.obj).kind is null group by classid
 order by 2 desc, cast(classid::regclass as text) ;

 
 
