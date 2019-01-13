
/* ****

ct_fles.sql: the base file to create object for fles-schema (scott)

notes:
 - follow this or ct_fles_extra.sql to re-build the database.
 - include only the minimum objects, try to leave out the bckps..
 - ideally, this file is runnable from sqlplus 

*/


spool ct_fles

/* 
optionally, drop objects, in corrct order 
*/

drop FUNCTION ADD_LAYER;
drop FUNCTION ADD_RIDER_LAYER;
drop FUNCTION ADD_COMBI_LAYER;
drop FUNCTION FL_SHOW_LCTN;
drop FUNCTION FL_SHOW_LCNT;
drop FUNCTION ADD_TOP_DOC;
drop FUNCTION ADD_END_DOC;
drop FUNCTION ADD_RIDER_LAYER_V1;
drop FUNCTION ADD_RIDER_LAYER_V2;
drop FUNCTION ADD_RIDER_LAYER_V3;
drop FUNCTION ADD_RIDER_LAYER_V4;
drop FUNCTION FL_TEST_INDENT;
drop FUNCTION FL_SHOW_LINE;
drop FUNCTION FL_MK_PLCMRK_LINE;
drop FUNCTION FL_MK_PLCMRK_LCTN;


drop VIEW FL_V_RTES;
drop VIEW FL_V_LCTN;
drop VIEW FL_V_COMBI;
drop VIEW FL_V_COMBI_LOC;
drop VIEW FL_CHK_CITIES;
drop VIEW FL_V_COMBI_CNT;
drop VIEW FL_COMBIS;
drop VIEW FL_RDRS_PROBLEMS;
drop VIEW FL_VIEW_MK_ROUTES;
drop VIEW FL_RIDER_NAMES;

drop SEQUENCE FL_LCTN_SEQ;
drop SEQUENCE FL_FLJS_SEQ;
drop SEQUENCE FL_RTES_SEQ;
drop SEQUENCE FL_RDRS_SEQ;

 alter table FL_RTES drop constraint FL_RTES_FK_RDRS;
 alter table FL_LCTN drop constraint FL_LCTN_FK_HDNG;
drop alter table FL_LCTN drop constraint FL_LCTN_FK_FLJS;
 alter table FL_RTES drop constraint FL_RTES_FK_FLJS;
 alter table FL_RTES drop constraint FL_RTES_FK_TO;
 alter table FL_RTES drop constraint FL_RTES_FK_FROM;
 alter table FL_LCTN drop constraint FL_LCTN_FK_FIND;

drop TABLE FL_RDRS;
drop TABLE FL_FLJS;
drop TABLE FL_LCTN;
drop TABLE FL_RTES;
drop TABLE GEO_LOC;
-- drop TABLE FL_STAG;
drop TABLE ABC_SCDOCK;
-- drop TABLE FL_STAG_BCK;
drop TABLE FL_CHK_CITY;
drop TABLE FL_COMBI;

/* 
0...5....1....5....2....5....3....5....4....5....5....5....6....5....7....5....8 
*/


-- start with sequences
create sequence fl_fljs_seq order nocache ;
create sequence fl_rdrs_seq order nocache ;
create sequence fl_lctn_seq order nocache ;
create sequence fl_rtes_seq order nocache ;

-- tables, indexes and constraints.

-- drop table fl_rdrs ;
create table fl_rdrs (
  rider_id       number (9,0) not null
, rider_name     varchar2(30) not null
-- room for more attributres.. rider_locations, email, telno, etc..
);

create unique index fl_rdrs_pk on fl_rdrs ( rider_id  );
create unique index fl_name_uk on fl_rdrs ( rider_name  );

alter table fl_rdrs add constraint fl_rdrs_pk primary key ( rider_id ) 
                       using index fl_rdrs_pk ;

-- drop table fl_fljs ;
create table fl_fljs (
  fles_id         number (9,0) not null
, fles_name       varchar2 (30) 
, fles_startdate  date
, fles_enddate    date
-- room for more: picture, dates.. 
);

