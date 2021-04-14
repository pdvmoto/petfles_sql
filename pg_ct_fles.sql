-- temp file to craate tables ct_fles_pg

-- requirement for pg: CUBE and EARTHDISTANCE:
-- create extension cube ;  -- for point operator <@> 
-- create extension earthdistance ;

--
-- note that yuo need psql -qAtX .... (option!) 
-- to prevent info and "+" IN output when generating kml.
-- 

-- drop relevat stuff, in order of dependency.

drop sequence fl_lctn_seq;
drop sequence fl_fljs_seq;
drop sequence fl_rtes_seq;
drop sequence fl_rdrs_seq;

-- drop the views
drop view  fl_v_combi ;
drop view  fl_v_combi_cnt ;
drop view  fl_v_chk_cities ; 
drop view  fl_v_rdrs_problems ; 

drop view  fl_v_lctn ; 
drop view  fl_v_rtes ; 
drop view  fl_view_mk_routes ; 
drop view  fl_rdrs_problems ; 
drop view  fl_v_rider_names ; 

-- drop table fl_stag ; 
-- drop table fl_stag_vc ; 

drop TABLE FL_RTES;
drop TABLE FL_LCTN;

drop TABLE FL_RDRS;
drop TABLE FL_FLJS;

drop table FL_COMBI;

-- now create, ...
-- start with sequences
create sequence fl_fljs_seq ;
create sequence fl_rdrs_seq ;
create sequence fl_lctn_seq ;
create sequence fl_rtes_seq ;



-- drop table fl_rdrs ;
create table fl_rdrs (
  rider_id       integer  not null
, rider_name     varchar(30) not null
-- room for more attributres.. rider_locations, email, telno, etc..
);

-- create unique index fl_rdrs_pk on fl_rdrs ( rider_id  );
create unique index fl_name_uk on fl_rdrs ( rider_name  );

alter table fl_rdrs add constraint fl_rdrs_pk primary key ( rider_id ) ; 

-- drop table fl_fljs ;
create table fl_fljs (
  fles_id         integer not null
, fles_name       varchar (30)
, fles_startdate  timestamp
, fles_enddate    timestamp
-- room for more: picture, dates..
);

-- create unique index fl_fljs_pk on fl_fljs ( fles_id  );
alter table fl_fljs add constraint fl_fljs_pk primary key ( fles_id ) ; 

/*
0...5....1....5....2....5....3....5....4....5....5....5....6....5....7....5....8
*/
-- drop table fl_lctn ;
create table fl_lctn (
  loc_id        integer  not null   -- pk
, fles_id       integer  not null   -- fk
, hiding_id     integer  not null   -- fk, the rider that hid the btl.
, hiding_date   timestamp         default clock_timestamp () not null
, Lat_degr      real  default 52.101       not null   -- from
, lon_degr      real  default  5.645       not null
 -- room for more.. from here on only optional and/or derived attributes...
, loc_desc      varchar(60)         -- text from xls
, hiding_blz    varchar(20)
, finder_blz    varchar(20)
, finder_date   date                    -- fnd-date, via location or the route?
, finder_id     integer             -- needs and FK !
, city          varchar(30)         -- derived or from xls ?
, prov          varchar(3)          -- from xls
, thread_nr           integer       -- constraint : positive integer
, pg_nr_in_thread     integer       -- positive integer
, post_nr_in_thread   integer       -- positive integer
, loc_remarks         varchar(60)
);

-- create unique index                fl_lctn_pk  on fl_lctn ( loc_id  );
alter table fl_lctn add constraint fl_lctn_pk primary key ( loc_id ) ; 

-- prevent accidental double-inserts;
create unique index fl_lctn_uk
                      on fl_lctn (hiding_id, hiding_date , lat_degr ) ;

-- the FKs to rider and fles
alter table fl_lctn add constraint fl_lctn_fk_fljs foreign key ( fles_id )
                        references fl_fljs                     ( fles_id);

alter table fl_lctn add constraint fl_lctn_fk_hdng foreign key ( hiding_id )
                        references fl_rdrs                     ( rider_id);

alter table fl_lctn add constraint fl_lctn_fk_find foreign key ( finder_id )
                        references fl_rdrs                     ( rider_id);



