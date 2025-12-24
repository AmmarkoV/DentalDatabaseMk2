unit calender;

interface

Type
 Appointment =
  Record
   name : string;
   surname : string;
   person_file : string;
   person_handling : string;
   comment : string;
   appointment_type : integer;
   dateday : integer;
   datemonth : integer;
   dateyear : integer;
   datehour : integer;
   datemin : integer; 
   time_takes:integer;
   used:boolean;
  End;

procedure day_after_days(days_after:integer; var theday,themonth,theyear:integer);

function GetLastYearLoaded:integer;
function GetLastMonthLoaded:integer;
   
function Calender_Function(day,month,year,mode:integer):integer;
procedure GetEasterDate (y, method : word; var d, m : integer);
procedure Add_Schedule_Day(theday:integer; theappoint:Appointment);
procedure GUI_add_new_schedule_day(day,monthnum,year,hour,minute,duration:integer; patient_file:string);

function Day_Data_Filename(day,themonth,theyear:integer):string;
procedure Load_Schedule_Day_File(thefile:string; theday,themonth,theyear:integer); 
procedure Save_Schedule_Day_File(thefile:string; theday,themonth,theyear:integer);
procedure Load_Schedule_Month(themonth,theyear:integer);
function GUI_select_day_month(var daynum,monthnum,year,all_users:integer):integer;
procedure display_schedule_month(monthnum,year:integer);
procedure Compact_Schedule(daynum,monthnum,year:integer; all_users:boolean);
procedure Init_Calender;

implementation
uses windows,ammarunit,apsfiles,ammargui,translate,the_works,people,people_map,string_stuff,userlogin,calender_help;
const
title='Calender Subsystem';
MonthStr:array [1..12] of string=('Ιανουάριος','Φεβρουάριος','Μάρτιος','Απρίλιος','Μαϊος','Ιούνιος','Ιούλιος','Αύγουστος','Σεπτέμβριος','Οκτώβριος','Νοέμβριος','Δεκέμβριος');
DayStr:array [1..7] of string=('Δευτέρα','Τρίτη','Τετάρτη','Πέμπτη','Παρασκευή','Σάββατο','Κυριακή');
max_human_dayload=15;   //Cannot BE ZERO , carefull
Max_Appointments_Loaded=4096;
Max_Appointments_Perday=Max_Appointments_Loaded div 31;


var Appoint_Mem:array[1..Max_Appointments_Loaded] of Appointment;
    Month_Appoint:array[0..31,1..Max_Appointments_Perday+1] of integer;  //to teleytaio einai reserved gia ton synoliko arithmo..
    Appoint_Mem_Place:integer;
    Last_Mem_Load_ID:string;
    what2dostring:array[0..11,1..3] of string; // what2dostring[x,y] x=0-11 , y=1 enikos ergasias , 2=plythintikos , 3=arthro enikou
    theappoint:Appointment;
    draw_alluser_schedules:boolean;
    last_month_loaded,last_year_loaded:integer;

function GetLastMonthLoaded:integer;
begin
GetLastMonthLoaded:=last_month_loaded;
end;

function GetLastYearLoaded:integer;
begin
GetLastYearLoaded:=last_year_loaded;
end;



function Get_Day_Length(theday:integer):integer;
begin
Get_Day_Length:=Month_Appoint[theday,Max_Appointments_Perday+1];
end;

procedure Set_Day_Length(theday,newlength:integer);
begin
Month_Appoint[theday,Max_Appointments_Perday+1]:=newlength;
end;

procedure Clean_Schedule_Day(theday:integer);
var i:integer;
begin
 for i:=1 to Max_Appointments_Perday do
        begin
          Month_Appoint[theday,i]:=0;
        end;
 Month_Appoint[theday,Max_Appointments_Perday+1]:=0; //Total Schedules that day
end;

procedure Swap_Item_Schedule_Day(day,item1,item2:integer);
var z:integer;
begin 
z:=Month_Appoint[day,item1];
Month_Appoint[day,item1]:=Month_Appoint[day,item2];
Month_Appoint[day,item2]:=z;
end;

procedure Delete_From_Schedule_Day(memnumb:integer);
var i,z,theday:integer;
begin
 theday:=Appoint_Mem[memnumb].dateday;
 for i:=1 to Get_Day_Length(theday) do
        begin
          if Month_Appoint[theday,i]=memnumb then begin
                                                   Month_Appoint[theday,i]:=0;
                                                   Swap_Item_Schedule_Day(theday,i,Get_Day_Length(theday));
                                                   break;
                                                  end;
        end;
 Month_Appoint[theday,Max_Appointments_Perday+1]:=Month_Appoint[theday,Max_Appointments_Perday+1]-1; //Total Schedules that day
end;

procedure Sort_Schedule_Day(theday:integer);
var i,z:integer;
begin

if Get_Day_Length(theday)>1 then
begin
 for i:=1 to Get_Day_Length(theday)-1 do
   for z:=1 to Get_Day_Length(theday)-1 do
       begin
         if Appoint_Mem[Month_Appoint[theday,z]].datehour>Appoint_Mem[Month_Appoint[theday,z+1]].datehour then Swap_Item_Schedule_Day(theday,z,z+1) else
         if Appoint_Mem[Month_Appoint[theday,z]].datehour=Appoint_Mem[Month_Appoint[theday,z+1]].datehour then
                begin //Idia wra alla ti ginetai me ta lepta.. ?
                  if Appoint_Mem[Month_Appoint[theday,z]].datemin>Appoint_Mem[Month_Appoint[theday,z+1]].datemin then  Swap_Item_Schedule_Day(theday,z,z+1) ;
                end; 

       end;
end;

end;

procedure Add_Schedule_Day(theday:integer; theappoint:Appointment);
var i:integer;
begin
if Max_Appointments_Loaded<=Appoint_Mem_Place then
          begin
           MessageBox (0, 'Η μνήμη για τα ραντεβού αυτού του μήνα είναι γεμάτη' , ' ', 0);
          end else
if Max_Appointments_Perday<=Get_Day_Length(theday) then
          begin
           MessageBox (0, 'Η μνήμη για τα ραντεβού αυτής της μέρας είναι γεμάτη' , ' ', 0);
          end else 
          begin
           Set_Day_Length(theday,Get_Day_Length(theday)+1);
           //Month_Appoint[theday,Max_Appointments_Perday+1]:=Month_Appoint[theday,Max_Appointments_Perday+1]+1;
           Appoint_Mem_Place:=Appoint_Mem_Place+1; 
                                                                              //Max_Appointments_Perday+1
           Month_Appoint[theday,Get_Day_Length(theday)]:=Appoint_Mem_Place;
           Appoint_Mem[Appoint_Mem_Place]:=theappoint; 
          end;
 //Month_Appoint[theday,Max_Appointments_Perday+1]:=0; //Total Schedules that day
end;

procedure clear_appoint(numb:integer);
begin 
Appoint_Mem[numb].used:=false;
Appoint_Mem[numb].name:='';
Appoint_Mem[numb].surname:='';
Appoint_Mem[numb].person_file:='';
Appoint_Mem[numb].person_handling:=Get_Current_User;
Appoint_Mem[numb].comment:='';
Appoint_Mem[numb].appointment_type:=0; 
Appoint_Mem[numb].dateday:=0;
Appoint_Mem[numb].datemonth:=0;
Appoint_Mem[numb].dateyear:=0;
Appoint_Mem[numb].datehour:=0;
Appoint_Mem[numb].time_takes:=0;
Appoint_Mem[numb].datemin:=0;
end;


procedure delete_appoint(numb:integer); 
begin//PROBLEMS..
Delete_From_Schedule_Day(numb);
clear_appoint(numb);
if numb=Appoint_Mem_Place then begin
                                Appoint_Mem_Place:=Appoint_Mem_Place-1;
                                //An einai i teleytaia eggrafi afairesi..
                                //Alliws menei gia na min diataraksei tis ypoloipes eggrafes kai trexoume..
                               end; 
end;

procedure load_what2dostring;
begin
what2dostring[1,3]:=tl('ένα');
what2dostring[1,1]:=tl('ραντεβού');
what2dostring[1,2]:=tl('ραντεβού');

what2dostring[2,3]:=tl('μια');
what2dostring[2,1]:=tl('επαγγελματική υποχρέωση');
what2dostring[2,2]:=tl('επαγγελματικές υποχρεώσεις');

what2dostring[3,3]:=tl('μια');
what2dostring[3,1]:=tl('κοινωνική υποχρέωση');
what2dostring[3,2]:=tl('κοινωνικές υποχρεώσεις');

what2dostring[4,3]:=tl('μια');
what2dostring[4,1]:=tl('προσωπική υπενθύμιση');
what2dostring[4,2]:=tl('προσωπικές υπενθυμίσεις');

what2dostring[5,3]:=tl('ένα');
what2dostring[5,1]:=tl('τηλεφώνημα');
what2dostring[5,2]:=tl('τηλεφωνήματα');

what2dostring[6,3]:=tl('μια');
what2dostring[6,1]:=tl('γιορτή');
what2dostring[6,2]:=tl('γιορτές');

what2dostring[7,3]:=tl('μια');
what2dostring[7,1]:=tl('υπενθύμηση');
what2dostring[7,2]:=tl('υπενθυμήσεις');

what2dostring[8,3]:=tl('μια');
what2dostring[8,1]:=tl('σημείωση');
what2dostring[8,2]:=tl('σημειώσεις');

what2dostring[9,3]:=tl('μια');
what2dostring[9,1]:=tl('σκέψη');
what2dostring[9,2]:=tl('σκέψεις');

what2dostring[10,3]:=tl('μια');
what2dostring[10,1]:=tl('ακύρωση');
what2dostring[10,2]:=tl('ακυρώσεις');

what2dostring[11,3]:=tl('μια');
what2dostring[11,1]:=tl('αλλαγή');
what2dostring[11,2]:=tl('αλλαγές');
end;

procedure Init_Calender;
begin
load_what2dostring;
end;


function Calender_Function(day,month,year,mode:integer):integer;
var a,y,m,JD,reslt,d1,d4,L:integer;
begin 
// mode=0 return DayofYear , mode=1 return DayOfWeek , mode=2 return WeekofYear
a:=0;
y:=0;
m:=0;
JD:=0;
reslt:=0;
if ((day>=1)and(day<=31)) then reslt:=reslt+1;
if ((month>=1)and(month<=12)) then  reslt:=reslt+1;
if ((mode>=0)and(mode<=2)) then  reslt:=reslt+1;

if (reslt=3) then
begin
a:=(14-month) div 12;
y:=year+4800-a;
m:=month+12*a-3;
JD:=day+(153*m+2)div 5+y*365+y div 4-y div 100+y div 400-32045;

case mode of

0:           begin
               y:=year+4799; //Day of Year
               reslt:=JD-(y*365+y div 4-y div 100+y div 400-31739);
             end;