create unique index fl_fljs_pk on fl_fljs ( fles_id  );
alter table fl_fljs add constraint fl_fljs_pk primary key ( fles_id ) 
                       using index fl_fljs_pk ;
/*
0...5....1....5....2....5....3....5....4....5....5....5....6....5....7....5....8 
*/
-- drop table fl_lctn ;
create table fl_lctn (
  loc_id        number (9,0 ) not null   -- pk
, fles_id       number (9,0 ) not null   -- fk
, hiding_id     number (9,0 ) not null   -- fk, the rider that hid the btl.     
, hiding_date   date         default sysdate not null
, Lat_degr      number(10,6) default 52.101       not null   -- from 
, lon_degr      number(10,6) default  5.645       not null 
 -- room for more.. from here on only optional and/or derived attributes...
, loc_desc      varchar2(60)            -- text from xls
, hiding_blz    varchar2(20)
, finder_blz    varchar2(20)
, finder_date   date                    -- fnd-date, via location or the route?
, finder_id     number (9,0)            -- needs and FK ! 
, city          varchar2(30)            -- derived or from xls ? 
, prov          varchar2(3)             -- from xls
, thread_nr           number (3,0)      -- constraint : positive integer
, pg_nr_in_thread     number (3,0)      -- positive integer
, post_nr_in_thread   number (5,0)      -- positive integer
, loc_remarks         varchar2(60)
);

create unique index                fl_lctn_pk  on fl_lctn ( loc_id  );
alter table fl_lctn add constraint fl_lctn_pk primary key ( loc_id ) 
                       using index fl_lctn_pk ;

-- the alternate unique key.. NOPE, doubles...
-- create unique index                fl_lctn_uk  on fl_lctn ( fles_id, hiding_id, hiding_date ) ; 

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
  rte_id        number (9,0 ) not null   -- pk
, fr_loc_id     number (9,0 ) not null   -- fk
, to_loc_id     number (9,0 ) not null   -- fk
--- and some derived data.
, rider_id      number (9,0 )    -- fk  -- note: rider is derived from lctn 
, fles_id       number (9,0 )    -- fk  -- note: fles is derived from lctn 
, dist_xls      number (7,3 )    -- note: distance as given in XLS 
, dist_SDO      number (7,3 )    -- note: derived from GEO-function.
, fr_sdo        SDO_GEOMETRY 
, to_sdo        SDO_GEOMETRY
 -- room for more..
);


create unique index                fl_rtes_pk  on fl_rtes ( rte_id  );
alter table fl_rtes add constraint fl_rtes_pk primary key ( rte_id ) 
                       using index fl_rtes_pk ;

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


-- add static data, 11x fles and 1x jaap43.
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_01' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_02' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_03' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_04' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_05' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_06' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_07' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_08' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_09' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_10' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_11' );
insert into fl_fljs ( fles_id, fles_name ) values ( fl_fljs_seq.nextval, 'Fles_12' );

commit ;        

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
                 , fles_enddate   = to_date ('10-10-2018', 'DD-MM-YYYY') 
where fles_id = 11 ;

update fl_fljs set fles_startdate = to_date ('10-10-2018', 'DD-MM-YYYY') 
                 , fles_enddate   = to_date ('29-11-2020', 'DD-MM-YYYY') 
where fles_id = 11 ;

-- and add jaap, the oldest rider...
insert into fl_rdrs ( rider_id, rider_name ) 
   values ( fl_rdrs_seq.nextval, 'jaap43'  );

commit ; 

-- earlier files contained test-data for SDO, 
-- not relevant in abbreviated version. See ct_fles_extra or ct_fles_code


-- Staging, for Loading from XLS.. see testimp.xls for loading-instructions.
-- condider: trigger to generate seq_id

-- stageing table: copy from xls
create table fl_stag (
  seq_id        number (9,0)    not null
, hiding_date   date            
, hiding_blz    varchar2( 6)
, hiding_rider  varchar2(30)     
, finder_date   date
, finder_blz    varchar2( 6)
, finder_rider  varchar2(30)
, lat_degr      number (9,6)
, lon_degr      number (9,6)
, loc_desc      varchar2(64)
, city          varchar2(30)
, prov          varchar2(3)
, distance      number (12,3)  -- tolerate excess. fix later.
);

