
-- display 1 or more riders, max 10 layers
-- check order of lines

set serveroutput on

set head off
set feedb off
set linesize 120 
set trim on
set trimspool on
set trimout on
set ver off

column cityname noprint

spool riders.kml

select add_top_doc ( 'Rider-data per layer' ) from dual ;

@do_rider_layer 14 -- bsi
@do_rider_layer 9 -- Amauta
@do_rider_layer 183 -- Ronny Rabbelaar
@do_rider_layer 265 -- frankivo

select add_end_doc from dual ;


spool off