1:           begin
               reslt:=JD mod 7+1;
             end;
2:           begin
                d4:=(JD+31741 - (JD mod 7)) mod 146097 mod 36524 mod 1461;
                L:=d4 div 1460;
                d1:=((d4-L) mod 365) + L;
                reslt:=d1 div 7+1;
             end;
3:          reslt:=JD;  //RETURN JULIAN DATE 
end;
 

end else
  begin
  OuttextCenter('Wrong input - Calender_Function()');
  reslt:=-1;
  end;

Calender_Function:=reslt;
end;




function Disektos_Xronos(year:integer):boolean;
var retres:boolean;
begin
retres:=false;
if (year) mod 400=0 then retres:=true;
if (year) mod 4=0 then begin
                        if (year) mod 100<>0 then retres:=true;
                       end;
Disektos_Xronos:=retres;
end;


function month_days(monthnum,year:integer):integer;
var retres:integer;
begin
case monthnum of
 1: retres:=31;
 2: begin 
     retres:=28;
     if Disektos_Xronos(year) then retres:=29; {Otan i xronia einai disekti o fevrouarios exei 29 meres}
    end;
 3: retres:=31;
 4: retres:=30;
 5: retres:=31;
 6: retres:=30;
 7: retres:=31;
 8: retres:=31;
 9: retres:=30;
 10: retres:=31;
 11: retres:=30;
 12: retres:=31;
end;  
month_days:=retres;
end;



procedure Save_Schedule_Day_File(thefile:string; theday,themonth,theyear:integer);
var fileused:text; 
    bufstr:string;
    i:integer;
    tmp_appoint:Appointment;
begin
 if Get_Day_Length(theday)>0 then
begin
  assign(fileused,thefile);
      {$i-}
        rewrite(fileused);
      {$i+}
      if Ioresult<>0 then MessageBox (0, 'Could not open file for Saving of Day Schedule' , ' ', 0) else
                          begin 
                               for i:=1 to Get_Day_Length(theday) do
                                    begin
                                      tmp_appoint:=Appoint_Mem[Month_Appoint[theday,i]]; 
                                      bufstr:='TODO(';
                                      bufstr:=bufstr+tmp_appoint.name+',';
                                      bufstr:=bufstr+tmp_appoint.surname+',';
                                      bufstr:=bufstr+tmp_appoint.person_file+',';
                                      bufstr:=bufstr+tmp_appoint.person_handling+',';
                                      bufstr:=bufstr+Convert2String(tmp_appoint.appointment_type)+',';
                                      bufstr:=bufstr+Convert2String(tmp_appoint.dateday)+',';
                                      bufstr:=bufstr+Convert2String(tmp_appoint.datemonth)+',';
                                      bufstr:=bufstr+Convert2String(tmp_appoint.dateyear)+',';
                                      bufstr:=bufstr+Convert2String(tmp_appoint.datehour)+',';
                                      bufstr:=bufstr+Convert2String(tmp_appoint.datemin)+',';
                                      bufstr:=bufstr+tmp_appoint.comment+',';
                                      bufstr:=bufstr+Convert2String(tmp_appoint.time_takes)+')';
                                      writeln(fileused,bufstr); 
                                    end; 
                           close(fileused);
                          end;
end;

end;

procedure Load_Schedule_Day_File(thefile:string; theday,themonth,theyear:integer);
var fileused:text; 
    bufstr:string;
    tmp_appoint:Appointment;
begin
  assign(fileused,thefile);
      {$i-}
        reset(fileused);
      {$i+}
      if Ioresult<>0 then MessageBox (0, 'Could not open file for Loading of Day Schedule' , ' ', 0) else
                          begin
                           while (not eof(fileused) ) do
                              begin
                               readln(fileused,bufstr);
                               seperate_words(bufstr);
                               if Upcase(get_memory(1))='TODO' then
                                                       begin
                                                        tmp_appoint.name:=get_memory(2);
                                                        tmp_appoint.surname:=get_memory(3);
                                                        tmp_appoint.person_file:=get_memory(4);
                                                        tmp_appoint.person_handling:=get_memory(5);
                                                        tmp_appoint.appointment_type:=get_memory_int(6);
                                                        tmp_appoint.dateday:=get_memory_int(7);
                                                        tmp_appoint.datemonth:=get_memory_int(8);
                                                        tmp_appoint.dateyear:=get_memory_int(9);
                                                        tmp_appoint.datehour:=get_memory_int(10);
                                                        tmp_appoint.datemin:=get_memory_int(11);
                                                        tmp_appoint.comment:=get_memory(12);
                                                        tmp_appoint.time_takes:=get_memory_int(13);
                                                        tmp_appoint.used:=true;
                                                        if (tmp_appoint.dateday<>theday) then //MessageBox (0, pchar('Mixed Days '+Convert2String(tmp_appoint.dateday)+','+Convert2String(theday)+', fixing..') ,pchar(thefile+' '+tmp_appoint.name), 0);
                                                        MessageBoxA(
  0,
  PAnsiChar(AnsiString(
    'Mixed Days ' +
    Convert2String(tmp_appoint.dateday) + ',' +
    Convert2String(theday) +
    ', fixing..'
  )),
  PAnsiChar(AnsiString(thefile + ' ' + tmp_appoint.name)),
  0
);
                                                        Add_Schedule_Day(tmp_appoint.dateday,tmp_appoint);  
                                                       end;
                              end;
                           close(fileused);
                          end;
end;

function Day_Data_Filename(day,themonth,theyear:integer):string;
var retres:string;
begin
retres:='Calender\'+Convert2String(day)+'_'+Convert2String(themonth)+'_'+Convert2String(theyear)+'.dat';
Day_Data_Filename:=retres;
end;

procedure Load_Schedule_Month(themonth,theyear:integer);
var fileused:text;
    i,daysofmonth:integer;
    monthstr,yearstr:string;
begin
monthstr:=''; yearstr:='';
if ((themonth>0) and (themonth<=31)) then
begin
 daysofmonth:=month_days(themonth,theyear);
 monthstr:=Convert2String(themonth);
 yearstr:=Convert2String(theyear);
 for i:=1 to daysofmonth do
    begin
      //assign(fileused,'Calender\'+Convert2String(i)+monthstr+yearstr+'.dat');
      assign(fileused,Day_Data_Filename(i,themonth,theyear));
      {$i-}
        reset(fileused);
      {$i+}
       if Ioresult<>0 then begin 
                            Clean_Schedule_Day(i);
                           end else
                      begin
                       close(fileused);
                       Clean_Schedule_Day(i);
                       //Load_Schedule_Day_File('Calender\'+Convert2String(i)+monthstr+yearstr+'.dat',i,themonth,theyear);
                      Load_Schedule_Day_File(Day_Data_Filename(i,themonth,theyear),i,themonth,theyear);
                      end;
    end;
end;
Last_Mem_Load_ID:=monthstr+yearstr;
end;


procedure save_form_specific;
var i:integer;
begin
theappoint.name:=get_object_data('name');
theappoint.surname:=get_object_data('surname');
theappoint.person_handling:=get_object_data('user');
theappoint.comment:=get_object_data('comments');
Val(get_object_data('day'),theappoint.dateday,i);
Val(get_object_data('month'),theappoint.datemonth,i);
Val(get_object_data('year'),theappoint.dateyear,i);
Val(get_object_data('hour'),theappoint.datehour,i);
Val(get_object_data('minute'),theappoint.datemin,i);
Val(get_object_data('duration'),theappoint.time_takes,i); 
Val(get_object_data('type'),theappoint.appointment_type,i);
end;

procedure display_schedule_specific(memplace:integer);
var borderx,bordery,textboxx,textboxx2,blocky,mid:integer;
    bufstr:string;        
    datesnstuff:array[1..4]of word;
    i,z,x,l:integer;
    alright_save:boolean;
    label start_schedule_specific,start_schedule_specific_no_appoint_refresh,end_schedule_specific;
begin 
start_schedule_specific:
theappoint:=Appoint_Mem[memplace];         // <- REFRESHES MEMORY
start_schedule_specific_no_appoint_refresh:
GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]); 

flush_gui_memory(0); 
borderx:=(GetMaxX-520) div 2;//(GridX(2,8) div 2);
bordery:=(GetMaxY-390) div 2; //10
include_object('window1','window','Dental Database - Ημερολόγιο..','no','','',borderx,bordery,GetMaxX-borderx+10,GetMaxY-bordery);
draw_all;
delete_object('window1','name'); 

set_gui_color(ConvertRGB(0,0,0),'comment');
borderx:=borderx+40;
blocky:=45;//GridY(1,14);
textboxx:=borderx+130;
textboxx2:=textboxx+250;
mid:=7;
//ΝΑΜΕ
include_object('namecomment','comment','Όνομα','no','','',borderx,bordery+45,0,0);
include_object('name','textbox',theappoint.name,'no','','',textboxx,Y1(last_object),textboxx2,0);    //X2(last_object)+mid
include_object('last_patient','buttonc','Τελευταία Κατ.','no','','',X2(last_object)+7,Y1(last_object),textboxx2,0);