create unique index fl_stag_pk on fl_stag ( seq_id ) ;
alter table fl_stag add constraint fl_stag_pk primary key  ( seq_id ) ;

-- at this point: import from petfles_pdv_v<n>.xls ...
-- instruction on sheet2 : some commas and some values too large!
-- on 14Jan: 2325 records 

/* ***
-- set fles-id here.. choose max when in doubt
-- note; this code should go lower, or elsewhere.. process script. 
UPDATE fl_lctn l
SET fles_id = NVL (
  (SELECT MAX ( fles_id)
  FROM fl_fljs f
  WHERE l.hiding_date BETWEEN f.fles_startdate AND f.fles_enddate
  ), 0 ) ;

commit;

*** */

-- first view: helper-view to find all distinct rider names from stageing.
create or replace view fl_v_rider_names as 
( select hiding_rider as rider_name from fl_stag
union 
  select finder_rider from fl_stag
);


/* *** more process info. separate file.
-- find new riders, and check for doubles (Later!).
select * from fl_rider_names    
where rider_name not in ( select rider_name from fl_rdrs ) 
order by upper (rider_name)
/

--do the insert first...
insert into fl_rdrs (rider_id, rider_name)
select fl_rdrs_seq.nextval, rider_name from fl_v_rider_names 
where rider_name not in ( select rider_name from fl_rdrs ) 
/

commit;


*** */

-- view to find problems in rider list, upper etc..
-- now find upper/lower problems from the real rider table.
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

/* *** process info

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

/* *** 

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
  and s.lat_degr    is not null 
/

commit ;

-- report on finds, per fles, per date, per rider...
-- see queries in other files...

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

/* ***

-- check for funnies, notably where from/to loc are not adjacent..
select * from fl_view_mk_routes 
where marker is not null
order by fr_loc_id
;

*** *

-- insert records and generate SDO (spatial) point-objects
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
  and dist_sdo > 150
order by dist_sdo desc ;


*** */

--------------------------------------------------------
--  DDL for Table FL_COMBI, needed to list+monitor combis
--------------------------------------------------------

  CREATE TABLE FL_COMBI
   (    "A" NUMBER(9,0),
        "B" NUMBER(9,0),
        "RIDER_A" VARCHAR2(30 BYTE),
        "RIDER_B" VARCHAR2(30 BYTE),
        "NR_A_TO_B" NUMBER,
        "NR_B_TO_A" NUMBER,
        "NR_OCC" NUMBER
   ) ;
create unique index fl_combi_pk on fl_combi (a, b);
create unique index fl_combi_u1 on fl_combi (b, a);

-- later consider indexes on names? 

alter table fl_combi add constraint fl_combi_pk primary key ( a, b )
                        using index fl_combi_pk ;


-- views used to compose checlists and kml-ooutput.
-- notably v_rtes and v_lctn join-in the non-key-dependent data.

--------------------------------------------------------
--  DDL for View FL_V_LCTN
--------------------------------------------------------

CREATE OR REPLACE VIEW fl_v_lctn (
       LOC_ID, CITY
     , HIDING_DATE, HIDING_ID
     , FINDER_ID, RTE_IN, RTE_OUT
     , NEXT_LOC_ID, LOC_DESC) AS 
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
--------------------------------------------------------

CREATE OR REPLACE VIEW fl_v_rtes (
        RTE_ID, FR_LOC_ID, TO_LOC_ID, HIDING_ID, RIDER_ID) AS 
  (
select r.rte_id, fr_loc_id, to_loc_id, to_l.hiding_id, r.rider_id
from fl_lctn fr_l   -- from
   , fl_rtes r      -- route points to destination
   , fl_lctn to_l   -- to destination
where r.fr_loc_id = fr_l.loc_id
  and to_l.loc_id = r.to_loc_id )
;

--------------------------------------------------------
--  DDL for View FL_V_COMBI
--------------------------------------------------------

