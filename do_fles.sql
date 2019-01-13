

set doc on
set verify on
set feedb on
set trimspool on

spool do_fles


/*
do_fles: the code (and instructions) needed to load and analyze fles-data.

instr: 
 - verify that ct_fles was run correctly.

 - get spreadsheet petfles_pdv_v0000.xls.
 - copy in data from BSI or other sources into first sheet.
 - verify column names, date-format DD-MM-YYYY (or other consistent fromat).
 - verify comma/dot for decimals.
 - remove empty lines (not essential, but better)

 - sqldevelloper, connect to correct schema.
  
 - 1. imprt from Excel (wizard) 
 - instructions on sheet2.
 - (*** later: CSV ***)

 - eyeball data in fl_stag 
 - verify views are functioning (detail...)

 - 2. insert missing riders.
 -    optionally: check rider names
 - 3. insert locations and routes.
 - 4. calculate distances (and report some: max-dist, nr-finds, ))
 
 - 5. find and store combis
 - 6. generate maps:
	- riders: top 10 with old function just to verify
	- riders: new system of select-varchars.. 
 	- combis : top 10 combis
	- verify ability to generate adhoc map with max 10 chosen riders.

Checks
 - rider names
 - city names
 - consistent locations and routes ? 


*/


-- re- 1. import from XLS
-- some verify SQL..


-- re-2. import new riders.

-- first view: all distinct rider names from stageing.
create or replace view fl_rider_names as 
( select hiding_rider as rider_name from fl_stag
union 
  select finder_rider from fl_stag
);

-- find new riders, and check for doubles (Later!).
select * from fl_rider_names    
where rider_name not in ( select rider_name from fl_rdrs ) 
order by upper (rider_name)
/

--do the insert first...
insert into fl_rdrs (rider_id, rider_name)
select fl_rdrs_seq.nextval, rider_name from fl_rider_names 
where rider_name not in ( select rider_name from fl_rdrs ) 
/
commit ;

-- now find upper/lower problems
create or replace view fl_rdrs_problems as 
( select rider_id, rider_name 
  from fl_rdrs r
  where exists (
        select 'x' from fl_rdrs u
        where upper(r.rider_name) = upper(u.rider_name)
          and r.rider_id <> u.rider_id
         )
)
/       

/* ***
-- list without outer joins..
select rp.rider_name
, h.hider
, f.found
from fl_rdrs_problems rp
, (select count (*) hider, hiding_rider from fl_stag group by hiding_rider )  h
, (select count (*) found, finder_rider from fl_stag group by finder_rider )  f
where h.hiding_rider = rp.rider_name
  and f.finder_rider = rp.rider_name
order by upper(rider_name)
/
*** */


-- list problem riders, add counts of occurences.
select rp.rider_name
, h.hider
, f.found
from fl_rdrs_problems rp
, (select count (*) hider, hiding_rider from fl_stag group by hiding_rider )  h
, (select count (*) found, finder_rider from fl_stag group by finder_rider )  f
where rp.rider_name = h.hiding_rider (+) 
  and rp.rider_name = f.finder_rider (+) 
order by upper(rider_name)
/

-- store locations, first the mandatory fields, add optional fields later to avoid outer-joins
insert into fl_lctn ( loc_id, fles_id, hiding_id, hiding_date, lat_degr, lon_degr, loc_desc, city, prov )
select seq_id, 1 -- dflt fles =>1 
, h.rider_id, s.hiding_date, s.lat_degr, s.lon_degr, s.loc_desc, s.city, s.prov
from fl_stag s
   , fl_rdrs h
where 1=1
  and h.rider_name = s.hiding_rider 
  and s.hiding_date is not null
  and s.lat_degr    is not null 
/

commit ;

--- -- -- -- -- -- -- -- time to fill routes.. -- -- - -- - -

-- link the to+from loc...
create or replace view fl_view_mk_routes as (
select 
  fl.loc_id fr_loc_id
, tl.loc_id to_loc_id
, decode ( tl.loc_id - fl.loc_id , 1, null, 'BEWARE') as marker
from fl_lctn fl
   , fl_lctn tl 
where tl.loc_id = ( select min ( nxt.loc_id ) -- the next valid location... 
                      from fl_lctn nxt 
                      where nxt.loc_id > fl.loc_id 
                      and nxt.lat_degr    is not null 
                      and nxt.hiding_date is not  null) 
); 



-- genereat the records 
-- later: put more columns in the view.. avoid the joins ?