//SURNAME
include_object('surnamecomment','comment','Επώνυμο','no','','',borderx,Y2(last_object)+10,0,0);
include_object('surname','textbox',theappoint.surname,'no','','',textboxx,Y1(last_object),textboxx2,0);
include_object('patient_find','buttonc','Αναζήτηση','no','','',X2(last_object)+7,Y1(last_object),textboxx2,0);
//DATE
include_object('datecomment','comment','Ημερομηνία Συμβάντος','no','','',borderx,Y2(last_object)+10,0,0);
include_object('day','textbox',Convert2String(theappoint.dateday),'no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXX'),0);
include_object('date/','comment',' / ','no','','',X2(last_object)+mid,Y1(last_object),0,0);
include_object('month','textbox',Convert2String(theappoint.datemonth),'no','','',X2(last_object)+mid,Y1(last_object),X2(last_object)+mid+TextWidth('XXX'),0);
include_object('date//','comment',' / ','no','','',X2(last_object)+mid,Y1(last_object),0,0);
include_object('year','textbox',Convert2String(theappoint.dateyear),'no','','',X2(last_object)+mid,Y1(last_object),X2(last_object)+mid+TextWidth('XXXXX'),0);
include_object('differ','buttonc','Αλλαγή ημερομηνίας','no','','',X2(last_object)+mid,Y1(last_object),0,0);
//TIME
include_object('timecomment','comment','Ώρα Συμβάντος','no','','',borderx,Y2(last_object)+10,0,0);
if theappoint.datehour=0 then bufstr:='' else bufstr:=Convert2String(theappoint.datehour);
include_object('hour','textbox',bufstr,'no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXXXX'),0);
include_object('time:','comment',' : ','no','','',X2(last_object)+mid,Y1(last_object),0,0);
if theappoint.datemin=0 then bufstr:='' else bufstr:=Convert2String(theappoint.datemin);
include_object('minute','textbox',bufstr,'no','','',X2(last_object)+mid,Y1(last_object),X2(last_object)+mid+TextWidth('XXXXX'),0);
include_object('dur:','comment','Διάρκεια','no','','',X2(last_object)+mid+20,Y1(last_object)+3,0,0);
include_object('duration','textbox',Convert2String(theappoint.time_takes),'no','','',X2(last_object)+mid,Y1(last_object)-3,X2(last_object)+mid+TextWidth('XXXXXXXX'),0);
include_object('dur2:','comment','λεπτά','no','','',X2(last_object)+mid,Y1(last_object)+3,0,0);
//USER
include_object('usercomment','comment','Αφορά τον','no','','',borderx,Y2(last_object)+10,0,0);
include_object('user','textbox',theappoint.person_handling,'no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXXXXXXXXX'),0);
include_object('user_select','buttonc','Αντιστοίχηση','no','','',X2('user')+7,Y1(last_object),textboxx2,0);
//TYPE
include_object('typecomment','comment','Τύπος','no','','',borderx,Y2(last_object)+10,0,0);
if theappoint.appointment_type=0 then theappoint.appointment_type:=1;
include_object('type','textbox',Convert2String(theappoint.appointment_type),'no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXX'),0);
include_object('typestr','textbox',what2dostring[theappoint.appointment_type,1],'no','','',X2(last_object)+mid,Y1(last_object),X2(last_object)+mid+TextWidth('XXXXΧX')*2,0);
include_object('typesymbols','buttonc','Αντιστοίχηση αριθμών','no','','',X2(last_object)+mid,Y1(last_object),0,0);
//COMMENTS
include_object('typecomment','comment','Σχόλια','no','','',borderx,Y2(last_object)+10,0,0);
include_object('comments','textbox',theappoint.comment,'no','','',borderx,Y2(last_object)+3,textboxx2,0);
include_object('Select_Works','buttonc','Εργασίες','no','','',X2(last_object)+mid,Y1(last_object),0,0);

//EXIT :)
include_object('opencontact','buttonc','’νοιγμα φακέλου της επαφής','no','','',borderx,GetMaxY-bordery-80,0,0);
include_object('save','buttonc','Αποθήκευση','no','','',borderx,GetMaxY-bordery-50,0,0);
include_object('cancel','buttonc','Ακύρωση','no','','',X2(last_object)+mid,Y1(last_object),0,0);
include_object('delete','buttonc','Διαγραφή','no','','',X2(last_object)+mid,Y1(last_object),0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+mid,Y1(last_object),0,0);
draw_all;

bufstr:='';


//if theappoint.person_file<>'' then bufstr:=theappoint.person_file else
//                                   begin
//                                    bufstr:=retrieve_map('',theappoint.name,theappoint.surname);
//                                    theappoint.person_file:=bufstr;
//                                   end;
//
//if (bufstr<>'') then Load_Person(bufstr); //Prefetch , poso mprosta einai ayto to Prog telospantwn... :)

fasttextboxchange(1);
repeat
interact;

