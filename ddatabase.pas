program DentalDatabase; 
uses Windows,ammarunit,apsfiles,ammargui,management,people,people_map,calender,userlogin,security,the_works,backups,settings,teeth,string_stuff,payments,pic_select,tools,user_tutorials,security_gra,calender_help,sms_send;
const  seperate_words_strength=15;
       seperate_words_read_strength=512;
ver1=0; ver2=0; ver3=3021;
version='0.40';
stat=0;
title='Dental Database Mk2 '+version;
DATABASE_PARAMS=3;
var userusing,curendir:string;
    i,program_init:integer;
    database:array[1..DATABASE_PARAMS] of integer; //1 Patients Record..  2 Safe Boot (1=OK BOOT , 0=Problem..)..  , 3 LastBackup
    schedule:array[1..2] of integer;
    memory:array[1..seperate_words_strength] of string;
    memoryinteger:array[1..seperate_words_strength] of integer;
label exit_program,exit_program_nosave,exit_express;



procedure seperate_words (bufstr4:string);
var buffers:array [1..5] of integer;
    zcount:integer;
    s3:string;
    buf:array[1..seperate_words_read_strength]of char;

begin
for zcount:=1 to seperate_words_strength do begin
                                             memory[zcount]:='';
                                             memoryinteger[zcount]:=0;
                                            end;
zcount:=0;
setlength (s3,1);
buffers[2]:=Length(bufstr4);
for zcount:=1 to Length(bufstr4) do begin
                                     s3:=Copy(bufstr4,zcount,1);
                                     buf[zcount]:=s3[1];
                                    end;
buffers[3]:=1;
buffers[4]:=0;
repeat
  buffers[4]:=buffers[4]+1;
  buffers[5]:=buffers[3];
  if buf[buffers[4]]='(' then buffers[3]:=buffers[3]+1
          else 
  if buf[buffers[4]]=',' then buffers[3]:=buffers[3]+1
          else
  if buf[buffers[4]]=')' then buffers[3]:=buffers[3]+1;

if buffers[5]=buffers[3] then
  begin
if buffers[3]<=seperate_words_strength then memory[buffers[3]]:=memory[buffers[3]]+buf[buffers[4]] else
                               begin
                                buffers[3]:=seperate_words_strength+1
                               end;
  end;
  if buffers[4]=buffers[2] then buffers[3]:=seperate_words_strength+1;
until buffers[3]>=seperate_words_strength+1;
for zcount:=1 to seperate_words_strength do begin
                                             val(memory[zcount],buffers[1],buffers[5]);
                                             if buffers[5]=0 then memoryinteger[zcount]:=buffers[1] else
                                                                  memoryinteger[zcount]:=0;
                                            end;
end;
 


procedure Check_Version_Update_Backup;
var fileused:text;
    bufstr:string;
begin
bufstr:='';
assign(fileused,'version');
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then begin 
                    readln(fileused,bufstr);
                    close(fileused);
                   end;
if version<>bufstr then
 begin 
  DrawJpegCentered(get_central_dir+'Art\backup');
  Full_Program_BackUp;
 end;

{$i-}
rewrite(fileused);
{$i+}
if Ioresult=0 then begin 
                    writeln(fileused,version);
                    close(fileused);
                   end;

end;






procedure load_art;
const MAX_ART=42;
var il,ily,lps:integer;
    aps2load:string;
