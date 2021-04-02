
-- do_rd2 : second set of riders
-- display 1 or more riders, max 10 layers
-- 
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

spool rd2.kml

select add_top_doc ( 'Rider-data per layer' ) from dual ;

-- @do_rider_layer 445 -- bsi
-- @do_rider_layer 323 -- Amauta
-- @do_rider_layer 379 -- pdv

@do_rider_layer 586 -- roeleey
@do_rider_layer 482 -- HK
@do_rider_layer 555 -- Coenster
@do_rider_layer 310 -- jaap
@do_rider_layer 324 -- deeffox
@do_rider_layer 357 -- FastEd
@do_rider_layer 614 -- Hans89
@do_rider_layer 319 -- Janhertog
@do_rider_layer 607 -- koen

-- @do_rider_layer 407 -- marsian
-- @do_rider_layer 487 -- okami
-- @do_rider_layer 388 -- outdoor
-- @do_rider_layer 408 -- picobello
-- @do_rider_layer 586 -- roeleey

select add_end_doc from dual ;


spool off