insert into fl_rtes ( rte_id, fr_loc_id, to_loc_id ,fles_id , rider_id 
, fr_sdo, to_sdo )
select fl_rtes_seq.nextval as rte_id
, rv.fr_loc_id
, rv.to_loc_id
, tl.fles_id
, tl.hiding_id  -- rider that went to hide it at destination...
-- , tl.distance   -- consider fetching distance from fl_stag stageing table 
, SDO_GEOMETRY ( 3001, 8307,      -- from 
     SDO_POINT_TYPE ( fl.lon_degr, fl.lat_degr, NULL ), NULL, NULL )
, SDO_GEOMETRY ( 3001, 8307,      -- to 
     SDO_POINT_TYPE ( tl.lon_degr, tl.lat_degr, NULL ), NULL, NULL )
from fl_view_mk_routes rv
   , fl_lctn fl
   , fl_lctn tl
where 1=1
  and rv.fr_loc_id = fl.loc_id
  and rv.to_loc_id = tl.loc_id
/

commit ; 

-- 4. calculate distances
-- now calcualte some distances...
update fl_rtes
set dist_sdo = SDO_GEOM.SDO_DISTANCE( fr_sdo, to_sdo, 0.0001,'unit=km') 
/

commit ;

-- and report on rides..select rt.dist_sdo as kms
select dist_sdo
     , r.rider_name
     , lt.hiding_date
     , ' from ' || lf.city || ' to ' || lt.city 
from fl_rtes rt
   , fl_lctn lf
   , fl_lctn lt
   , fl_rdrs r
where lf.loc_id = rt.fr_loc_id
  and lt.loc_id = rt.to_loc_id
  and r.rider_id = rt.rider_id
  and dist_sdo > 250
order by dist_sdo desc ;


-- - 5. find and store combis

/* ***
-- verify combis from staging

select distdinct hiding_rider, finder_rider from fl_stag;
select count (*) from ( select distinct hiding_rider, finder_rider from fl_stag) ;

-- select combis from location, this is key-list to start combi (parent) records
select distinct hiding_id, finder_id from fl_v_lctn;
select count (*) from ( select distinct hiding_id, finder_id from fl_v_lctn );

 *** */

prompt 'create table with combis, and calculate contents.

-- now build list to create combi-table: a, b, names, and totals.
-- this will at first contain doubles. remove later..
-- drop table fl_combi;

insert into  fl_combi  (
select distinct hiding_id a, finder_id b
 , ra.rider_name rider_a
 , rb.rider_name rider_b
 , 999 as nr_a_to_b, 999 as nr_b_to_a, 999 as nr_occ
from fl_v_lctn l
   , fl_rdrs ra
   , fl_rdrs rb
where l.hiding_id = ra.rider_id
  and l.finder_id = rb.rider_id 
  );

-- clean up doubles, alphabetically
delete from fl_combi where rider_a > rider_b; 

update fl_combi c
set c.nr_a_to_b = (select nr_occ 
                     from fl_v_combi_cnt l
                    where l.hiding_id = c.a 
                      and l.finder_id = c.b ) 
  , c.nr_b_to_a = (select nr_occ 
                     from fl_v_combi_cnt l
                    where l.hiding_id = c.b 
                      and l.finder_id = c.a ) ;

-- get/set totals and removes nulls                 
update fl_combi c 
set nr_occ =  nvl ( nr_a_to_b, 0) + nvl(nr_b_to_a, 0)
  , nr_a_to_b = nvl (nr_a_to_b, 0)
  , nr_b_to_a = nvl (nr_b_to_a, 0);

select count (*) count_combis from fl_v_combi;

/* *** 

-- show combis
select '@do_combi_layer ' || a || ' '  || b
, c.* from fl_combi  c
where nr_occ is not null order by nr_a_to_b desc, nr_occ desc, rider_a  ;

*** */

-- show some results.
select a, rider_a, b, rider_b, nr_a_to_b, nr_b_to_a, nr_occ
from fl_combi
where nr_occ > 20
order by nr_occ desc;


-- add a few other counts.. : max_find, max_city, max_km
-- per rider
select 
  r.rider_name
, count (*) n_x_hidden
from fl_lctn l
   , fl_rdrs r
where r.rider_id = l.hiding_id
group by r.rider_name
having count (*) > 10 
order by 2 desc ;

select city, count (*) nr_hidden
from fl_lctn 
group by city
having count (*) > 5
order by 2 desc;



spool off


