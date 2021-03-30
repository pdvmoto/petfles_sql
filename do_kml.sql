set head off
set feedb off

spool names1.kml

select add_top_doc ( 'Funny Names P 3' ) from dual ;

select add_rider_layer ( 'bassjunky' ) from dual ;
select add_rider_layer ( 'frankivo' ) from dual ;
select add_rider_layer ( 'Amauta' ) from dual ;
select add_rider_layer ( 'Ronny Rabbelaar' ) from dual ;

select add_end_doc from dual ; 

spool off

spool names2.kml

select add_top_doc ( 'Funny Names P 1' ) from dual ;

select add_rider_layer ( 'Dennisik' ) from dual; 
select add_rider_layer ( 'Dennisik' ) from dual; 
select add_rider_layer ( 'HighKing' ) from dual; 
select add_rider_layer ('highking' ) from dual; 
select add_rider_layer (  'Ootje' ) from dual; 
select add_rider_layer ( 'ootje' ) from dual; 

select add_end_doc from dual ; 

spool off


spool names3.kml

select add_top_doc ( 'Funny Names P 1' ) from dual ;

select add_rider_layer ( 'BSI' ) from dual; 
select add_rider_layer ( 'Fasteddy' ) from dual; 
select add_rider_layer ( 'Highking' ) from dual; 
select add_rider_layer ( 'Hjerteknuser' ) from dual; 
select add_rider_layer ( 'Okami_Xci' ) from dual; 
select add_rider_layer ( 'Rik60NL' ) from dual; 
select add_rider_layer ( 'Ronny Rabbelaar' ) from dual; 
select add_rider_layer ( 'Scoot_020/Scoot_2' ) from dual; 
select add_rider_layer ( 'tdemmer' ) from dual; 

select add_end_doc from dual ; 

spool names4.kml

select add_top_doc ( 'Funny Names P 1' ) from dual ;
select add_rider_layer ( 'ronk' ) from dual; 
select add_end_doc from dual ; 
spool off