CREATE OR REPLACE VIEW "FL_V_COMBI" (
 "A", "B", "RIDER_A", "RIDER_B", "NR_A_TO_B", "NR_B_TO_A", "NR_OCC") AS 
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
--------------------------------------------------------

  CREATE OR REPLACE VIEW "FL_V_COMBI_CNT" ("HIDING_ID", "FINDER_ID", "NR_OCC") AS 
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
--  DDL for View FL_V_COMBI_LOC
--------------------------------------------------------

  CREATE OR REPLACE VIEW "FL_V_COMBI_LOC" 
("LOC_ID", "HIDING_DATE", "RTE_IN", "RTE_OUT", "HIDING_ID"
, "FINDER_ID", "RIDER_A", "RIDER_B", "NR_OCC") AS 
  (
select l.loc_id, l.hiding_date, l.rte_in, l.rte_out, l.hiding_id
, l.finder_id, c.rider_a, c.rider_b, c.nr_occ
from fl_v_lctn l
   , fl_v_combi c
where 1=1 
  and ( (l.hiding_id = c.a and l.finder_id = c.b )  -- a or b...
      or  
        (l.hiding_id = c.b and l.finder_id = c.a )
      ) )
;

--------------------------------------------------------
--  DDL for View FL_CHK_CITIES
--------------------------------------------------------

CREATE OR REPLACE VIEW "FL_CHK_CITIES" ("CITY", "NR_OCC") AS
  ( select city, count (*) as nr_occ
from fl_lctn
group by city )
;

--------------------------------------------------------

/* *** 

comments...

*** */

-- functions to generate KML...

--------------------------------------------------------
--  DDL for Function ADD_END_DOC
--------------------------------------------------------