if GUI_Exit then begin
                  i:=MessageBox (0, 'Θα θέλατε να αποθηκευθεί η καταχώρηση? ' , pchar(title), 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
                  if i=IDYES then begin
                                   set_button('save',1);
                                  end;
                 end;

if get_object_data('last_patient')='4' then
                                     begin
                                       set_button('last_patient',0);
                                       save_form_specific;//Save things temporary , before the new Window messes everything up
                                       theappoint.person_file:=People_Data(9);
                                       theappoint.name:=People_Data(2);
                                       theappoint.surname:=People_Data(3); 
                                       goto start_schedule_specific_no_appoint_refresh;
                                     end else
if get_object_data('cancel')='4' then
                                     begin
                                       set_button('cancel',0);  
                                       i:=MessageBox (0, 'Είστε σίγουρος/η οτι θέλετε να μαρκαριστεί ως ακυρωμένη η συγκεκριμένη καταχώρηση? ' , pchar(title), 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
                                       if i=IDYES then begin
                                                         set_object_data('type','value','10',10);
                                                         draw_object_by_name('type');
                                                         set_object_data('typestr','value',what2dostring[10,1],10);
                                                         draw_object_by_name('typestr');
                                                       end;
                                     end else
if get_object_data('differ')='4' then
                                     begin
                                       set_button('differ',0);
                                       {Val(get_object_data('day'),theappoint.dateday,mid);
                                       Val(get_object_data('month'),theappoint.datemonth,mid);
                                       Val(get_object_data('year'),theappoint.dateyear,mid);  }
                                       save_form_specific;
                                       i:=0;
                                       GUI_select_day_month(theappoint.dateday,theappoint.datemonth,theappoint.dateyear,i);
                                       goto start_schedule_specific_no_appoint_refresh;
                                       //TODO 
                                     end else
if get_object_data('Select_Works')='4' then begin
                                            set_button('Select_Works',0);
                                            save_graph_window;
                                            {theappoint.name:=get_object_data('name');
                                            theappoint.surname:=get_object_data('surname'); 
                                            theappoint.person_handling:=get_object_data('user'); //-> an theloyme mono ton sygkekrimeno xristi.. Get_Current_User;
                                            Val(get_object_data('type'),theappoint.appointment_type,mid);
                                            Val(get_object_data('day'),theappoint.dateday,mid);
                                            Val(get_object_data('month'),theappoint.datemonth,mid);
                                            Val(get_object_data('year'),theappoint.dateyear,mid);
                                            Val(get_object_data('hour'),theappoint.datehour,mid); 
                                            Val(get_object_data('minute'),theappoint.datemin,mid); }
                                            save_form_specific; //Save things temporary , before the new Window messes everything up
                                            bufstr:=Select_Works(false);
                                            load_graph_window;
                                            if bufstr<>'' then begin 
                                                                theappoint.comment:=Get_Str_From_Mem(2,Get_Work_Mem_From_Code(bufstr));
                                                               end;
                                            goto start_schedule_specific_no_appoint_refresh;
                                           end else 
if get_object_data('patient_find')='4' then begin
                                            set_button('patient_find',0);
                                            save_graph_window;
                                            {theappoint.comment:=get_object_data('comments');
                                            theappoint.person_handling:=get_object_data('user'); //-> an theloyme mono ton sygkekrimeno xristi.. Get_Current_User;
                                            Val(get_object_data('type'),theappoint.appointment_type,mid);
                                            Val(get_object_data('day'),theappoint.dateday,mid);
                                            Val(get_object_data('month'),theappoint.datemonth,mid);
                                            Val(get_object_data('year'),theappoint.dateyear,mid);
                                            Val(get_object_data('hour'),theappoint.datehour,mid); 
                                            Val(get_object_data('minute'),theappoint.datemin,mid); }
                                            save_form_specific;//Save things temporary , before the new Window messes everything up
                                            bufstr:=GUI_search_person;
                                            load_graph_window;
                                            if bufstr<>'' then
                                                           begin 
                                                             theappoint.person_file:=bufstr; 
                                                             if (bufstr<>'') then begin
                                                                                   Load_Person(bufstr,true); //Prefetch , poso mprosta einai ayto to Prog telospantwn... :)
                                                                                   theappoint.name:=People_Data(2);
                                                                                   theappoint.surname:=People_Data(3);
                                                                                  end;
                                                           end;
                                               goto start_schedule_specific_no_appoint_refresh; 
                                           end else
if get_object_data('user_select')='4' then begin
                                            set_button('user_select',0);
                                            if (Get_User_Access(Get_Current_User)>=100) then begin
                                                                                                 save_graph_window;
                                                                                                  {theappoint.name:=get_object_data('name');
                                                                                                  theappoint.surname:=get_object_data('surname');
                                                                                                  theappoint.comment:=get_object_data('comments');
                                                                                                  Val(get_object_data('type'),theappoint.appointment_type,mid);
                                                                                                  Val(get_object_data('day'),theappoint.dateday,mid);
                                                                                                  Val(get_object_data('month'),theappoint.datemonth,mid);
                                                                                                  Val(get_object_data('year'),theappoint.dateyear,mid);
                                                                                                  Val(get_object_data('hour'),theappoint.datehour,mid);
                                                                                                  Val(get_object_data('minute'),theappoint.datemin,mid);}
                                                                                                  save_form_specific; //Save things temporary , before the new Window messes everything up
                                                                                                 bufstr:=GUI_Select_User;
                                                                                                 load_graph_window;
                                                                                                 if bufstr<>'' then
                                                                                                   begin
                                                                                                    set_object_data('user','value',bufstr,0);
                                                                                                    theappoint.person_handling:=bufstr;
                                                                                                    draw_object_by_name('user');
                                                                                                   end; 
                                                                                                 goto start_schedule_specific_no_appoint_refresh;
                                                                                                end else
                                            MessageBox (0, 'Χρειάζεται κωδικός μεγαλύτερης πρόσβασης (100+)' , ' ', 0);
                                           end else
if get_object_data('typesymbols')='4' then
                                     begin
                                       set_button('typesymbols',0);
                                       bufstr:='Οι τύποι ραντεβού είναι οι εξής.. '+#10;
                                       for mid:=1 to 11 do
                                       bufstr:=bufstr+' '+Convert2String(mid)+' - '+what2dostring[mid,1]+#10;
                                       //bufstr := bufstr + ' ' + Convert2String(mid) + ' - ' + AnsiString(what2dostring[mid,1]) + #10;
                                       //bufstr := bufstr + ' ' + Convert2String(mid) + ' - ' + string(what2dostring[mid,1]) + #10;
                                       save_graph_window;
                                       //MessageBox (0, PChar(bufstr) , PChar(' '), 0);
                                       MessageBoxA( 0,  PAnsiChar(AnsiString(bufstr)),  PAnsiChar(AnsiString(' ')),  0);
                                       load_graph_window;
                                     end else
if get_object_data('save')='4' then  begin
                                       set_button('save',0);  
                                      { theappoint.person_file:=get_object_data('name')+'_'+get_object_data('surname')+'.dat';
                                       theappoint.name:=get_object_data('name');
                                       theappoint.surname:=get_object_data('surname');
                                       theappoint.person_handling:=get_object_data('user'); //-> an theloyme mono ton sygkekrimeno xristi.. Get_Current_User;
                                       theappoint.comment:=get_object_data('comments');
                                       Val(get_object_data('type'),theappoint.appointment_type,mid);
                                       Val(get_object_data('day'),theappoint.dateday,mid);
                                       Val(get_object_data('month'),theappoint.datemonth,mid);
                                       Val(get_object_data('year'),theappoint.dateyear,mid);
                                       Val(get_object_data('hour'),theappoint.datehour,mid);
                                       Val(get_object_data('minute'),theappoint.datemin,mid);  }
                                       save_form_specific;
                                       theappoint.person_file:=retrieve_map('',theappoint.name,theappoint.surname); 
                                       if (theappoint.dateday=0) then begin 
                                                                        MessageBox (0, 'Δεν δώσατε χρονιά της ημερομηνίας ' , 'Error', 0 + MB_ICONEXCLAMATION); 
                                                                      end;
                                       if (theappoint.datemonth=0) then begin 
                                                                        MessageBox (0, 'Δεν δώσατε μήνα της ημερομηνίας ' , 'Error', 0 + MB_ICONEXCLAMATION);
                                                                      end;
                                       if (theappoint.dateyear=0) then begin 
                                                                        MessageBox (0, 'Δεν δώσατε μέρα της ημερομηνίας ' , 'Error', 0 + MB_ICONEXCLAMATION);
                                                                      end;

                                       //datehour : integer;
                                       //datemin : integer;
                                       //time_takes:integer;
                                       alright_save:=true;
                                       //Check duration
                                      if ((theappoint.dateday>0) and (theappoint.dateday<=31)) then
                                       if (Month_Appoint[theappoint.dateday,Max_Appointments_Perday+1]>0) then
                                         begin
                                          //x this time
                                          x:=60*theappoint.datehour+theappoint.datemin;
                                          for l:=1 to Month_Appoint[theappoint.dateday,Max_Appointments_Perday+1] do
                                            begin
                                             i:=Month_Appoint[theappoint.dateday,l];
                                             //z TEST TIME..
                                             z:=60*Appoint_Mem[i].datehour+Appoint_Mem[i].datemin;
                                             if ((z<=x) and (x<z+Appoint_Mem[i].time_takes) and (memplace<>i) and (theappoint.person_handling=Appoint_Mem[i].person_handling) and (Appoint_Mem[i].appointment_type<>10) and (Appoint_Mem[i].appointment_type<>11) ) then
                                                 begin
                                                   bufstr:=Convert2String(theappoint.dateday)+'/'+Convert2String(theappoint.datemonth)+'/'+Convert2String(theappoint.dateyear)+#10;
                                                   bufstr:=bufstr+'Το ραντεβού αυτό θα διακόψει '+what2dostring[Appoint_Mem[i].appointment_type,3]+' '+what2dostring[Appoint_Mem[i].appointment_type,1]+' '+Convert2String(z+Appoint_Mem[i].time_takes-x)+' λεπτά πριν το προγραμματισμένο τέλος .. ';
                                                   bufstr:=bufstr+#10+' Είστε σίγουροι οτι θέλετε να προσθέσετε αυτή την καταχώρηση?';
                                                   //z:=MessageBox (0,pchar(bufstr),'Ημερολόγιο',0+MB_YESNO+MB_ICONQUESTION);
                                                   z := MessageBoxA(0,PAnsiChar(AnsiString(bufstr)), PAnsiChar(AnsiString('Ημερολόγιο')),MB_YESNO or MB_ICONQUESTION );
                                                   if z=IDNO then
                                                     begin
                                                      alright_save:=false;
                                                      break;
                                                     end;
                                                 end;
                                            end;
                                         end;

                     if alright_save then
                        begin //SAVE ALLOWED
                                       if (not theappoint.used) then begin
                                                                      theappoint.used:=true;
                                                                      Add_Schedule_Day(theappoint.dateday,theappoint);
                                                                      Save_Schedule_Day_File(Day_Data_Filename(theappoint.dateday,theappoint.datemonth,theappoint.dateyear),theappoint.dateday,theappoint.datemonth,theappoint.dateyear); 
                                                                     end else
                                                                     begin
                                                                      if ((Appoint_Mem[memplace].dateday<>theappoint.dateday) or (Appoint_Mem[memplace].datemonth<>theappoint.datemonth) or (Appoint_Mem[memplace].dateyear<>theappoint.dateyear) ) then
                                                                        begin
                                                                         //i:=MessageBox (0, 'Η καταχώρηση άλλαξε ημερομηνία , θέλετε να μείνει υπόμνημα στην παλιά ημερομηνία σχετικά με την αλλαγή ?' , title, 0 + MB_YESNO + MB_ICONQUESTION);
                                                                         MessageBox (0, 'Η καταχώρηση άλλαξε ημερομηνία , θα μείνει υπόμνημα στην παλιά ημερομηνία σχετικά με την αλλαγή..' , title, 0  + MB_ICONQUESTION);
                                                                         {if i=IDYES then }begin //Na minei ena ypomnima..
                                                                                          Appoint_Mem[memplace].comment:=' Αλλαγή για  '+Convert2String(theappoint.dateday)+'/'+Convert2String(theappoint.datemonth)+'/'+Convert2String(theappoint.dateyear);
                                                                                          Appoint_Mem[memplace].appointment_type:=11;
                                                                                          Save_Schedule_Day_File(Day_Data_Filename(Appoint_Mem[memplace].dateday,Appoint_Mem[memplace].datemonth,Appoint_Mem[memplace].dateyear),Appoint_Mem[memplace].dateday,Appoint_Mem[memplace].datemonth,Appoint_Mem[memplace].dateyear);
                                                                                         end;{ else
                                                                                         begin //Oliki diagrafi..
                                                                                          delete_appoint(memplace);
                                                                                          Appoint_Mem[memplace].used:=false;
                                                                                          Save_Schedule_Day_File(Day_Data_Filename(Appoint_Mem[memplace].dateday,Appoint_Mem[memplace].datemonth,Appoint_Mem[memplace].dateyear),Appoint_Mem[memplace].dateday,Appoint_Mem[memplace].datemonth,Appoint_Mem[memplace].dateyear); 
                                                                                         end; }
                                                                         if ((Appoint_Mem[memplace].datemonth<>theappoint.datemonth) or (Appoint_Mem[memplace].dateyear<>theappoint.dateyear)) then //Prepei na fortwsoume ton allo mina..
                                                                                            begin
                                                                                             Load_Schedule_Month(theappoint.datemonth,theappoint.dateyear);
                                                                                            end;
                                                                         //To parelthon taktopoiithike , pame na perasoume tis kainourgies plirofories..
                                                                         Add_Schedule_Day(theappoint.dateday,theappoint);
                                                                         Save_Schedule_Day_File(Day_Data_Filename(theappoint.dateday,theappoint.datemonth,theappoint.dateyear),theappoint.dateday,theappoint.datemonth,theappoint.dateyear);
                                                                         if ((Appoint_Mem[memplace].datemonth<>theappoint.datemonth) or (Appoint_Mem[memplace].dateyear<>theappoint.dateyear)) then //Restore ston arxiko mina..
                                                                                            begin
                                                                                             Load_Schedule_Month(Appoint_Mem[memplace].datemonth,Appoint_Mem[memplace].dateyear);
                                                                                            end;
                                                                         MessageBox (0, 'Οι αλλαγές αποθηκεύτηκαν' , title, 0 + MB_ICONASTERISK);
                                                                         goto end_schedule_specific;

                                                                        end else
                                                                      Appoint_Mem[memplace]:=theappoint; 
                                                                     end; 
                                       DrawApsXY('greenbtn',X1('save')-GetApsInfo('greenbtn','sizex')-5,Y1('save')+3);
                end; // SAVE ALLOWED
                                     end else
if get_object_data('delete')='4' then  begin
                                        set_button('delete',0);
                                        save_graph_window;
                                        //mid:=MessageBox (0, pchar('Είστε σίγουροι οτι θέλετε να διαγράψετε την συγκεκριμένη καταχώρηση ('+what2dostring[theappoint.appointment_type,1]+')') , 'Διαγραφή ', 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
                                        mid := MessageBoxA(
  0,
  PAnsiChar(AnsiString(
    'Είστε σίγουροι οτι θέλετε να διαγράψετε την συγκεκριμένη καταχώρηση (' +
    what2dostring[theappoint.appointment_type,1] + ')'
  )),
  PAnsiChar(AnsiString('Διαγραφή ')),
  MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL
);
                                        if mid=IDYES then
                                                  begin
                                                   set_button('exit',1);
                                                   delete_appoint(memplace);
                                                  end else
                                        load_graph_window;

                                       end else
if get_object_data('opencontact')='4' then
                                     begin
                                       set_button('opencontact',0);

                                       if theappoint.person_file='' then   //Den exei ginei prefetch to arxeio astheni.. Pame na dokimasoume na to fortwsoume..
                                           begin
                                            theappoint.name:=get_object_data('name');
                                            theappoint.surname:=get_object_data('surname');
                                            theappoint.person_file:=retrieve_map('',theappoint.name,theappoint.surname); 
                                            //if (theappoint.person_file<>'') then  Load_Person(theappoint.person_file,true); 
                                           end;

                                       if (theappoint.person_file<>'') then begin
                                                                             Load_Person(theappoint.person_file,true);
                                                                             View_Person();
                                                                             goto start_schedule_specific;
                                                                            end;
                                     end else 
if get_object_data('type')<>Convert2String(theappoint.appointment_type) then
                                            begin
                                              Val(get_object_data('type'),theappoint.appointment_type,mid);
                                              set_object_data('typestr','value',what2dostring[theappoint.appointment_type,1],0);
                                              draw_object_by_name('typestr');
                                            end;

until GUI_Exit;
end_schedule_specific:
set_gui_color(ConvertRGB(255,255,255),'comment');
end;



procedure GUI_add_new_schedule_day(day,monthnum,year,hour,minute,duration:integer; patient_file:string);
var buf_restore:string;
begin
if Appoint_Mem_Place>=Max_Appointments_Loaded then MessageBox (0, 'Το πρόγραμμα της ημέρας είναι γεμάτο..' , title, 0) else
                                                            begin
                                                             clear_appoint(Appoint_Mem_Place+1);
                                                             Appoint_Mem[Appoint_Mem_Place+1].dateday:=day;
                                                             Appoint_Mem[Appoint_Mem_Place+1].datemonth:=monthnum;
                                                             Appoint_Mem[Appoint_Mem_Place+1].dateyear:=year; 
                                                             Appoint_Mem[Appoint_Mem_Place+1].datehour:=hour;
                                                             Appoint_Mem[Appoint_Mem_Place+1].datemin:=minute;
                                                             Appoint_Mem[Appoint_Mem_Place+1].time_takes:=duration;
                                                             if patient_file<>'' then begin
                                                                                       buf_restore:=People_Data(9);
                                                                                       Load_Person(patient_file,false);
                                                                                       Appoint_Mem[Appoint_Mem_Place+1].name:=People_Data(2);
                                                                                       Appoint_Mem[Appoint_Mem_Place+1].surname:=People_Data(3);
                                                                                       if buf_restore<>'' then Load_Person(buf_restore,true);
                                                                                      end;
                                                             Appoint_Mem[Appoint_Mem_Place+1].person_file:=patient_file;
                                                             display_schedule_specific(Appoint_Mem_Place+1);
                                                            end;
end;


procedure display_schedule_day(day,monthnum,year,all_users:integer);
var borderx,bordery,ax1,ax2,ay1,ay2,recat,blockx,blocky,totalappointments:integer;
    theapp:Appointment;
    bufstr,lastobj:string;
    shadeeffect:boolean;
label start_schedule_day;
begin 
Write_2_Log('Displaying schedule of '+Convert2String(day)+'/'+Convert2String(monthnum)+'/'+Convert2String(year));
start_schedule_day: 
borderx:=40;
bordery:=40;
flush_gui_memory(0);
draw_background(3);
//DrawRectangle2(borderx,bordery,GetMaxX-borderx,GetMaxY-bordery,ConvertRGB(255,255,199),ConvertRGB(255,255,199));

SetFont('Arial','Greek',36,0,700,0);
GotoXY(1,(bordery+20-Textheight('A')) div 4);
OutTextCenter(Convert2String(day)+' / '+tl(MonthStr[monthnum])+' / '+Convert2String(year)); 
SetFont('Arial','Greek',17,0,900,0);
TextColor(ConvertRGB(0,0,0));

Sort_Schedule_Day(day);

ay1:=bordery;
ay2:=GetMaxY-bordery-30;  //to -30 gia na min akoumpaei sta koumpia apo katw :P
blocky:=TextHeight('A')*3 div 2;
recat:=1;
totalappointments:=0;
shadeeffect:=false;
while ay1<ay2 do
  begin
     if shadeeffect then DrawRectangle2(borderx,ay1,GetMaxX-borderx,ay1+blocky,ConvertRGB(221,221,221),ConvertRGB(221,221,221)) else
                         DrawRectangle2(borderx,ay1,GetMaxX-borderx,ay1+blocky,ConvertRGB(204,204,204),ConvertRGB(204,204,204));
     shadeeffect:= ( not shadeeffect );
     //DrawLine(borderx,y1,GetMaxX-borderx,y1,ConvertRGB(255,0,0));
     if Get_Day_Length(day)>=recat then begin
                                         theapp:= Appoint_Mem[Month_Appoint[day,recat]];
         if ((theapp.person_handling=Get_Current_User) or (all_users=3)) then
                 begin  //Person Restrictions..
                                         bufstr:=' ';
                                         if (theapp.datehour>=0) and (theapp.datehour<=9) then bufstr:=bufstr+'0';
                                         bufstr:=bufstr+Convert2String(theapp.datehour)+' : ';

                                         if (theapp.datemin>=0) and (theapp.datemin<=9) then bufstr:=bufstr+'0';
                                         bufstr:=bufstr+Convert2String(theapp.datemin)+'   ';
 
                                         bufstr:=bufstr+what2dostring[theapp.appointment_type,1]+'   σχετικά με τον/την  ';
                                         bufstr:=bufstr+theapp.name+' '+theapp.surname+'  '; 
                                         bufstr:=bufstr+' αφορά τον '+theapp.person_handling+'  ';
                                         if theapp.time_takes>0 then bufstr:=bufstr+' διαρκεί '+Convert2String(theapp.time_takes)+' λεπτά   ';
                                         OuttextXY(borderx,ay1,bufstr);
                                         include_object('layer('+Convert2String(recat)+')','layer','1','no','','select',borderx,ay1,GetMaxX-borderx,ay1+TextHeight('A'));

                     totalappointments:=totalappointments+1;
                     //TOTAL APPOINTMENTS
                  end;
                                        end;
     recat:=recat+1;
     if recat=Max_Appointments_Perday+1 then break;
     ay1:=ay1+blocky;
  end;

if totalappointments=0 then begin //NA PAROUSIASTEI VOITHITIKO PARATHIRAKI POU NA LEEI OTI I MERA EINAI ADEIA :) ADDED 5-5-07
                              if all_users=3 then bufstr:='Η μέρα αυτή είναι κενή κάντε κλίκ εδώ ή στο κουμπί Προσθήκη κάτω δεξια για νέα καταχώρηση..' else
                                                  bufstr:='Η μέρα αυτή είναι κενή για εσάς κάντε κλίκ εδώ ή στο κουμπί Προσθήκη κάτω δεξια για νέα καταχώρηση..';
                              include_object('add_first','buttonc',bufstr,'no','','',-1,GetMaxY div 2,-1,0);
                              //DrawRectangle2(0,0,0,0,0,0); 
                              DrawRectangle2(X1('add_first')-20,Y1('add_first')-20,X2('add_first')+20,Y2('add_first')+20,ConvertRGB(123,123,123),ConvertRGB(103,103,103));
                            end else
                              include_object('add_first','layer','1','no','','',1,123,1,123);


TextColor(ConvertRGB(255,255,255));

include_object('lab_pro','label','Προβολή προγράμματος όλων των χρηστών : ','no','','',40,GetMaxY-40,0,0);
include_object('all_users','checkbox',Convert2String(all_users),'no','','',TextWidth('Προβολή προγράμματος όλων των χρηστών : ')+7,GetMaxY-40,0,0);   //X2(last_object)    Y1(last_object)

include_object('add_schedule','buttonc','Προσθήκη','no','','',GetMaxX-180,GetMaxY-40,0,0);
include_object('exit','buttonc','Έξοδος','no','','',GetMaxX-90,GetMaxY-40,0,0);       //X2(last_object)
SetFont('Arial','Greek',15,0,700,0);
draw_all;
repeat
interact;
lastobj:=return_last_mouse_object;

if get_object_data('add_first')='4' then begin
                                          set_button('add_first',0);
                                          set_button('add_schedule',1); 
                                         end;


if get_object_data('add_schedule')='4' then begin
                                              set_button('add_schedule',0);
                                              if Appoint_Mem_Place>=Max_Appointments_Loaded then MessageBox (0, 'Το πρόγραμμα της ημέρας είναι γεμάτο..' , title, 0) else
                                                            begin
                                                             clear_appoint(Appoint_Mem_Place+1);
                                                             Appoint_Mem[Appoint_Mem_Place+1].dateday:=day;
                                                             Appoint_Mem[Appoint_Mem_Place+1].datemonth:=monthnum;
                                                             Appoint_Mem[Appoint_Mem_Place+1].dateyear:=year; 
                                                             display_schedule_specific(Appoint_Mem_Place+1);
                                                            end;
                                            end else
if get_object_data(lastobj)='4' then begin
                                       if (lastobj<>'') then seperate_words(lastobj);
                                       if (Upcase(get_memory(1))='LAYER') then    begin
                                                                                    Val(get_memory(2),ax1,ax2);
                                                                                    if (ax1>0) and (ax1<=Get_Day_Length(day)) then display_schedule_specific(Month_Appoint[day,ax1]) else
                                                                                                                                   display_schedule_specific(Max_Appointments_Loaded);
                                                                                    goto start_schedule_day;
                                                                                  end;
                                       set_object_data('layer('+get_memory(2)+')','VALUE','1',1);
                                     end;
until  GUI_Exit;
Save_Schedule_Day_File(Day_Data_Filename(day,monthnum,year),day,monthnum,year);
end;


function GUI_select_day_month(var daynum,monthnum,year,all_users:integer):integer;
var daysdrawn,xx,xspace,xborder,yy,yspace,yborder,boxx,boxy:integer;
    x11,y11,x22,y22,i,y,days,dayweight:integer;
   // all_users:integer; // <- An einai 3 tote dinetai info gia olous tous users..
    usrmonth,usryear,lastobj:string;
    datesnstuff:array[1..4]of word;  
    what2docount:array[1..11] of integer;
    retres:integer;
    label start_schedule_month,end_schedule_month;
begin
retres:=0;
all_users:=3;

start_schedule_month:

flush_gui_memory(0);
draw_background(3); 

GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
if monthnum=0 then monthnum:=datesnstuff[3];
if year=0 then year:=datesnstuff[4];
// datesnstuff[1] = Current day

usrmonth:=Convert2String(monthnum);
usryear:=Convert2String(year);
include_object('backmonth','buttonc','<-','no','','',100,GetMaxY-40,0,0);
include_object('themonth','textbox',usrmonth,'no','','',X2(last_object)+7,Y1(last_object),X2(last_object)+7+TextWidth('XXX'),0);
include_object('the/','comment',' / ','no','','',X2(last_object)+7,Y1(last_object)+3,0,0);
include_object('theyear','textbox',usryear,'no','','',X2(last_object)+7,Y1(last_object)-3,X2(last_object)+7+TextWidth('XXXXX'),0);
include_object('forwardmonth','buttonc','->','no','','',X2(last_object)+7,Y1(last_object),0,0);

include_object('lab_pro','label','Προβολή προγράμματος όλων των χρηστών : ','no','','',X2(last_object)+40,Y1(last_object),0,0);
include_object('all_users','checkbox',Convert2String(all_users),'no','','',X2(last_object)+7,Y1(last_object),0,0);

include_object('exit','buttonc','Έξοδος','no','','',GetMaxX-100,GetMaxY-40,0,0);

if Last_Mem_Load_ID<>Convert2String(monthnum)+Convert2String(year) then Load_Schedule_Month(monthnum,year);   // LOAD FROM HARDDRIVE

ChangeCursorIcon(mouse_icon_resource('arrow'));
xspace:=20;
xborder:=60;
yspace:=20;
yborder:=120;
boxx:=(GetMaxX-2*xborder) div 7;
boxy:=(GetMaxY-2*yborder) div 6;

SetFont('Arial','Greek',36,0,700,0);
GotoXY(1,(yborder-Textheight('A')) div 4);
OutTextCenter(tl(MonthStr[monthnum])+' '+Convert2String(year));
SetFont('Arial','Greek',22,0,700,0);

for x11:=1 to 7 do begin
                    x22:=TextWidth(DayStr[x11]);
                    OutTextXY(boxx*(x11-1)+((boxx-x22) div 2)+xborder,yborder-30,DayStr[x11]);
                  end;

SetFont('Arial','Greek',15,0,700,0);
daysdrawn:=0;
yy:=1; //prwto row..
xx:=Calender_Function(1,monthnum,year,1); 
while daysdrawn<month_days(monthnum,year) do
           begin
            daysdrawn:=daysdrawn+1;
            x11:=xborder+(boxx)*(xx-1);
            y11:=yborder+(boxy)*(yy-1);
            x22:=xborder+(boxx)*xx;
            y22:=yborder+(boxy)*yy;
            include_object('layer('+Convert2String(daysdrawn)+')','layer','1','no','','select',x11,y11,x22,y22);
            if (datesnstuff[1]=daysdrawn) and (datesnstuff[3]=monthnum) and (datesnstuff[4]=year)then
                      DrawRectangle2(x11,y11,x22,y22,ConvertRGB(255,0,0),ConvertRGB(0,155,0)) else
                      DrawRectangle2(x11,y11,x22,y22,ConvertRGB(255,0,0),ConvertRGB(155,0,0));

            dayweight:=0;
            if Get_Day_Length(daysdrawn)>0 then
                        begin 
                         for i:=1 to 11 do what2docount[i]:=0;
                         for i:=1 to Get_Day_Length(daysdrawn) do
                                             begin

                                       if ((Appoint_Mem[Month_Appoint[daysdrawn,i]].person_handling=Get_Current_User) or (all_users=3)) then
                                            begin //Person Restrictions
                                               y:=Appoint_Mem[Month_Appoint[daysdrawn,i]].appointment_type;
                                               if ((y>=1) and (y<=10)) then what2docount[y]:=what2docount[y]+1;
                                               dayweight:=dayweight+1;
                                            end;

                                             end; 
                         y:=0;
                         for i:=1 to 11 do begin
                                            y:=y+1;
                                            if what2docount[i]<1 then y:=y-1 else
                                            if what2docount[i]=1 then OutTextXY(x11+37,y11+5+TextHeight('Α')*y,' 1 '+what2dostring[i,1]) else
                                            if what2docount[i]>1 then OutTextXY(x11+37,y11+5+TextHeight('Α')*y,' '+Convert2String(what2docount[i])+' '+what2dostring[i,2]);
                                           end;
                        end;
            SetFont('Arial','Greek',22,0,700,0);
            OutTextXY(x11+5,y11+5,Convert2String(daysdrawn));

            SetFont('Arial','Greek',13,0,700,0);
            i:=(100*dayweight) div max_human_dayload; //Pososto plirotitas meras..
            OutTextXY(x11+5,y11+2*TextHeight('A'),'('+Convert2String(i)+'%)');

            SetFont('Arial','Greek',15,0,700,0);
            
            xx:=xx+1;
            if xx>7 then begin
                          xx:=1;
                          yy:=yy+1;
                         end;
           end;
draw_all;
delay(100);
for x11:=1 to 16 do Mousebutton(1);
repeat
interact;
lastobj:=return_last_mouse_object;

if get_object_data('themonth')<>usrmonth then begin
                                                Val(get_object_data('themonth'),days,yy);
                                                if ((yy=0) and (days>0) and (days<=12))
                                                         then begin
                                                              usrmonth:=get_object_data('themonth');
                                                              monthnum:=days;
                                                              goto start_schedule_month;
                                                             end else
                                                             begin
                                                              set_object_data('themonth','VALUE',usrmonth,0);
                                                             end;
                                              end;
if get_object_data('theyear')<>usryear then begin
                                                Val(get_object_data('theyear'),days,yy);
                                                if ((yy=0) and (days>2004))
                                                         then begin
                                                              usryear:=get_object_data('theyear');
                                                              year:=days;
                                                              goto start_schedule_month;
                                                             end else
                                                             begin
                                                              set_object_data('theyear','VALUE',usryear,0);
                                                             end;
                                              end;

if get_object_data('forwardmonth')='4' then begin
                                             set_button('forwardmonth',0);
                                             Val(get_object_data('themonth'),days,yy);
                                             days:=days+1;
                                             if days>12 then begin
                                                              days:=1;
                                                              year:=year+1;
                                                             end;
                                             monthnum:=days;
                                             goto start_schedule_month;
                                            end else
if get_object_data('backmonth')='4' then   begin
                                             set_button('backmonth',0);
                                             Val(get_object_data('themonth'),days,yy);
                                             days:=days-1;
                                             if days<1 then begin
                                                             days:=12;
                                                             year:=year-1;
                                                            end;
                                             monthnum:=days;
                                             goto start_schedule_month;
                                            end else 
if get_object_data(lastobj)='4' then begin
                                       if (lastobj<>'') then seperate_words(lastobj);
                                       if (Upcase(get_memory(1))='LAYER') then    begin
                                                                                    Val(get_memory(2),days,yy);
                                                                                    retres:=days;
                                                                                    goto end_schedule_month;
                                                                                    //display_schedule_day(days,monthnum,year,all_users);
                                                                                    //MessageBox (0, Pchar(get_memory(2)) , 'Dialog', 0);
                                                                                    //goto start_schedule_month;
                                                                                  end;
                                       set_object_data('layer('+get_memory(2)+')','VALUE','1',1);
                                      end else
if get_object_data('all_users')<>Convert2String(all_users)  then
                                           begin
                                             Val(get_object_data('all_users'),i,yy);
                                             all_users:=i; 
                                              goto start_schedule_month;
                                           end;

until GUI_Exit;
end_schedule_month:
if retres>0 then daynum:=retres;
Val(get_object_data('themonth'),monthnum,yy);
Val(get_object_data('theyear'),year,yy);
GUI_select_day_month:=retres;
end;

procedure display_schedule_month(monthnum,year:integer);
var the_selection,all_users:integer; 
    end_month:boolean;
begin
all_users:=0;
end_month:=false;
GUI_select_day_month(the_selection,monthnum,year,all_users); //FIRST..
if GUI_Exit then end_month:=true else
if the_selection<>0 then display_schedule_day(the_selection,monthnum,year,all_users);
while (not (end_month))  do
   begin
    GUI_select_day_month(the_selection,monthnum,year,all_users);
    if GUI_Exit then end_month:=true else
    if the_selection<>0 then display_schedule_day(the_selection,monthnum,year,all_users);
   end;
end;





 
procedure draw_n_add_compact_month(ax1,ay1,ax2,ay2,month,year:integer);
var daysdrawn,i,boxx,boxy,xx,yy,x11,x22,y11,y22,bcol:integer;
    datesnstuff:array[1..4]of word;
    draw_colors:array[1..6] of integer;
    // 1 Text Color
    // 2 Border Color
    // 3 Active Day Color
    // 4 Passed Days Color
    // 5 Future Days Color
    // 6 Out Color

    bufc:char;
begin
GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);

boxx:=(ax2-ax1) div 8;//2*TextWidth('000');
boxy:=(ay2-ay1) div 8;//2*TextHeight('000');
draw_colors[1]:=ConvertRGB(255,255,255);
draw_colors[2]:=ConvertRGB(255,0,0);
draw_colors[3]:=ConvertRGB(0,155,0);
draw_colors[4]:=ConvertRGB(155,0,0);
draw_colors[5]:=ConvertRGB(100,0,0);
draw_colors[6]:=ConvertRGB(255,255,255);

delete_object('compact_month','OWNINGWINDOW');

bcol:=TakeTextColor;
TextColor(draw_colors[6]);

OutTextXY(ax1,ay1,(MonthStr[month])+' '+Convert2String(year));
SetFont('arial','greek',20,0,0,0);
for i:=1 to 7 do begin
                   if i=1 then bufc:='Δ' else
                   if i=2 then bufc:='T' else
                   if i=3 then bufc:='T' else
                   if i=4 then bufc:='Π' else
                   if i=5 then bufc:='Π' else
                   if i=6 then bufc:='Σ' else
                   if i=7 then bufc:='Κ';
                   OutTextXY(ax1+(boxx)*(i-1)+(ax1 div 2),ay1+25,bufc);
                 end;
SetFont('arial','greek',15,0,0,0);


TextColor(draw_colors[1]);

ay1:=ay1+23;
daysdrawn:=0;
xx:=Calender_Function(1,month,year,1);
yy:=2;
while daysdrawn<month_days(month,year) do
           begin
            daysdrawn:=daysdrawn+1;
            x11:=ax1+(boxx)*(xx-1);
            y11:=ay1+(boxy)*(yy-1);
            x22:=ax1+(boxx)*xx;
            y22:=ay1+(boxy)*yy;

            if (datesnstuff[1]=daysdrawn) and (datesnstuff[3]=month) and (datesnstuff[4]=year)then
            DrawRectangle2(x11,y11,x22,y22,draw_colors[2],draw_colors[3]) else    // SIMERINI IMERA..
            if (datesnstuff[1]<daysdrawn) or (datesnstuff[3]<month) or (datesnstuff[4]<year)then
            DrawRectangle2(x11,y11,x22,y22,draw_colors[2],draw_colors[4]) else // PALIA MERA
            DrawRectangle2(x11,y11,x22,y22,draw_colors[2],draw_colors[5]); //MELLON
            include_object('layer('+Convert2String(daysdrawn)+')','layer','1','compact_month','','select',x11,y11,x22,y22);
            OutTextXY(x11+5,y11+5,Convert2String(daysdrawn));

            xx:=xx+1;
            if xx>7 then begin
                          xx:=1;
                          yy:=yy+1;
                         end;
           end;

TextColor(bcol); 
end;




procedure draw_n_add_compact_nameday(ax1,ay1,ax2,ay2,day,month,year:integer; all_users:boolean);
const MAX_NAMES=30;
var theapp:Appointment;
    names_gathered:array[1..MAX_NAMES,1..2] of string;
    i,z,x,y,nums,namenums:integer;
    what2add,thefile:string;

begin
delete_object('compact_names','OWNINGWINDOW');
nums:=Month_Appoint[day,Max_Appointments_Perday+1];
namenums:=0;
if nums>0 then
  begin  //Collect Appointment Names..
   for i:=1 to nums do
    begin
     theapp := Appoint_Mem[Month_Appoint[day,i]]; 


      if ((theapp.person_handling=Get_Current_User) or (all_users)) then
     begin //  USER
     what2add:=theapp.name+' '+theapp.surname;
     thefile:=theapp.person_file;
     if namenums>0 then // If names added search catalogue..
        begin
          z:=0;
          for x:=1 to namenums do
            begin
             if Equal(names_gathered[x,1],what2add) then begin
                                                        z:=1;
                                                        break;
                                                       end;
            end;
        end else z:=0; //If empty , you can add

     if ((namenums>=MAX_NAMES) and (z=0)) then z:=1; //Save Overflow..

     if z=0 then //If name doesnot exist
        begin
         namenums:=namenums+1;
         names_gathered[namenums,1]:=what2add;
         names_gathered[namenums,2]:=thefile;
        end;
 
     end; //   USER
    end;
  end;


include_object('lab_pro','label','Προβολή προγράμματος όλων : ','no','','',ax1+5,ay1+5,ax2-5,0);
if all_users then what2add:='3' else what2add:='1';
include_object('all_users','checkbox',what2add,'no','','',X2(last_object)+7,Y1(last_object),0,0);
include_object('search','buttonc','Αναζήτηση Ασθενών','compact_names','','',ax1+5,Y2(last_object)+5,ax2-5,0);

if namenums>0 then
  begin
   for i:=1 to namenums do
    begin                                                                                          //X1(last_object)        X2(last_object)
     include_object('name('+names_gathered[i,2],'buttonc',names_gathered[i,1],'compact_names','','',ax1+5,Y2(last_object)+5,ax2-5,0);
    end;
  end;
draw_all;
end;


                                                                               //all_users:boolean
procedure draw_n_add_compact_weeksched(ax1,ay1,ax2,ay2,day,month,year:integer; all_users:boolean);
var blockx,i,tmpx,daysdrawn,dayweight,startday,valid_day_1,valid_day_2,x11,y11,y,z:integer;
    what2docount:array[1..11] of integer;
    datesnstuff:array[1..4]of word;
    label end_draw;
begin
//DrawRectangle2(ax1+5,ay1+5,ax2-5,ay2-5,ConvertRGB(123,123,123),ConvertRGB(123,123,123));
blockx:=(ax2-ax1-20) div 7;
SetFont('arial','greek',20,0,0,0);
for i:=1 to 7 do
   begin
    tmpx:=(blockx-TextWidth(DayStr[i])) div 2;
    OutTextXY(ax1+tmpx+(i-1)*blockx,ay1+10,DayStr[i]);
    if i<7 then DrawLine(ax1+5+i*blockx,ay1+6,ax1+5+i*blockx,ay2-5,ConvertRGB(193,193,193)); 
   end;
SetFont('arial','greek',15,0,0,0);


GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
startday:=day;
startday:=startday-Calender_Function(day,month,year,1)+1;
if startday<1 then begin
                     valid_day_1:=1;
                     z:=Calender_Function(1,month,year,1)-1; 
                   end else
                   begin 
                    valid_day_1:=startday;
                    z:=0;// TEST 01-02-07 
                   // z:=Calender_Function(startday,month,year,1);
                   end;

if startday+6>month_days(month,year) then
                   begin
                     valid_day_2:=month_days(month,year);
                     //z:=Calender_Function(1,month,year,1);
                   end else
                   begin 
                    valid_day_2:=startday+6; 
                   end;

 
y11:=ay1+30;

  for daysdrawn:=valid_day_1 to valid_day_2 do
  begin
    z:=z+1; //CURRENT DAY OF WEEK
    x11:=ax1+(z-1)*blockx;
    if ( (datesnstuff[1]=daysdrawn) and (datesnstuff[3]=month) and  (datesnstuff[4]=year) ) then DrawRectangle2(x11+5,ay2-30,x11+5+blockx,ay2-20,ConvertRGB(0,255,0),ConvertRGB(0,255,0));
    dayweight:=0;
    if Get_Day_Length(daysdrawn)>0 then
                        begin 
                         for i:=1 to 11 do what2docount[i]:=0;
                         for i:=1 to Get_Day_Length(daysdrawn) do
                                             begin

                                       if ((Appoint_Mem[Month_Appoint[daysdrawn,i]].person_handling=Get_Current_User) or (all_users)) then
                                            begin //Person Restrictions
                                               y:=Appoint_Mem[Month_Appoint[daysdrawn,i]].appointment_type;
                                               if ((y>=1) and (y<=10)) then what2docount[y]:=what2docount[y]+1;
                                               dayweight:=dayweight+1;
                                            end;

                                             end; 
                         y:=0;
                         OutTextXY(x11+5,y11+5+TextHeight('Α')*y,Convert2String(daysdrawn)+'/'+Convert2String(month)+'/'+Convert2String(year));
                         for i:=1 to 11 do begin
                                            y:=y+1;
                                            if what2docount[i]<1 then y:=y-1 else
                                            if what2docount[i]=1 then OutTextXY(x11+5,y11+5+TextHeight('Α')*y,StringShrink(' 1 '+what2dostring[i,1],blockx)) else
                                            if what2docount[i]>1 then OutTextXY(x11+5,y11+5+TextHeight('Α')*y,StringShrink(' '+Convert2String(what2docount[i])+' '+what2dostring[i,2],blockx));
                                           end;
                        end;

  end;


end_draw:
end;


procedure calc_x_y_field(sta_x,mid_x,sta_y,end_y,from_hour,from_minute,to_hour,to_minute:integer; var bx1,by1,bx2,by2:integer);
var f_comp,t_comp:integer;
    page2:boolean;
    minutey:real;
begin
if from_hour>=12 then page2:=true else page2:=false;
minutey:= (end_y-sta_y) / (12*60) ;

if page2 then begin
               f_comp:=(from_hour-12)*60+from_minute;
               t_comp:=(to_hour-12)*60+to_minute;  
              end else
              begin 
               f_comp:=from_hour*60+from_minute;
               t_comp:=to_hour*60+to_minute;
              end;
f_comp:=round(f_comp*minutey);
t_comp:=round(t_comp*minutey);


bx1:=TextWidth('24:00');
bx2:=GetApsInfo('field','sizex')+TextWidth('24:00');
by1:=f_comp;
by2:=t_comp;


if page2 then begin
               bx1:=bx1+mid_x;
               bx2:=bx2+mid_x;
              end else
              begin
               bx1:=bx1+sta_x;
               bx2:=bx2+sta_x;
              end;
by1:=by1+sta_y;
by2:=by2+sta_y; 
end;


procedure calc_time_field(ax1,midx,ay1,ay2,bx1,by1,by2:integer; var from_hour,from_minute,to_hour,to_minute:integer);
var f_comp,t_comp,lny:integer;
    page2:boolean;
    minutey:real;
begin
minutey:=(ay2-ay1) / (12*60);
if bx1>=midx then page2:=true else
                  page2:=false;

from_minute:=round ( (by1-ay1) / (minutey) );
from_hour:=from_minute div 60;
from_minute:=from_minute mod 60;

to_minute:=round ( (by2-ay1) / (minutey) );
to_hour:=to_minute div 60;
to_minute:=to_minute mod 60;

if page2 then begin
                from_hour:=from_hour+12;
                to_hour:=to_hour+12;
              end;
end;


procedure draw_n_add_compact_daysched(ax1,ay1,ax2,ay2,day,month,year:integer; all_users:boolean);
var drx1,drx2,lny,i,z,hour,min,mid_x,dr_color,keep_col:integer;
    bx1,by1,bx2,by2:integer;
    theapp:Appointment;
    datesnstuff:array[1..4]of word;
begin
keep_col:=TakeTextColor;
dr_color:=ConvertRGB(0,0,0);
                                                 //Get_GUI_Color(1)
DrawRectangle2(ax1+5,ay1+5,ax2-5,ay2-5,ConvertRGB(225,225,225),ConvertRGB(255,225,225));
if get_object_number('add_new_program_layer')<=0 then include_object('add_new_program_layer','layer','1','no','','ring',ax1+5,ay1+5,ax2-5,ay2-5);
     
TextColor(dr_color);
drx1:=ax1+5;
drx2:=ax1+(ax2-ax1) div 2;
mid_x:=drx2;
DrawLine(drx2,ay1+5,drx2,ay2-5,dr_color);

lny:=(ay2-ay1-10) div 12;
hour:=0;
for z:=1 to 2 do
begin
    for i:=1 to 12 do
      begin
       if i<>12 then DrawLine(drx1,ay1+5+(i)*lny,drx2,ay1+5+(i)*lny,dr_color);
      // DrawApsXY('field',TextWidth('24:00')+drx1,ay1+5+(i-1)*lny);
      // DrawRectangle2(TextWidth('24:00')+drx1+2,ay1+5+(i-1)*lny+GetApsInfo('field','sizey'),TextWidth('24:00')+drx1-1+GetApsInfo('field','sizex'),ay1+5+(i-1)*lny+GetApsInfo('field','sizey')+30,ConvertRGB(54,134,174),ConvertRGB(54,134,174));

       //HOUR DRAW
       OutTextXY(drx1,ay1+5+(i-1)*lny,Convert2String(hour)+':00');
       hour:=hour+1;
      end;
drx1:=drx2;
drx2:=ax2-5;
end;

GetLTime(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
calc_x_y_field(ax1+5,mid_x,ay1+5,ay2-5,datesnstuff[1],datesnstuff[2],datesnstuff[1],datesnstuff[2]+10,bx1,by1,bx2,by2);
DrawRectangle2(bx1+1,by1,bx1+(ax2-ax1) div 2-45,by2,ConvertRGB(255,0,0),ConvertRGB(255,0,0));

//GIA NA MHN FAINONTAI WRES TOU TYPOU 4:9 alla 4:09 ktl ktl
if Length(Convert2String(datesnstuff[2]))<2 then set_memory(1,'0'+Convert2String(datesnstuff[2])) else
                                                 set_memory(1,Convert2String(datesnstuff[2]));
//GIA NA MHN FAINONTAI WRES TOU TYPOU 4:9 alla 4:09 ktl ktl
                                                                               //Convert2String(datesnstuff[2])
OutTextXY(bx1+(ax2-ax1) div 2-95,by2,'Τώρα '+Convert2String(datesnstuff[1])+':'+get_memory(1));

SetFont('arial','greek',13,0,0,0);

if Month_Appoint[day,Max_Appointments_Perday+1]>0 then
  begin 
   for i:=1 to Month_Appoint[day,Max_Appointments_Perday+1] do
    begin
     theapp:=Appoint_Mem[Month_Appoint[day,i]];

     if ((theapp.person_handling=Get_Current_User) or (all_users)) then
     begin//USER
      min:=theapp.time_takes;
      hour:=theapp.datehour+min div 60;
      min:=theapp.datemin+min mod 60;
      calc_x_y_field(ax1+5,mid_x,ay1+5,ay2-5,theapp.datehour,theapp.datemin,hour,min,bx1,by1,bx2,by2);

      //

      DrawRectangle2(bx1+1,by1+GetApsInfo('field','sizey'),bx2,by2,ConvertRGB(54,134,174),ConvertRGB(54,134,174));
      DrawRectangle2(bx1+5,by1+GetApsInfo('field','sizey')+5,bx2-5,by2-5,ConvertRGB(255,134,174),ConvertRGB(255,134,174));
      DrawApsXY('field',bx1,by1);
      OutTextXY(bx1+6,by1,StringShrink(First_Capital(what2dostring[theapp.appointment_type,1]),GetApsInfo('field','sizex')-12) ); //+GetApsInfo('field','sizey')
      include_object('appointment('+Convert2String(i),'layer','1','no','','select',bx1,by1,bx2,by2);
     end;//USER
    end;
  end;

SetFont('arial','greek',15,0,0,0);
TextColor(keep_col);
end;

procedure Compact_Schedule(daynum,monthnum,year:integer; all_users:boolean);
var agridx,agridy,ax,ay,ax1,ay1,ax2,ay2,bx,by,x,y,i,z:integer;
    next_sched_for_person:string;
    borders:array[1..4]of integer;
    datesnstuff:array[1..4]of word;
    ov_day,ov_month,ov_year:integer; //OVERIDE KANONIKES IMEROMINIES
    lastobj:string;
    last_redraw:integer;
label start_draw;
begin 
borders[1]:=1;
borders[2]:=1;
agridx:=250;  //330
agridy:=250;  //280
borders[3]:=GetMaxX;
borders[4]:=GetMaxY;

next_sched_for_person:='';

GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
if monthnum=0 then monthnum:=datesnstuff[3];
if year=0 then year:=datesnstuff[4];
if daynum=0 then daynum:=datesnstuff[1];

ov_day:=daynum;
ov_month:=monthnum;
ov_year:=year;


start_draw:
last_redraw:=GetTickCount;



flush_gui_memory(0);
draw_background(3); 
SetLineSettings(4,4,4);
DrawLine(agridx,borders[2],agridx,borders[4],ConvertRGB(123,123,123));
DrawLine(borders[1],agridy,borders[3],agridy,ConvertRGB(123,123,123));
SetLineSettings(1,1,1);

if Last_Mem_Load_ID<>Convert2String(monthnum)+Convert2String(year) then Load_Schedule_Month(monthnum,year);   // LOAD FROM HARDDRIVE

draw_n_add_compact_month(borders[1]+10,borders[2]+20,agridx,agridy,monthnum,year);
//anti gia daynum,monthnum,year mpike ov_day,ov_month,ov_year
draw_n_add_compact_nameday(borders[1]+10,agridy+10,agridx-10,borders[4],ov_day,ov_month,ov_year,all_users); 
draw_n_add_compact_weeksched(agridx+10,borders[2]+10,borders[3]-10,agridy-10,ov_day,ov_month,ov_year,all_users); 
draw_n_add_compact_daysched(agridx+10,agridy+10,borders[3]-10,borders[4]-10,ov_day,ov_month,ov_year,all_users);
include_object('new','buttonc','Νέα εργασία','main_window','','',borders[3]-400,borders[4]-30,0,0);
include_object('parallel_view','buttonc','Προβολή παράλληλων εργασιών','main_window','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('exit','buttonc','Έξοδος','main_window','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;
//MessageBox (0, 'Το συγκεκριμένο κομμάτι του προγράμματος είναι υπο κατασκευή..' , ' ', 0 + MB_ICONASTERISK);
repeat
 interact;

 if (GetTickCount>last_redraw+60000) then begin
                                           draw_n_add_compact_daysched(agridx+10,agridy+10,borders[3]-10,borders[4]-10,daynum,monthnum,year,all_users);
                                           last_redraw:=GetTickCount;
                                           draw_object_by_name('exit');
                                         end;

 lastobj:=last_object_activated; 


 if get_object_data('parallel_view')='4' then  begin
                                         set_button('parallel_view',0);
                                         print_week_parallel(ov_day,ov_month,ov_year);
                                         goto start_draw;
                                        end else
 
 if get_object_data('new')='4' then  begin
                                         set_button('new',0);
                                         GUI_add_new_schedule_day(ov_day,ov_month,ov_year,0,0,0,next_sched_for_person);
                                         goto start_draw;
                                        end else
 if get_object_data('search')='4' then  begin
                                         set_button('search',0);
                                         next_sched_for_person:=GUI_search_person;
                                         goto start_draw;
                                        end else
 if get_object_data('add_new_program_layer')='4' then  begin
                                        set_button('add_new_program_layer',0);
                                        save_graph_window;   
                                           i:=1; //clicks
                                           ax:=GetMouseX;
                                           ay:=GetMouseY;
                                           //DrawRectangle2(ax,ay,ax+100,ay+15,ConvertRGB(54,134,174),ConvertRGB(54,134,174));
                                           //OutTextXY(ax+10,ay,'Νέο ραντεβού!');
                                           x:=ax;
                                           bx:=ax;
                                           y:=ay;
                                           by:=ay;
                                           //DrawRectangle(x-5,y-5,x+5,y+5,ConvertRGB(255,0,0));
                                            repeat
                                              delay(10);
                                              x:=GetMouseX;
                                              y:=GetMouseY;
                                              if y<agridy+10 then y:= agridy+11;
                                              if y>borders[4]-10 then y:= borders[4]-11;
 
                                              if i>=1 then DrawRectangle2(ax,ay,ax+100,y,ConvertRGB(54,134,174),ConvertRGB(54,134,174));
                                              if y<by then load_graph_window_xy(ax,y,ax+101,by+1);
                                              if ((y>=by) and (y<=ay) ) then load_graph_window_xy(ax,by-4,ax+101,y);
                                              by:=y;
                                                                                       
                                              if MouseButton(1)=2 then begin
                                                                         i:=i+1;
                                                                         if i>=2 then begin 
                                                                                       WaitClearMouseButton(1);
                                                                                       //DrawRectangle(x-5,y-5,x+5,y+5,ConvertRGB(255,0,0));
                                                                                      end;
                                                                         end;


                                             until ((i>=2) or Equal(readkeyfast,'escape'));

 
                                        load_graph_window; 

                                        if y<ay then begin
                                                      by:=ay;
                                                      ay:=y;
                                                     end;
                                        DrawRectangle2(ax,ay,ax+100,by,ConvertRGB(54,134,174),ConvertRGB(54,134,174));
                                        OutTextXY(ax+10,ay,'Νέο ραντεβού!');
                                         
                                        //AX1 diaforetiko tou AX ktl ktl
                                        ax1:=agridx+10;
                                        ay1:=agridy+10;
                                        ax2:=borders[3]-10;
                                        ay2:=borders[4]-10;
                                        calc_time_field(ax1,ax1+(ax2-ax1) div 2,ay1+5,ay2-5,ax,ay,by,x,y,i,z);
                                        //MessageBox (0, pchar('From '+Convert2String(x)+':'+Convert2String(y)+' to '+Convert2String(i)+':'+Convert2String(z)) , ' ', 0);
                                        i:=(i*60+z)-(x*60+y);
                                        GUI_add_new_schedule_day(ov_day,ov_month,ov_year,x,y,i,next_sched_for_person);
                                        goto start_draw; 
                                       end else
 if (lastobj<>'') then
   begin
     seperate_words(lastobj);
     if Equal(get_memory(1),'layer') then
       begin 
        if get_object_data(lastobj)='4' then begin
                                              set_object_data(lastobj,'value','1',1);
                                              ov_day:=get_memory_int(2);
                                             end;
        flush_last_object_activated;  
        goto start_draw;
       end else
     if Equal(get_memory(1),'all_users') then
       begin

       if get_object_data('all_users')='3' then begin
                                                 all_users:=true;
                                                 set_object_data('all_users','value','1',1);
                                                end else
                                                begin
                                                 all_users:=false;
                                                 set_object_data('all_users','value','3',1);
                                                end; 
        flush_last_object_activated;  
        goto start_draw;
       end else
     if Equal(get_memory(1),'name') then
       begin
        set_object_data(lastobj,'value','1',1);
        flush_last_object_activated; 
        Load_Person(get_memory(2),true);
        View_Person;
        goto start_draw;
       end else
     if Equal(get_memory(1),'appointment') then
       begin
        set_object_data(lastobj,'value','1',1);
        flush_last_object_activated; 
        Val(get_memory(2),x,y);
        if (x>0) and (x<=Get_Day_Length(daynum)) then display_schedule_specific(Month_Appoint[daynum,x]);
                                                 //else display_schedule_specific(Max_Appointments_Loaded);
        goto start_draw;
       end; 
     lastobj:='';
    end;
until GUI_Exit;

end;




procedure GetEasterDate (y, method : word; var d, m : integer);
var
   FirstDig, Remain19, temp,              //intermediate results
   tA, tB, tC, tD, tE         : integer;  //table A to E results
begin

{ :=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
  *  This algorithm is an arithmetic interpretation
  *  of the 3 step Easter Dating Method developed
  *  by Ron Mallen 1985, as a vast improvement on
  *  the method described in the Common Prayer Book

  *  Published Australian Almanac 1988
  *  Refer to this publication, or the Canberra Library
  *  for a clear understanding of the method used

  *  Because this algorithm is a direct translation of the
  *  official tables, it can be easily proved to be 100%
  *  correct

  *  It's free!  Please do not modify code or comments!

  *  11.7.99 - Pascal converting by Thomas Koehler, www.thkoehler.de

   :=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=}


    FirstDig := y div 100;            //first 2 digits of year
    Remain19 := y mod 19;             //remainder of year / 19

    if (method = 1) or (method = 2) then
        begin
        //calculate PFM date
        tA := ((225 - 11 * Remain19) mod 30) + 21;

         {find the next Sunday}
        tB := (tA - 19) mod 7;
        tC := (40 - FirstDig) mod 7;

        temp := y mod 100;
        tD := (temp + temp div 4) mod 7;

        tE := ((20 - tB - tC - tD) mod 7) + 1;
        d := tA + tE;

        if method = 2 then  //convert Julian to Gregorian date
            begin
            //10 days were skipped
            //in the Gregorian calendar from 5-14 Oct 1582
            temp := 10;
            //Only 1 in every 4 century years are leap years in the Gregorian
            //calendar (every century is a leap year in the Julian calendar)
            if y > 1600 then
                temp := temp + FirstDig - 16 - ((FirstDig - 16) div 4);
            d := d + temp;
            end;
        end
    else
        begin
       //calculate PFM date
        temp := (FirstDig - 15) div 2 + 202 - 11 * Remain19;
        if (FirstDig > 26) then temp := temp - 1;
        if (FirstDig > 38) then temp := temp - 1;
        if (FirstDig = 21) Or (FirstDig = 24) Or (FirstDig = 25)
          Or (FirstDig = 33) Or (FirstDig = 36) Or (FirstDig = 37) then
            temp := temp - 1;

        temp := temp mod 30;
        tA := temp + 21;
        if (temp = 29) then
            tA := tA - 1;
        if (temp = 28) and (Remain19 > 10) then
            tA := tA - 1;

       //find the next Sunday
        tB := (tA - 19) mod 7;

        temp := (40 - FirstDig) mod 4;
        //tC := temp - (temp > 1) - (temp := 3)
        tC := temp;
        if temp > 1 then tC := tC + 1;
        if temp = 3 then tC := tC + 1;

        temp := y mod 100;
        tD := (temp + temp div 4) mod 7;

        tE := ((20 - tB - tC - tD) mod 7) + 1;
        d := tA + tE;

        end;

  //return the date
    m := 3;
    if (d > 61) then
    begin
        d := d - 61;  //when the original calculation is converted to the
        m := 5;       //Gregorian calendar, Easter Sunday can occur in May
    end;
    if (d > 31) then
      begin
          d := d - 31;
          m := 4;
      end;
end;

procedure day_after_days(days_after:integer; var theday,themonth,theyear:integer);
begin
theday:=theday+days_after;
repeat
if theday>month_days(themonth,theyear) then
        begin
          theday:=theday-month_days(themonth,theyear);
          themonth:=themonth+1;
        end;
if themonth>12 then
        begin
         themonth:=themonth-12;
         theyear:=theyear+1;
        end;
until ( (theday>0) and (theday<=month_days(themonth,theyear)) and (themonth>0) and (themonth<=12) );
end;



//begin
end.