begin 
chdir(curendir+'Art\');

//Check JPG File Existance
if (not check_file_existance('backup')) then begin
                                               Write_2_Log('Could not find backup data while loading Art.. ');
                                               MessageBox (0, 'Could not find backup data.. , Unstable run..' , ' ', 0 + MB_ICONASTERISK);
                                             end;
if (not check_file_existance('progupdate')) then begin
                                                  Write_2_Log('Could not find progupdate data while loading Art.. ');
                                                  MessageBox (0, 'Could not find progupdate data.. , Unstable run..' , ' ', 0 + MB_ICONASTERISK);
                                                 end;


lps:=0;
ily:=0;
il:=GetLoadingX;
SetTransparentColor(ConvertRGB(123,123,0));
repeat
lps:=lps+1;
if lps=1 then aps2load:='network8' else
if lps=2 then aps2load:='calndr2' else
if lps=3 then aps2load:='note1' else
if lps=4 then aps2load:='door02' else
if lps=5 then aps2load:='doc01' else
if lps=6 then aps2load:='diskett2' else
if lps=7 then aps2load:='chklst' else
if lps=8 then aps2load:='chip02' else
if lps=9 then aps2load:='trash1' else
if lps=10 then aps2load:='cdrom3' else
if lps=11 then aps2load:='tools' else
if lps=12 then aps2load:='ffinder' else
if lps=13 then aps2load:='books06' else
if lps=14 then aps2load:='fcabin01' else
if lps=15 then aps2load:='monitr3' else
if lps=16 then aps2load:='doc07' else
if lps=17 then aps2load:='doc06' else
if lps=18 then aps2load:='dental_defaultuser' else
if lps=19 then aps2load:='statgraph' else
if lps=20 then aps2load:='greenbtn' else
if lps=21 then aps2load:='yellowbtn' else
// SMILEYS
if lps=22 then aps2load:='smiley_confused' else
if lps=23 then aps2load:='smiley_unhappy' else
if lps=24 then aps2load:='smiley_question' else
if lps=25 then aps2load:='smiley_neutral' else
if lps=26 then aps2load:='smiley_mad' else
if lps=27 then aps2load:='smiley_ntropalos' else
if lps=28 then aps2load:='smiley_idea' else
if lps=29 then aps2load:='smiley_happy' else
if lps=30 then aps2load:='smiley_exclaim' else
if lps=31 then aps2load:='smiley_frown' else
if lps=32 then aps2load:='smiley_evil' else
if lps=33 then aps2load:='smiley_eek' else
if lps=34 then aps2load:='smiley_surprised' else
if lps=35 then aps2load:='smalltooth' else
if lps=36 then aps2load:='smallcalender' else
if lps=37 then aps2load:='tooth_map' else
if lps=38 then aps2load:='doc03' else
if lps=39 then aps2load:='tooth_map_2'else
if lps=40 then aps2load:='field' else
if lps=41 then aps2load:='tag'else
if lps=42 then aps2load:='forbidden';



loadaps(aps2load);
if lps<18 then drawapsxy(aps2load,il,GetMaxY-40);
il:=il+GetApsInfo(aps2load,'sizex')+2;
if ily<GetApsInfo(aps2load,'sizey') then ily:=GetApsInfo(aps2load,'sizey');
if il+GetApsInfo(aps2load,'sizex')+2>2048 then begin
                                                il:=1;
                                                SetLoadingXY(il,GetLoadingY+ily+2);
                                               end;  
SetLoadingXY(il,GetLoadingY);
until lps=MAX_ART;

il:=1;
SetLoadingXY(il,GetLoadingY+ily+2);
chdir(curendir); 
end;


procedure Save_Database;
var fileused:text; 
    i:integer;
begin 
chdir(get_central_dir);
assign(fileused,'database.ini');
{$i-}
rewrite(fileused);
{$i+}
if Ioresult<>0 then MessageBox (0, 'Could not Save_Database ! ' , ' ', 0 + MB_ICONEXCLAMATION);
writeln(fileused,'Generated by Dental Database Mk2');
writeln(fileused,'VERSION(',ver1,',',ver2,',',ver3,')');
database[3]:=GetLastBackup;
for i:=1 to DATABASE_PARAMS do writeln(fileused,'DATABASE(',i,',',database[i],')');
if GetLastBackupFilename<>'' then writeln(fileused,'DATABASE(600,',GetLastBackupFilename,')');
close(fileused);
end;

procedure Load_Database;
const MAX_RETRIES=10;
var fileused:text;
    bufstr,last_b_file:string;
    retries,i:integer;
label Start_Load_Database;
begin 
chdir(get_central_dir);
retries:=0; 
last_b_file:='';
Start_Load_Database:
assign(fileused,'database.ini');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                     OutTextCenter('Απασχολημένη βάση δεδομένων ( προσπάθεια '+Convert2String(retries)+'/'+Convert2String(MAX_RETRIES)+' )');
                     retries:=retries+1;
                     if retries<MAX_RETRIES then begin
                                                  delay(1000);
                                                  goto Start_Load_Database;
                                                 end else
                                                 begin
                                                  i:=MessageBox (0, 'Θέλετε να γίνει επαναπροσπάθεια φόρτωσης?' , ' ', 0 + MB_YESNO + MB_ICONEXCLAMATION);
                                                  if i=IDYES then begin
                                                                    retries:=0;
                                                                    goto Start_Load_Database;
                                                                  end;
                                                 end;
                    end 
                     else
begin   
 repeat
   readln(fileused,bufstr);
   seperate_words(bufstr);
   if (Equal(memory[1],'VERSION')) then begin
                                         if ((memoryinteger[2]<=ver1) and (memoryinteger[3]<=ver2) and (memoryinteger[4]<=ver3)) then begin end else //Normal Versioning
                                                          begin
                                                           Write_2_Log('Το πρόγραμμα αναβαθμίστηκε από την έκδοση '+memory[3]+'.'+memory[4]+' στην '+version);
                                                           outtextcenter('Το πρόγραμμα αναβαθμίστηκε από την έκδοση '+memory[3]+'.'+memory[4]+' στην '+version);
                                                           delay(1000);
                                                          end;
                                        end else
   if (Equal(memory[1],'DATABASE')) then begin
                                          if (memoryinteger[2]=600) then  last_b_file:=memory[3] else
                                          if ((memoryinteger[2]>0) and (memoryinteger[2]<=DATABASE_PARAMS)) then database[memoryinteger[2]]:=memoryinteger[3];
                                         end;
 until eof(fileused);
 close(fileused);
 SetLastBackup(database[3]);
 SetLastBackupFilename(last_b_file);
end;

end;
 



procedure search_person_menu;
var textboxx,textboxx2:integer;
    commentx:integer;
    return_query:string;
begin
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
include_object('backwindow','window','Dental Database Mk2 , Αναζήτηση ασθενών',' ','','',GetMaxX div 3,200,GetMaxX-(GetMaxX div 3),GetMaxY-190);
draw_all;
commentx:=X1(last_object)+30;
include_object('codecomment','comment','Κώδικός','no','','',commentx,Y1(last_object)+50,0,0);
textboxx:=X2(last_object)+30;
textboxx2:=GetMaxX-(GetMaxX div 3)-30;
include_object('code','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);
include_object('namecomment','comment','Όνομα','no','','',commentx,Y2(last_object)+15,0,0);
include_object('name','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('surnamecomment','comment','Επίθετο','no','','',commentx,Y2(last_object)+15,0,0);
include_object('surname','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('datecomment','comment','Επανεξέταση','no','','',commentx,Y2(last_object)+15,0,0);
include_object('dateday','textbox','','no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXX'),0);
include_object('/','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('datemonth','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXX'),0);
include_object('//','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('dateyear','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXXXX'),0);

include_object('telcomment','comment','Τηλέφωνο','no','','',commentx,Y2(last_object)+15,0,0);
include_object('telephone','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('profcomment','comment','Επάγγελμα','no','','',commentx,Y2(last_object)+15,0,0);
include_object('profession','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('areacomment','comment','Περιοχή','no','','',commentx,Y2(last_object)+15,0,0);
include_object('area','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

delete_object('backwindow','NAME');
include_object('search','buttonc','Αναζήτηση','no','','',(GetMaxX div 2)-40,Y2(last_object)+40,0,0);
include_object('exit','buttonc','’κυρο','no','','',X2(last_object)+15,Y1(last_object),0,0);
fasttextboxchange(1);
draw_all;
repeat
interact;
if get_object_data('search')='4' then begin
                                       set_button('search',0);
                                       Write_2_Log('Searching for '+get_object_data('code')+get_object_data('name')+get_object_data('surname')+get_object_data('dateday')+get_object_data('datemonth')+get_object_data('dateyear')+get_object_data('area')+get_object_data('telephone')+get_object_data('profession'));
                                       return_query:=query_database(get_object_data('code'),get_object_data('name'),get_object_data('surname'),get_object_data('dateday'),get_object_data('datemonth'),get_object_data('dateyear'),get_object_data('area'),get_object_data('telephone'),get_object_data('profession'));
                                       if return_query<>'' then begin
                                                                 Write_2_Log('Accessing file '+return_query);
                                                                 Load_Person(return_query,true);
                                                                 View_Person();
                                                                end;
                                       set_button('exit',1);
                                       break;
                                      end;
until GUI_Exit;
end;        


function GUI_Inject_Person:integer;
var retres,i:integer;
    formx:integer;
begin
retres:=0;
formx:=TextWidth('XXXXXXXX');
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
clrscreen;
draw_window;

include_object('window1','window','Εισαγωγή εμβόλιμου μητρώου.. ','no','','',GridX(1,3),300,GridX(2,3),450);
draw_all;
delete_object('window1','name');
include_object('recordcomment','comment','Αριθμός μητρώου για αντικατάσταση : ','no','','',GridX(1,3)+30,360,0,0);
include_object('record','textbox','','no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+formx,0);
//include_object('recordcomment','comment','(0 = όχι εμβόλιμη καταχώρηση)','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('ok','buttonc','Αντικατάσταση','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;
repeat
interact;
if get_object_data('ok')='4' then begin
                                    Val(get_object_data('record'),retres,i);
                                    if ((retres<=0) or (retres>database[1])) then retres:=0;
                                    set_button('exit',1);
                                  end; 
until GUI_Exit;
GUI_Inject_Person:=retres;
end;


procedure new_person_prepare;
var textboxx,textboxx2:integer;
    commentx,injection:integer;
    newrecordname,name,surname:string;
    label start_prepare;
begin
injection:=0;
name:='';
surname:='';
start_prepare:

flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
include_object('backwindow','window','Dental Database Mk2 , version '+version,'','','',GetMaxX div 3,200,GetMaxX-(GetMaxX div 3),GetMaxY-200);
draw_all;
commentx:=X1(last_object)+30;
include_object('codecomment','comment','Κώδικός','no','','',commentx,Y1(last_object)+50,0,0);
textboxx:=X2(last_object)+30;
textboxx2:=GetMaxX-(GetMaxX div 3)-30;
include_object('code','comment',Convert2String(database[1]+1),'no','','',textboxx,Y1(last_object),textboxx2,0);
include_object('namecomment','comment','Όνομα','no','','',commentx,Y2(last_object)+15,0,0);
include_object('name','textbox',name,'no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('surnamecomment','comment','Επίθετο','no','','',commentx,Y2(last_object)+15,0,0);
include_object('surname','textbox',surname,'no','','',textboxx,Y1(last_object),textboxx2,0);

name:='';
surname:='';
delete_object('backwindow','NAME');
include_object('create','buttonc','Δημιουργία','no','','',(GetMaxX div 2)-160,Y2(last_object)+40,0,0);
if injection=0 then include_object('inject_to','buttonc','Εμβόλιμη καταχώρηση','no','','',X2(last_object)+5,Y1(last_object),0,0) else
                    include_object('inject_to','buttonc','Εμβόλιμη καταχώρηση στο '+Convert2String(injection),'no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('exit','buttonc','’κυρο','no','','',X2(last_object)+5,Y1(last_object),0,0);
draw_all;
newrecordname:='';
repeat
interact;
if get_object_data('name')<>name then begin
                                       name:=get_object_data('name');
                                       name:=First_Capital(Sigma_Teliko(name));
                                       name:=TrimSpaces(name);
                                       set_object_data('name','VALUE',name,0);
                                       draw_object_by_name('name');
                                       activate_object('surname');
                                      end else
if get_object_data('surname')<>surname then begin
                                             surname:=get_object_data('surname');
                                             surname:=First_Capital(Sigma_Teliko(surname));
                                             surname:=TrimSpaces(surname);
                                             set_object_data('surname','VALUE',surname,0);
                                             draw_object_by_name('surname');
                                           end else
if get_object_data('inject_to')='4' then begin
                                            set_button('inject_to',0);
                                            injection:=GUI_Inject_Person;
                                            goto start_prepare;
                                           end else
if get_object_data('create')='4' then begin
                                      set_button('create',0);
                                      if ((get_object_data('name')='') and (get_object_data('surname')='')) then
                                      begin
                                       MessageBox (0, 'Παρακαλώ συμπληρώστε τα στοιχεία του ασθενούς..' , ' ', 0 + MB_ICONASTERISK);
                                      end else 
                                      if ( (not IsStringFilesystemCompatible(get_object_data('name'))) or (not IsStringFilesystemCompatible(get_object_data('surname'))) ) then
                                      begin
                                       MessageBox (0, 'Απαγορεύεται η χρήση των χαρακτήρων / \ * ? : " > < | στο όνομα και το επώνυμο!'+#10+'Αφαιρέστε τους για να γίνει η καταχώρηση.'+#10+'Tip: Σε περιπτώσεις όπως πχ Κων/νος γράψτε Κωνσταντίνος..' , ' ', 0 + MB_ICONASTERISK);
                                      end else
                                      begin  
                                    if injection=0 then
                                     begin
                                      database[1]:=database[1]+1; 
                                      Save_Database;  

                                      newrecordname:=get_object_data('name')+'_'+get_object_data('surname')+'_'+Convert2String(database[1])+'.dat';
                                      newrecordname:=Greeklish(newrecordname); // Για συμβατότητα με NON-Greek Windows..
                                      Write_2_Log('Adding new person '+get_object_data('name')+get_object_data('surname')+' - '+newrecordname);
                                      add2map(get_object_data('code'),get_object_data('name'),get_object_data('surname'),newrecordname);
                                      New_Person(newrecordname,get_object_data('code'),get_object_data('name'),get_object_data('surname'));
                                      View_Person();
                                      Write_2_Log('New Record , '+get_object_data('name')+' '+get_object_data('surname'));
                                     end else
                                     begin
                                      Write_2_Log('Attempting to alter record  '+Convert2String(injection));
                                      newrecordname:=retrieve_map(Convert2String(injection),'','');
                                      Write_2_Log('Record points to -> '+newrecordname);
                                      delete4map('','','',newrecordname);
                                      Write_2_Log('Deleted '+newrecordname);
                                      newrecordname:=get_object_data('name')+'_'+get_object_data('surname')+'_'+Convert2String(injection)+'.dat';
                                      newrecordname:=Greeklish(newrecordname); // Για συμβατότητα με NON-Greek Windows..
                                      add2map(Convert2String(injection),get_object_data('name'),get_object_data('surname'),newrecordname);
                                      New_Person(newrecordname,Convert2String(injection),get_object_data('name'),get_object_data('surname'));
                                      View_Person();
                                      Write_2_Log('New Record , '+get_object_data('name')+' '+get_object_data('surname'));
                                     end;
                                      break; 
                                      end;
                                    end;
until GUI_Exit;

end;

procedure RestartProgram;
begin
Write_2_Log('Restart Command Issued..');
database[2]:=1; //OK , finish
Save_Database;
set_user_state(Get_Current_User,'0');
chdir(get_central_dir);
RunEXE('Dental Database.exe','normal');
goto exit_express;
end;


procedure main_menu;
var spacex,i,z,x,chkmsgs,inmsgs:integer;
    selection:boolean;
    datesnstuff:array[1..4]of word;
    label redraw_main;
begin 

spacex:=42;
repeat 
redraw_main:
selection:=false;
flush_gui_memory(0);
draw_background(3);
set_gui_color(ConvertRGB(255,255,255),'comment');

include_object('backwindow','window','Dental Database Mk2 , version '+version,'','','',250,50,GetMaxX-250,GetMaxY-50);
draw_all;
delete_object('backwindow','NAME'); 

include_object('label1','label',title,'no','','',10,7,162,28);

include_object('newpatient','buttonc','Νέος ασθενής','no','','',-1,240+spacex*1,-1,0);
DrawApsXY2('doc07',X1(last_object)-60,Y1(last_object));
include_object('openpatient','buttonc','Αναζήτηση ασθενών','no','','',-1,240+spacex*2,-1,0);
DrawApsXY2('ffinder',X1(last_object)-60,Y1(last_object));
include_object('calender','buttonc','Ημερολόγιο','no','','',-1,240+spacex*3,-1,0);
DrawApsXY2('calndr2',X1(last_object)-60,Y1(last_object));
include_object('rendezervous','buttonc','Νέο Ραντεβού','no','','',-1,240+spacex*4,-1,0);
DrawApsXY2('doc01',X1(last_object)-60,Y1(last_object));
include_object('today','buttonc','Σημερινή Ημέρα','no','','',-1,240+spacex*5,-1,0);
DrawApsXY2('doc03',X1(last_object)-60,Y1(last_object));
include_object('statistics','buttonc','Στατιστικά / Managment','no','','',-1,240+spacex*6,-1,0);
DrawApsXY2('doc06',X1(last_object)-60,Y1(last_object));
include_object('settings','buttonc','Τεχνικές Ρυθμίσεις','no','','',-1,240+spacex*7,-1,0);
DrawApsXY2('chklst',X1(last_object)-60,Y1(last_object));

inmsgs:=Incoming_User_Messages;
include_object('msgs','buttonc',Convert2String(inmsgs)+' εισερχόμενα μηνύματα','no','','',-1,240+spacex*8,-1,0);
DrawApsXY2('note1',X1(last_object)-60,Y1(last_object));

include_object('exitmain','buttonc','Έξοδος','no','','',-1,240+spacex*9,-1,0);
DrawApsXY2('door02',X1(last_object)-60,Y1(last_object));
draw_all;
DrawApsXY2('logoddmk2',(GetMaxX-GetApsInfo('logoddmk2','sizex'))div 2,100);
chkmsgs:=GetTickCount;
window_needs_redraw;
TextColor(COnvertRGB(255,255,255));


repeat
interact;

if Equal(get_gui_key,'UP ARROW') then signal_alert;

if window_needs_redraw then  goto redraw_main;

if schedule[1]<GetTickCount+SMS_Query_Time then begin
                                                {  GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
                                                  schedule[1]:=GetTickCount+SMS_Query_Time;
                                                  i:=datesnstuff[1];
                                                  z:=datesnstuff[3];
                                                  x:=datesnstuff[4];
                                                  day_after_days(SMS_Days_Before,i,z,x);  }
                                                end;


if GUI_Exit then set_object_data('exitmain','value','4',4);
if get_object_data('newpatient')='4' then selection:=true else
if get_object_data('openpatient')='4' then selection:=true else
if get_object_data('calender')='4' then selection:=true else
if get_object_data('today')='4' then selection:=true else
if get_object_data('rendezervous')='4' then selection:=true else
if get_object_data('settings')='4' then selection:=true else
if get_object_data('statistics')='4' then selection:=true else
if get_object_data('msgs')='4' then selection:=true else
if get_object_data('exitmain')='4' then selection:=true; 
sleep(70);
if (GetTickCount-chkmsgs)>6000 then begin
                                     i:=Incoming_User_Messages;
                                     if i<>inmsgs then
                                                   begin
                                                    set_object_data('msgs','extra1',Convert2String(i)+' εισερχόμενα μηνύματα',0);
                                                    draw_object_by_name('msgs');
                                                   end;
                                    end;
until selection=true;
if get_object_data('today')='4' then begin
                                      set_button('today',0);
                                      if (take_char(1)+take_char(2)+take_char(3)+take_char(4)+take_char(8)+take_char(9)+take_char(18)+take_char(16)<>2604) then view_screen(1) else
                                      Compact_Schedule(0,0,0,true);
                                     end else
if get_object_data('rendezervous')='4' then begin
                                      set_button('rendezervous',0);
                                      if (take_char(1)+take_char(2)+take_char(3)+take_char(4)+take_char(8)+take_char(9)+take_char(18)+take_char(16)<>2604) then view_screen(1) else
                                      gui_pick_next_free_day('');
                                     end else  
if get_object_data('newpatient')='4' then begin
                                            if ((random<0.2)and(take_char(1)+take_char(2)+take_char(3)+take_char(4)+take_char(8)+take_char(9)+take_char(18)+take_char(16)<>2604)) then view_screen(1);

                                            set_button('newpatient',0);
                                            new_person_prepare;
                                          end else
if get_object_data('openpatient')='4' then begin
                                             set_button('openpatient',0);
                                             search_person_menu; 
                                           end else
if get_object_data('settings')='4' then begin
                                             Write_2_Log('Accessing Settings..');
                                             set_button('settings',0);
                                             if (take_char(1)+take_char(2)+take_char(3)+take_char(4)+take_char(8)+take_char(9)+take_char(18)+take_char(16)<>2604) then view_screen(1);

                                              if Get_User_Access(Get_Current_User)>=500 then settings_menu else
                                              begin
                                               MessageBox (0, Pchar('Χρειάζεστε κωδικό μεγαλύτερης πρόσβασης για να δείτε και να αλλάξετε ρυθμίσεις στο πρόγραμμα ! ('+Convert2String(Get_User_Access(Get_Current_User))+')') , title, 0 + MB_ICONASTERISK);
                                               Write_2_Log('Access Denied');
                                              end;
                                           end else
if get_object_data('statistics')='4' then begin
                                             Write_2_Log('Accessing Statistics..');
                                             set_button('statistics',0);
                                              if (take_char(1)+take_char(2)+take_char(3)+take_char(4)+take_char(8)+take_char(9)+take_char(18)+take_char(16)<>2604) then view_screen(1) else
                                              if Get_User_Access(Get_Current_User)>=500 then database_menu else
                                              begin
                                               MessageBox (0, Pchar('Χρειάζεστε κωδικό μεγαλύτερης πρόσβασης για να δείτε στατιστικά χρήσης του προγράμματος ! ('+Convert2String(Get_User_Access(Get_Current_User))+')') , title, 0 + MB_ICONASTERISK);
                                               Write_2_Log('Access Denied');
                                              end;
                                           end else
if get_object_data('msgs')='4' then begin
                                     Write_2_Log('Checking Messages..');
                                     set_button('msgs',0);
                                     GUI_User_Message; 
                                    end else
if get_object_data('calender')='4' then begin
                                             set_button('calender',0);
                                             Write_2_Log('Accessing calender ');
                                             display_schedule_month(0,0);
                                           end else
if get_object_data('exitmain')='4' then begin
                                            save_graph_window; 
                                            filter_oldmonitor('screen',1);
                                            i:=MessageBox (0, 'Είστε σίγουροι οτι θέλετε να κλείσετε την βάση δεδομένων?' , title, 0 + MB_YESNO + MB_ICONQUESTION+ MB_SYSTEMMODAL);
                                         if i=IDNO then begin
                                                         set_button('exitmain',0);
                                                         load_graph_window;
                                                        end else         
                                         if i=IDYES then begin
                                                          outtextcenter('SAVING & CLOSING DOWN , THANK YOU FOR USING ME..'); 
                                                         end;
                                          end;

if get_need_restart then RestartProgram;

until get_object_data('exitmain')='4';
end;




procedure preliminary_check;
var typ:integer;
begin
typ:=GetDriveType(nil);
if typ=0 then OuttextCenter('The drive type cannot be determined') else
if typ=1 then OuttextCenter('The root directory does not exist') else
if typ=DRIVE_REMOVABLE then OuttextCenter('The drive can be removed from the drive') else
if typ=DRIVE_FIXED	 then OuttextCenter('The disk cannot be removed from the drive') else
if typ=DRIVE_REMOTE	 then OuttextCenter('The drive is a remote (network) drive') else
if typ=DRIVE_CDROM	 then OuttextCenter('The drive is a CD-ROM drive') else
if typ=DRIVE_RAMDISK	then OuttextCenter('The drive is a RAM disk');

end;








procedure files_create_1stboot;
var
  fileused: Text;
  datesnstuff: array[1..4] of Word;
begin
  GetLDate(datesnstuff[1], datesnstuff[2], datesnstuff[3], datesnstuff[4]);

  MessageBoxA(0, A('Πρώτη εκτέλεση , καλωσήρθατε..'), A('Welcome !'), MB_ICONASTERISK);

  assign(fileused,'log.dat');
  {$i-} rewrite(fileused); {$i+}
  if IOResult <> 0 then
    MessageBoxA(0, A('Δεν ήταν δυνατή η δημιουργία του αρχείου καταγραφής!'), A('Error !'), MB_ICONHAND)
  else
  begin
    writeln(fileused,'//- New Log Created! -//');
    close(fileused);
  end;

  assign(fileused,'database.ini');
  {$i-} rewrite(fileused); {$i+}
  if IOResult <> 0 then
    MessageBoxA(0, A('Δεν ήταν δυνατή η δημιουργία της βάσης δεδομένων!'), A('Error !'), MB_ICONHAND)
  else
  begin
    writeln(fileused,'Generated by Dental Database Mk2');
    writeln(fileused,'DATABASE(1,1)');
    writeln(fileused,'DATABASE(2,1)');
    close(fileused);
  end;

  assign(fileused,'Database\map.map');
  {$i-} rewrite(fileused); {$i+}
  if IOResult <> 0 then
    MessageBoxA(0, A('Δεν ήταν δυνατή η δημιουργία του αρχείου χάρτη της βάσης!'), A('Error !'), MB_ICONHAND)
  else
    close(fileused);
end;



procedure draw_aps_mem;
var x,y:integer;
begin
for x:=1 to GetMaxX do
for y:=1 to GetMaxY do
        PutPixel(x,y,GetApsPixelColor(x,y));
readkey;
end;

procedure TestNewAps;
begin
LoadAps('logo');
DrawApsXY2('logo',1,1);
delay(1000);
InvertAps('logo','VERTICALY');
delay(1000);
DrawApsXY2('logo',1,1);
readkey;
end;

begin

APS_SAFE_MODE;
program_init:=GetTickCount; 
set_update_stat(stat);
Write_2_Log('Launch Dental Database Mk2 v'+version);
writeln('Now Launching Dental Database Mk2 v',version);
writeln('');
writeln('In case the Graphical User Interface stops responding you can');
writeln('close the application by closing this window..');
writeln('');
writeln('Written by Ammar Qammaz - ammar@otenet.gr');
                         // 0,0    1024,768
if Equal(paramstr(1),'WINDOW') then InitGraph('Dental Database',1024,768,0) else
InitGraph('Dental Database',0,0,0);
gui_full_screen;  //SKIN TRANS MODE OFF
clrscreen;
GetDir(0,curendir);
if curendir[Length(curendir)]<>'\' then curendir:=curendir+'\';

if paramcount>0 then
 begin
  if Equal(paramstr(1),'SETUP') then files_create_1stboot;
 end;

  

FlushApsMemory;
writeln('Flushing Ammar Picturing System..');
flush_gui_memory(0);
SetFont('arial','greek',15,0,0,0);
SetInternalKeyboardLanguage('Greek');
load_skin('default'); //  skin1 windowsskin  tiggz tiggz
Set_GUI_Parameter(1,1);  //PLIKTROLOGISI SET TO FAST
Set_GUI_Parameter(4,2);  //cpu_time SET TO MINIMUM

disclaimer_menu; 


load_art;
ChangeCursorIcon(mouse_icon_resource('ARROW'));
 
set_gui_color(ConvertRGB(50,50,50),'COMMENT'); 


if (not (GUI_lock)) then goto exit_program_nosave;


SetFont('arial','greek',15,0,0,0);
SetInternalKeyboardLanguage('Greek');
LoadAps('logoddmk2');
SetLoadingXY(0,GetLoadingY+GetApsInfo('logoddmk2','SIZEY')+1);

LoadPicture('ddlogo.jpg');
DrawAPSXY2('ddlogo',(GetMaxX-GetApsInfo('ddlogo','sizex')) div 2,50+(GetMaxY-GetApsInfo('ddlogo','sizey')) div 2);
SetFont('arial','greek',40,0,0,0);
TextColor(ConvertRGB(255,0,0));
GotoXY(0,((GetMaxY-GetApsInfo('ddlogo','sizey')) div 2)-TextHeight('A'));
OutTextCenter(title);
TextColor(ConvertRGB(255,255,255));
SetFont('arial','greek',15,0,0,0);
UnLoadAps('ddlogo');

//interact;
MouseButton(1);
delay(400);
OuttextCenter('Disabling ScreenSaver');  disable_win_screensaver;

OuttextCenter('Initializing Login'); Init_Login;   //Initiazlize Login..

Write_2_Log('Reached Login in '+Convert2String(GetTickCount-program_init)+' milliseconds');

if is_master_computer then Write_2_Log('Running from master server');

read_cd_key;
 


if login_screen then begin                       // Login
                      Write_2_Log('Login Success..');
                      OutTextCenter('Login Success..');
                     end else
                     begin
                       goto exit_program_nosave;
                     end;

OuttextCenter('Initializing Settings'); Init_Settings; 
OuttextCenter('Initializing Teeth'); Init_Teeth; 
OuttextCenter('Initializing Backups'); Init_Backups;
OuttextCenter('Initializing People Map'); Init_People_Map;
                                          Clean_Up_Map; //Clean up map..
OuttextCenter('Initializing People'); Init_People;
OuttextCenter('Initializing Calender'); Init_Calender;
OuttextCenter('Initializing Works'); Init_Works;
OuttextCenter('Initializing Payments'); Init_Payments;
OuttextCenter('Initializing Management'); Init_Management;
OuttextCenter('Initializing SMS Send'); Init_SMS_Send;

Write_2_Log('Starting Up services..');
OuttextCenter('Starting Up task scheduler'); //Init_SMS_Send;

MouseButton(1);
if ((check_file_existance(get_external_scheduler)) and (get_external_scheduler<>'') and (is_master_computer)) then
           RunExeInItsDir(AnalyseFilename(get_external_scheduler,'directory'),get_external_scheduler);

Check_Aquired_Images('C:\');

  
Backup_Log; // MAKE BACKUP
if ((is_master_computer) and (Get_User_Access(Get_Current_User)>=500)) then
Check_Version_Update_Backup else // Backup if new version
OutTextCenter('New Version , run as administrator for autobackup..');

Load_Database;
OutTextCenter('Database indicates '+Convert2String(database[1])+' Persons ');
if database[2]=0 then begin
                       Write_2_Log('Database Appears running...'); 
                      end; 
if database[3]<0 then begin
                       Write_2_Log('No backup info..');
                      end;
database[2]:=0; //Flag for non normal finish..
Save_Database; 

// STARTUP CHECK !!!!!!!!!
memory[1]:=get_user_state(Get_Current_User);
if memory[1]='running' then begin
                                  Write_2_Log('Still running ? , Crash ? ..');
                                  MessageBox (0, 'Την τελευταία φορά που χρησιμοποιήσατε το πρόγραμμα δεν ολοκλήρωσε την λειτουργία του σωστα ή ο λογαριασμός σας είναι ανοιχτός και από κάποιο άλλο τερματικό..  , αν αντιμετωπίζετε προβλήματα επικοινωνήστε με την A-TECH ammar@otenet.gr..' , title, 0 + MB_ICONASTERISK);
                                 end else
if memory[1]='loading_picture' then begin
                                     Write_2_Log('Crash while loading a picture!..'); 
                                     MessageBox (0, 'Κατα την τελευταία εκτέλεση και ενώ φορτονώταν ένα αρχείο εικόνας το πρόγραμμα δεν ολοκλήρωσε την λειτουργία του σωστα , αν αντιμετωπίζετε προβλήματα επικοινωνήστε με την A-TECH ammar@otenet.gr..' , title, 0 + MB_ICONASTERISK);
                                     memoryinteger[1]:=MessageBox (0, 'Επειδή το πρόβλημα δημιουργήθηκε λόγω κάποιου αρχείου εικόνας θέλετε να απενεργοποιηθούν προληπτικά για αυτή την φορά τα εξωτερικά αρχεία εικόνας ? ' , 'Images Safe Mode..', 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
                                     if memoryinteger[1]=IDYES then Set_Display_Photos(false);
                                    end else
if memory[1]='0' then  Write_2_Log('Normal startup') else
                        begin
                          Write_2_Log('Start-UP after crash..');
                          MessageBox (0, 'Κατα την τελευταία εκτέλεση το πρόγραμμα δεν ολοκλήρωσε την λειτουργία του σωστα , αν αντιμετωπίζετε προβλήματα επικοινωνήστε με την A-TECH ammar@otenet.gr..' , title, 0 + MB_ICONASTERISK);
                         end;
set_user_state(Get_Current_User,'running');
if get_setting(9)<>'3' then Text_Memory('clear',''); //FAST TYPING

//GUI_Store_Backup(get_backup_device,'thebackback.bak');
schedule[1]:=GetTickCount; //Metraei Counter gia SMS SEnd


main_menu;    // Entry point gia ta panta..

exit_program:
if ( (GetLastBackup>0) and  (Get_User_Access(Get_Current_User)>=500) and (NeedBackup) and (is_master_computer) ) then
                     begin
                      if get_setting(8)='1' then i:=IDYES else  //
                      i:=MessageBox (0, 'Έχει περάσει καιρός από τότε που κάνατε το τελευταίο backup'+#10+'Θέλετε να δημιουργήσετε ένα αντίγραφο ασφαλείας της Βάσης Δεδομένων' , 'Backup', 0 + MB_YESNO + MB_ICONQUESTION);
                      if i=IDYES then begin 
                                       DrawJpegCentered(get_central_dir+'Art\backup'); 
                                       Full_BackUp;
                                      end;
                     end;
database[2]:=1; //OK , finish
Save_Database;
set_user_state(Get_Current_User,'0');

//APS_out_stats;
//AmmarGUI_out_stats;
exit_program_nosave:

if (take_char(1)+take_char(2)+take_char(3)+take_char(4)+take_char(8)+take_char(9)+take_char(18)+take_char(16)<>2604) then
   begin
    {ISODYNAMEI ME DRAW ADD KAI DELAY(8000); } view_screen(1);
   end;

GotoXY(0,0);
exit_express:
OuttextCenter('Enabling ScreenSaver');  enable_win_screensaver;
Write_2_Log('Session closed after '+Convert2String((GetTickCount-program_init) div 1000)+' seconds');
FlushApsMemory;
Close_GUI;
CloseGraph;
Logout;
halt;
end.