CREATE OR REPLACE FUNCTION ADD_END_DOC return number as
begin
  dbms_output.put_line ( '
  </Document>
</kml>
' );

  return null;
end;
/

--------------------------------------------------------
--  DDL for Function ADD_TOP_DOC
--------------------------------------------------------

CREATE OR REPLACE FUNCTION ADD_TOP_DOC ( vc_docname varchar2 ) return 
number 
as

  vc_crlf varchar2(2) := chr(13)||chr(10);
  nl      varchar2(2) := chr(13)||chr(10);

begin
dbms_output.put_line (
     vc_crlf
  || '<?xml version="1.0" encoding="utf-8"?> '          || vc_crlf
  || '  <kml xmlns="http://earth.google.com/kml/2.1"> ' || vc_crlf
  || '    <Document><name>' || vc_docname || ' </name> ' ) ;

return null;
end;
/

--------------------------------------------------------
--  DDL for Function FL_MK_PLCMRK_LINE
--------------------------------------------------------

prompt 'plcmrk line'

CREATE OR REPLACE FUNCTION FL_MK_PLCMRK_LINE ( n_rte_id number ) 
  return varchar2 
AS
  vc_plcmrk_line varchar2(1000) ;
begin

-- select the whole thing...
With cr as (select chr(13)||chr(10) lf from dual)
select   /*  l_fr.hiding_date, l_fr.city, l_fr.lon_degr, l_fr.lat_degr
, l_fr.hiding_id hider, rdr_fr.rider_name hidden_by
, rdr_rte.rider_name the_rider
, l_to.lon_degr, l_to.lat_degr to_coord
--, r.*
,  r.dist_sdo Distance_km
-- now form the complete line-Placemark...
, */
      cr.lf || '<Placemark>'
   || cr.lf || '  <name>' || rdr_rte.rider_name 
            || ' on ' || to_char (l_to.hiding_date, 'DD-MON-YYYY')
            ||  '</name>'
   || cr.lf || '  <description>' || 'Hid by ' || rdr_fr.rider_name 
                                 || ' in ' || l_fr.city || '.'
--                      || cr.lf || l_fr.loc_desc || '.'
                        || cr.lf || 'Brought to ' || l_to.city 
                        || '(' || to_char (r.dist_sdo, '9999.9') || 'Km)'
--                      || cr.lf || l_to.loc_desc || '.'
                        || cr.lf || '(add next finder+date here...)'
                        || cr.lf || '(rte_id='|| to_char (r.rte_id) || ')'
                                 ||'</description>'
   || cr.lf || '  <LineString>'
   || cr.lf || '    <tessellate>1</tessellate>'
   || cr.lf || '    <coordinates>'
   || cr.lf || '      ' || to_char(l_fr.lon_degr) ||', '|| to_char ( l_fr.lat_degr) ||', 0'
   || cr.lf || '      ' || to_char(l_to.lon_degr) ||', '|| to_char ( l_to.lat_degr) ||', 0'
   || cr.lf || '    </coordinates>'
   || cr.lf || '  </LineString>'
   || cr.lf || '</Placemark>' --as line_kml
into vc_plcmrk_line
from fl_rtes r
   , fl_lctn l_fr
   , fl_lctn l_to
   , fl_rdrs rdr_fr   -- the rider who hid the bottle at from_loc
   , fl_rdrs rdr_rte  -- the rider who did the route
   , cr
where r.fr_loc_id = l_fr.loc_id
  and r.to_loc_id = l_to.loc_id
  and rdr_fr.rider_id = l_fr.hiding_id
  and rdr_rte.rider_id = r.rider_id
  and rte_id = n_rte_id
;

return vc_plcmrk_line;
end;
/
show errors

--------------------------------------------------------
--  DDL for Function FL_SHOW_LINE
--------------------------------------------------------

CREATE OR REPLACE FUNCTION "FL_SHOW_LINE" ( n_rte_id number ) 
  return number 
AS
-- put the placemerk-line to dbms_output, mainly for testing.
begin
  dbms_output.put_line ( ' ' || fl_mk_plcmrk_line ( n_rte_id) || '' ) ;
  return null;
end;
/
show errors

--------------------------------------------------------
--  DDL for Function FL_MK_PLCMRK_LCTN
--------------------------------------------------------
prompt 'plcmrk_lctn..' 

  CREATE OR REPLACE FUNCTION "FL_MK_PLCMRK_LCTN" ( n_loc_id number ) 
return varchar2 
AS
  vc_plcmrk_lctn varchar2(1000) ;
begin

-- select the whole thing...
With cr as (select chr(13)||chr(10) lf from dual)   -- add indent spaces here.
select   /*   keep commented-columns inselect for later debug
  l_fr.hiding_date, l_fr.city, l_fr.lon_degr, l_fr.lat_degr
, l_fr.hiding_id hider, rdr_fr.rider_name hidden_by
, rdr_rte.rider_name the_rider
, l_to.lon_degr, l_to.lat_degr to_coord
--, r.*
,  r.dist_sdo Distance_km
-- now form the complete line-Placemark...
, */
      cr.lf || '<Placemark>'
   || cr.lf || '  <name>' || l.city 
                          || ' on ' || to_char (l.hiding_date, 'DD-MON-YYYY')
                          ||  '</name>'
   || cr.lf || '  <description>' 
                           || 'VS: ' || rdr_rte.rider_name || '.'
                  || cr.lf || 'LV: '  || rdr_fnd.rider_name 
                           || '(' 
                           || to_char (l_go.hiding_date - l.hiding_date) 
                           || ' days).'
                  || cr.lf || 'To ' || l_go.city 
                           ||  ' (' || to_char (r_go.dist_sdo, 999.9) || ' Km)'
                  || cr.lf || '(loc_id='|| to_char (l.loc_id) || ')'
                  || cr.lf || '(rider_id='|| to_char (rdr_rte.rider_id) || ')'
                  || cr.lf || '(finder_id='|| to_char (rdr_fnd.rider_id) || ')'
                  ||'</description>'
   || cr.lf || '  <Point>'
   || cr.lf || '    <coordinates>'
   || cr.lf || '      ' || to_char(l.lon_degr) ||','
                        || to_char ( l.lat_degr) ||',0'
   || cr.lf || '    </coordinates>'
   || cr.lf || '  </Point>'
   || cr.lf || '</Placemark>' --as line_kml
into vc_plcmrk_lctn
from
     fl_lctn l
   , fl_rtes r        -- route to arrive
   , fl_rtes r_go     -- route to go
   , fl_lctn l_go
--   , fl_rdrs rdr_fr   -- the rider who hid the bottle at from_loc
   , fl_rdrs rdr_rte  -- the rider who did the route and hid the bottle
   , fl_rdrs rdr_fnd  -- rider who found it
   , cr
where r.to_loc_id = l.loc_id
  and rdr_rte.rider_id = l.hiding_id
  and r_go.fr_loc_id = l.loc_id
  and l_go.loc_id = r_go.to_loc_id
  and rdr_fnd.rider_id = l_go.hiding_id
  and l.loc_id = n_loc_id
;

return vc_plcmrk_lctn;
end;
/
show errors

--------------------------------------------------------
--  DDL for Function FL_SHOW_LCNT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "FL_SHOW_LCNT" ( n_loc_id number ) 
  return number 
AS
-- put the placemerk-line to dbms_output, mainly for testing.
begin
  dbms_output.put_line ( ' ' || fl_mk_plcmrk_lctn ( n_loc_id) || '' ) ;
  return null;
end;
/
show errors 

-- old function for rider-layers
create or replace function add_rider_layer ( vc_rider varchar2 ) 
  return number 
AS
  n_places_found  number ;
  vc_crlf         varchar2(2) := chr(13) || chr(10);
begin

  dbms_output.put_line('    <Folder><name>' || vc_rider || '</name>');

-- add all find-places for given rider. with vc_hide_loc and v_linestring
-- beware: literal CF+LF and spaces in select... need better formattingsolution..
  FOR rec_found in (
  select r.rider_name, r.rider_id, loc.hiding_date, loc.city , prev_loc.city from_city
     , '<Placemark>
     <name>' || to_char (loc.hiding_date, 'YYYY-MON-DD ') ||  r.rider_name ||' </name>
     <description>'|| 'Verstopt in ' || prev_loc.city || ' door ' || r_from.rider_name
     || ' op '  || to_char (prev_loc.hiding_date, 'YYYY-MON-DD (')
     || to_char ( loc.hiding_date - prev_loc.hiding_date) || ' dgn)' || '</description>
     <Point><coordinates>' || to_char(prev_loc.lon_degr) || ',' || to_char (prev_loc.lat_degr)   ||', 0 </coordinates>
       </Point>
     </Placemark>' as vc_hide_loc
     , '<Placemark>
        <name>' ||
       to_char ( loc.hiding_date, 'YYYY-MON-DD, ' ) || r.rider_name || ':  ' ||prev_loc.city || ' - ' ||  loc.city
       || '</name>
       <LineString>
           <tessellate>1</tessellate><width>4</width>
           <coordinates>      ' || to_char (prev_loc.lon_degr) || ',' || to_char (prev_loc.lat_degr) || ',0
           ' || to_char (     loc.lon_degr) || ',' || to_char (     loc.lat_degr) || ',0
          </coordinates>
     </LineString>
     </Placemark>' as vc_linestring
from fl_rdrs r
  ,  fl_lctn loc
  ,  fl_rtes rt
  ,  fl_lctn prev_loc
  ,  fl_rdrs r_from   -- find hider/hider on prev loc.
where r.rider_id = loc.hiding_id
  and rt.to_loc_id = loc.loc_id
  and rt.fr_loc_id = prev_loc.loc_id
  and r_from.rider_id = prev_loc.hiding_id
  and r.rider_name = vc_rider
  and loc.lat_degr is not null  -- preent blanks
  order by loc.hiding_date)
  LOOP

    -- display the line to the loc, and the hiding loc.
    dbms_output.put_line ( '    ' || rec_found.vc_hide_loc);
    dbms_output.put_line ( '    ' || rec_found.vc_linestring);

  END LOOP ; -- for all locations foudn by rider

-- add end of layer
  dbms_output.put_line('    </Folder> ');

  return null;
end;
/
show errors

-- 
spool off

