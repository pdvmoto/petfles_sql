

-- add layer with rider info: layer, find-loc, line..
-- call from show riders 
-- check order of lines

set head off
set feedb off
set linesize 120 
set trim on
set trimspool on

column cityname noprint
column orderby  noprint

-- the foldername: rider, finds, kms..
with rdr as ( select rd.rider_name
, count (*) finds
, sum (rt.dist_sdo) as kms
from fl_rdrs rd
    , fl_rtes rt
 where rt.rider_id = rd.rider_id
   and rd.rider_id = &1
group by rd.rider_id, rd.rider_name 
)
select '<Folder><name>' 
  || r.rider_name || ', ' ||  to_char (r.finds) || ' finds, ' 
  || to_char ( r.kms ) || ' km</name>'
from rdr r
/
  

-- generate the elements for this layer
with rtlist  as 
( select /*+ materialize */  
         l.rte_in, l.loc_id, l.rte_out, l.hiding_date
  from fl_v_lctn l
  where l.hiding_id = &1
  order by l.hiding_date
) -- materialize the list to sort it.
select 
  fl_mk_plcmrk_line ( rte_in  )  
, fl_mk_plcmrk_lctn ( loc_id  )  
, fl_mk_plcmrk_line ( rte_out )  
from rtlist l 
order by hiding_date ;

-- close the folder
select '</Folder>' from dual ;

-- select add_end_doc from dual;


