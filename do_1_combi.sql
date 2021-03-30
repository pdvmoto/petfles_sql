
-- show a combi, 
-- later: show layer for 1 combi using &1 and &2.
-- check order of lines

set head off
set feedb off
set linesize 120 
set trim on

column cityname noprint
column orderby  noprint

spool combi1.kml

select add_top_doc ( 'show combis' ) from dual ;

-- select '<Folder><name>first comby</name>' from dual ;
-- select '</Folder>' from dual ;

-- the foldername
select '<Folder><name>' || c.rider_a || ' and ' || c.rider_b || '</name>'
from fl_combi c
where a=13 and b=185 ;

with combilist as 
( select /*+ materialize */  rte_in,  loc_id, rte_out
, to_char (hiding_date, 'YYYY-MM-DD') as hiding_date
--,         hiding_date, rider_a, rider_b, hiding_id, finder_id
   from fl_v_combi_loc  c
  where  ( hiding_id = 13 and finder_id = 185) 
     or  ( hiding_id = 185 and finder_id = 13)
order by  hiding_date, loc_id 
) -- materialize the list to sort it.
select 
  fl_mk_plcmrk_line ( rte_in  )  
, fl_mk_plcmrk_lctn ( loc_id  )  
, fl_mk_plcmrk_line ( rte_out )  
from combilist c  ;

select '</Folder>' from dual ;

select add_end_doc from dual;

spool off