-- drop table fl_rtes ;
create table fl_rtes (
  rte_id        integer  not null   -- pk
, fr_loc_id     integer  not null   -- fk
, to_loc_id     integer  not null   -- fk
--- and some derived data.
, rider_id      integer      -- fk  -- note: rider is derived from lctn
, fles_id       integer      -- fk  -- note: fles is derived from lctn
, dist_xls      numeric (7,3 )    -- note: distance as given in XLS
, dist_sdo      numeric (10,3 )    -- note: derived from GEO-function.
, fr_earth        earth
, to_earth        earth
 -- room for more..
);


-- create unique index                fl_rtes_pk  on fl_rtes ( rte_id  );
alter table fl_rtes add constraint fl_rtes_pk primary key ( rte_id ) ; 

-- and prevent accidental doubles:
create unique index fl_rtes_uk on fl_rtes ( fr_loc_id, to_loc_id ) ;

-- add FK constraints for From and To locations
alter table fl_rtes add constraint fl_rtes_fk_from foreign key ( fr_loc_id )
                        references fl_lctn                     (    loc_id );

alter table fl_rtes add constraint fl_rtes_fk_to   foreign key ( to_loc_id )
                        references fl_lctn                     (    loc_id );


-- the FKs to rider and fles
alter table fl_rtes add constraint fl_rtes_fk_fljs foreign key ( fles_id )
                        references fl_fljs                     ( fles_id);

alter table fl_rtes add constraint fl_rtes_fk_rdrs foreign key ( rider_id )
                        references fl_rdrs                     ( rider_id);


-- -- -- -- -- add static data, 11x fles and 1x jaap43 -- -- --- -- 

insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_01' );
insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_02' );
insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_03' );
insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_04' );
insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_05' );

insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_06' );
insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_07' );
insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_08' );
insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_09' );
insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_10' );

insert into fl_fljs ( fles_id, fles_name ) values ( nextval('fl_fljs_seq'),  'Fles_11' );

