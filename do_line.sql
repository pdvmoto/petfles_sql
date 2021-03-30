
-- test lines in kml
-- check order of lines

set head off
set feedb off
set linesize 120 
set trim on

spool rte_lines.kml

select add_top_doc ( 'lots of lines' ) from dual ;

select '<Folder>' from dual ;

select fl_show_line ( rte_id ) from fl_rtes where fr_loc_id  < 200
order by fr_loc_id ; 

select '</Folder>' from dual ;

select add_end_doc from dual;

spool off






