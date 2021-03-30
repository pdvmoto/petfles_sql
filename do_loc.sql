
-- test lines in kml
-- check order of lines

set head off
set feedb off
set linesize 120 
set trim on

column cityname noprint

spool rte_locs.kml

select add_top_doc ( 'lots of locations with a doubt' ) from dual ;

-- select '<Folder><name>first folder</name>' from dual ;

-- select fl_show_lctn ( l.loc_id ) from fl_lctn l where l.loc_id  < 40
-- order by l.loc_id ; 

-- select '</Folder>' from dual ;


select '<Folder><name>locations with doubt</name>' from dual ;

with list  as ( select /*+ MATERIALIZE */ l.city as cityname , l.loc_id
from fl_lctn l
where l.city in (select  city 
                   from fl_chk_city 
                   where marker = 1 
                     and city >= 'O') 
order by upper ( l.city )
)
select cityname
, fl_show_lctn ( list.loc_id )  
from list 
where rownum < 100;   

select '</Folder>' from dual ;

select add_end_doc from dual;

spool off