-- add dates as workaround
update fl_fljs set fles_startdate = to_date ('16-08-2010', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('17-09-2010', 'DD-MM-YYYY')
where fles_id = 1 ;

update fl_fljs set fles_startdate = to_date ('20-09-2010', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('26-11-2010', 'DD-MM-YYYY')
where fles_id = 2 ;

update fl_fljs set fles_startdate = to_date ('17-11-2010', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('02-03-2011', 'DD-MM-YYYY')
where fles_id = 3 ;

update fl_fljs set fles_startdate = to_date ('04-03-2011', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('06-04-2012', 'DD-MM-YYYY')
where fles_id = 4 ;

update fl_fljs set fles_startdate = to_date ('07-04-2012', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('29-04-2012', 'DD-MM-YYYY')
where fles_id = 5 ;

update fl_fljs set fles_startdate = to_date ('30-04-2012', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('17-07-2012', 'DD-MM-YYYY')
where fles_id = 6 ;

update fl_fljs set fles_startdate = to_date ('18-07-2012', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('31-05-2013', 'DD-MM-YYYY')
where fles_id = 7 ;

update fl_fljs set fles_startdate = to_date ('01-06-2013', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('29-11-2013', 'DD-MM-YYYY')
where fles_id = 8 ;

update fl_fljs set fles_startdate = to_date ('29-11-2013', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('26-09-2014', 'DD-MM-YYYY')
where fles_id = 9 ;

update fl_fljs set fles_startdate = to_date ('27-09-2014', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('04-01-2015', 'DD-MM-YYYY')
where fles_id = 10 ;

update fl_fljs set fles_startdate = to_date ('04-01-2015', 'DD-MM-YYYY')
                 , fles_enddate   = to_date ('29-11-2020', 'DD-MM-YYYY')
where fles_id = 11 ;

-- and add jaap, the oldest rider...
insert into fl_rdrs ( rider_id, rider_name )
   values ( nextval ('fl_rdrs_seq'), 'jaap43'  );



-- here.

-- Staging, for Loading from XLS.. see testimp.xls for loading-instructions.
-- condider: trigger to generate seq_id

-- stageing table: copy from xls, 
-- first we need vc-fields to cover date-fmt, 
-- and distbance-column in earlier position.
create table fl_stag_vc (
  seq_id        integer     not null
, hiding_date   varchar(10)
, hiding_blz    varchar( 6)
, hiding_rider  varchar(30)
, finder_date   varchar(10)
, finder_blz    varchar( 6)
, finder_rider  varchar(30)
, lat_degr      real 
, lon_degr      real
, distance      real  -- tolerate excess. fix later.
, loc_desc      varchar(64)
, city          varchar(30)
, prov          varchar(3)
, c1            varchar(3)
, c2            varchar(3)
, c3            varchar(3)
, c4            varchar(3)
, c5            varchar(3)
, c6            varchar(3)
);

-- create unique index fl_stag_vc_pk on fl_stag_vc ( seq_id ) ;
-- constraint seems to imply index by same name..
alter table fl_stag_vc add constraint fl_stag_vc_pk primary key  ( seq_id ) ;


-- the final stageing table: with timestamps for date-fields
create table fl_stag (
  seq_id        integer     not null
, hiding_date   timestamp
, hiding_blz    varchar( 6)
, hiding_rider  varchar(30)
, finder_date   timestamp
, finder_blz    varchar( 6)
, finder_rider  varchar(30)
, lat_degr      real 
, lon_degr      real
, loc_desc      varchar(64)
, city          varchar(30)
, prov          varchar(3)
, distance      real  -- tolerate excess. fix later.
);

-- create unique index fl_stag_pk on fl_stag ( seq_id ) ;
-- constraint seems to imply index by same name..
alter table fl_stag add constraint fl_stag_pk primary key  ( seq_id ) ;

-- -- -- 
-- check sanity of data in staging table
select seq_id, hiding_date, hiding_rider, lat_degr, lon_degr 
from fl_stag 
where lat_degr > 55 
   or lon_degr > 7.3 
   or lat_degr < 50 
   or lon_degr < 3  ;

-- -- -- -- -- -- a number of views to help.. -- -- -- -- 

-- first view: helper-view to find all distinct rider names from stageing.
create or replace view fl_v_rider_names as
( select hiding_rider as rider_name from fl_stag
union
  select finder_rider from fl_stag
);

--do the insert first...
insert into fl_rdrs (rider_id, rider_name)
select nextval ( 'fl_rdrs_seq' ), rider_name from fl_v_rider_names
where rider_name not in ( select rider_name from fl_rdrs ) ; 

-- view to find problems in rider list, upper etc..
-- now find upper/lower problems from the real rider table.
create or replace view fl_v_rdrs_problems as
( select rider_id, rider_name
  from fl_rdrs r
  where exists (
        select 'x' from fl_rdrs u
        where upper(r.rider_name) = upper(u.rider_name)
          and r.rider_id <> u.rider_id
         )
) ; 

-- list without outer joins..
select rp.rider_name
, h.hider
, f.found
from fl_v_rdrs_problems rp
, (select count (*) hider, hiding_rider from fl_stag group by hiding_rider )  h
, (select count (*) found, finder_rider from fl_stag group by finder_rider )  f
where h.hiding_rider = rp.rider_name
  and f.finder_rider = rp.rider_name
order by upper(rider_name); 


-- store locations, first the mandatory fields, add optional fields later to avoid outer-joins
insert into fl_lctn
     ( loc_id, fles_id, hiding_id, hiding_date
     , lat_degr, lon_degr, loc_desc, city, prov )
select seq_id, 1                                      -- dflt fles =>1
     , h.rider_id, s.hiding_date
     , s.lat_degr, s.lon_degr, s.loc_desc, s.city, s.prov
from fl_stag s
   , fl_rdrs h
where 1=1
  and h.rider_name = s.hiding_rider
  and s.hiding_date is not null
  and s.lat_degr    is not null ; 

-- link the to+from loc...
create or replace view fl_view_mk_routes as (
select
  fl.loc_id fr_loc_id
, tl.loc_id to_loc_id
-- , decode ( tl.loc_id - fl.loc_id , 1, null, 'BEWARE') as marker
from fl_lctn fl
   , fl_lctn tl
where tl.loc_id = ( select min ( nxt.loc_id ) -- the next valid location...
                      from fl_lctn nxt
                      where nxt.loc_id > fl.loc_id
                      and nxt.lat_degr    is not null
                      and nxt.hiding_date is not  null)
);

-- insert records and generate SDO (spatial) point-objects
insert into fl_rtes ( rte_id, fr_loc_id, to_loc_id ,fles_id 
                    , rider_id, fr_earth, to_earth
)
select nextval ( 'fl_rtes_seq' ) as rte_id
, rv.fr_loc_id
, rv.to_loc_id
, tl.fles_id
, tl.hiding_id  -- rider that went to hide it at destination...
-- , tl.distance   -- consider fetching distance from fl_stag stageing table
, ll_to_earth (fl.lat_degr, fl.lon_degr )  
, ll_to_earth (tl.lat_degr, tl.lon_degr )  
from fl_view_mk_routes rv
   , fl_lctn fl
   , fl_lctn tl
where 1=1
  and rv.fr_loc_id = fl.loc_id
  and rv.to_loc_id = tl.loc_id ;

update fl_rtes set dist_sdo = earth_distance(fr_earth, to_earth) / 1000  ; 

--------------------------------------------------------
--  DDL for View FL_V_LCTN
-- consdier: adding hider_name and finder name
--------------------------------------------------------

CREATE OR REPLACE VIEW fl_v_lctn (
       loc_id, city
     , hiding_date, hiding_id
     , finder_id, rte_in, rte_out
     , next_loc_id, loc_desc) as
  (
select fr_l.loc_id, fr_l.city
     , fr_l.hiding_date, fr_l.hiding_id
     , to_l.hiding_id as finder_id, i.rte_id as rte_in, r.rte_id as rte_out
     , r.to_loc_id as next_loc_id, fr_l.loc_desc
from fl_lctn fr_l   -- origin destination, where the combi occurs.
   , fl_rtes r      -- route points to destination, needed to get finder
   , fl_lctn to_l   -- to destination, the location where finder is know
   , fl_rtes i      -- the route in, to display line if needed.
where r.fr_loc_id = fr_l.loc_id
  and to_l.loc_id = r.to_loc_id
  and i.to_loc_id = fr_l.loc_id)
;

--------------------------------------------------------
--  DDL for View FL_V_RTES
-- for postgres: consider including the coordinates of both points.
-- conider addeing distances
--------------------------------------------------------

select  'fl_v_rtes' ; 

CREATE OR REPLACE VIEW fl_v_rtes (
        RTE_ID, FR_LOC_ID, TO_LOC_ID, HIDING_ID, RIDER_ID
      , fr_lat_degr, fr_lon_degr, fr_city
      , to_lat_degr, to_lon_degr, to_city 
      , dist_sdo) AS
  (
select r.rte_id, fr_loc_id, to_loc_id, to_l.hiding_id, r.rider_id
      , fr_l.lat_degr ,  fr_l.lon_degr , fr_l.city 
      , to_l.lat_degr ,  to_l.lon_degr , to_l.city 
      ,    r.dist_sdo ,  fr_l.hiding_date
from fl_lctn fr_l   -- from
   , fl_rtes r      -- route points to destination
   , fl_lctn to_l   -- to destination
where r.fr_loc_id = fr_l.loc_id
  and to_l.loc_id = r.to_loc_id )
;


select 'now do some reporting' as info ; 

select r.rte_id, r.fr_city, r.to_city, r.dist_sdo as kms
, hiding_id, rider_id, r.hiding_date
from fl_v_rtes  r
where r.dist_sdo > 290 
order by r.dist_sdo desc
;


-- rider with most finds.
select r.rider_name, count (*)  as nr_hidden
from fl_lctn l
   , fl_rdrs r
where r.rider_id = l.hiding_id
group by r.rider_name
having count (*) > 50
order by count (*) desc,  r.rider_name ;

-- city with most hidings.
select l.city, count (*)
from fl_lctn l
group by l.city
having  ( count (*) > 20 or l.city like '%estkap%' )
order by 2 desc, 1 ;

-- count per province
select l.prov, count (*)
from fl_lctn l
group by l.prov
order by 2 desc, 1 ;

-- km per rider
select rd.rider_name, sum ( rt.dist_sdo ) as totkms
from fl_rdrs rd
   , fl_rtes rt
where  rt.rider_id = rd.rider_id
group by rd.rider_name
having sum ( rt.dist_sdo ) > 2000
order by 2 desc;


--------------------------------------------------------
--  DDL for Table FL_COMBI, needed to list+monitor combis
--------------------------------------------------------

CREATE TABLE fl_combi
   (    a integer, 
        b integer, 
        rider_a varchar(30),
        rider_b varchar(30),
        nr_a_to_b integer,
        nr_b_to_a integer,
        nr_occ integer
   ) ;

create unique index fl_combi_pk on fl_combi (a, b);
create unique index fl_combi_u1 on fl_combi (b, a);

--------------------------------------------------------
--  DDL for View FL_V_COMBI
-- note: found that this view is "wrong", and is not used anywehre. 
-- dont need it.
--------------------------------------------------------

CREATE OR REPLACE VIEW fl_v_combi (
 a, b, rider_a, rider_b, nr_a_to_b, nr_b_to_a, nr_occ) AS
  (
select distinct c.a, c.b, ra.rider_name rider_a, rb.rider_name rider_b
     , 999 as nr_a_to_b, 999 as nr_b_to_a, 999 as nr_occ
from  fl_rdrs ra
    , fl_rdrs rb
    , ( select distinct hiding_id a, finder_id b  -- unique combis of riders
        from fl_v_lctn l
      union
        select distinct finder_id  , hiding_id
        from fl_v_lctn
      )  c
where ra.rider_id = c.a
  and rb.rider_id = c.b )
;

--------------------------------------------------------
--  DDL for View FL_V_COMBI_CNT
-- this one, count, is used instead.
--------------------------------------------------------

  CREATE OR REPLACE VIEW fl_v_combi_cnt (hiding_id, finder_id, nr_occ) AS
  (
select l.hiding_id, to_l.hiding_id as finder_id, count (*) nr_occ
from fl_lctn l
   , fl_rtes r  -- route points to l
   , fl_lctn to_l
where r.fr_loc_id = l.loc_id
  and to_l.loc_id = r.to_loc_id
group by l.hiding_id, to_l.hiding_id )
;



--------------------------------------------------------
--  DDL for View FL_V_COMBI_CNT
--------------------------------------------------------

CREATE OR REPLACE VIEW fl_v_combi_cnt (HIDING_ID, FINDER_ID, NR_OCC) AS
  (
select l.hiding_id, to_l.hiding_id as finder_id, count (*) nr_occ
from fl_lctn l
   , fl_rtes r  -- route points to l
   , fl_lctn to_l
where r.fr_loc_id = l.loc_id
  and to_l.loc_id = r.to_loc_id
group by l.hiding_id, to_l.hiding_id )
;

select * from fl_v_combi_cnt 
order by 3 desc 
limit 10 ; 


--------------------------------------------------------
--  DDL for View FL_CHK_CITIES
--------------------------------------------------------

CREATE OR REPLACE VIEW fl_v_chk_cities (city, nr_occ) AS
  ( select city, count (*) as nr_occ
from fl_lctn
group by city )
;

-- start by inserting distinct combi-sets including the a-b/b-a doubles
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

delete from fl_combi where rider_a > rider_b ; 

update fl_combi c
set nr_a_to_b = (select nr_occ
                     from fl_v_combi_cnt l
                    where l.hiding_id = c.a
                      and l.finder_id = c.b )
  , nr_b_to_a = (select nr_occ
                     from fl_v_combi_cnt l
                    where l.hiding_id = c.b
                      and l.finder_id = c.a ) ;

-- get/set totals and removes nulls
update fl_combi c
set nr_occ =  coalesce ( nr_a_to_b, 0) + coalesce(nr_b_to_a, 0)
  , nr_a_to_b = coalesce (nr_a_to_b, 0)
  , nr_b_to_a = coalesce (nr_b_to_a, 0);

select count (*) count_combis from fl_v_combi;

-- verify
select * from fl_combi 
order by nr_occ desc 
limit 10;

-- and re-verify with total-counts.
select sum(nr_a_to_b) as ab, sum(nr_b_to_a) as ba, sum (nr_occ ) as total 
from fl_combi ;

select count (*) from fl_rtes ; 

