
-- test lines in kml
-- check order of lines

set head off
set feedb off
set linesize 120 
set trim on

column cityname noprint

spool fi_rte.kml

select add_top_doc ( 'lots of locations with a doubt' ) from dual ;

-- select '<Folder><name>first folder</name>' from dual ;

-- select fl_show_lctn ( l.loc_id ) from fl_lctn l where l.loc_id  < 40
-- order by l.loc_id ; 

-- select '</Folder>' from dual ;


select '<Folder><name>locations with doubt</name>' from dual ;

with list  as ( select /*+ MATERIALIZE */ 
 l.loc_id, l.rte_in, l.rte_out
from fl_v_lctn l
where 1=1 
  and hiding_id = 32 -- frankivo
order by l.hiding_date
)
select 
--   fl_mk_plcmrk_line ( list.rte_in )   -- error in this set... 
    fl_mk_plcmrk_lctn ( list.loc_id )  
-- , fl_mk_plcmrk_line ( list.rte_out )  
from list 
where 1=1
/

select '</Folder>' from dual ;

select add_end_doc from dual;

spool off



