# petfles_sql

Code to extract and calculate petfles-results

TL;DR: 
Run the create-script and run the import script.
you will then find your data in the tble fl_stag (stageing);
for postgres: pg_ct_fles.sql
for oracle  : ct_fles.sql
import-script into either database: impport_<date>.sql, insert-stmnts that work in both databases...
as of 01-Apr: 3857 records.
Have fun SQL-ing.
/TL;DR


More complete description, 
and how to put data in to "proper" tables for locations and routes, 
read on....:

Purpose is to store + share the SQL code for "petfles"
(and to explore github)

Source of data is the petfles-XLS from BSI.

Template xls petfles_pdv_version<n>

ct_fles.sql: Creation of database objects (stageing-table, data-tables, views, pl/sql objects)

do_fles.sql: processing code, idially this sql runs+creates all output.

Processing can happen in an Oracle or PostgreSQL database

Data goes into a stageing table : FL_STAG
processing by SQL and PL/SQL, using do_fles.sql
Output should be spooled to text-files *.lst: top-finds, top-kms, top-locations....

todo items
 - soundex or diff to find typos in rider-names and city-names.
 - use do_fles to  produce files with various result-lists
 - list of anomalies in original-data
 - lists per year: rider-finds, rider-kms...
 - read from XLS - which tool would work... ? (sql-dev is very convenient) 

