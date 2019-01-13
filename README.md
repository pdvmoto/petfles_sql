# petfles_sql

code to extract and calculate petfles-results


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

