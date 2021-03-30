

-- show 10 largest combis (or whatever in wherclause)
-- call do_1_combi a b
-- check order of lines

set head off
set feedb off
set linesize 120 
set trim on

column cityname noprint
column orderby  noprint

-- spool combi1.kml

-- select add_top_doc ( 'show combis' ) from dual ;

-- select '<Folder><name>first comby</name>' from dual ;
-- select '</Folder>' from dual ;

-- the foldername
select '<Folder><name>' 
       || c.rider_a || ' (' ||to_char(nr_a_to_b) || ') and ' 
       || c.rider_b || ' (' ||to_char(nr_b_to_a) || ')</name>'
from fl_combi c
where a=&1 and b=&2 ;

-- generate the elements for this layer
with combilist as 
( select /*+ materialize */  rte_in,  loc_id, rte_out
--, to_char (hiding_date, 'YYYY-MM-DD') as hiding_date
--,         hiding_date, rider_a, rider_b, hiding_id, finder_id
   from fl_v_combi_loc  c
  where  ( hiding_id = &1 and finder_id = &2) 
     or  ( hiding_id = &2 and finder_id = &1)
order by  hiding_date, loc_id 
) -- materialize the list to sort it.
select 
  fl_mk_plcmrk_line ( rte_in  )  
, fl_mk_plcmrk_lctn ( loc_id  )  
, fl_mk_plcmrk_line ( rte_out )  
from combilist c  ;

-- close the folder
select '</Folder>' from dual ;

-- select add_end_doc from dual;


