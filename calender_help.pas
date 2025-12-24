unit calender_help;

interface

Type
 Calender_Query =
  Record
   intermediate_time:integer;
   max_overtime:integer;
   urgent:boolean;
   early:boolean;
   late:boolean;
   low_density:boolean;
   high_density:boolean;

   //monday:boolean; //tuesday:boolean; //thirsday:boolean; //wednesday:boolean; //friday:boolean; //saturday:boolean; //sunday:boolean;
   week:array[1..7] of boolean;
   from_time_h:array[1..7] of byte;
   from_time_m:array[1..7] of byte;
   to_time_h:array[1..7] of byte;
   to_time_m:array[1..7] of byte;
   duration:integer;

   after_days:integer;
   before_days:integer;
  End;

procedure gui_pick_next_free_day(name_file:string); 
procedure print_week_parallel(the_d,the_m,the_y:integer);

implementation 
uses windows,ammarunit,ammargui,apsfiles,calender,userlogin;
var cal1:Calender_Query;


function Calender_Gather_Free_Time(cal_q:Calender_Query):string;
var i,startdate,enddate:integer;
    datesnstuff:array[1..4]of word;
    loaded_month,loaded_year:integer;
begin
GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
i:=Calender_Function(datesnstuff[1],datesnstuff[3],datesnstuff[4],0);
startdate:=cal_q.after_days+i;
enddate:=cal_q.before_days+i;

  if enddate>Calender_Function(31,12,datesnstuff[4],0) then MessageBox (0, 'Η ημερομηνία τέλους που δόθηκε για την εύρεση ελεύθερου χρόνου για την εξέταση ξεπερνάει τα όρια του τρέχοντος χρόνου..'+#10+'Η αναζήτηση θα πραγματοποιηθεί μέχρι το τέλος του τρέχοντος χρόνου.. ', 'Υπέρβαση του τρέχοντος χρόνου..', 0 + MB_ICONASTERISK);

loaded_month:=GetLastMonthLoaded;
loaded_year:=GetLastYearLoaded; 

while (i<enddate) do
 begin



  i:=i+1;
 end;

 Load_Schedule_Month(loaded_month,loaded_year);

end;





procedure save_pick_next_free_day_form_to_var;
var i,z:integer;
begin
  Val(get_object_data('keno'),cal1.intermediate_time,i);
  Val(get_object_data('yperorira'),cal1.max_overtime,i);
  if get_object_data('prot_e')='3' then  cal1.urgent:=true else cal1.urgent:=false;
  if get_object_data('prot_1')='3' then  cal1.early:=true else cal1.early:=false;
  if get_object_data('prot_2')='3' then  cal1.late:=true else cal1.late:=false;
  if get_object_data('prot_3')='3' then  cal1.low_density:=true else cal1.low_density:=false;
  if get_object_data('prot_4')='3' then  cal1.high_density:=true else cal1.high_density:=false;

  Val(get_object_data('fromhour'),cal1.from_time_h[1],i);
  Val(get_object_data('fromminute'),cal1.from_time_m[1],i);
  Val(get_object_data('tohour'),cal1.to_time_h[1],i);
  Val(get_object_data('tominute'),cal1.to_time_m[1],i);

 for z:=2 to 7 do
  begin
    cal1.from_time_h[z]:=cal1.from_time_h[1];
    cal1.from_time_m[z]:=cal1.from_time_m[1];
    cal1.to_time_h[z]:=cal1.to_time_h[1];
    cal1.to_time_m[z]:=cal1.to_time_m[1];
  end;
 
  if get_object_data('monday')='3' then  cal1.week[1]:=true else cal1.week[1]:=false;
  if get_object_data('tuesday')='3' then  cal1.week[2]:=true else cal1.week[2]:=false;
  if get_object_data('thirsday')='3' then  cal1.week[3]:=true else cal1.week[3]:=false;
  if get_object_data('wednesday')='3' then  cal1.week[4]:=true else cal1.week[4]:=false;
  if get_object_data('friday')='3' then  cal1.week[5]:=true else cal1.week[5]:=false;
  if get_object_data('saturday')='3' then  cal1.week[6]:=true else cal1.week[6]:=false;
  if get_object_data('sunday')='3' then  cal1.week[7]:=true else cal1.week[7]:=false;

  Val(get_object_data('duration'),cal1.duration,i);
  Val(get_object_data('fromday'),cal1.after_days,i);
  Val(get_object_data('today'),cal1.before_days,i);

end;


 
procedure gui_pick_next_free_day(name_file:string);
var wnx1,wny1,wnx2,wny2:integer;
    bufstr:string;
label start_wnd;
begin 
start_wnd:
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');  

wnx1:=GridX(1,3);
wny1:=200;
wnx2:=GridX(2,3);
wny2:=600;

include_object('window1','window','Εύρεση χρόνου για ραντεβού.. ','no','','',wnx1,wny1,wnx2,wny2+20);
draw_all;
delete_object('window1','name'); 

wnx1:=wnx1+40;
wny1:=wny1+55;
include_object('usercomm','comment','Όνομα χρήστη : ','no','','',wnx1,wny1,0,0); 
bufstr:=Users_As_A_List; 
include_object('user','dropdown',bufstr,'no','','',X2(last_object)+5,Y1(last_object)-4,wnx2-40,Y1(last_object)+34);
set_object_data('user','VALUE',Convert2String(Get_User_Number(Get_Current_User)),0);

include_object('protimisi1_com','comment','Όσο το δυνατόν νωρίτερα τα ραντεβού : ','no','','',wnx1,Y2(last_object)+18,0,0);
include_object('prot_1','checkbox','1','no','','',X2(last_object)+5,Y1(last_object)-3,0,0);
include_object('protimisi2_com','comment','Όσο το δυνατόν αργότερα τα ραντεβού : ','no','','',wnx1,Y2(last_object)+7,0,0);
include_object('prot_2','checkbox','1','no','','',X2(last_object)+5,Y1(last_object)-3,0,0);
include_object('protimisi3_com','comment','Αραιά ραντεβού σε πλάτoς ημερών : ','no','','',wnx1,Y2(last_object)+7,0,0);
include_object('prot_3','checkbox','1','no','','',X2(last_object)+5,Y1(last_object)-3,0,0);
include_object('protimisi4_com','comment','Πυκνά ραντεβού σε πλάτoς ημερών : ','no','','',wnx1,Y2(last_object)+7,0,0);
include_object('prot_4','checkbox','1','no','','',X2(last_object)+5,Y1(last_object)-3,0,0);
include_object('protimisie_com','comment','Επείγον , πρώτη δυνατή ημερομηνία : ','no','','',wnx1,Y2(last_object)+7,0,0);
include_object('prot_e','checkbox','1','no','','',X2(last_object)+5,Y1(last_object)-3,0,0);

include_object('keno_com','comment','Ενδιάμεσο κενό ραντεβού : ','no','','',wnx1,Y2(last_object)+10,0,0);
include_object('keno','textbox','2','no','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+35,0);
include_object('keno_com2','comment',' λεπτά ','no','','',X2(last_object)+5,Y1(last_object)+3,0,0);

include_object('yper_com','comment','Υπερωρίες έως : ','no','','',wnx1,Y2(last_object)+14,0,0);
include_object('yperorira','textbox','10','no','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+35,0);
include_object('yper_com2','comment',' λεπτά την ημέρα','no','','',X2(last_object)+5,Y1(last_object)+3,0,0);
                                                              //wnx1+30,wny1+40,wnx2-30,wny2-30
include_object('bord1','border','Προτιμήσεις γιατρού','no','','',wnx1-10,wny1-15,wnx2-30,Y2(last_object)+10);

include_object('bord2','border','Προτιμήσεις ασθενή','no','','',wnx1-10,Y2(last_object)+15,wnx2-30,wny2-30);
include_object('days','comment',' Δ   Τ   Τ   Π   Π   Σ   Κ','no','','',wnx1-10+5,Y1(last_object)+8,0,0);
include_object('monday','checkbox','1','no','','',wnx1-10+5,Y1(last_object)+15,0,0);
include_object('tuesday','checkbox','1','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('thirsday','checkbox','1','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('wednesday','checkbox','1','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('friday','checkbox','1','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('saturday','checkbox','1','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('sunday','checkbox','1','no','','',X2(last_object)+2,Y1(last_object),0,0);

include_object('from_c','comment','Από : ','no','','',X2(last_object)+30,Y1(last_object)-10,0,0);
include_object('fromhour','textbox','','no','','',X2(last_object)+2,Y1(last_object),X2(last_object)+32,0);
include_object('from_c2','comment',' : ','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('fromminute','textbox','','no','','',X2(last_object)+2,Y1(last_object),X2(last_object)+32,0);

include_object('to_c','comment','Έως : ','no','','',X1('from_c'),Y2(last_object)+10,0,0);
include_object('tohour','textbox','','no','','',X2(last_object)+2,Y1(last_object),X2(last_object)+32,0);
include_object('to_c2','comment',' : ','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('tominute','textbox','','no','','',X2(last_object)+2,Y1(last_object),X2(last_object)+32,0);

include_object('duration_c','comment','Διάρκεια : ','no','','',X1('monday'),Y2('monday')+10,0,0);
include_object('duration','textbox','','no','','',X2(last_object)+2,Y1(last_object),X2(last_object)+32,0);
include_object('duration_c2','comment',' λεπτά ','no','','',X2(last_object)+5,Y1(last_object),0,0);

include_object('fromday_c','comment','Από','no','','',X1('monday'),Y2('duration')+16,0,0);
include_object('fromday','textbox','','no','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+45,0);
include_object('fromday_c2','comment',' έως και ','no','','',X2(last_object)+5,Y1(last_object)+3,0,0);
include_object('today','textbox','','no','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+45,0);
include_object('fromday_c3','comment','ημέρες από τώρα','no','','',X2(last_object)+5,Y1(last_object)+3,0,0);


include_object('ok','buttonc','OK','no','','',GridX(1,3)+30,Y2('bord2')+10,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;

fasttextboxchange(1);
repeat
 interact;
 if window_needs_redraw then begin
                               goto start_wnd; 
                              end; 

 if last_object_activated<>'' then begin
                                    //SWITCHING
                                    if Equal(last_object_activated,'prot_1') then
                                                begin
                                                  if (get_object_data('prot_1')='3') and (get_object_data('prot_2')='3') then
                                                            begin
                                                              set_object_data('prot_2','value','1',1);
                                                              draw_object_by_name('prot_2');
                                                            end;
                                                end else
                                    if Equal(last_object_activated,'prot_2') then
                                                begin
                                                  if (get_object_data('prot_1')='3') and (get_object_data('prot_2')='3') then
                                                            begin
                                                              set_object_data('prot_1','value','1',1);
                                                              draw_object_by_name('prot_1');
                                                            end;
                                                end else
                                    if Equal(last_object_activated,'prot_3') then
                                                begin
                                                  if (get_object_data('prot_3')='3') and (get_object_data('prot_4')='3') then
                                                            begin
                                                              set_object_data('prot_4','value','1',1);
                                                              draw_object_by_name('prot_4');
                                                            end;
                                                end else
                                    if Equal(last_object_activated,'prot_4') then
                                                begin
                                                  if (get_object_data('prot_3')='3') and (get_object_data('prot_4')='3') then
                                                            begin
                                                              set_object_data('prot_3','value','1',1);
                                                              draw_object_by_name('prot_3');
                                                            end;
                                                end;

                                    flush_last_object_activated;
                                   end;
 if get_object_data('ok')='4' then begin
                                    set_button('ok',0);
                                    MessageBox (0, 'Η λειτουργία είναι υπο κατασκευή !' , ' ', 0 + MB_ICONASTERISK);
                                    save_pick_next_free_day_form_to_var;
                                    Calender_Gather_Free_Time(cal1);
                                    set_button('exit',1);
                                   end;
until GUI_Exit; 
end;







procedure print_week_parallel(the_d,the_m,the_y:integer); 
var i,sz_x,borderx,bordery:integer;
begin
flush_gui_memory(0);
borderx:=(GetMaxX-640) div 2;
bordery:=(GetMaxY-480) div 2;
include_object('window1','window','Εύρεση χρόνου για ραντεβού.. ','no','','',borderx,bordery,borderx+640,bordery+480);
draw_all;
delete_object('window1','name'); 

 sz_x:=620 div 7;
 for i:=1 to 7 do
   begin
     DrawRectangle( borderx+16+(i-1)*sz_x , bordery+50, borderx+16+(i)*sz_x , bordery+450 , ConvertRGB(0,0,0) );

   end;
 
 repeat
   interact;
 until GUI_Exit;
end;








begin
end.
