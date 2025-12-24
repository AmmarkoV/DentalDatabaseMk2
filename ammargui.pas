{Id:Unit Constructed by Ammar Qammaz (ammar@otenet.gr) 2003-2004

             Copyright (c) 2003-2004-2005-2006 - Ammar Qammaz

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

Do not Alter the unit in any way before mailing to --> ammar@otenet.gr
version 0.6999
}
{$INFO Uses AmmarGui , written by Ammar Qammaz}
{ver 0.6999}
{target 4}
{id Made By Ammar}
unit ammargui;
interface
uses windows,ammarunit,apsfiles,gui_typing,string_stuff,ammargui_draw_functions;

function  AmmarGuiVersion:string;
procedure AmmarGUI_out_stats;

procedure GUI_Enter_Form(thewind:string);
procedure GUI_Exit_Form(thewind:string);
procedure Flash_AmmarGUI(target:string);
procedure Deflash_AmmarGUI(target:string);
procedure gui_full_screen;
procedure enable_win_screensaver;
procedure disable_win_screensaver;
procedure disable_ammargui_screensaver;
procedure draw_language(thelanguage:string);
procedure draw_button_complimentary(draw_undraw:integer; shift_state,control_state,alt_state:boolean; extrachar:string);
function Suggest_Typing(typed:string):string;
function shift_mask(what2mask:string):string;
function ReadText2(startingtxt:string; sizelength:integer; masked:boolean):string;    
function GridX(curpiece,pieces:integer):integer;
function GridY(curpiece,pieces:integer):integer;
procedure fasttextboxchange(selev:integer);
procedure check_write_codec; 
procedure Text_Memory(comnd,datatxt:string);
procedure draw_background(selection:integer);
procedure Close_GUI;
function Get_GUI_Color(num:integer):integer;
function load_skin(skinname:string):string;
function Get_GUI_CopyPaste:string;
procedure Set_GUI_CopyPaste(thecop:string);
function Get_GUI_Parameter(typ:integer):integer;
procedure Set_GUI_Parameter(typ,dat:integer);
procedure flush_gui_memory(clearskin:integer);
procedure copy_object_memory(fromwhere,towhere,objcount:integer);
function  mouse_icon_resource(typeofmouse:string):string;
procedure GUI_ChangeCursorIcon(mousetype:string);
function delete_object(name,numname:string):boolean;
function last_object():string;
function last_object_activated():string;
procedure flush_last_object_activated;
procedure include_object(name,typeofobj,valueofobj,ownerwindow,soundofobj,cursor4obj:string; x1,y1,x2,y2:integer);
procedure clear_mouse;
function X1(name:string):integer;
function Y1(name:string):integer;
function X2(name:string):integer;
function Y2(name:string):integer;
function text_handle_menu(x,y,MAX_EPILOGES:integer; arrayinp:array of string):integer;
procedure wait_clear_key(thekey:string);
function  get_object_number(name:string):integer;
function get_object_total_number:integer;
function get_number_object (thenum:integer):string;
function  get_object_data(name:string):string;
function  get_object_size(name,typ:string):integer;
function GUI_Exit:boolean;
procedure GUI_Exit_disarm;
function  set_object_data(name,datas,thevalue:string; datai:integer):string;
function get_object_data_full(name,datas:string):string;
procedure set_button(btnname:string; what:integer);
procedure set_gui_color(thecolor:integer; what:string);
procedure draw_window;
procedure draw_btncustom(value,text:string; x1,y1,x2,y2:integer);
procedure draw_btn(size,value:string; x1,y1:integer);
procedure draw_chk(size,value:string; x1,y1:integer);
procedure draw_dropdown(selection,listofstuff:string; ax1,ay1,ax2,ay2:integer);
procedure draw_border(title:string; ax1,ay1,ax2,ay2:integer);
procedure draw_text_area(value:string; x1,y1,x2,y2:integer);
procedure draw_field(value:string; x1,y1,x2,y2:integer);
procedure draw_progressbar(value:string; x1,y1,x2,y2:integer);
procedure draw_label(value:string; x1,y1:integer);
procedure draw_object(numtmp:integer);
procedure draw_object_by_name(numname:string);
procedure draw_spontaneus_object(thetyp,theval:string; tx1,ty1,tx2,ty2:integer);
procedure draw_objects_on_window(numname:string);
procedure draw_all;
procedure draw_mem; {TEST}
procedure draw_mem_text; {TEST}
procedure Draw_a_WindowTST(title1:string; active,x,y,sizex1,sizey1:integer);
procedure activate_object(name:string);
function  movefocus:integer;
function  return_focus:string;
function  return_last_mouse_object:string;
function get_gui_key:string;
procedure interact;
function GUI_MouseX:integer;
function GUI_MouseY:integer;

implementation
const
   version='0.6999.10';
   maxresolutionx=2048;
   maxresolutiony=1080;
   maxtextmemory=1024;
   maxobjects=255;
   seperate_words_read_strength=200;
   seperate_words_strength=25;

//OBJECTS
   obj_window=1; obj_layer=2; obj_textbox=3; obj_comment=4; obj_label=5;
   obj_progressbar=6; obj_checkboxl=7; obj_checkbox=8; obj_button=9; obj_buttonc=10;
   obj_buttonl=11; obj_icon=12; obj_textbox_password=13; obj_buttonaps=14; obj_border=15;
   obj_dropdown=16; obj_mainwindow=17; obj_button_clp=18; { CLP = Custom Large Picture }
// UNDER DEVELOPMENT
   enableturbo=false;
// UNDER DEVELOPMENT
// COLOR
   window_background=1; 
   window_background_inactive=2;
   window_border=3;
   window_title=4;
   menu_active=5;
   menu_active_text=16;
   textbox_out=6;
   textbox_in=7;
   textbox_text=8;
   textbox_suggestion=9;
   comments_color=10;
   button_color=11;
   button_text=12;
   button_active_text=13;
   button_activated_text=14;
   progressbar=15;


   button_text_skin=16;
   button_active_text_skin=17;
   button_activated_text_skin=18;
   focused_region=19;
    
   MAX_COLORS=20;
// COLOR
   MAX_METRICS=2;


var i:integer;
    memory:array[1..seperate_words_strength] of string;
    memoryinteger:array[1..seperate_words_strength] of integer;
    curdir,bufstin,enviromentdir:string;
    dataloaded:array[1..15]of integer;   {6=FASTTEXTBOXCHANGE 7=FOCUS 8=Depth of map 9=textmemory pointer 10=activate object 11=Shortcuts on/off 1/0 12 reserver 13 last object added.. , 14 last object activated , 15 have main window..}
    dataloadedst:array[1..2]of string; {1=ACTIVE WINDOW 2=? }
    objects:array[0..maxobjects,1..8] of string;   // 0 gia na swsw kanena tyxaio error
    objectsdat:array[0..maxobjects,1..6] of integer; {5=EXTRA MEMORY FOR WINDOW OBJECT(ACTIVE OR NOT) 6=Object Type new ..}
    full_map:array[1..maxresolutionx,1..maxresolutiony]of integer; {oli i othoni..}
    map:array[1..maxresolutionx,1..101]of integer; {map[x,map[x,101]]=Teleytaia kataxorisi sto map[x,}
    textmemory:array[1..maxtextmemory] of string;
    metrics:array[1..MAX_METRICS]of integer; // 1=Text Field Border Size.. 2=Comments/Labels Color
    colors:array[1..MAX_COLORS] of integer; 

    idle_time,MAX_IDLE_TIME:integer;
    pliktrologisi_speed,special_key_speed,blink_key_speed,cpu_time,auto_complete_letter,move_snap:integer;

    keybinp:string;
    

    last_cursor:string;
    default_skin:string;
    copypaste_mem:string;
    agui_screensaver_disable:boolean;
    //MAPPING
    start_map:integer;
    //SKIN
    current_skin:string;
    old_style_buttons:boolean; 
    transparent_window_regions:boolean;
    // READTEXT FUNCTION
    advanced_read:boolean;
    //SPEED IMPROVEMENTS
    obj_prediction:string;
    obj_pred_int:integer;
    //DEBUG
   // mouse_querys,mouse_times:integer;


    //INLINE PARAMETERS FOR EXTRA SPEED
    sxbtnminimize,sxbtnmaximize,sxbtnexit,sybtnminimize,sybtnmaximize,sybtnexit,sxupmiddle,sxupmiddle2:integer;
    sxupleft,syupleft,sxuptransection,sxupright,syupright:integer;
    sydownright,sxmiddleright,symiddleright,sxmiddleleft,symiddleleft,sxdownmiddle,sydownmiddle:integer;


procedure disable_ammargui_screensaver;
begin
agui_screensaver_disable:=true;
end;

function AmmarGuiVersion:string;
begin
AmmarGuiVersion:=version;
end; 

function seperate_words_old(bufstr4:string):integer;
var buffers:array [1..6] of integer;
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
buffers[6]:=1;
repeat
  buffers[4]:=buffers[4]+1;
  buffers[5]:=buffers[3];
  if buf[buffers[4]]='(' then buffers[3]:=buffers[3]+1
          else 
  if buf[buffers[4]]=',' then buffers[3]:=buffers[3]+1
          else 
  if buf[buffers[4]]='.' then buffers[3]:=buffers[3]+1
          else 
  if buf[buffers[4]]=')' then buffers[3]:=buffers[3]+1;
  buffers[6]:=buffers[3]; //RETAIN TOTAL

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
seperate_words_old:=buffers[6];
end;


procedure gui_full_screen;
begin
transparent_window_regions:=false;
end;



function clear_file(thefile:string):boolean;
var fileused:text;
begin
assign(fileused,thefile);
rewrite(fileused);
close(fileused);
clear_file:=true;
end;

function delete_file(filenam:string):boolean;
var filetst:text;
    retres:boolean;
begin
retres:=true;
assign(filetst,filenam);
{$i-}
 reset(filetst);
{$i+}
if Ioresult=0 then begin
                    close(filetst);
                    erase(filetst);
                      {$i-}
                      reset(filetst);
                      {$i+}
                      if Ioresult=0 then begin
                                          retres:=false;
                                          close(filetst);
                                         end;
                   end;
end;

procedure GUI_Enter_Form(thewind:string);
begin
clear_file(thewind);
DeFlash_AmmarGUI(thewind);
end;

procedure GUI_Exit_Form(thewind:string);
begin
delete_file(thewind);
end;


 
function Retrieve_Map_Object(x,y:integer):integer;
var theobjid:integer;
label skip_retrieve;
begin 
theobjid:=0;
if ((x>maxresolutionx) or (x<1)) then goto skip_retrieve;
if ((y>maxresolutiony) or (y<1)) then goto skip_retrieve;
if ((full_map[x,y]>start_map) and (full_map[x,y]<=start_map+maxobjects)) then begin
                                                                              theobjid:=full_map[x,y]-start_map;
                                                                             end;

skip_retrieve:
Retrieve_Map_Object:=theobjid;
end;


procedure Map_Object(theobjid:integer);
var x,y,x1,y1,x2,y2:integer;
begin 
if ((theobjid<=maxobjects) and (theobjid>=1)) then
 begin
  x1:=objectsdat[theobjid,1];
  y1:=objectsdat[theobjid,2];
  x2:=objectsdat[theobjid,3];
  y2:=objectsdat[theobjid,4];
  //MessageBox (0, pchar('Map '+Convert2String(theobjid)+' from '+Convert2String(x1)+' '+Convert2String(y1)+' '+Convert2String(x2)+' '+Convert2String(y2)+' ') , ' ', 0);
  for x:=x1 to x2 do
   for y:=y1 to y2 do
      begin
         full_map[x,y]:=start_map+theobjid;
      end;
 end;
end;

procedure Remove_Map_Object(theobjid:integer);
var x,y,x1,y1,x2,y2:integer;
begin 
if ((theobjid<=maxobjects) and (theobjid>=1)) then
 begin
  x1:=objectsdat[theobjid,1];
  y1:=objectsdat[theobjid,2];
  x2:=objectsdat[theobjid,3];
  y2:=objectsdat[theobjid,4];
  for x:=x1 to x2 do
   for y:=y1 to y2 do
      begin
         if full_map[x,y]=start_map+theobjid then full_map[x,y]:=0;
      end;
 end;
end;


 
procedure Deflash_AmmarGUI(target:string);
var fileused:text;
    i,z:integer;
begin
assign(fileused,target);
{$i-}
rewrite(fileused);
{$i+}
if Ioresult<>0 then MessageBox (0, 'Error Deflashing data ' , 'AmmarGUI Error', 0 + MB_ICONEXCLAMATION) else
  begin
   writeln(fileused,dataloaded[1]);
   writeln(fileused,8);
   writeln(fileused,6); 
   for i:=1 to dataloaded[1] do
     begin 
       for z:=1 to 8 do writeln(fileused,objects[i,z]);
       for z:=1 to 6 do writeln(fileused,objectsdat[i,z]); 
     end;
   close(fileused);
  end;
end;

procedure Flash_AmmarGUI(target:string);
var fileused:text;
    i,z:integer;
begin
assign(fileused,target);
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin {MessageBox (0, 'Error Deflashing data ' , 'AmmarGUI Error', 0 + MB_ICONEXCLAMATION)} end else
  begin
   flush_gui_memory(0);
   readln(fileused,dataloaded[1]);
   readln(fileused,i);
   readln(fileused,z);
   if ((i<>8) or (z<>6)) then MessageBox (0, 'It appears that Flash_AmmarGUI runs old code.. Update to the newest AmmarGUI , Incorrect reading..' , 'AmmarGUI Error', 0 + MB_ICONEXCLAMATION);
   for i:=1 to dataloaded[1] do
     begin 
       for z:=1 to 8 do begin
                         {if not eof(fileused) then} readln(fileused,objects[i,z]);
                        end;
       for z:=1 to 6 do begin
                        { if not eof(fileused) then} readln(fileused,objectsdat[i,z]);
                        end;
       if (not Equal(objects[i,2],'border')) then Map_Object(i);
     end;
   close(fileused);
  end;
end; 






procedure Set_GUI_CopyPaste(thecop:string);
begin
copypaste_mem:=thecop;
end;

function Get_GUI_CopyPaste:string;
begin
Get_GUI_CopyPaste:=copypaste_mem;
end;

procedure Set_GUI_Parameter(typ,dat:integer);
begin
if typ=1 then pliktrologisi_speed:=dat else
if typ=2 then special_key_speed:=dat else
if typ=3 then blink_key_speed:=dat else
if typ=4 then cpu_time:=dat else
if typ=5 then auto_complete_letter:=dat else
if typ=6 then dataloaded[2]:=dat else
if typ=7 then dataloaded[3]:=dat else
if typ=8 then begin
               if dat=1 then transparent_window_regions:=true else
                             transparent_window_regions:=false;
              end;


end;

function Get_GUI_Parameter(typ:integer):integer;
var retres:integer;
begin
retres:=0;
if typ=1 then retres:=pliktrologisi_speed else
if typ=2 then retres:=special_key_speed else
if typ=3 then retres:=blink_key_speed else
if typ=4 then retres:=cpu_time else
if typ=5 then retres:=auto_complete_letter else
if typ=6 then retres:=dataloaded[2] else
if typ=7 then retres:=dataloaded[3] else
if typ=8 then begin
               if transparent_window_regions then retres:=1 else
                                                  retres:=0;
              end;
Get_GUI_Parameter:=retres;
end;



                                                                     
procedure flush_gui_memory(clearskin:integer); //KATHARIZEI OLES TIS METAVLITES
var flushx,flushy:integer;
begin


if start_map<50000 then start_map:=start_map+maxobjects else
                        begin
                         start_map:=0;
                         for flushx:=1 to maxresolutionx do
                          for flushy:=1 to maxresolutiony do
                          full_map[flushx,flushy]:=0;
                        end;

if dataloaded[1]=0 then dataloaded[1]:=1; //PROSWRINA GIA APOFYGI ERROR..
for flushx:=1 to dataloaded[1] do
for flushy:=1 to 8 do
objects[flushx,flushy]:='';

for flushx:=1 to dataloaded[1] do
for flushy:=1 to 5 do
objectsdat[flushx,flushy]:=0;

{
for flushx:=1 to maxresolutionx do
for flushy:=1 to 101 do
map[flushx,flushy]:=0;   //Anti gia 101 flushy SPEED IMPROVEMENT 17-4-06
} //AFOU PLEON EXW DIRECT MAPPING TSAMPA ARA EFYGE.. CPU 31-10-06

for flushx:=1 to 8 do dataloaded[flushx]:=0;{OXI TO 9 giati svinetai i mnimi tou text etsi!}
//dataloaded[12]:=ConvertRGB(255,255,255); // DEFAULT COLOR LABEL,COMMENTS  ASPRO
dataloaded[11]:=1; //Energopoiisi Tab + Enter + Space
dataloaded[15]:=0;
for flushx:=1 to 2 do dataloadedst[flushx]:='';
//metrics[1]:=2; // 1=Text Field Border Size..
//metrics[2]:=ConvertRGB(255,255,255);
if clearskin=1 then FlushApsMemory;
FlushMouseButtons;
flush_last_object_activated;
obj_prediction:='';
obj_pred_int:=0;
GUI_ChangeCursorIcon(mouse_icon_resource('ARROW'));
end;

procedure check_write_codec; //ELEGXEI AN EINAI EGKATESTIMENO TO FRAUNHOFER CODEC
var successflag:boolean;
    destinationdir:pchar;
    testexist:text;
    response:integer;
begin
successflag:=false;
destinationdir:='';
GetSystemDirectory(destinationdir,MAX_PATH);
assign(testexist,destinationdir+'\L3codeca.acm');
{$i-}
reset(testexist);
{$i+}
if Ioresult<>0 then begin
                      response:=MessageBox (0, 'Whould you like to install the Advanced Fraunhofer codec to be able to hear music' , 'Your computer doesn`t have a required sound codec', 0 + MB_YESNO + MB_ICONQUESTION);
                      if response=IDYES then begin
                                              RunEXE(enviromentdir+'l3codecx.exe','normal');
                                              halt;
                                             end else
                                             begin
                                             end;
                    end else
                    begin 
                      close(testexist); 
                    end;
end;

procedure AmmarGUI_out_stats;
var fileused:text;
    i:integer;
begin
assign(fileused,'AmmarGUI_stats.dat');
{$i-}
append(fileused);
{$i+}
if Ioresult<>0 then rewrite(fileused);
writeln(fileused,'AmmarGUI SESSION START '+version+'------------------'); 
//writeln(fileused,'Mouse querys : ',mouse_querys);
//writeln(fileused,'Mouse searches : ',mouse_times);
writeln(fileused,'SESSION END---------------------------------');
close(fileused);
end;



procedure draw_language(thelanguage:string);
begin
thelanguage:=Upcase(thelanguage);
if thelanguage='ENGLISH' then DrawApsXY('uk',GetMaxX-40,GetMaxY-20) else
if thelanguage='GREEK' then DrawApsXY('gr',GetMaxX-40,GetMaxY-20);
end;

function GridX(curpiece,pieces:integer):integer;
var retres:integer;
begin 
retres:=(GetMaxX div pieces) * curpiece;
GridX:=retres;
end;

function GridY(curpiece,pieces:integer):integer;
var retres:integer;
begin 
retres:=(GetMaxY div pieces) * curpiece;
GridY:=retres;
end;
 
function convert_objecttype_string2int(objtyp:string):integer;   //METATREPEI TO STRING POU PERIGRAFEI ENA ANTIKEIMENO STON ANTISTOIXO ARITHMO
var upcsinpt:String;
    res:integer;
begin
upcsinpt:=Upcase(objtyp); 

if upcsinpt='BUTTONCLP' then res:=obj_button_clp else
if upcsinpt='DROPDOWN' then res:=obj_dropdown else
if upcsinpt='MAINWINDOWMOVE' then res:=obj_mainwindow else
if upcsinpt='BORDER' then res:=obj_border else
if upcsinpt='WINDOW' then res:=obj_window else
if upcsinpt='LAYER' then res:=obj_layer else
if upcsinpt='TEXTBOX' then res:=obj_textbox else
if upcsinpt='COMMENT' then res:=obj_comment else
if upcsinpt='LABEL' then res:=obj_label else
if upcsinpt='PROGRESSBAR' then res:=obj_progressbar else
if upcsinpt='CHECKBOXL' then res:=obj_checkboxl else
if upcsinpt='CHECKBOX' then res:=obj_checkbox else
if upcsinpt='BUTTON' then res:=obj_button else
if upcsinpt='BUTTONC' then res:=obj_buttonc else
if upcsinpt='BUTTONL' then res:=obj_buttonl else
if upcsinpt='BUTTONAPS' then res:=obj_buttonaps else
if upcsinpt='ICON' then res:=obj_icon else
if upcsinpt='TEXTBOX-PASSWORD' then res:=obj_textbox_password else
                          res:=0;
convert_objecttype_string2int:=res;
end;

procedure copy_object_memory(fromwhere,towhere,objcount:integer);
var copyx,copyy:integer;
begin
if objcount=0 then objcount:=dataloaded[1];
if (towhere+objcount>maxobjects) or (fromwhere<=0) or (towhere<=0) or (objcount<=0) then OuttextCenter('Error Calling copy_object_memory , out of object array bounds') else
           begin
            for copyx:=fromwhere to fromwhere+objcount do begin
                                                           for copyy:=1 to 8 do objects[towhere+copyx-fromwhere,copyy]:=objects[copyx,copyy];
                                                           for copyy:=1 to 5 do objectsdat[towhere+copyx-fromwhere,copyy]:=objectsdat[copyx,copyy];
                                                          end;
           end;
end;

function mouse_icon_resource(typeofmouse:string):string; //EPISTREFEI TO PATH TOU ANTISTOIXOU CURSOR
var resmous:string;
begin
resmous:=''; 
if (Equal(typeofmouse,'ARROW')) or (Equal(typeofmouse,'NORMAL')) then resmous:=enviromentdir+'Pointers\Arrow.cur' else
if Equal(typeofmouse,'WAIT') then resmous:=enviromentdir+'Pointers\Wait.cur' else
if Equal(typeofmouse,'FORWARD') then resmous:=enviromentdir+'Pointers\Forward.cur' else
if Equal(typeofmouse,'RIGHT') then resmous:=enviromentdir+'Pointers\Right.cur' else
if Equal(typeofmouse,'LEFT') then resmous:=enviromentdir+'Pointers\Left.cur' else
if Equal(typeofmouse,'DOWN') then resmous:=enviromentdir+'Pointers\Down.cur' else
if Equal(typeofmouse,'UP') then resmous:=enviromentdir+'Pointers\Up.cur' else
if Equal(typeofmouse,'SELECT') then resmous:=enviromentdir+'Pointers\Select.cur' else
if Equal(typeofmouse,'TYPE') then resmous:=enviromentdir+'Pointers\Type.cur' else
if Equal(typeofmouse,'MAGNIFY') then resmous:=enviromentdir+'Pointers\Magnifier.cur' else
if Equal(typeofmouse,'USE') then resmous:=enviromentdir+'Pointers\Use.cur' else
if Equal(typeofmouse,'PICK') then resmous:=enviromentdir+'Pointers\Pick.cur' else
if Equal(typeofmouse,'RING') then resmous:=enviromentdir+'Pointers\Ring.cur' else
                                  resmous:=typeofmouse;
mouse_icon_resource:=resmous;
end;

function set_load_mouse_icon_resource(typeofmouse:string):string;
begin
last_cursor:=mouse_icon_resource(typeofmouse);
set_load_mouse_icon_resource:=last_cursor;
end;


procedure GUI_ChangeCursorIcon(mousetype:string); 
begin 
if mousetype<>last_cursor then begin
                               last_cursor:=mousetype;
                               ChangeCursorIcon(mousetype);
                              end;
end;

procedure fasttextboxchange(selev:integer);  //ENERGOPOIEI APENERGOPOIEI TIN GRIGORI ALLAGI APO TEXTBOX SE TEXTBOX
begin
if selev=1 then dataloaded[6]:=1 else
                dataloaded[6]:=0;
end;

function check_file_existance(filename:string):boolean;
var file2check:file;
    res:boolean;
begin
assign(file2check,filename);
{$i-}
reset(file2check);
{$i+}
if Ioresult=0 then begin
                    res:=true;
                    close(file2check);
                   end else
                    res:=false;
check_file_existance:=res;
end;


procedure draw_background(selection:integer);
var locx,locy,locz:integer;
begin 
if selection=4 then begin
                        DrawJpeg('back1.jpg',1,1);
                    end else 
if selection=3 then begin
                        if ((check_file_existance('back1.jpg')) and (GetMaxX<1281)) then DrawJpeg('back1.jpg',1,1) else
                           begin 
                            locz:=(GetMaxY div 256)+20;
                            locy:=-locz;
                            SetLineSettings(locz,locz,locz);
                            locx:=256;
                            repeat
                             locy:=locy+locz;
                             locx:=locx+1;
                             DrawLine(-locz,locy,GetMaxX+locz,locy,ConvertRGB(0,0,locx));
                            until locy>=GetMaxY;
                            SetLineSettings(1,1,1); 
                           end;
                           end else
if selection=1 then begin
                             GotoXY(0,0);
                             drawdesktop;
                            end else
if selection=0 then clrscreen;
end;



function Adjust2Enviroment:string;
var i:integer;
    bufstr,originaldir:string;
    overridefile:text;
    foundsharedres:boolean;
    knownpaths:array[1..10]of string;
begin
GetDir(0,originaldir);
 
if Length(originaldir)>0 then begin
if originaldir[Length(originaldir)]<>'\' then originaldir:=originaldir+'\';
                              end else  originaldir:='\'; 
foundsharedres:=false;
knownpaths[1]:=originaldir+'Resources\';
knownpaths[2]:='C:\Program Files\A-Tech\Resources\';
knownpaths[3]:='C:\Program Files\A-Tech\Resources\';
knownpaths[4]:=knownpaths[3];//'A:\Program Files\A-Tech\Resources\';
knownpaths[5]:='D:\Program Files\A-Tech\Resources\';
knownpaths[6]:='E:\Program Files\A-Tech\Resources\';
knownpaths[7]:='F:\Program Files\A-Tech\Resources\';
knownpaths[8]:='G:\Program Files\A-Tech\Resources\';
knownpaths[9]:='H:\Program Files\A-Tech\Resources\';
knownpaths[10]:='I:\Program Files\A-Tech\Resources\';

MAX_IDLE_TIME:=5*60000;
assign(overridefile,'enviroment.nfo');
{$i-}
reset(overridefile);
{$i+}
if Ioresult=0 then begin
                    //Yparxei override file , ara yparxei kapoia allagi sto path..
                    while ( not (eof(overridefile)) ) do
                      begin
                       readln(overridefile,bufstr);
                       seperate_words_old(bufstr);
                       if Equal(memory[1],'old_style_buttons') then old_style_buttons:=true  else
                       if Equal(memory[1],'transparent_window_regions') then transparent_window_regions:=true  else 
                       if Equal(memory[1],'screensaver_time') then MAX_IDLE_TIME:=memoryinteger[2]*60000  else
                       if Equal(memory[1],'skin') then default_skin:=memory[2]  else
                       if Equal(memory[1],'enviroment_path') then knownpaths[1]:=memory[2] else
                                                                  break;

                      end;
                    close(overridefile);
                   end;

i:=1;

while (i<=10) and (not foundsharedres) do 
begin
{$i-}
chdir(knownpaths[i]);
{$i+}
if Ioresult=0 then begin
                    foundsharedres:=true;
                    bufstr:=knownpaths[i];
                   end; 
i:=i+1;
end; 
 
if not foundsharedres then begin
                            enviromentdir:=knownpaths[2];
                            MessageBox (0, pchar('Could not find A-TECH Resources folder.. '+#10+'Please download it from our website and copy it to C:\Program Files\A-TECH\Resources'+#10+'I will now try to connect you to the A-Tech download page'+#10+'You will need to run this program again after you finish copying the Resources..'), 'AmmarGUI Could not initialize', 0 + MB_ICONEXCLAMATION);
                            if check_file_existance('C:\Program Files\Internet Explorer\IEXPLORE.EXE') then
                            RunExE('"C:\Program Files\Internet Explorer\IEXPLORE.EXE" "http://users.otenet.gr/~ammar/Downloads/Resources.zip"','NORMAL') else
                            MessageBox (0, pchar('Could not find Internet Explorer.. '+#10+'Please visit http://62.103.22.50/'), 'AmmarGUI Could not initialize', 0 + MB_ICONEXCLAMATION);
                            delay(3000);
                            halt;
                           end else
                            enviromentdir:=bufstr;

//outtextcenter('Setting Enviroment to '+enviromentdir);
//MessageBox (0, pchar('Setting Enviroment to '+enviromentdir) , ' ', 0);
Chdir(originaldir);
Adjust2Enviroment:=enviromentdir;
end;


procedure store_skin_metrics;
begin
store_skin_metrics_window;
sxbtnminimize:=GetApsInfo('btnminimize','SIZEX');
sybtnminimize:=GetApsInfo('btnminimize','SIZEY');
sxbtnmaximize:=GetApsInfo('btnmaximize','SIZEX');
sybtnmaximize:=GetApsInfo('btnmaximize','SIZEY');
sxbtnexit:=GetApsInfo('btnexit','SIZEX');
sybtnexit:=GetApsInfo('btnexit','SIZEY'); 
sxupmiddle2:=GetApsInfo('upmiddle2','SIZEX'); 
sxupright:=GetApsInfo('upright','SIZEX');
syupright:=GetApsInfo('upright','SIZEY');
sydownright:=GetApsInfo('downright','SIZEY');
sxmiddleright:=GetApsInfo('middleright','SIZEX');
symiddleright:=GetApsInfo('middleright','SIZEY'); 
sxdownmiddle:=GetApsInfo('downmiddle','SIZEX');
sydownmiddle:=GetApsInfo('downmiddle','SIZEY'); 
end;

function Get_GUI_Color(num:integer):integer;
begin
Get_GUI_Color:=colors[num];
end;

procedure load_skin_colors;
var fileused:text;
    bufstr:string;
begin
colors[window_background]:=ConvertRGB(208,219,241);
colors[window_background_inactive]:=ConvertRGB(208,219,241);
colors[window_border]:=ConvertRGB(116,127,155);
colors[window_title]:=ConvertRGB(255,255,255);
colors[menu_active]:=ConvertRGB(0,0,255);
colors[menu_active_text]:=ConvertRGB(0,0,0);
colors[textbox_out]:=ConvertRGB(44,0,255);
colors[textbox_in]:=ConvertRGB(0,0,0);
colors[textbox_text]:=ConvertRGB(255,255,255);
colors[textbox_suggestion]:=ConvertRGB(255,0,0);
colors[comments_color]:=ConvertRGB(0,0,0);
colors[button_color]:=ConvertRGB(192,192,192);
colors[button_text]:=ConvertRGB(0,0,0);
colors[button_active_text]:=ConvertRGB(255,230,23);
colors[button_activated_text]:=ConvertRGB(255,0,0);
colors[progressbar]:=ConvertRGB(255,0,0);
colors[focused_region]:=ConvertRGB(255,255,0);
 
assign(fileused,'colours.dat');
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then
   begin
    while (not (eof(fileused)) ) do
      begin
       readln(fileused,bufstr);
       seperate_words_old(bufstr);
       if Equal(memory[1],'Window_Background') then colors[window_background]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Window_Background_Inactive') then colors[window_background_inactive]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Window_Border') then colors[window_border]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Window_Title') then colors[window_title]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Menu_Active') then colors[menu_active]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Menu_Active_Text') then colors[menu_active_text]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else 
       if Equal(memory[1],'Textbox_Out') then colors[textbox_out]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Textbox_In') then colors[textbox_in]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Textbox_Text') then  colors[textbox_text]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Textbox_Suggestion') then colors[textbox_suggestion]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Comments') then colors[comments_color]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Button') then colors[button_color]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Button_Text') then colors[button_text]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Button_Active_Text') then colors[button_active_text]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Button_Activated_Text') then colors[button_activated_text]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'ProgressBar') then colors[progressbar]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else

       if Equal(memory[1],'Button_Text_Skin') then colors[button_text_skin]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Button_Active_Text_Skin') then colors[button_active_text_skin]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]) else
       if Equal(memory[1],'Button_Activated_Text_Skin') then colors[button_activated_text_skin]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]);
       if Equal(memory[1],'Focused_Region') then colors[focused_region]:=ConvertRGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]);


      end; 
    close(fileused);
   end; 
end;

procedure load_skin_metrics;
var fileused:text;
    bufstr:string;
begin
metrics[1]:=2;

assign(fileused,'metrics.dat');
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then
   begin
    while (not (eof(fileused)) ) do
      begin
       readln(fileused,bufstr);
       seperate_words_old(bufstr);
       if Equal(memory[1],'Textbox_Size') then begin
                                                metrics[1]:=memoryinteger[2]; 
                                               end;
      end;
    close(fileused);
   end; 
end;



function load_skin(skinname:string):string;     //FORTONEI TO SKIN
var memx,memy,maxy,progress,bufsiz:integer;
    curaps:string;
begin
current_skin:=skinname;
GetDir(0,curdir);
if Upcase(curdir[Length(curdir)])<>'\' then curdir:=curdir+'\'; 

Adjust2Enviroment; 

if default_skin='' then default_skin:='skin1';
if ((Equal(skinname,'default')) or (Equal(skinname,'')) ) then skinname:=default_skin;

{$i-}
chdir(enviromentdir+skinname+'\');
{$i+}
if Ioresult<>0 then begin
                     MessageBox (0, pchar('Could not find '+skinname+' skin.. '+#10+'You could try to download it from the A-TECH website..'+#10+'Continuing with default skin..') , ' ', 0 + MB_ICONASTERISK);
                     skinname:='skin1';
                     chdir(enviromentdir+skinname+'\');
                    end;

load_skin_colors;
load_skin_metrics;
SetTransparentColor(ConvertRGB(123,123,0));
memx:=1;
memy:=1;
maxy:=1;
progress:=0;
repeat
progress:=progress+1;
SetLoadingXY(memx+1,memy+1);
if progress=1 then curaps:='guiuppercase' else
if progress=2 then curaps:='guilowercase' else
if progress=3 then curaps:='guicontrol' else
if progress=4 then curaps:='wnddn' else
if progress=5 then curaps:='wndup' else
if progress=6 then curaps:='wndlt' else
if progress=7 then curaps:='wndrt' else
if progress=8 then curaps:='guishift' else
if progress=9 then curaps:='guialt' else
if progress=10 then curaps:='guiplus' else
if progress=11 then curaps:='btns1' else
if progress=12 then curaps:='btns2' else
if progress=13 then curaps:='btns3' else
if progress=14 then curaps:='chks1' else
if progress=15 then curaps:='chks2' else
if progress=16 then curaps:='chks3' else
if progress=17 then curaps:='downleft' else
if progress=18 then curaps:='downmiddle' else
if progress=19 then curaps:='downright' else
if progress=20 then curaps:='middleleft' else
if progress=21 then curaps:='middleright' else
if progress=22 then curaps:='upleft' else
if progress=23 then curaps:='upmiddle2' else
if progress=24 then curaps:='upmiddle' else
if progress=25 then curaps:='upright' else
if progress=26 then curaps:='uptransection' else
if progress=27 then curaps:='btnminimize'else
if progress=28 then curaps:='btnmaximize'else
if progress=29 then curaps:='btnexit'else
if progress=30 then curaps:='up2middle' else
if progress=31 then curaps:='middle2left' else
if progress=32 then curaps:='up2transection' else
if progress=33 then curaps:='down2left' else
if progress=34 then curaps:='up2left' else
if progress=35 then curaps:='gr' else
if progress=36 then curaps:='uk' else
if progress=37 then curaps:='btncleft' else
if progress=38 then curaps:='btncright' else
if progress=39 then curaps:='btncmain' else
if progress=40 then curaps:='btncleftlight' else
if progress=41 then curaps:='btncrightlight' else
if progress=42 then curaps:='btncmainlight';



{if progress=37 then curaps:='guiuppercase' else
if progress=38 then curaps:='guilowercase' else
if progress=39 then curaps:='guicontrol' else
if progress=40 then curaps:='guishift' else
if progress=41 then curaps:='guialt' else
if progress=42 then curaps:='guiplus'; }//else ??????????

if progress=17 then begin  {WINDOWS SKIN!! ALLAZEI DIRECTORY EPEIDI VRISKONTAI SE DIAFORETIKO} 
                     chdir(enviromentdir+skinname+'\Window\'); 
                    end;
if progress=35 then begin  {EPANAFORA STO PROIGOUMENO DIRECTORY }
                     chdir(enviromentdir+skinname+'\');
                    end;
LoadAps(curaps);
{outtextcenter('Loading '+curaps+''); }
if maxy<GetApsInfo(curaps,'sizey') then maxy:=GetApsInfo(curaps,'sizey');
bufsiz:=GetApsInfo(curaps,'sizex');
memx:=memx+bufsiz+2;
if memx>=1821 then begin   {OSTE NA MIN TELEIOSEI TO PAPER}
                     memx:=1;
                     memy:=memy+maxy+2;
                   end;
until progress=42;
SetLoadingXY(1,maxy+2);
chdir(curdir);
store_skin_metrics;
load_skin:=skinname;
copypaste_mem:=PasteFromClipboard;
if transparent_window_regions then adjust_window_shape_transparency;
SetBackgroundColor(colors[window_background]);


{outtextcenter('Done loading '+skinname+'');   } 
end;

procedure Close_GUI;
begin
CopyToClipboard(copypaste_mem);
end;


procedure Text_Memory(comnd,datatxt:string);  //GRIGORI PLIKTROLOGISI!
var fileused:text;
begin
if Equal(comnd,'ADD') then begin
                             dataloaded[9]:=dataloaded[9]+1;
                             if dataloaded[9]>maxtextmemory then dataloaded[9]:=maxtextmemory;
                             textmemory[dataloaded[9]]:=datatxt;
                            end else
if Equal(comnd,'FREE') then begin
                              Str(maxtextmemory-dataloaded[9],memory[15]);
                              outtext('Free text memory is : '+memory[15])
                             end else
if Equal(comnd,'VIEW') then begin
                             for i:=1 to dataloaded[9] do outtextcenter(textmemory[i]); 
                            end else 
if Equal(comnd,'CLEAR') then begin
                               for i:=1 to dataloaded[9] do textmemory[i]:='';
                               dataloaded[9]:=0;
                              end else
if Equal(comnd,'SAVE') then begin
                              assign(fileused,datatxt);
                              {$i-}
                              rewrite(fileused);
                              {$i+}
                              if Ioresult<>0 then MessageBox (0, 'Could not save Text_Memory' , ' ', 0 + MB_ICONEXCLAMATION) else
                              begin
                                writeln(fileused,dataloaded[9]);
                                if (dataloaded[9]>0) then begin
                                                           for i:=1 to dataloaded[9] do writeln(fileused,textmemory[i]); 
                                                          end;
                                close(fileused)
                              end;
                             end else
if Equal(comnd,'LOAD') then begin
                              assign(fileused,datatxt);
                              {$i-}
                              reset(fileused);
                              {$i+}
                              if Ioresult<>0 then MessageBox (0, 'Could not load Text_Memory' , ' ', 0 + MB_ICONEXCLAMATION) else
                              begin
                                readln(fileused,dataloaded[9]);
                                if (dataloaded[9]>0) then begin
                                                           for i:=1 to dataloaded[9] do readln(fileused,textmemory[i]);
                                                          end;
                                close(fileused)
                              end;
                              end;
end;

procedure draw_button_complimentary(draw_undraw:integer; shift_state,control_state,alt_state:boolean; extrachar:string);
var x,plusnum,black:integer;
begin 
if Equal(extrachar,'CONTROL') then extrachar:='' else
if Equal(extrachar,'SHIFT') then extrachar:='' else
if Equal(extrachar,'ALT') then extrachar:='';
if ((not shift_state)and(not control_state)and(not alt_state)) then draw_undraw:=0;

if draw_undraw=-1 then begin
                         x:=GetMaxX-50;
                         x:=x-(4*GetApsInfo('guiplus','sizex'))-GetApsInfo('guicontrol','sizex')-GetApsInfo('guishift','sizex')-GetApsInfo('guialt','sizex')-10;
                         x:=x-TextWidth(extrachar);
                         DrawRectangle2(x,GetMaxY-17,GetMaxX-40,GetMaxY,ConvertRGB(0,0,0),ConvertRGB(0,0,0));
                       end else
if draw_undraw=1 then
begin
plusnum:=0;
black:=ConvertRGB(0,0,0);
x:=GetMaxX-50;
if (extrachar<>'') then begin
                          SetBackgroundMode('OPAQUE');
                          x:=x-TextWidth(extrachar)-3;
                          OutTextXY(x+2,GetMaxY-17,extrachar);
                          SetBackgroundMode('TRANSPARENT');
                        end;
if (shift_state) then begin
                       x:=x-GetApsInfo('guiplus','sizex')-3; 
                       if draw_undraw=1 then DrawApsXY('guiplus',x,GetMaxY-17);
                       x:=x-GetApsInfo('guishift','sizex');
                       if draw_undraw=1 then DrawApsXY('guishift',x,GetMaxY-17);
                      end;
if (alt_state) then begin
                       x:=x-GetApsInfo('guiplus','sizex')-3; 
                       if draw_undraw=1 then DrawApsXY('guiplus',x,GetMaxY-17);
                       x:=x-GetApsInfo('guialt','sizex');
                       if draw_undraw=1 then DrawApsXY('guialt',x,GetMaxY-17);
                      end; 
if (control_state) then begin
                       x:=x-GetApsInfo('guiplus','sizex')-3;
                       if draw_undraw=1 then DrawApsXY('guiplus',x,GetMaxY-17);
                       x:=x-GetApsInfo('guicontrol','sizex');
                       if draw_undraw=1 then DrawApsXY('guicontrol',x,GetMaxY-17);
                      end;
end;

end;


function shift_mask(what2mask:string):string;
var i:integer; 
begin
if Length(what2mask)>1 then what2mask:=Upcase2(what2mask) else
if Length(what2mask)=1 then begin 
                              case what2mask[1] of
                                '`' : what2mask:='~' ;
                                '0' : what2mask:=')' ;
                                '1' : what2mask:='!' ;
                                '2' : what2mask:='@' ;
                                '3' : what2mask:='#' ;
                                '4' : what2mask:='$' ;
                                '5' : what2mask:='%' ;
                                '6' : what2mask:='^' ;
                                '7' : what2mask:='&' ;
                                '8' : what2mask:='*' ;
                                '9' : what2mask:='(' ;
                                '-' : what2mask:='_' ;
                                '=' : what2mask:='+' ;
                                '[' : what2mask:='{' ;
                                ']' : what2mask:='}' ;
                                '\' : what2mask:='|' ;
                                ',' : what2mask:='<' ;
                                '.' : what2mask:='>' ;
                                '/' : what2mask:='?' ;
                                ';' : what2mask:=':' ;
                                chr(39) : what2mask:='"';
                              end; 
                              what2mask:=Upcase2(what2mask);
                            end;

shift_mask:=what2mask;
end;

function IgnoreTunas(bufstr1:string):string; // Afairei tous tonous apo kefalaia..
var retres:string;
    i:integer;
begin
retres:='';
if Length(bufstr1)>0 then begin
for i:=1 to Length(bufstr1) do begin
                                 if bufstr1[i]='¢' then retres:=retres+'A' else
                                 if bufstr1[i]='¸' then retres:=retres+'Å' else
                                 if bufstr1[i]='º' then retres:=retres+'É' else
                                 if bufstr1[i]='¼' then retres:=retres+'Ï' else
                                 if bufstr1[i]='¿' then retres:=retres+'Ù' else
                                 if bufstr1[i]='¾' then retres:=retres+'Õ' else
                                 if bufstr1[i]='¹' then retres:=retres+'Ç' else
                                 retres:=retres+bufstr1[i];
                               end;
                           end;
IgnoreTunas:=retres;
end;

procedure wait_clear_key(thekey:string);
var bufkey:string;
begin
bufkey:=thekey;
while bufkey=thekey do
       begin
        bufkey:=readkeyfast;
        sleep(pliktrologisi_speed);
       end;
end;


function text_handle_menu(x,y,MAX_EPILOGES:integer; arrayinp:array of string):integer;
const MAX_MAX_EPILOGES=100; 
var the_menu:array [1..MAX_MAX_EPILOGES] of string;// =('cut','copy','paste','delete','upcase','lowercase','flip','multiple','A-TECH');
    mousex,mousey,newmousex,newmousey,selection_x,selection_y,retaincolor,selection,last_selection:integer;
    borders:array[1..4]of integer;
    bufstr:string;
    i,z:integer;
    end_menu:boolean;
begin 
z:=0;
for i:=1 to MAX_EPILOGES do begin 
                             the_menu[i]:=arrayinp[i-1]; 
                             if TextWidth(the_menu[i])>z then z:=TextWidth(the_menu[i]);
                            end;
GUI_ChangeCursorIcon(mouse_icon_resource('ARROW'));
save_graph_window;
selection_y:=TextHeight('A');
selection_x:=z+4;
retaincolor:=TakeTextColor;
end_menu:=false;
TextColor(ConvertRGB(0,0,0));

if x<0 then x:=10 else
if x+selection_x+4>GetMaxX then x:=0-selection_x+GetMaxX-14;
if y<0 then y:=10 else
if (y+(selection_y*MAX_EPILOGES)>GetMaxY) then  y:=0-selection_y*MAX_EPILOGES+GetMaxY-14;

borders[1]:=x;
borders[2]:=y;
borders[3]:=x+selection_x+4;
borders[4]:=y+selection_y*MAX_EPILOGES; 

DrawRectangle2(borders[1],borders[2],borders[3],borders[4],colors[window_border],colors[window_background]);
for i:=1 to MAX_EPILOGES do begin
                             OutTextXY(borders[1]+2,borders[2]+selection_y*(i-1),the_menu[i]);
                            end;
last_selection:=-1; //Arxika gia na ginei draw i prwti epilogi..
selection:=-1;
repeat 
  newmousex:=GetMouseX;
  newmousey:=GetMouseY;
  if ((mousex<>newmousex) or (mousey<>newmousey) )then begin
                                                        mousex:=newmousex;
                                                        mousey:=newmousey;
                                                        selection:=(mousey-borders[2]) div selection_y;
                                                        selection:=selection+1;
                                                        if mousey<borders[2] then selection:=-1;
                                                       end;
  sleep(pliktrologisi_speed);
  bufstr:=Upcase(readkeyfast);
  if bufstr='UP ARROW' then begin
                             selection:=selection-1;
                             if selection<1 then selection:=MAX_EPILOGES; 
                             sleep(70);
                            end else
  if bufstr='DOWN ARROW' then begin
                               selection:=selection+1;
                               if selection>MAX_EPILOGES then selection:=1;
                               sleep(70);
                              end else
  if bufstr='ESCAPE' then begin
                            selection:=0;
                            end_menu:=true;
                          end else
  if  ((bufstr='ENTER') or (bufstr=' ')) then begin
                                               end_menu:=true;
                                              end;


  if last_selection<>selection then begin
                                    i:=last_selection;
                                    if ((i>=1) and (i<=MAX_EPILOGES)) then begin
                                    DrawRectangle2(borders[1]+1,borders[2]+selection_y*(i-1)+1,borders[3]-1,borders[2]+selection_y*(i)-1,colors[window_background],colors[window_background]);
                                    OutTextXY(borders[1]+2,borders[2]+selection_y*(i-1),the_menu[i]);
                                                                          end;
                                    i:=selection;
                                    if ((i>=1) and (i<=MAX_EPILOGES)) then begin
                                    DrawRectangle2(borders[1]+1,borders[2]+selection_y*(i-1)+1,borders[3]-1,borders[2]+selection_y*(i)-1,colors[menu_active],colors[menu_active]);
                                    TextColor(colors[menu_active_text]);
                                    OutTextXY(borders[1]+2,borders[2]+selection_y*(i-1),the_menu[i]);
                                    TextColor(ConvertRGB(0,0,0));
                                                                          end;
                                   end;
 if ((MouseButton(1)=1)) then
                         begin
                           if ((borders[1]<mousex) or (borders[2]<mousey) or (borders[3]>mousex) or (borders[4]>mousey)) then
                                        //Click Mesa sto box..
                                        begin
                                          //MessageBox (0, Pchar(Convert2String(selection)) , ' ', 0);
                                        end else
                                        begin
                                          selection:=0; 
                                        end; // Click Eksw apo to box..
                           end_menu:=true;
                          end;
 last_selection:=selection;
until end_menu;


load_graph_window;
MouseButton(1);
FlushMouseButtons;
TextColor(retaincolor);
//ChangeCursorIcon(mouse_icon_resource('TYPE'));
GUI_ChangeCursorIcon(mouse_icon_resource('ARROW'));
text_handle_menu:=selection;
end;

procedure text_tools(x,y:integer; var texttoalter:string);
const
  prepare_menu: array [1..9] of string =
    ('cut','copy','paste','delete','upcase','lowercase','flip','multiple','A-TECH');
var //prepare_menu:array [1..9] of string =('cut','copy','paste','delete','upcase','lowercase','flip','multiple','A-TECH');
    selection,last_selection:integer;
    bufstr:string;
begin
selection:=text_handle_menu(x,y,9,prepare_menu{,texttoalter});
if selection=1 then begin  //CUT
                     copypaste_mem:=texttoalter;
                     CopyToClipboard(copypaste_mem);
                     texttoalter:='';
                    end else
if selection=2 then begin  //COPY
                     copypaste_mem:=texttoalter; 
                     CopyToClipboard(copypaste_mem);
                    end else
if selection=3 then begin //PASTE 
                     texttoalter:=copypaste_mem;
                    end else
if selection=4 then begin //DELETE 
                     texttoalter:='';
                    end else
if selection=5 then begin //UPCASE 
                     texttoalter:=Upcase2(texttoalter);
                    end else
if selection=6 then begin //LOWERCASE 
                     texttoalter:=texttoalter;
                    end else
if selection=7 then begin //FLIP
                     bufstr:='';
                     for last_selection:=Length(texttoalter) downto 1 do bufstr:=bufstr+texttoalter[last_selection]; 
                     texttoalter:=bufstr;
                    end else
if selection=8 then begin //MULTIPLE
                     //
                    end; 
GUI_ChangeCursorIcon(mouse_icon_resource('TYPE'));
end;
 
function Suggest_Typing(typed:string):string;   //THELEI DOULEIA!
var done_suggesting:boolean;
    txtchk,wrd1,wrd2,chkstart1,chkstart2,i:integer;
    awrd,retres:string;
    resnum:integer;
    results:array[1..10] of string;
    results_score:array[1..10] of integer;

begin
retres:='';
done_suggesting:=false; 
resnum:=0;
if ((Length(typed)>=auto_complete_letter) and (dataloaded[9]>0)) then
   begin   //Auto_complete_letter , se posa grammata ksekinaei auto completion..
     txtchk:=1;
     while (txtchk<=dataloaded[9]) do
        begin
         awrd:=textmemory[txtchk];

  if awrd<>'' then
     begin //PROTECT FROM UNDERFLOW.. (KENI LEKSI PROTASI)
         wrd1:=0; // I leksi mas..
         wrd2:=1; // I leksi pou mporei na symplirwnei tin diki mas..
         chkstart1:=0;
         chkstart2:=0;
         repeat
          wrd1:=wrd1+1; 
          if wrd1>Length(typed) then begin
                                       MessageBox (0, 'YOU HAVE DETECTED A BUG!!FAST TEXT SYSTEM - TYPED OVERFLOW' , ' ', 0);
                                       Text_Memory('save','debug_fast.txt'); 
                                     end else
          if wrd2>Length(awrd) then begin
                                       {MessageBox (0, 'YOU HAVE DETECTED A BUG!!FAST TEXT SYSTEM - AWRD OVERFLOW' , ' ', 0);
                                       Text_Memory('save','debug_fast.txt');}
                                     end else
          if ((IgnoreTunas(Upcase2(typed[wrd1])))=IgnoreTunas(Upcase2(awrd[wrd2]))) then begin
                                                                                        if chkstart1=0 then begin
                                                                                                              chkstart1:=wrd1;
                                                                                                              chkstart2:=wrd2; //ekei pou arxizei to match..
                                                                                                            end;
                                                                                        wrd2:=wrd2+1;
                                                                                       end else
                                                                                       begin
                                                                                        chkstart1:=0; //den exoume match pleon..
                                                                                        chkstart2:=0; //den exoume match pleon..
                                                                                        wrd2:=1; 
                                                                                        retres:='';
                                                                                       end;
          if ((wrd2-chkstart2>1)) then begin
                                         retres:='';
                                         for i:=wrd2 to Length(awrd) do retres:=retres+awrd[i];
                                       end else retres:='';
         until ( {(done_suggesting) or (wrd2>=Length(awrd)) or} (wrd1>=Length(typed)) );
          if retres<>'' then begin
                              if resnum<10 then resnum:=resnum+1;
                              results[resnum]:=retres;
                              results_score[resnum]:=chkstart1;
                             { retres:=retres+' -  chkstart1='+Convert2String(chkstart1)+' , wrd1='+Convert2String(wrd1)+' chkstart2='+Convert2String(chkstart2)+' , wrd2='+Convert2String(wrd2);
                              retres:=retres+' ('+awrd+')'; }
                              if chkstart1=1 then break;
                             end;
        // if done_suggesting then break;
   end; //PROTECT FROM UNDERFLOW.. (KENI LEKSI PROTASI)
        txtchk:=txtchk+1;
       end;  
    end; 

if  resnum>0 then begin
                    chkstart1:=9999; //Best result..
                    for i:=1 to resnum do begin
                                           if results_score[resnum]<chkstart1 then begin
                                                                                     chkstart1:=results_score[resnum];
                                                                                     results_score[1]:=results_score[resnum];
                                                                                     results[1]:=results[resnum]; 
                                                                                   end;
                                          end;
                   retres:=results[1];
                   {retres:=retres+' -  chkstart1='+Convert2String(chkstart1)+' , wrd1='+Convert2String(wrd1)+' chkstart2='+Convert2String(chkstart2)+' , wrd2='+Convert2String(wrd2);
                   retres:=retres+' ('+awrd+')'; }
                  end;
//retres:=retres+' ('+typed+')';
Suggest_Typing:=retres;
end;

function ReadText2(startingtxt:string; sizelength:integer; masked:boolean):string;    //READ TEXT ME ENSWMATWMENI TIN GRIGORI PLIKTROLOGISI!
begin 
if advanced_read then ReadText2:=ReadTextGUI(startingtxt,sizelength,masked) else
                      ReadText2:=ReadTextGUI2(startingtxt,sizelength,masked);
end;

procedure prepare_sorted_space_swap_objects(objnum1,objnum2:integer);
var i1,i2:integer;
    bufstr:string;
begin
for i1:=1 to 8 do begin
                   bufstr:=objects[objnum1,i1];
                   objects[objnum1,i1]:=objects[objnum2,i1];
                   objects[objnum2,i1]:=bufstr;
                  end;
for i1:=1 to 6 do begin
                   i2:=objectsdat[objnum1,i1];
                   objectsdat[objnum1,i1]:=objectsdat[objnum2,i1];
                   objectsdat[objnum2,i1]:=i2;
                  end;
end;

function prepare_sorted_space(name:string):integer;
var left,right,pont,i,sorted:integer;
begin
dataloaded[1]:=dataloaded[1]+1;
objects[dataloaded[1],1]:=name; 
sorted:=dataloaded[1];
if (dataloaded[1]>1) and (enableturbo) then
begin
left:=2;
right:=dataloaded[1]-1;
pont:=0;
   while (left<right) do begin
                          for i:=right downto left do begin
                                                       if objects[i-1,1]>objects[i,1] then begin
                                                                                            prepare_sorted_space_swap_objects(i-1,i);  
                                                                                            pont:=i;
                                                                                           end;
                                                      end;
                          left:=pont;
                          for i:=left to right do    begin
                                                       if objects[i,1]>objects[i+1,1] then begin
                                                                                            prepare_sorted_space_swap_objects(i+1,i); 
                                                                                            pont:=i;
                                                                                           end;
                                                      end;
                          right:=pont;  
                        end;
sorted:=-1;
i:=1;
while (i<=dataloaded[1]) and (sorted=-1) do
                            begin
                             if objects[i,1]=name then sorted:=i;
                             i:=i+1;
                            end; 
end;
prepare_sorted_space:=sorted;
end;


function last_object():string;
begin
last_object:=objects[dataloaded[13],1];
end;

function last_object_activated():string;
begin
if ((dataloaded[14]>0) and (dataloaded[14]<=maxobjects)) then last_object_activated:=objects[dataloaded[14],1] else
                                                              last_object_activated:='';
end;

procedure flush_last_object_activated;
begin
dataloaded[14]:=0;
end;


procedure include_object(name,typeofobj,valueofobj,ownerwindow,soundofobj,cursor4obj:string; x1,y1,x2,y2:integer);
var flag1,centerx,add_wnd_x,needs_map,needs_add_objects:boolean;
    depth,added,tmp_x:integer;
begin
needs_map:=true;
centerx:=false;
add_wnd_x:=false;

if Equal(typeofobj,'WINDOWCONTROLS') then needs_add_objects:=false else
                                          needs_add_objects:=true;

if needs_add_objects then
begin
 added:=prepare_sorted_space(name);
 dataloaded[13]:=added;
 if dataloaded[7]=0 then dataloaded[7]:=added; //SAVE CRASH (NO FOCUS) , Gianna 14-07-06
 objects[added,1]:=name;
 objects[added,2]:=typeofobj;
 objects[added,3]:=valueofobj;
 objects[added,4]:=soundofobj;
 objects[added,5]:=cursor4obj;
 //6 krymeno extra 1
 objects[added,7]:=ownerwindow;
 objectsdat[added,1]:=x1;
 objectsdat[added,2]:=y1;
 objectsdat[added,3]:=x2;
 objectsdat[added,4]:=y2;
 objectsdat[added,6]:=convert_objecttype_string2int(typeofobj);
 if (x1=-1) and (x2=-1) then centerx:=true;  {An x1=-1 k x2=-1 tote to programma ta rithmizei aytomata oste na kentraristoun}

 if x1<-1 then x1:=0;
 if y1<-1 then y1:=0;
 if x2<-1 then x2:=0;
 if y2<-1 then y2:=0;
end;

if Equal(typeofobj,'WINDOWCONTROLS') then
               begin
                 needs_map:=false;
                 add_wnd_x:=true;
                end else
if Upcase(objects[added,2])='BUTTONCLP' then begin      //RYTHMISI Y2
                                              //objectsdat[added,4]:=y1+TextHeight(valueofobj);
                                             // objects[added,6]:=valueofobj;   {DYNATES EPILOGES!}
                                             // objects[added,3]:='1';
                                            //  objects[added,5]:='SELECT';
                                            objects[added,6]:=valueofobj;   {LABEL GIA TO KOUMPI!}
                                            objects[added,3]:='1';
                                            seperate_words_old(valueofobj);
                                            if memory[2]<>'' then
                                               begin
                                                if GetApsInfo(memory[2],'sizey')>10+y2-y1 then
                                                       begin
                                                         objectsdat[added,4]:=y1+GetApsInfo(memory[2],'sizey')+10;
                                                       end;
                                               end;
                                            end else
if Upcase(objects[added,2])='DROPDOWN' then begin      //RYTHMISI Y2
                                              objectsdat[added,4]:=y1+TextHeight(valueofobj);
                                              objects[added,6]:=valueofobj;   {DYNATES EPILOGES!}
                                              objects[added,3]:='1';
                                              objects[added,5]:='SELECT';
                                            end else
if Upcase(objects[added,2])='BORDER' then begin
                                           needs_map:=false;
                                          end else
if Upcase(objects[added,2])='PROGRESSBAR' then begin
                                                          objectsdat[added,4]:=y1+TextHeight(valueofobj);
                                                       end else
if Upcase(objects[added,2])='DATA' then begin
                                                 end else
if Upcase(objects[added,2])='LAYER' then begin
                                                 end else
if Upcase(objects[added,2])='ICON' then begin
                                                  seperate_words_old(objects[added,3]);
                                                  objects[added,8]:=memory[1];{ONOMA TIS APS ICON POU THA DEIXNEI!!!!!}
                                                  objects[added,3]:='1';
                                                  objects[added,6]:=memory[2]; {LABEL TIS EIKONAS}
                                                  objectsdat[added,3]:=objectsdat[added,1]+GetApsInfo(objects[added,3],'SIZEX');
                                                  objectsdat[added,4]:=objectsdat[added,2]+GetApsInfo(objects[added,3],'SIZEY');
                                                 end else
if Upcase(objects[added,2])='WINDOW' then begin 
                                                  objectsdat[added,5]:=0;{THE WINDOW IS NOT ACTIVE AT FIRST} 
                                                  add_wnd_x:=true;
                                                 end else
if Upcase(objects[added,2])='LABEL' then begin  {RITHMISI X2,Y2}
                                                  objectsdat[added,3]:=x1+TextWidth(valueofobj);
                                                  objectsdat[added,4]:=y1+TextHeight(valueofobj);
                                                 end else
if Upcase(objects[added,2])='COMMENT' then begin  {RITHMISI X2,Y2}
                                                  objectsdat[added,3]:=x1+TextWidth(valueofobj);
                                                  objectsdat[added,4]:=y1+TextHeight(valueofobj);
                                                 end else
if Upcase(objects[added,2])='TEXTBOX' then begin
                                                     objectsdat[added,4]:=8+y1+textheight('A');
                                                    end else
if Upcase(objects[added,2])='TEXTBOX-PASSWORD' then begin
                                                             objectsdat[added,4]:=8+y1+textheight('A');
                                                            end else
if Upcase(objects[added,2])='CHECKBOXL' then begin
                                                       objectsdat[added,3]:=x1+GetApsinfo('chkl1','sizex');
                                                       objectsdat[added,4]:=y1+GetApsinfo('chkl1','sizey');
                                                     end else
if Upcase(objects[added,2])='CHECKBOX' then begin
                                                       objectsdat[added,3]:=x1+GetApsinfo('chks1','sizex');
                                                       objectsdat[added,4]:=y1+GetApsinfo('chks1','sizey');
                                                     end else
if Upcase(objects[added,2])='BUTTON' then begin
                                                       objectsdat[added,3]:=x1+GetApsinfo('btns1','sizex');
                                                       objectsdat[added,4]:=y1+GetApsinfo('btns1','sizey');
                                                  end else
if Upcase(objects[added,2])='BUTTONC' then begin
                                                       {objectsdat[dataloaded[1],3]:=x1+74;}
                                                       if Textwidth(valueofobj)+20>44 then objectsdat[added,3]:=x1+Textwidth(valueofobj)+20 else
                                                                                  {TEST}   objectsdat[added,3]:=x1+44;
                                                       objectsdat[added,4]:=y1+23;
                                                       objects[added,6]:=valueofobj;   {LABEL GIA TO KOUMPI!}
                                                       objects[added,3]:='1';
                                                  end else
if Upcase(objects[added,2])='BUTTONL' then  begin
                                                       objectsdat[added,3]:=x1+GetApsinfo('btnl1','sizex');
                                                       objectsdat[added,4]:=y1+GetApsinfo('btnl1','sizey');
                                                    end else
if Upcase(objects[added,2])='BUTTONAPS' then  begin
                                               objects[added,6]:=objects[added,3];
                                               objectsdat[added,3]:=x1+GetApsinfo(objects[added,3]+'0','sizex'); //Ypotithetai oti einai loaded 2 APS (objects[added,3]+'0' kai objects[added,3]+'1')
                                               objectsdat[added,4]:=y1+GetApsinfo(objects[added,3]+'0','sizey');
                                               objects[added,3]:='1'; 
                                             end;
if centerx=true then begin   {Kentrarisma ston aksona twn X}
                      depth:=objectsdat[added,3]-objectsdat[added,1]; {Tsigounia metavlitwn}
                      objectsdat[added,1]:=(GetMaxX-depth) div 2;
                      objectsdat[added,3]:=objectsdat[added,1]+depth;
                     end;

if needs_map then Map_Object(added); //New Mapping 24-4-2006

if add_wnd_x then begin
                   depth:=y1+((GetApsInfo('upmiddle2','sizey')-GetApsInfo('btnexit','sizey')) div 2);      //GIA NA DOULEVEI TO X TOU PARATHIROU..
                   include_object('wnd_exit','layer','1','','','SELECT',x2-GetApsInfo('upright','sizex')-GetApsInfo('btnexit','sizex'),depth,x2-GetApsInfo('upright','sizex'),depth+GetApsInfo('btnexit','sizey'));
                   //seperate_words(objects[added,1]);
                   //if Equal(get_memory(1),'main_window') then
                   if ((Equal(objects[added,1],'main_window')) or (Equal(typeofobj,'WINDOWCONTROLS')) ) then
                         begin
                        tmp_x:=x2-GetApsInfo('upright','sizex')-GetApsInfo('btnexit','sizex')-2-GetApsInfo('btnmaximize','sizex')-2-GetApsInfo('btnminimize','sizex')-2;
                        include_object('movehandle','MAINWINDOWMOVE','1','','','SELECT',x1,y1,tmp_x-2,depth+GetApsInfo('btnexit','sizey'));
                        include_object('wnd_minimize','layer','1','','','SELECT',tmp_x,depth,tmp_x+GetApsInfo('btnminimize','sizex'),depth+GetApsInfo('btnminimize','sizey'));
                        dataloaded[15]:=1; //SIGNAL OTI YPARXEI MAIN WINDOW
                        end;
                   dataloaded[13]:=added;
                  end;

end;

function delete_object(name,numname:string):boolean;
var objnum,z2,z:integer;
begin
z2:=1;
objnum:=-1;
if Equal(numname,'WINDOW') then z2:=7 else
if Equal(numname,'OWNINGWINDOW') then z2:=7 else
if Equal(numname,'NAME') then z2:=1;
 if dataloaded[1]>0 then
    begin
     for z:=1 to dataloaded[1] do if Equal(objects[z,z2],name) then objnum:=z;
    end;


if objnum<>-1 then begin
                    Remove_Map_Object(objnum);
                    for z:=1 to 8 do objects[objnum,z]:='';
                    for z:=objectsdat[objnum,1] to objectsdat[objnum,3] do
                    for z2:=1 to map[z,101] do begin
                                                if map[z,z2]=objnum then map[z,z2]:=0;
                                                {Mporei na ginei pio grigora alla tha prepei na ginei
                                                oposdipote etsi an sto melon kano compacting sto map!}
                                               end;
                    for z:=1 to 6 do objectsdat[objnum,z]:=0;
                   end;
if objnum=-1 then delete_object:=false else
                  delete_object:=true;
end;

procedure draw_mem_text;
var x:integer;
begin
for x:=1 to dataloaded[1] do outtextcenter(objects[x,1]+' '+objects[x,2]+' '+objects[x,3]);
end;

procedure draw_mem; //DEVELOP - ZVGRAFIZEI STIN OTHONI TA FORTOMENA ANTIKEIMENA ME KOKKINES GRAMMES
var x,x2:integer;
begin
{for x:=1 to maxresolutionx do
for x2:=1 to 100 do if map[x,x2]<>0 then drawline(x,(x2-1)*7,x,(x2)*7,ConvertRGB(255,0,0));
outtextxy(5,5,Convert2String(dataloaded[1])+' Objects');
outtextxy(5,5+TextHeight('A'),'Depth of map is '+Convert2String(dataloaded[8]));
outtextxy(5,5+2*TextHeight('A'),'Enviroment directory '+enviromentdir);         }
for x:=1 to GetMaxX do
 for x2:=1 to GetMaxY do
  if full_map[x,x2]>start_map then PutPixel(x,x2,ConvertRGB(255,0,0));
    
//dataloaded:array[1..11]of integer;   {6=FASTTEXTBOXCHANGE 7=FOCUS 8=Depth of map 9=textmemory pointer 10=activate object 11=Shortcuts on/off 1/0}
    
end; 



function get_object_number(name:string):integer;  //Epistrefei to noumero tou array pou kouvalaei to Object   -1 alliws..
var objnum,z:integer;
begin
if obj_prediction=name then begin
                             objnum:=obj_pred_int; //An to antikeimeno itan to teleytaio thimomaste poio itan..
                            end else
                            begin
                             objnum:=-1;
                            end;
if objnum=-1 then begin
                   for z:=1 to dataloaded[1] do if Equal(objects[z,1],name) then objnum:=z;
                  end;
get_object_number:=objnum;

obj_prediction:=name;
obj_pred_int:=objnum;
end;

function get_object_total_number:integer;
begin
get_object_total_number:=dataloaded[1];
end;

function get_number_object (thenum:integer):string;
var retres:string;
begin
if get_object_total_number<=thenum then retres:=objects[thenum,1] else
                                        retres:='';
get_number_object:=retres;
end;


function get_object_size(name,typ:string):integer; //TO MEGETHOS ENOS ANTIKEIMENOU
var objnum,z:integer;
begin


objnum:=get_object_number(name);

if objnum<>-1 then begin
                    if Upcase(typ)='X' then get_object_size:=objectsdat[objnum,3]-objectsdat[objnum,1] else
                    if Upcase(typ)='Y' then get_object_size:=objectsdat[objnum,4]-objectsdat[objnum,2] else
                    if Upcase(typ)='X1' then get_object_size:=objectsdat[objnum,1] else
                    if Upcase(typ)='Y1' then get_object_size:=objectsdat[objnum,2] else
                    if Upcase(typ)='X2' then get_object_size:=objectsdat[objnum,3] else
                    if Upcase(typ)='Y2' then get_object_size:=objectsdat[objnum,4] else
                                            get_object_size:=-1;
                   end else
                   get_object_size:=-1;


end;

function X1(name:string):integer;
begin
X1:=get_object_size(name,'X1');
end;

function Y1(name:string):integer;
begin
Y1:=get_object_size(name,'Y1');
end;

function X2(name:string):integer;
begin
X2:=get_object_size(name,'X2');
end;

function Y2(name:string):integer;
begin
Y2:=get_object_size(name,'Y2');
end;



function get_object_data(name:string):string; //OI PLIROFORIES POU KOUVALAEI ENA ANTIKEIMENO
var objnum,z:integer;
begin
objnum:=-1;
for z:=1 to dataloaded[1] do if Upcase(objects[z,1])=Upcase(name) then objnum:=z;
if objnum<>-1 then get_object_data:=objects[objnum,3] else
                   get_object_data:='';
end;


function GUI_Exit:boolean;
var retres:boolean;
begin
retres:=false;
if get_object_data('exit')='4' then retres:=true;
if get_object_data('wnd_exit')='4' then retres:=true;
GUI_Exit:=retres;
end;


procedure GUI_Exit_disarm;
begin
set_object_data('exit','value','1',1);
set_object_data('wnd_exit','value','1',1);
end;

function set_object_data(name,datas,thevalue:string; datai:integer):string; //ALLAGI STIS PLIROFORIES POU KOUVALAEI ENA ANTIKEIMENO
var objnum,z:integer;
begin
objnum:=-1;
for z:=1 to dataloaded[1] do if Upcase(objects[z,1])=Upcase(name) then objnum:=z;
if objnum<>-1 then begin
                    if Upcase(datas)='X1' then objectsdat[objnum,1]:=datai else
                    if Upcase(datas)='Y1' then objectsdat[objnum,2]:=datai else
                    if Upcase(datas)='X2' then objectsdat[objnum,3]:=datai else
                    if Upcase(datas)='Y2' then objectsdat[objnum,4]:=datai else
                    if Upcase(datas)='EXTRA2' then objectsdat[objnum,5]:=datai else
                    if Upcase(datas)='NAME' then objects[objnum,1]:=thevalue else
                    if Upcase(datas)='TYPE' then objects[objnum,2]:=thevalue else
                    if Upcase(datas)='VALUE' then objects[objnum,3]:=thevalue else
                    if Upcase(datas)='SOUND' then objects[objnum,4]:=thevalue else
                    if Upcase(datas)='CURSOR' then objects[objnum,5]:=thevalue else
                    if Upcase(datas)='EXTRA1' then objects[objnum,6]:=thevalue else
                    if Upcase(datas)='OWNINGWINDOW' then objects[objnum,7]:=thevalue;
                   end;
set_object_data:=thevalue;
end;

function get_object_data_full(name,datas:string):string; //ANAKTISI PLIROFORIES POU KOUVALAEI ENA ANTIKEIMENO
var objnum,z:integer;
    thevalue:string;
begin
objnum:=-1;
thevalue:='';
for z:=1 to dataloaded[1] do if Upcase(objects[z,1])=Upcase(name) then objnum:=z;
if objnum<>-1 then begin
                    if Upcase(datas)='NAME' then thevalue:=objects[objnum,1] else
                    if Upcase(datas)='TYPE' then thevalue:=objects[objnum,2] else
                    if Upcase(datas)='VALUE' then thevalue:=objects[objnum,3] else
                    if Upcase(datas)='SOUND' then thevalue:=objects[objnum,4] else
                    if Upcase(datas)='CURSOR' then thevalue:=objects[objnum,5] else
                    if Upcase(datas)='EXTRA1' then thevalue:=objects[objnum,6] else
                    if Upcase(datas)='OWNINGWINDOW' then thevalue:=objects[objnum,7];
                   end;
get_object_data_full:=thevalue;
end;

procedure set_button(btnname:string; what:integer);
begin
if (objectsdat[get_object_number(btnname),6]=obj_buttonc) or (objectsdat[get_object_number(btnname),6]=obj_layer) or (objectsdat[get_object_number(btnname),6]=obj_buttonaps)then
begin
if what=0 then set_object_data(btnname,'VALUE','1',1) else
if (what=1) and (objectsdat[get_object_number(btnname),6]=obj_buttonc) then set_object_data(btnname,'VALUE','4',4) else
                                                                            set_object_data(btnname,'VALUE','3',3);
end;
end;


procedure set_gui_color(thecolor:integer; what:string);
begin

what:=Upcase(what);                                    //
if (Equal(what,'COMMENT')) or (Equal(what,'LABEL')) then colors[comments_color]:=thecolor else
                                                     begin
                                                     end;

end;


procedure draw_window; {Tetragono gyro apo tin othoni}
begin
SetLineSettings(5,5,5);
DrawLine(1,1,GetMaxX,1,ConvertRGB(0,0,255));
DrawLine(GetMaxX-4,1,GetMaxX-4,GetMaxY,ConvertRGB(0,0,255));
DrawLine(GetMaxX,GetMaxY-4,1,GetMaxY-4,ConvertRGB(0,0,255));
DrawLine(1,GetMaxY,1,1,ConvertRGB(0,0,255));
SetLineSettings(1,1,1);
end;






procedure draw_btncustom(value,text:string; x1,y1,x2,y2:integer);
var valuetmp:string;
    sbtx,sbty,x,szxtmp,y,theclr,aclr:integer;
begin
aclr:=TakeTextColor;
valuetmp:='1'; 
if value='1' then valuetmp:='1' else
if value='2' then valuetmp:='2' else
if value='3' then valuetmp:='3' else
if value='4' then valuetmp:='4' else
outtextcenter('Error in value of button !');
sbtx:=x2-x1;
sbty:=y2-y1;
//DrawRectangle2(x1,y1,x1+sbtx,y1+sbty,GetBackgroundColor,GetBackgroundColor);
if value='3' then begin
                    szxtmp:=GetApsInfo('btncleftlight','sizex');
                    for y:=1 to GetApsInfo('btncmainlight','sizey')+1 do
                     begin
                       theclr:=GetApsPixelColor(GetApsInfo('btncmainlight','x')+1,y+GetApsInfo('btncmainlight','y'));
                       DrawLine(x1+szxtmp,y+y1,x2-szxtmp+1,y+y1,theclr);
                     end;

                   DrawAPSXY('btncleftlight',x1,y1);
                   DrawAPSXY('btncrightlight',x2-szxtmp,y1);

                    TextColor(ConvertRGB(0,0,0));
                    {if sbtx<>74 then OuttextXY(x1+10,y1+2,text) else
                                     OuttextXY(x1+17,y1+2,text); }
                    sbty:=x2-x1-TextWidth(text);
                    if sbty<=0 then sbty:=0 else
                                    sbty:=sbty div 2;
                    OuttextXY(x1+sbty+1,y1+2,text); {TO +1 to exw balei gia effect kai kala pros ta mesa :-)}
                    TextColor(ConvertRGB(255,255,255));
                  end else
                 begin
                  {orizontia}
                   {for x:=1 to 1024 do
                    for y:=1 to 1024 do
                     PutPixel(x,y,GetApsPixelColor(x,y));

                     PutPixel(GetApsInfo('btncmain','x'),GetApsInfo('btncmain','y'),ConvertRGB(255,0,0));
                    readkey; }

                    szxtmp:=GetApsInfo('btncleft','sizex');
                    for y:=1 to GetApsInfo('btncmain','sizey')+1 do
                     begin
                       theclr:=GetApsPixelColor(GetApsInfo('btncmain','x')+1,y+GetApsInfo('btncmain','y'));
                       DrawLine(x1+szxtmp,y+y1,x2-szxtmp+1,y+y1,theclr);
                     end;

                   DrawAPSXY('btncleft',x1,y1);
                   DrawAPSXY('btncright',x2-szxtmp,y1);

                  {katheta} 
                   if value='1' then TextColor(colors[button_text_skin]) else
                   if value='4' then TextColor(colors[button_activated_text_skin]) else
                   if value='2' then TextColor(colors[button_active_text_skin]);
                   {if sbtx<>74 then OuttextXY(x1+10,y1+2,text) else
                                    OuttextXY(x1+17,y1+2,text); }
                   {sbty tsigounia metavlitis, Prosoxi na min xrisimopoieitai parakato !!!!!!!}
                   sbty:=x2-x1-TextWidth(text);
                   if sbty<=0 then sbty:=0 else
                                   sbty:=sbty div 2;
                   OuttextXY(x1+sbty,y1+2,text);
                   TextColor(ConvertRGB(255,255,255));
                 end;
TextColor(aclr);
end;









procedure draw_btncustom_old(value,text:string; x1,y1,x2,y2:integer);
var valuetmp:string;
    sbtx,sbty:integer;
begin
if old_style_buttons then
      begin
        draw_btncustom(value,text,x1,y1,x2,y2);
      end else
      begin
valuetmp:='1'; 
if value='1' then valuetmp:='1' else
if value='2' then valuetmp:='2' else
if value='3' then valuetmp:='3' else
if value='4' then valuetmp:='4' else
outtextcenter('Error in value of button !');
sbtx:=x2-x1;
sbty:=y2-y1;
//DrawRectangle2(x1,y1,x1+sbtx,y1+sbty,GetBackgroundColor,GetBackgroundColor);
DrawRectangle2(x1,y1,x1+sbtx,y1+sbty,ConvertRGB(192,192,192),ConvertRGB(192,192,192));
if value='3' then begin
                   {orizontia}
                    DrawLine(x1,y1,x1+sbtx,y1,ConvertRGB(0,0,0));
                    DrawLine(x1,y1+1,x1+sbtx,y1+1,ConvertRGB(128,128,128));
                    DrawLine(x1,y1+sbty-1,x1+sbtx,y1+sbty-1,ConvertRGB(128,128,128));
                    DrawLine(x1,y1+sbty,x1+sbtx,y1+sbty,ConvertRGB(0,0,0));
                   {katheta}
                    DrawLine(x1,y1,x1,y1+sbty,ConvertRGB(0,0,0));
                    DrawLine(x1+1,y1+1,x1+1,y1+sbty-1,ConvertRGB(128,128,128));
                    DrawLine(x1+sbtx-1,y1+1,x1+sbtx-1,y1+sbty-1,ConvertRGB(128,128,128));
                    DrawLine(x1+sbtx,y1,x1+sbtx,y1+sbty,ConvertRGB(0,0,0));
                    TextColor(ConvertRGB(0,0,0));
                    {if sbtx<>74 then OuttextXY(x1+10,y1+2,text) else
                                     OuttextXY(x1+17,y1+2,text); }
                    sbty:=x2-x1-TextWidth(text);
                    if sbty<=0 then sbty:=0 else
                                    sbty:=sbty div 2;
                    OuttextXY(x1+sbty+1,y1+2,text); {TO +1 to exw balei gia effect kai kala pros ta mesa :-)}
                    TextColor(ConvertRGB(255,255,255));
                  end else
                 begin
                  {orizontia}
                   DrawLine(x1,y1,x1+sbtx,y1,ConvertRGB(255,255,255));
                   DrawLine(x1+1,y1+1,x1+sbtx-2,y1+1,ConvertRGB(223,223,223));
                   DrawLine(x1+1,y1+sbty-1,x1+sbtx-1,y1+sbty-1,ConvertRGB(128,128,128));
                   DrawLine(x1,y1+sbty,x1+sbtx,y1+sbty,ConvertRGB(0,0,0));
                  {katheta}
                   DrawLine(x1,y1,x1,y1+sbty-1,ConvertRGB(255,255,255));
                   DrawLine(x1+1,y1+1,x1+1,y1+sbty-2,ConvertRGB(223,223,223));
                   DrawLine(x1+sbtx-1,y1+1,x1+sbtx-1,y1+sbty-2,ConvertRGB(128,128,128));
                   DrawLine(x1+sbtx,y1,x1+sbtx,y1+sbty,ConvertRGB(0,0,0));
                   if value='1' then TextColor(colors[button_text]) else
                   if value='4' then TextColor(colors[button_activated_text]) else
                   if value='2' then TextColor(colors[button_active_text]);
                   {if sbtx<>74 then OuttextXY(x1+10,y1+2,text) else
                                    OuttextXY(x1+17,y1+2,text); }
                   {sbty tsigounia metavlitis, Prosoxi na min xrisimopoieitai parakato !!!!!!!}
                   sbty:=x2-x1-TextWidth(text);
                   if sbty<=0 then sbty:=0 else
                                   sbty:=sbty div 2;
                   OuttextXY(x1+sbty,y1+2,text);
                   TextColor(ConvertRGB(255,255,255));
                 end;
     end;
end;

procedure draw_btn(size,value:string; x1,y1:integer);
var sizetmp,valuetmp:string;
begin
sizetmp:='s';
valuetmp:='1';
if Upcase(size)='LARGE' then sizetmp:='l' else
if Upcase(size)='SMALL' then sizetmp:='s' else
outtextcenter('Error in size of button !');
if value='1' then valuetmp:='1' else
if value='2' then valuetmp:='2' else
if value='3' then valuetmp:='3' else
outtextcenter('Error in value of button !');
{DrawRectangle2(x1,y1,x1+GetApsinfo('btn'+sizetmp+valuetmp,'sizex'),y1+GetApsinfo('btn'+sizetmp+valuetmp,'sizey'),ConvertRGB(0,0,0),ConvertRGB(0,0,0));
}
UndrawApsXY('btn'+sizetmp+valuetmp,x1,y1,ConvertRGB(0,0,0));
DrawApsXY('btn'+sizetmp+valuetmp,x1,y1);
end;

procedure draw_btnaps(value,apsname:string;  x1,y1:integer);
begin
if (value='4') or (value='3') or (value='2') then DrawApsXY2(apsname+'1',x1,y1) else
if (value='1') then DrawApsXY2(apsname+'0',x1,y1);
end;

procedure draw_chk(size,value:string; x1,y1:integer);
var sizetmp,valuetmp:string;
begin
sizetmp:='s';
valuetmp:='1';
if Upcase(size)='LARGE' then sizetmp:='l' else
if Upcase(size)='SMALL' then sizetmp:='s' else
outtextcenter('Error in size of check-button !');
if value='1' then valuetmp:='1' else
if value='2' then valuetmp:='2' else
if value='3' then valuetmp:='3' else
outtextcenter('Error in value of check-button !');
//DrawRectangle2(x1,y1,x1+GetApsinfo('chk'+sizetmp+valuetmp,'sizex'),y1+GetApsinfo('chk'+sizetmp+valuetmp,'sizey'),ConvertRGB(0,0,0),ConvertRGB(0,0,0));
DrawApsXY('chk'+sizetmp+valuetmp,x1,y1);
end;

procedure draw_progressbar(value:string; x1,y1,x2,y2:integer);
var percnt,tmpint,retaincolor:integer;
begin
retaincolor:=TakeTextColor;
//TextColor(dataloaded[12]);
TextColor(ConvertRGB(255,255,255));
SetLineSettings(0,0,4);
DrawRectangle2(x1,y1,x2,8+y1+textheight('A'),ConvertRGB(0,0,0),ConvertRGB(0,0,0));
DrawRectangle(x1,y1,x2,8+y1+textheight('A'),ConvertRGB(44,0,255));

OuttextXY(x1+((x2-x1)-TextWidth(value+'%'))div 2+4,y1+4,value+'%');
SetLineSettings(0,0,1);
Val(value,percnt,tmpint);
if percnt<0   then percnt:=0;
if percnt>100 then percnt:=100;

if (percnt>0) and ((x1+4)<(x1+(percnt*(x2-x1) div 100)-4)) then
DrawRectangle2(x1+4,y1+3,x1+(percnt*(x2-x1) div 100)-4,4+y1+textheight('A'),ConvertRGB(255,0,0),ConvertRGB(255,0,0));
sleep(1);
readkeyfast;
OuttextXY(x1+((x2-x1)-TextWidth(value+'%'))div 2+4,y1+4,value+'%');
//DEN KANOUN WRITE TA ILITHIA WINDOWS GIA AYTO YPARXOUN OI 2 PARAKATW GRAMMES!
MouseButton(1);
sleep(1);
TextColor(retaincolor);
end;

procedure draw_field(value:string; x1,y1,x2,y2:integer);
var i,z,calcsize:integer;
    bufstr:string;
begin
SetLineSettings(0,0,metrics[1]); 
DrawRectangle2(x1,y1,x2,8+y1+textheight('A'),colors[textbox_in],colors[textbox_in]);
DrawRectangle(x1,y1,x2,8+y1+textheight('A'),colors[textbox_out]);
SetLineSettings(0,0,1);

if Length(value)>0 then
  begin
   i:=TakeTextColor;
   TextColor(colors[textbox_text]);


   if TextWidth(value)<x2-x1-5 then bufstr:=value else
           begin
            calcsize:=0;
            bufstr:='';
            z:=1;
            while z<=Length(value) do
                    begin
                        if x2-x1-5>calcsize+TextWidth(value[z]) then begin
                                                                    bufstr:=bufstr+value[z];
                                                                    calcsize:=calcsize+TextWidth(value[z]);
                                                                   end
                                                                   else break;
                        z:=z+1;
                    end;
            end; 
   OuttextXY(x1+4,y1+4,bufstr);
   TextColor(i);
  end;
end;

procedure draw_border(title:string; ax1,ay1,ax2,ay2:integer);
var thecol,acol,aspot,aht:integer;
begin
thecol:=colors[window_border];//ConvertRGB(116,127,155);
aspot:=ax1+(ax2-ax1) div 9;
aht:=TextHeight('A') div 2;
//Panw Aristera
DrawLine(ax1,ay1,aspot,ay1,thecol);
DrawLine(aspot,ay1,aspot,ay1-aht,thecol);
DrawLine(aspot,ay1,aspot,ay1+aht,thecol);
//Keimeno
acol:=TakeTextColor;
TextColor(colors[comments_color]);
OutTextXY(aspot+2,ay1-aht,title);
TextColor(acol);
//Panw Deksia
aspot:=aspot+4+TextWidth(title);
DrawLine(aspot,ay1,aspot,ay1-aht,thecol);
DrawLine(aspot,ay1,aspot,ay1+aht,thecol);
DrawLine(aspot,ay1,ax2,ay1,thecol);


//Katw tetragwno
DrawLine(ax1,ay1,ax1,ay2,thecol);
DrawLine(ax2,ay1,ax2,ay2,thecol);
DrawLine(ax1,ay2,ax2,ay2,thecol);
end;


function StringShrink(thestr:string; thepix:integer):string;
var tmpstr:string;
    xsize,letter,totlet:integer;
begin
tmpstr:='';
xsize:=0;
totlet:=Length(thestr);
letter:=1;
while ((xsize<thepix) and (letter<=totlet) ) do
  begin
   xsize:=xsize+TextWidth(thestr[letter]);
   tmpstr:=tmpstr+thestr[letter];
   letter:=letter+1;
  end; 
if ((Length(tmpstr)>2) and (Length(tmpstr)<>totlet)) then
                         begin
                          tmpstr[Length(tmpstr)]:='.';
                          tmpstr[Length(tmpstr)-1]:='.';
                         end;
StringShrink:=tmpstr;
end;
 
  
procedure draw_dropdown(selection,listofstuff:string; ax1,ay1,ax2,ay2:integer);
var i,sel,z,bx1,bx2,retaincolor:integer;
begin
SetLineSettings(0,0,2);
DrawRectangle2(ax1,ay1,ax2,ay1+GetApsInfo('btncmain','sizey')+2,ConvertRGB(44,0,255),ConvertRGB(0,0,0));
ay2:=ay1+TextHeight('A')+2;
z:=GetApsInfo('btncleft','sizey') div 5;
i:=GetApsInfo('btncleft','sizex');
draw_btncustom('1','   ',ax2-30,ay1,ax2-2,ay2);
bx1:=ax2-30+GetApsInfo('btncleft','sizex')+3;
//bx2:=ax2-30+GetApsInfo('btncleft','sizex')+3;
DrawLine(bx1,ay1+z+2,bx1+6,ay2-z+2,ConvertRGB(255,255,255));
DrawLine(bx1+6,ay2-z+2,ax2-i-1,ay1+z+2,ConvertRGB(255,255,255));
SetLineSettings(0,0,1);
i:=seperate_words_old(listofstuff);
Val(selection,sel,bx1);
z:=(ay2-ay1-TextHeight('A')) div 2;
retaincolor:=TakeTextColor;
TextColor(colors[textbox_text]);
if ((sel>i) or (sel>seperate_words_strength) ) then OutTextXY(ax1+3,ay1+z+3,'Error') else
              OutTextXY(ax1+3,ay1+z+3,StringShrink(memory[sel],ax2-30-ax1)); 
TextColor(retaincolor);
end;

function draw_dropdown_selections(objid:integer):string;
var objlist:array[1..255] of string;
    i,sel,z:integer;
begin  
i:=seperate_words_old(objects[objid,6]);
Val(objects[objid,3],sel,z);
for z:=1 to i do
  begin
    objlist[z]:=memory[z];
  end;
WaitClearMouseButton(1);
draw_dropdown_selections:=Convert2String(text_handle_menu(objectsdat[objid,1],objectsdat[objid,4]+2,i,objlist)); 
end;

procedure draw_text_area(value:string; x1,y1,x2,y2:integer);
var i,y,sy,siz:integer;
    retaincolor:integer;
    tmp_str:string;
    label end_draw;
begin 
if Length(value)<1 then goto end_draw;

retaincolor:=TakeTextColor;
TextColor(colors[comments_color]);
i:=1;
siz:=0;
tmp_str:='';
y:=y1;
while i<=Length(value) do
 begin
  tmp_str:=tmp_str+value[i];
  siz:=siz+TextWidth(value[i]);
  if siz+10>x2-x1 then
   begin
      sy:=TextHeight(tmp_str);
      OutTextXY(x1,y,tmp_str);
      tmp_str:='';
      siz:=0;
      y:=y+sy;
   end;
   i:=i+1; 
 end;
OutTextXY(x1,y,tmp_str); 
TextColor(retaincolor);
GotoXY(x1,y);
end_draw:
end;



procedure draw_password_field(value:string; x1,y1,x2,y2:integer);
var i:integer;
begin
SetLineSettings(0,0,metrics[1]);
DrawRectangle2(x1,y1,x2,8+y1+textheight('A'),colors[textbox_in],colors[textbox_in]);
DrawRectangle(x1,y1,x2,8+y1+textheight('A'),colors[textbox_out]);
SetLineSettings(0,0,1);
if Length(value)>0 then begin
                         i:=TakeTextColor;
                         TextColor(colors[textbox_text]);
                         for i:=1 to Length(value) do
                           OuttextXY(x1+4+(i-1)*TextWidth('*'),y1+4,'*');
                         TextColor(i);
                        end;

end;

procedure draw_label(value:string; x1,y1:integer);
var retaincolor:integer;
begin
retaincolor:=TakeTextColor;
TextColor(colors[comments_color]); //2 anti gia comments_color
OuttextXY(x1,y1,value);
TextColor(retaincolor);
end;

procedure Draw_a_Window_old(title1:string; active,x,y,sizex1,sizey1:integer);
var tmpx,tmpy,borderx,bordery,realsizex,realsizey:integer;
    sizeup1,sizeup2,sizeright,sizeleft,sizedown:integer;
    sizex,sizey,b:integer;  {b anti gia i}
    title,upmiddle,middleleft,uptransection,downleft,upleft:string;
begin
if active=1 then begin {KAthorismos ton eikonon analoga me to an to parathiro einai energo}
                  upmiddle:='upmiddle';
                  middleleft:='middleleft';
                  uptransection:='uptransection';
                  downleft:='downleft';
                  upleft:='upleft';
                 end else
                 begin
                  upmiddle:='up2middle';
                  middleleft:='middle2left';
                  uptransection:='up2transection';
                  downleft:='down2left';
                  upleft:='up2left';
                 end;

sizeup2:=(GetApsInfo('btnminimize','SIZEX')+GetApsInfo('btnmaximize','SIZEX')+GetApsInfo('btnmaximize','SIZEX')) div GetApsInfo('upmiddle2','SIZEX'); 
sizeup2:=sizeup2+3;
{To sizex einai to megethos tou kyrios tmimatos tis mparas (upmiddle)}
sizex:=sizex1-GetApsInfo(upleft,'SIZEX')-GetApsInfo(uptransection,'SIZEX')-GetApsInfo('upright','SIZEX')-sizeup2*GetApsInfo('upmiddle2','SIZEX');
sizey:=sizey1-GetApsInfo('upright','SIZEY')-GetApsInfo('downright','SIZEY');
{Fores pou epanalamvanontai oi eikones}
sizeup1:=sizex div GetApsInfo(upmiddle,'SIZEX');
title:='';
if TextWidth(title1)>sizex then begin  {Na xoraei o titlos}
                                 tmpx:=(TextWidth(title1)-sizex) div TextWidth('A');
                                 tmpx:=Length(title1)-tmpx-2;
                                 if tmpx>1 then title:=Copy(title1,1,tmpx);
                                 title:=String(title+'..');
                                end else
                                title:=title1;
sizeright:=sizey div GetApsInfo('middleright','SIZEY');
realsizex:=GetApsInfo(upleft,'SIZEX')+sizeup1*GetApsInfo(upmiddle,'SIZEX')+GetApsInfo(uptransection,'SIZEX')+sizeup2*GetApsInfo('upmiddle2','SIZEX')+GetApsInfo('upright','SIZEX');
realsizey:=GetApsInfo('upright','SIZEY')+sizeright*GetApsInfo('middleright','SIZEY')+GetApsInfo('downright','SIZEY');
sizeleft:=(sizey-GetApsInfo(downleft,'SIZEY')) div GetApsInfo(middleleft,'SIZEY');
sizeleft:=sizeleft+3;
sizedown:=(realsizex-GetApsInfo(downleft,'SIZEX')-GetApsInfo('downright','SIZEX')) div GetApsInfo('downmiddle','SIZEX');

{Background tou parathirou}
DrawRectangle2(x+{7}GetApsInfo(middleleft,'SIZEX')+2,y+{29}GetApsInfo(upleft,'SIZEY')+1,x+realsizex-GetApsInfo('middleright','SIZEX'){4},y+realsizey-GetApsInfo('downmiddle','SIZEY'){4},ConvertRGB(208,219,241),ConvertRGB(208,219,241));

{Oi akres tou parathirou}
DrawApsXY(upleft,x,y);
borderx:=GetApsInfo(upleft,'SIZEX');
for b:=1 to sizeup1 do begin
                     DrawApsXY(upmiddle,x+borderx+(b-1)*GetApsInfo(upmiddle,'SIZEX'),y);
                    end;
borderx:=borderx+sizeup1*GetApsInfo(upmiddle,'SIZEX');

{O Titlos}
OutTextXY(x+GetApsInfo(upleft,'SIZEX')+1,y+(GetApsInfo(upmiddle,'SIZEY')-TextHeight('A')) div 2,title);

{Ypoloipes akres tou parathirou}
DrawApsXY(uptransection,x+borderx,y);
borderx:=borderx+GetApsInfo(uptransection,'SIZEX');

for b:=1 to sizeup2 do DrawApsXY('upmiddle2',x+borderx+(b-1)*GetApsInfo('upmiddle2','SIZEX'),y);
borderx:=borderx+sizeup2*GetApsInfo('upmiddle2','SIZEX');

DrawApsXY('upright',x+borderx,y);
borderx:=borderx+GetApsInfo('upright','SIZEX');
bordery:=GetApsInfo('upright','SIZEY');

for b:=1 to sizeright do begin
                     DrawApsXY('middleright',x+borderx-GetApsInfo('middleright','SIZEX'),y+bordery+(b-1)*GetApsInfo('middleright','SIZEY'));
                    end; 
bordery:=bordery+sizeright*GetApsInfo('middleright','SIZEY');

for b:=1 to sizeleft do begin
                     DrawApsXY(middleleft,x,y+GetApsInfo(upleft,'SIZEY')+(b-1)*GetApsInfo(middleleft,'SIZEY'));
                    end; 

DrawApsXY(downleft,x,y+realsizey-GetApsInfo(downleft,'SIZEY'));
borderx:=GetApsInfo(downleft,'SIZEX');
for b:=1 to sizedown do begin
                     DrawApsXY('downmiddle',x+borderx+(b-1)*GetApsInfo('downmiddle','SIZEX'),y+realsizey-GetApsInfo('downmiddle','SIZEY'));
                    end;
borderx:=borderx+sizedown*GetApsInfo('downmiddle','SIZEX');

DrawApsXY('downright',x+realsizex-GetApsInfo('downright','SIZEX'),y+realsizey-GetApsInfo('downright','SIZEY'));
bordery:=bordery+GetApsInfo('downright','SIZEY');

{BUTTONS! Minimize , maximize , exit}
borderx:=GetApsInfo(upleft,'SIZEX')+sizeup1*GetApsInfo(upmiddle,'SIZEX')+GetApsInfo(uptransection,'SIZEX')+2;
DrawApsXY('btnminimize',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnminimize','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnminimize','SIZEX');
DrawApsXY('btnmaximize',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnmaximize','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnmaximize','SIZEX');
DrawApsXY('btnexit',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnexit','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnexit','SIZEX');
end;

procedure Draw_a_WindowTST(title1:string; active,x,y,sizex1,sizey1:integer);
var tmpx,tmpy,borderx,bordery,realsizex,realsizey:integer;
    sizeup1,sizeup2,sizeright,sizeleft,sizedown:integer;
    sizex,sizey,b:integer;  {b anti gia i}
    title,upmiddle,middleleft,uptransection,downleft,upleft:string; 
    tmp_id:integer;
begin
if active=1 then begin {KAthorismos ton eikonon analoga me to an to parathiro einai energo}
                  upmiddle:='upmiddle';
                  middleleft:='middleleft';
                  uptransection:='uptransection';
                  downleft:='downleft';
                  upleft:='upleft';
                 end else
                 begin
                  upmiddle:='up2middle';
                  middleleft:='middle2left';
                  uptransection:='up2transection';
                  downleft:='down2left';
                  upleft:='up2left';
                 end;

//LOADING TWN DIASTASEWN TOU SKIN..
{sxbtnminimize:=GetApsInfo('btnminimize','SIZEX');
sybtnminimize:=GetApsInfo('btnminimize','SIZEY');
sxbtnmaximize:=GetApsInfo('btnmaximize','SIZEX');
sybtnmaximize:=GetApsInfo('btnmaximize','SIZEY');
sxbtnexit:=GetApsInfo('btnexit','SIZEX');
sybtnexit:=GetApsInfo('btnexit','SIZEY');
sxupmiddle2:=GetApsInfo('upmiddle2','SIZEX');
sxupright:=GetApsInfo('upright','SIZEX');
syupright:=GetApsInfo('upright','SIZEY');
sydownright:=GetApsInfo('downright','SIZEY');
sxmiddleright:=GetApsInfo('middleright','SIZEX');
symiddleright:=GetApsInfo('middleright','SIZEY');}
sxupleft:=GetApsInfo(upleft,'SIZEX');
syupleft:=GetApsInfo(upleft,'SIZEY');
sxupmiddle:=GetApsInfo(upmiddle,'SIZEX');
sxuptransection:=GetApsInfo(uptransection,'SIZEX');
sxmiddleleft:=GetApsInfo(middleleft,'SIZEX');
symiddleleft:=GetApsInfo(middleleft,'SIZEY');

//FORES POU EPANALAMVANONTAI OI EIKONES
sizeup2:=(sxbtnminimize+sxbtnmaximize+sxbtnexit) div sxupmiddle2;
sizeup2:=sizeup2+3;
{To sizex einai to megethos tou kyrios tmimatos tis mparas (upmiddle)}
sizex:=sizex1-sxupleft-sxuptransection-sxupright-sizeup2*sxupmiddle2;
sizey:=sizey1-syupright-sydownright;
{Fores pou epanalamvanontai oi eikones}
sizeup1:=sizex div sxupmiddle;
title:='';

//FIXING TOU TITLOU..
if TextWidth(title1)>sizex then begin  {Na xoraei o titlos}
                                 tmpx:=(TextWidth(title1)-sizex) div TextWidth('A');
                                 tmpx:=Length(title1)-tmpx-2;
                                 if tmpx>1 then title:=Copy(title1,1,tmpx);
                                 title:=String(title+'..');
                                end else
                                title:=title1;


sizeright:=sizey div symiddleright;
realsizex:=sxupleft+sizeup1*sxupmiddle+sxuptransection+sizeup2*sxupmiddle2+sxupright;
realsizey:=GetApsInfo('upright','SIZEY')+sizeright*GetApsInfo('middleright','SIZEY')+GetApsInfo('downright','SIZEY');

sizeleft:=(sizey-GetApsInfo(downleft,'SIZEY')) div GetApsInfo(middleleft,'SIZEY');
sizeleft:=sizeleft+3;
//sizeleft:=sizey div GetApsInfo(middleleft,'SIZEY');

sizedown:=(realsizex-GetApsInfo(downleft,'SIZEX')-GetApsInfo('downright','SIZEX')) div GetApsInfo('downmiddle','SIZEX');


//DRAWING TO BACKGROUND TOU PARATHIROU..                                                                                                      
DrawRectangle2(x+{7}GetApsInfo(middleleft,'SIZEX')+2,y+{29}GetApsInfo(upleft,'SIZEY'){+1},x+realsizex-GetApsInfo('middleright','SIZEX'){4},y+realsizey-GetApsInfo('downmiddle','SIZEY'){4},colors[window_background],colors[window_background]);


{Oi akres tou parathirou}
DrawApsXY(upleft,x,y);
borderx:=GetApsInfo(upleft,'SIZEX');

tmp_id:=Retrieve_Aps_ID(upmiddle); // Gia epitaxynsi k na min xanoume CPU cycles kathe fora gia kati pou kseroume...
for b:=1 to sizeup1 do begin
                        DrawApsXY_i(tmp_id,x+borderx+(b-1)*sxupmiddle,y);
                       end;
borderx:=borderx+sizeup1*sxupmiddle;

{O Titlos}
b:=TakeTextColor;
TextColor(colors[window_title]);
OutTextXY(x+GetApsInfo(upleft,'SIZEX')+1,y+(GetApsInfo(upmiddle,'SIZEY')-TextHeight('A')) div 2,title);
TextColor(b);
{Ypoloipes akres tou parathirou}
DrawApsXY_i(Retrieve_Aps_ID(uptransection),x+borderx,y); //FIX YPARXEI 1 PIXEL DIAFORA STO YPSOS
borderx:=borderx+GetApsInfo(uptransection,'SIZEX');

for b:=1 to sizeup2 do DrawApsXY('upmiddle2',x+borderx+(b-1)*sxupmiddle2,y);
borderx:=borderx+sizeup2*sxupmiddle2;

DrawApsXY('upright',x+borderx,y);
borderx:=borderx+sxupright;
bordery:=syupright;

tmp_id:=Retrieve_Aps_ID('middleright'); // Gia eptaxynsi k na min xanoume CPU cycles kathe fora gia kati pou kseroume...
for b:=1 to sizeright do DrawApsXY_i(tmp_id,x+borderx-sxmiddleright,y+bordery+(b-1)*symiddleright);
bordery:=bordery+sizeright*symiddleright;


tmp_id:=Retrieve_Aps_ID(middleleft); // Gia eptaxynsi k na min xanoume CPU cycles kathe fora gia kati pou kseroume...
for b:=1 to sizeleft do DrawApsXY_i(tmp_id,x,y+syupleft+(b-1)*symiddleleft);

DrawApsXY(downleft,x,y+realsizey-GetApsInfo(downleft,'SIZEY'));
borderx:=GetApsInfo(downleft,'SIZEX');

tmp_id:=Retrieve_Aps_ID('downmiddle'); // Gia eptaxynsi k na min xanoume CPU cycles kathe fora gia kati pou kseroume...
for b:=1 to sizedown do DrawApsXY_i(tmp_id,x+borderx+(b-1)*sxdownmiddle,y+realsizey-sydownmiddle);
borderx:=borderx+sizedown*sxdownmiddle;

DrawApsXY('downright',x+realsizex-GetApsInfo('downright','SIZEX'),y+realsizey-GetApsInfo('downright','SIZEY'));
bordery:=bordery+GetApsInfo('downright','SIZEY');

//DRAWING FIX!
DrawRectangle2(x+GetApsInfo(upleft,'SIZEX')+1,y+GetApsInfo(upmiddle,'SIZEY')+1,x+sizex1-GetApsInfo('upright','SIZEX')-2,y+GetApsInfo(upmiddle,'SIZEY')+10,colors[window_background],colors[window_background]);
//DRAWING FIX!

{BUTTONS! Minimize , maximize , exit}
borderx:=GetApsInfo(upleft,'SIZEX')+sizeup1*GetApsInfo(upmiddle,'SIZEX')+GetApsInfo(uptransection,'SIZEX')+2;
DrawApsXY('btnminimize',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnminimize','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnminimize','SIZEX');
DrawApsXY('btnmaximize',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnmaximize','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnmaximize','SIZEX');
DrawApsXY('btnexit',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnexit','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnexit','SIZEX');
end;


procedure draw_icon(icnname,icntext:string; x1,y1:integer);
begin
{SetBackgroundColor(ConvertRGB(208,219,241));
SetBackgroundMode('OPAQUE');  }
TextColor(ConvertRGB(0,0,0));
DrawApsXY(icnname,x1+(TextWidth(' '+icntext+' ')-GetApsInfo(icnname,'SIZEY')) div 2,y1);
DrawRectangle2(x1,y1+5+GetApsInfo(icnname,'SIZEY'),x1+TextWidth(' '+icntext+' '),y1+5+GetApsInfo(icnname,'SIZEY')+TextHeight('A'),ConvertRGB(208,219,241),ConvertRGB(208,219,241));
OutTextXY(x1,y1+5+GetApsInfo(icnname,'SIZEY'),' '+icntext+' ');
TextColor(ConvertRGB(255,255,255));
{SetBackgroundColor(ConvertRGB(0,0,0));
SetBackgroundMode('TRANSPARENT');      }
end;

procedure draw_focus; //ZVGRAFIZEI ME KITRINES TELITSES POU EINAI TO FOCUS
var dx:integer;
begin
for dx:=objectsdat[dataloaded[7],1] to objectsdat[dataloaded[7],3] do begin
                                                                       if odd(dx)=true then putpixel(dx,objectsdat[dataloaded[7],2],colors[focused_region]);
                                                                       if odd(dx)=false then putpixel(dx,objectsdat[dataloaded[7],4]-1,colors[focused_region]);
                                                                      end;
for dx:=objectsdat[dataloaded[7],2] to objectsdat[dataloaded[7],4] do begin
                                                                       if odd(dx)=true then putpixel(objectsdat[dataloaded[7],1],dx,colors[focused_region]);
                                                                       if odd(dx)=false then putpixel(objectsdat[dataloaded[7],3]-1,dx,colors[focused_region]);
                                                                      end;
end;


procedure draw_btn_custom_large_pictured(value,text:string; x1,y1,x2,y2:integer);
var i,bx,by,retaincolor:integer;
begin
   DrawRectangle2(x1,y1,x2,y2,colors[window_background],colors[window_background]);
   
   SetLineSettings(5,5,5);
   if value='1' then begin
                      DrawRectangle(x1,y1,x2,y2,colors[window_border])
                     end else
   if value='2' then begin
                      DrawRectangle(x1,y1,x2,y2,colors[focused_region])
                     end else
   if value='3' then begin
                      DrawRectangle(x1,y1,x2,y2,colors[window_border]);
                     end else
                     begin
                      DrawRectangle(x1,y1,x2,y2,ConvertRGB(255,0,0));
                     end;

   SetLineSettings(1,1,1);
   
   i:=seperate_words_old(text);
   if i>0 then
     begin
      if memory[1]<>'' then begin
                             SetFont('arial','greek',25,0,0,0);
                             retaincolor:=TakeTextColor;
                             TextColor(colors[comments_color]);

                             if memory[2]='' then  bx:=x2-x1+3 else
                                                   bx:=x2-x1-GetApsInfo(memory[2],'sizex')+3;
                             bx:=(bx-TextWidth(memory[1])) div 2; 
                             if memory[2]<>'' then bx:=bx+GetApsInfo(memory[2],'sizex')+3;
                             

                             by:=(y2-y1-TextHeight('A')) div 2;
                             OutTextXY(x1+bx,y1+by,memory[1]);
                             SetFont('arial','greek',15,0,0,0);
                             TextColor(retaincolor);
                            end;
      if memory[2]<>'' then DrawApsXY2(memory[2],x1+3,y1+6);
     end;
   
end;

procedure draw_object(numtmp:integer); //ZWGRAFIZEI TO SYGKEKRIMENO OBJECT
begin  
case objectsdat[numtmp,6] of
obj_button_clp : draw_btn_custom_large_pictured(objects[numtmp,3],objects[numtmp,6],objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3],objectsdat[numtmp,4]);
obj_dropdown : draw_dropdown(objects[numtmp,3],objects[numtmp,6],objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3],objectsdat[numtmp,4]);
obj_border : draw_border(objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3],objectsdat[numtmp,4]);
obj_progressbar: draw_progressbar(objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3],objectsdat[numtmp,4]);
obj_label: draw_label(objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2]);
obj_comment: draw_label(objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2]);
obj_textbox:  draw_field(objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3],objectsdat[numtmp,4]);
obj_textbox_password: draw_password_field(objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3],objectsdat[numtmp,4]);
//obj_checkboxl:  draw_chk('large',objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2]);
obj_checkbox: draw_chk('small',objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2]);
//obj_button: draw_btn('small',objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2]);
obj_buttonc: draw_btncustom(objects[numtmp,3],objects[numtmp,6],objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3],objectsdat[numtmp,4]);
//obj_buttonl: draw_btn('large',objects[numtmp,3],objectsdat[numtmp,1],objectsdat[numtmp,2]);
obj_buttonaps: draw_btnaps(objects[numtmp,3],objects[numtmp,6],objectsdat[numtmp,1],objectsdat[numtmp,2]);
obj_window:                               begin
                                           if Upcase(dataloadedst[1])=Upcase(objects[numtmp,1]) then Draw_a_Window(objects[numtmp,3],1,objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3]-objectsdat[numtmp,1],objectsdat[numtmp,4]-objectsdat[numtmp,2]) else
                                                                                                     Draw_a_Window(objects[numtmp,3],1,objectsdat[numtmp,1],objectsdat[numtmp,2],objectsdat[numtmp,3]-objectsdat[numtmp,1],objectsdat[numtmp,4]-objectsdat[numtmp,2]);
                                           end;
obj_layer: begin end;
obj_icon: draw_icon(objects[numtmp,6],objects[numtmp,8],objectsdat[numtmp,1],objectsdat[numtmp,2]);
end;
end;


procedure draw_spontaneus_object(thetyp,theval:string; tx1,ty1,tx2,ty2:integer);
begin
 dataloaded[1]:=dataloaded[1]+1;

 objects[dataloaded[1],2]:=thetyp;
 objects[dataloaded[1],3]:=theval;
 objectsdat[dataloaded[1],1]:=tx1;
 objectsdat[dataloaded[1],2]:=ty1;
 objectsdat[dataloaded[1],3]:=tx2;
 objectsdat[dataloaded[1],4]:=ty2;
 objectsdat[dataloaded[1],6]:=convert_objecttype_string2int(thetyp);
 draw_object(dataloaded[1]);

 dataloaded[1]:=dataloaded[1]-1;
end;


procedure draw_object_by_name(numname:string);//ZWGRAFIZEI ENA SYGKEKRIMENO OBJECT ME PARAMETRO TO ONOMA TOU
var objnum,z:integer;
begin
objnum:=-1; z:=0;
while (objnum=-1) and (z<=dataloaded[1]) do begin
                                             z:=z+1;
{for i:=1 to dataloaded[1] do }              if Upcase(objects[z,1])=Upcase(numname) then objnum:=z; 
                                             if z=dataloaded[1]+1 then outtextcenter('REACHES END+1 PROBLEM!!');
                                           end;
if objnum<>-1 then draw_object(objnum);
end;

procedure draw_objects_on_window(numname:string);
var z:integer;
begin
z:=0;
while z<=dataloaded[1] do begin
                           z:=z+1;
                           if Upcase(objects[z,7])=Upcase(numname) then draw_object(z);
                          end;
end;

procedure draw_all;
var z:integer;
    need_to_restore_clip:boolean;
begin
need_to_restore_clip:=false;
if window_needs_redraw then
     begin
       if (( window_needs_redraw_at(1)<>0 ) or ( window_needs_redraw_at(2)<>0 ) or ( window_needs_redraw_at(3)<>0 ) or ( window_needs_redraw_at(4)<>0 ) ) then
         begin
          need_to_restore_clip:=true;
          set_window_clipping(window_needs_redraw_at(1),window_needs_redraw_at(2),window_needs_redraw_at(3),window_needs_redraw_at(4)); 
         end;
     end;

draw_language(GetInternalKeyboardLanguage);
for z:=1 to dataloaded[1] do draw_object(z);

if enableturbo then draw_mem_text; //UNDER DEVELOPMENT

if need_to_restore_clip then set_window_clipping(0,0,0,0); 
set_window_drawn;
end;

function userclicktype:integer;
begin
userclicktype:=0;
if Mousebutton(1)=1 then userclicktype:=1 else
if Mousebutton(2)=1 then userclicktype:=2 else
if Mousebutton(3)=1 then userclicktype:=3;
end;

procedure draw_led(clrused:integer); //LAMPAKI KATW DEKSIA..
begin
putpixel(GetMaxX-5,GetMaxY-5,clrused); 
putpixel(GetMaxX-6,GetMaxY-5,clrused);
putpixel(GetMaxX-5,GetMaxY-6,clrused);
putpixel(GetMaxX-6,GetMaxY-6,clrused);
end;

procedure clear_mouse;
begin
dataloaded[4]:=0;
dataloaded[5]:=0;
end;

function return_focus:string; //EPISTREFEI TO FOCUS
begin
return_focus:=objects[dataloaded[7],1];
end;


function movefocus:integer; //METAKINEI TO FOCUS
var lastfocus:integer;
    label start_movefocus;
begin
lastfocus:=dataloaded[7];
start_movefocus:
dataloaded[7]:=dataloaded[7]+1;
if dataloaded[7]>dataloaded[1] then dataloaded[7]:=1;
if (Upcase(objects[dataloaded[7],2])='LABEL') or (Upcase(objects[dataloaded[7],2])='COMMENT') or (Upcase(objects[dataloaded[7],2])='WINDOW') or (Upcase(objects[dataloaded[7],2])='LAYER') or (Upcase(objects[dataloaded[7],2])='PROGRESSBAR') or (Upcase(objects[dataloaded[7],2])='DATA')
         then begin
               goto start_movefocus;
              end else
              begin
                draw_object(lastfocus);
              end;

draw_focus;
movefocus:=dataloaded[7];
end;


function return_last_mouse_object:string;   //TO TELEYTAIO OBJECT PANW APO TO OPOIO HTAN TO MOUSE
var retres:string;
begin
retres:='';
if dataloaded[4]>0 then retres:=objects[dataloaded[4],1];
return_last_mouse_object:=retres;
end;

function mouse_over_object(objec,msx,msy:integer):integer;  //EPISTREFEI 1 AN TO MOUSE EINAI PANW APO TO OBJECT OBJEC
var z2:integer;
begin 
mouse_over_object:=0;
if map[msx,objec]<>0 then begin
                           if objectsdat[map[msx,z2],1]<=msx then
                           if objectsdat[map[msx,z2],3]>=msx then
                           if objectsdat[map[msx,z2],2]<=msy then
                           if objectsdat[map[msx,z2],4]>=msy then mouse_over_object:=1;
                          end;
end;

function objects_under_mouse(msx,msy:integer):integer;  //EPISTREFEI TO PLITHOS TWN OBJECTS PANW APO TA OPOIA EINAI TO MOUSE
var z2,totobjs:integer;
begin
z2:=0; totobjs:=0;
repeat
z2:=z2+1;
if map[msx,z2]<>0 then begin
                          if objectsdat[map[msx,z2],1]<=msx then
                          if objectsdat[map[msx,z2],3]>=msx then
                          if objectsdat[map[msx,z2],2]<=msy then
                          if objectsdat[map[msx,z2],4]>=msy then totobjs:=totobjs+1;
                      end;
until z2>=dataloaded[8]+1;         {PITHANO BUG @!@!@!@}
objects_under_mouse:=totobjs;
end;

procedure activate_object(name:string);  //ENERGOPOIEI TO OBJECT
var objnum,z:integer;
begin 
if name<>'' then begin
dataloaded[2]:=GetMouseX;
dataloaded[3]:=GetMouseY;
z:=0;
objnum:=get_object_number(name);
if objnum<>-1 then begin
                    dataloaded[10]:=objnum;
                    z:=dataloaded[4];
                    dataloaded[4]:=objnum;
                    draw_object(z);
                   end;
                  end;
end;



function workmouseold:byte;
var mousex,mousey,maxmap,z:integer;
    flag1:boolean;
begin
workmouseold:=0;
mousex:=GetMouseX;
mousey:=GetMouseY;
if ((dataloaded[2]=mousex)and(dataloaded[3]=mousey)) then begin
                                                            if cpu_time>0 then sleep(cpu_time);
                                                            //sleep(10);
                                                            //FIX 4-1-06 (PARATIRISA OTI TO PROGRAMMA XRISIMOPOIEI POLY CPU TIME..)
                                                            //TWRA ME TIN IDIA AKRIVWS TAXYTITA OTAN DEN KANEI KATI O XRISTIS EKSIKONOMOUME XRONO GIA TO SYSTIMA...
                                                          end else

                             begin
workmouseold:=1;
//mouse_querys:=mouse_querys+1;
dataloaded[5]:=dataloaded[4];  // Last Object save
flag1:=false;
maxmap:=dataloaded[8]+1;         {PITHANO BUG @!@!@!@}
if maxmap>100 then maxmap:=100;
i:=0;
repeat
i:=i+1;
//mouse_times:=mouse_times+1;
if map[mousex,i]<>0 then begin
                          if ((objectsdat[map[mousex,i],1]<=mousex) and (objectsdat[map[mousex,i],3]>=mousex) and (objectsdat[map[mousex,i],2]<=mousey) and (objectsdat[map[mousex,i],4]>=mousey)) then
                          // An to click ginei kapou pou yparxei object..
                                                                     begin
                                                                       flag1:=true; 
                                                                       dataloaded[4]:=map[mousex,i];  // Curent object einai ayto pou epileksame
                                                                       if Upcase(objects[map[mousex,i],2])='WINDOW' then begin 
                                                                                                                          if objects_under_mouse(mousex,mousey)>1 then begin
                                                                                                                                                                        flag1:=false;
                                                                                                                                                                        dataloaded[4]:=dataloaded[5];
                                                                                                                                                                        draw_led(ConvertRGB(0,0,255)); 
                                                                                                                                                                       end;


                                                                                                                          {if (i+1<=maxmap) and (i+1<=map[mousex,101]) and (objects_under_mouse(mousex,mousey)>1) then
                                                                                                                          for z:=i+1 to map[mousex,101] do begin
                                                                                                                                                            if (map[mousex,z]<>0) then flag1:=false;
                                                                                                                                                            draw_led(ConvertRGB(0,0,255));
                                                                                                                                                           end;    }
                                                                                                                         end;
                                                                       draw_led(ConvertRGB(255,0,0));
                                                                      end;
                         end;
if i=maxmap then begin
               dataloaded[4]:=0;
               draw_led(ConvertRGB(0,255,0));
              end;
if flag1=true then i:=maxmap;
until i=maxmap;
dataloaded[2]:=mousex;
dataloaded[3]:=mousey;
if dataloaded[4]=0 then Mousebutton(1);  {MPOREI NA TO ARGEI LIGO OMWS KATHARIZEI TA KOUMPIA!}
                              end;
end; 

procedure disable_win_screensaver;
begin
SystemParametersInfo(SPI_SETPOWEROFFACTIVE,0,0,0);
SystemParametersInfo(SPI_SETSCREENSAVEACTIVE,0,0,0);
end;

procedure enable_win_screensaver;
begin
SystemParametersInfo(SPI_SETPOWEROFFACTIVE,1,0,0);
SystemParametersInfo(SPI_SETSCREENSAVEACTIVE,1,0,0);
end;

procedure ammargui_screensaver;
var curdir:string;
    startx,starty:integer;
    mousex,mousey,x,y,i:integer;
    aps_x1,aps_y1:integer;
    label end_screensaver;
begin
Save_Graph_Window;
getdir(0,curdir);
chdir(enviromentdir);
aps_x1:=GetLoadingX;
aps_y1:=GetLoadingY; 
SetLoadingXY(aps_x1+300,aps_y1+200);
ChangeCursorIcon('ARROW');
LoadAps('atech');
startx:=GetMouseX;
starty:=GetMouseY;
SetMouseXY(GetMaxX,GetMaxY); 
mousex:=GetMouseX;
mousey:=GetMouseY;
clrscreen;
randomize;
while true do
  begin 
    DrawRectangle2(x,y,x+GetApsInfo('atech','sizex')+2,y+GetApsInfo('atech','sizey')+2,ConvertRGB(0,0,0),ConvertRGB(0,0,0));
    x:=Round(Random(GetMaxX-GetApsInfo('atech','sizex')));
    y:=Round(Random(GetMaxY-GetApsInfo('atech','sizey')));
    DrawApsXY('atech',x,y);
    for i:=1 to 100 do
      begin
        delay(130);
        if ((mousex<>GetMouseX) or (mousey<>GetMouseY) or (readkeyfast<>'')) then goto end_screensaver;
      end;
  end;

end_screensaver:
last_cursor:='';
GUI_ChangeCursorIcon(mouse_icon_resource('ARROW'));  
SetMouseXY(startx,starty);
UnLoadAps('atech');
SetLoadingXY(aps_x1,aps_y1);
chdir(curdir);
Load_Graph_Window;
end;

function GUI_MouseX:integer;
begin
GUI_MouseX:=dataloaded[2];
end;

procedure Set_GUI_MouseX(thenum:integer);
begin
dataloaded[2]:=thenum;
end;

function GUI_MouseY:integer;
begin
GUI_MouseY:=dataloaded[3];
end;

procedure Set_GUI_MouseY(thenum:integer);
begin
dataloaded[3]:=thenum;
end;


function workmouse:byte;
var mousex,mousey,z:integer;
    retres:byte;
begin
retres:=0;
mousex:=GetMouseX;
mousey:=GetMouseY;
if ((dataloaded[2]=mousex)and(dataloaded[3]=mousey)) then begin
                                                            if agui_screensaver_disable then idle_time:=0;
                                                            if idle_time=0 then idle_time:=GetTickCount else//We are idle and it`s the first loop..
                                                                                begin //We are idle and it might be time for the screensaver.. 
                                                                                 if GetTickCount-idle_time>MAX_IDLE_TIME then
                                                                                    begin
                                                                                     ammargui_screensaver;
                                                                                     idle_time:=0;
                                                                                    end;
                                                                                end;
                                                            if cpu_time>0 then sleep(cpu_time);
                                                            //sleep(10);
                                                            //FIX 4-1-06 (PARATIRISA OTI TO PROGRAMMA XRISIMOPOIEI POLY CPU TIME..)
                                                            //TWRA ME TIN IDIA AKRIVWS TAXYTITA OTAN DEN KANEI KATI O XRISTIS EKSIKONOMOUME XRONO GIA TO SYSTIMA...
                                                          end else

                             begin
                               retres:=1;
                               //mouse_querys:=mouse_querys+1;
                              //mouse_times:=mouse_times+1;
                               idle_time:=0;//We are NOT idle..
                               dataloaded[5]:=dataloaded[4];  // Last Object save
                               dataloaded[2]:=mousex;
                               dataloaded[3]:=mousey;
                               dataloaded[4]:=Retrieve_Map_Object(mousex,mousey);
                               if dataloaded[4]=0 then begin
                                                        Mousebutton(1);
                                                        draw_led(ConvertRGB(0,255,0));
                                                        dataloaded[4]:=0;
                                                        //workmouse:=Workmouseold;
                                                       end else draw_led(ConvertRGB(255,0,0));
                             end;
workmouse:=retres;
end;

function get_gui_key:string;
begin
 get_gui_key:=keybinp; 
end;


procedure button_handling(i,buttontype:integer);
var z,l:integer;
begin
// buttontype = 2 then buttonclp
if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                        GUI_ChangeCursorIcon(mouse_icon_resource('SELECT'));
                                        if objects[i,3]='1' then
                                                     begin 
                                                      if buttontype=2 then  draw_btn_custom_large_pictured('2',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4])  else
                                                                            draw_btncustom('2',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                     end;
                                        dataloaded[5]:=dataloaded[4];
                                     end;
  if (userclicktype=1) or (dataloaded[10]<>0) then
                                       begin {CLICK}
                                         dataloaded[14]:=i; // Last Object activated..
                                         if objects[i,3]='1' then objects[i,3]:='3' else
                                         if objects[i,3]='4' then objects[i,3]:='3' else
                                         if objects[i,3]='3' then objects[i,3]:='1';
                                         if buttontype=2 then  draw_btn_custom_large_pictured(objects[i,3],objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4])  else
                                                               draw_btncustom(objects[i,3],objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                          

                                  if (dataloaded[10]=0) then
                                         begin
                                           if objects[i,3]='3' then l:=1 else l:=0;
                                           z:=MouseButton(1);
                                           while z<>2 do
                                              begin
                                               delay(5);
                                               z:=MouseButton(1);
                                               if z=2 then break else
                                                  begin
                                                   Set_GUI_MouseX(GetMouseX);
                                                   Set_GUI_MouseY(GetMouseY);
                                                   if ((GUI_MouseX>=objectsdat[i,1]) and (GUI_MouseX<=objectsdat[i,3]) and (GUI_MouseY>=objectsdat[i,2]) and (GUI_MouseY<=objectsdat[i,4])) then
                                                        begin //TO MOUSE EINAI MESA STO KOUMPI
                                                           if l=0 then begin //PREPEI NA KSANAZWGRAFISOUME TO PATIMA :P
                                                                         if buttontype=2 then  draw_btn_custom_large_pictured('3',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4])  else
                                                                                               draw_btncustom('3',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                         l:=1;
                                                                       end;
                                                        end else
                                                        begin //TO MOUSE EINAI EKSW APO TO KOUMPI
                                                           if l=1 then begin //PREPEI NA KSANAZWGRAFISOUME OTI TO KOUMPI DN EINAI PATIMENO :P
                                                                         if buttontype=2 then  draw_btn_custom_large_pictured('1',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]) else
                                                                                               draw_btncustom('1',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                         l:=0;
                                                                       end;
                                                        end;
                                                   end;
                                               end;
                                           end else
                                           delay(70);  //GIA POIO HARD FEELING STO PATIMA TOU ENTER :)


                                                                                             if ((l=1) or (dataloaded[10]<>0)) then
                                                                                               begin //TO KOUMPI PATITHIKE TELIKA
                                                                                                if objects[i,3]='1' then objects[i,3]:='3' else
                                                                                                if objects[i,3]='3' then objects[i,3]:='4';
                                                                                                if buttontype=2 then  draw_btn_custom_large_pictured(objects[i,3],objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]) else
                                                                                                                      draw_btncustom(objects[i,3],objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                                end else
                                                                                               begin //TO KOUMPI DEN PATITHIKE TELIKA (EINAI SIGOURA ZWGRAFISMENO SWSTA)
                                                                                                objects[i,3]:='1';
                                                                                               end; 


                                                                                             dataloaded[5]:=0;
                                                                                             dataloaded[7]:=i;
                                                                                            end;
  
end;


procedure interact;
var i,z,l,k,ax,ay:integer;
begin 
            {workmouseold}
if workmouse=0 then begin  // <- To workmouse einai poly dynati synartisi , dn fainetai me to mati..

                     if dataloaded[11]=1 then begin
                     keybinp:=readkeyfast; 
                     if Equal(keybinp,'F1') then begin
                                                  if Upcase(GetInternalKeyboardLanguage)='ENGLISH' then SetInternalKeyboardLanguage('GREEK') else
                                                                                                        SetInternalKeyboardLanguage('ENGLISH');
                                                  draw_language(GetInternalKeyboardLanguage);
                                                end else
                     if Equal(keybinp,'F2')  then begin
                                                   if advanced_read then begin
                                                                          advanced_read:=false;
                                                                          MessageBox (0, 'Keyboard field text set to basic mode' , 'AmmarGUI', 0);
                                                                         end  else
                                                                         begin
                                                                          advanced_read:=true;
                                                                           MessageBox (0, 'Keyboard field text set to advanced mode' , 'AmmarGUI', 0);
                                                                         end;
                                                  end else
                     if Equal(keybinp,'F5')  then begin
                                                   draw_all; 
                                                   //GUI_ChangeCursorIcon(mouse_icon_resource('ARROW')); 
                                                   ChangeCursorIcon('ARROW');
                                                  end else
                     if Equal(keybinp,'F12')  then begin
                                                   draw_all; 
                                                   i:=MessageBox (0, 'Are you sure you want to close this application ?'+#10+'Any unsaved progress will be lost..' , 'Closing AmmarGUI application', 0 + MB_ICONEXCLAMATION + MB_YESNO + MB_SYSTEMMODAL);
                                                   if i=IDYES then begin
                                                                    closegraph; 
                                                                    halt;
                                                                   end;
                                                   delay(200);
                                                   wait_clear_key('F12');
                                                   readkeyfast;
                                                   keybinp:='';    
                                                  end else
                     if Equal(keybinp,'TAB')  then movefocus else
                   {  if Equal(keybinp,'F6')  then begin
                                                    FlushApsMemory;
                                                    if current_skin='skin1' then load_skin('windowsskin') else
                                                                                 load_skin('skin1');
                                                    draw_all;
                                                  end;       }
                     if (Equal(keybinp,' ')) or (Equal(keybinp,'ENTER')) then activate_object({objects[}return_focus{,1]});
                                              end;
                    end;

//if window_needs_redraw then draw_all;
if dataloaded[4]<>0 then begin 
      if (dataloaded[5]<>0) and (dataloaded[5]<>dataloaded[4]) then begin
                                                                     draw_object(dataloaded[5]); // 
                                                                    end;
                          begin
                            i:=dataloaded[4]; //Current Object
                            if objects[i,5]<>'' then  begin
                                                        //MessageBox (0, pchar('"'+objects[i,5]+'"') , ' ', 0); 
                                                        if (mouse_icon_resource(objects[i,5]))<>last_cursor then
                                                         begin
                                                          GUI_ChangeCursorIcon(mouse_icon_resource(objects[i,5]));
                                                         end;
                                                      end;
                              case objectsdat[i,6] of
                              obj_mainwindow:                       begin
                                                                     if dataloaded[5]<>dataloaded[4] then begin  //MOUSE OVER SOMETHING NEW
                                                                                                           dataloaded[5]:=dataloaded[4];
                                                                                                          end; 
                                                                     if (userclicktype=1) or (dataloaded[10]<>0)then
                                                                                              begin //CLICK
                                                                                                 dataloaded[14]:=i; // Last Object activated.. 
                                                                                                 objects[i,3]:='3';
                                                                                                  z:=MouseButton(1);
                                                                                                  l:=GetMouseX;//+GetWindowStartX;
                                                                                                  k:=GetMouseY;//+GetWindowStartY;
                                                                                                  ax:=l+1; ay:=k+1; //PRwti Energopoiisi
                                                                                                  GUI_ChangeCursorIcon(mouse_icon_resource('PICK'));
                                                                                                  while ((z=1) or (z=0) and ( not Equal(readkeyfast,'ESCAPE') ) ) do
                                                                                                     begin
                                                                                                       delay(move_snap);
                                                                                                       if ( (ax>l+2) or (ax<l-2) ) or ( (ay>k+2) or (ay<>k-2)) then
                                                                                                                                     begin
                                                                                                                                      memoryinteger[1]:=GetWindowStartX;
                                                                                                                                      memoryinteger[2]:=GetWindowStartY;
                                                                                                                                      WindowMove(GetWindowStartX+ax-l,GetWindowStartY+ay-k);
                                                                                                                                      l:=ax-GetWindowStartX+memoryinteger[1]; k:=ay-GetWindowStartY+memoryinteger[2];
                                                                                                                                     end;
                                                                                                       ax:=GetMouseX;//+GetWindowStartX;
                                                                                                       ay:=GetMouseY;//+GetWindowStartY;
                                                                                                       z:=MouseButton(1); 
                                                                                                     end; 
                                                                                                 set_window_needs_redraw;
                                                                                                 GUI_ChangeCursorIcon(mouse_icon_resource('ARROW'));
                                                                                                 dataloaded[5]:=0;
                                                                                                 dataloaded[7]:=i;
                                                                                              end;
                                                                    end;
                              obj_dropdown:                         begin
                                                                     if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                           //draw_icon(objects[i,6],objects[i,8],objectsdat[i,1],objectsdat[i,2]);
                                                                                                           draw_object(i);
                                                                                                           dataloaded[5]:=dataloaded[4]; 
                                                                                                          end; 
                                                                     if (userclicktype=1) or (dataloaded[10]<>0)then
                                                                                              begin {CLICK}
                                                                                                 dataloaded[14]:=i; // Last Object activated.. 
                                                                                                 objects[i,3]:=draw_dropdown_selections(i); 
                                                                                                 dataloaded[5]:=0;
                                                                                                 dataloaded[7]:=i;
                                                                                              end;
                                                                    end; 
                              obj_icon:                             begin
                                                                     if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                           draw_icon(objects[i,6],objects[i,8],objectsdat[i,1],objectsdat[i,2]);
                                                                                                           dataloaded[5]:=dataloaded[4]; 
                                                                                                          end; 
                                                                     if (userclicktype=1) or (dataloaded[10]<>0)then
                                                                                              begin {CLICK}
                                                                                                 dataloaded[14]:=i; // Last Object activated..
                                                                                                 if objects[i,3]='1' then objects[i,3]:='4' else
                                                                                                 if objects[i,3]='4' then objects[i,3]:='1';
                                                                                                 dataloaded[5]:=0;
                                                                                                 dataloaded[7]:=i;
                                                                                              end;
                                                                   end;
                              obj_layer:                             begin
                                                                     if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                           dataloaded[5]:=dataloaded[4];
                                                                                                          end;
                                                                     if (userclicktype=1) or (dataloaded[10]<>0) then
                                                                                              begin {CLICK}
                                                                                                 dataloaded[14]:=i; // Last Object activated..
                                                                                                 if objects[i,3]='1' then objects[i,3]:='4' else
                                                                                                 if objects[i,3]='4' then objects[i,3]:='1';
                                                                                                 if dataloaded[15]=1 then
                                                                                                           begin
                                                                                                             if Equal(objects[i,1],'wnd_minimize') then begin
                                                                                                                                                         ShowWindow(WindowHandle, SW_MINIMIZE);
                                                                                                                                                         objects[i,3]:='1';
                                                                                                                                                        end;
                                                                                                           end;
                                                                                                 dataloaded[5]:=0; 
                                                                                                 dataloaded[7]:=i;
                                                                                              end;
                                                                   end;
                              obj_window:                            begin
                                                                     if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                            if dataloaded[5]<>0 then 
                                                                                                            if Upcase(objects[dataloaded[5],2])<>'WINDOW' then draw_object(dataloaded[5]); 
                                                                                                            GUI_ChangeCursorIcon(mouse_icon_resource('ARROW'));
                                                                                                          end;
                                                                     if (userclicktype=1) or (dataloaded[10]<>0) then
                                                                                            begin {CLICK}
                                                                                              dataloaded[14]:=i; // Last Object activated..
                                                                                              if Upcase(dataloadedst[1])='' then begin
                                                                                                                                  draw_led(ConvertRGB(255,57,240)); 
                                                                                                                                  dataloadedst[1]:=objects[i,1];
                                                                                                                                  draw_object_by_name(objects[i,1]);
                                                                                                                                  draw_objects_on_window(objects[i,1]);
                                                                                                                                  objectsdat[i,5]:=1;
                                                                                                                                 end else
                                                                                              if Upcase(dataloadedst[1])<>Upcase(objects[i,1]) then begin
                                                                                                                                                     draw_led(ConvertRGB(252,255,39)); 
                                                                                                                                                     bufstin:=dataloadedst[1];
                                                                                                                                                     dataloadedst[1]:=objects[i,1];
                                                                                                                                                     draw_object_by_name(bufstin);
                                                                                                                                                     draw_objects_on_window(bufstin);
                                                                                                                                                     draw_object_by_name(objects[i,1]); 
                                                                                                                                                     draw_objects_on_window(objects[i,1]);
                                                                                                                                                     objectsdat[i,5]:=1;
                                                                                                                                                     set_object_data(bufstin,'extra2','',0); 
                                                                                                                                                   end;
                                                                                              dataloaded[7]:=i;
                                                                                             end;
                                                                   end;
                              obj_label:                             begin
                                                                     if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW} 
                                                                                                           TextColor(ConvertRGB(0,0,255));
                                                                                                           draw_label(objects[i,3],objectsdat[i,1],objectsdat[i,2]);
                                                                                                           TextColor(ConvertRGB(255,255,255));
                                                                                                           dataloaded[5]:=dataloaded[4];
                                                                                                          end;
                                                                     if (userclicktype=1) or (dataloaded[10]<>0)
                                                                                        then begin {CLICK}
                                                                                              dataloaded[14]:=i; // Last Object activated..
                                                                                              TextColor(ConvertRGB(255,0,0));
                                                                                              draw_label(objects[i,3],objectsdat[i,1],objectsdat[i,2]);
                                                                                              TextColor(ConvertRGB(255,255,255));
                                                                                              dataloaded[5]:=0;
                                                                                              dataloaded[7]:=i;
                                                                                             end;
                                                                   end;
                              obj_comment:                           begin
                                                                     if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                           //draw_label(objects[i,3],objectsdat[i,1],objectsdat[i,2]);
                                                                                                          end;
                                                                   end;
                              obj_progressbar:                       begin
                                                                     //if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                     //                                      draw_progressbar(objects[i,3],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                     //                                     end;
                                                                   end;
                              obj_textbox_password :                 begin
                                                                      if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                            GUI_ChangeCursorIcon(mouse_icon_resource('TYPE'));
                                                                                                            TextColor(ConvertRGB(0,0,255));
                                                                                                            draw_password_field(objects[i,3],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                                            TextColor(ConvertRGB(255,255,255));
                                                                                                            dataloaded[5]:=dataloaded[4];
                                                                                                           end;
                                                                      if (userclicktype=1) or (dataloaded[10]<>0) then
                                                                                             begin {CLICK}
                                                                                               dataloaded[14]:=i; // Last Object activated..
                                                                                               //TextColor(ConvertRGB(255,255,255));
                                                                                               draw_field('',objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                               SetLineSettings(0,0,metrics[1]);
                                                                                               DrawRectangle2(objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],8+objectsdat[i,2]+textheight('A'),colors[textbox_in],colors[textbox_in]);
                                                                                               DrawRectangle(objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],8+objectsdat[i,2]+textheight('A'),colors[button_active_text]);
                                                                                               SetLineSettings(0,0,1);
                                                                                               GotoXY(objectsdat[i,1]+4,objectsdat[i,2]+4);

                                                                                               {objectsdat[added,1]:=x1;
                                                                                               objectsdat[added,2]:=y1;
                                                                                               objectsdat[added,3]:=x2;
                                                                                               objectsdat[added,4]:=y2;   }

                                                                                               objects[i,3]:=readtext2(objects[i,3],objectsdat[i,3]-objectsdat[i,1],true);
                                                                                               dataloaded[7]:=i;
                                                                                               if dataloaded[6]=1 then begin {Grigori enallagi textbox}
                                                                                                                        i:=dataloaded[7];
                                                                                                                        repeat
                                                                                                                         movefocus;
                                                                                                                         if dataloaded[7]=i then i:=-1;
                                                                                                                         if Upcase(objects[dataloaded[7],2])='TEXTBOX' then begin
                                                                                                                                                                             if dataloaded[7]<>i then begin
                                                                                                                                                                                                      SetMouseXY(objectsdat[dataloaded[7],1]+1,objectsdat[dataloaded[7],2]+1);
                                                                                                                                                                                                      dataloaded[4]:=dataloaded[7];
                                                                                                                                                                                                      dataloaded[5]:=0;
                                                                                                                                                                                                      i:=-1
                                                                                                                                                                                                      end;
                                                                                                                                                                            end;
                                                                                                                        until i=-1;
                                                                                                                       end;
                                                                                              // dataloaded[5]:=0; {TEST dataloaded[4]}
                                                                                               draw_password_field(objects[i,3],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                              end;
                                                                     end;
                              obj_textbox:                           begin
                                                                      if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                            GUI_ChangeCursorIcon(mouse_icon_resource('TYPE'));
                                                                                                           // TextColor(ConvertRGB(0,0,255));
                                                                                                            draw_field(objects[i,3],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                                           // TextColor(ConvertRGB(255,255,255));
                                                                                                            dataloaded[5]:=dataloaded[4];
                                                                                                           end;
                                                                      if (userclicktype=1) or (dataloaded[10]<>0) then
                                                                                             begin {CLICK}
                                                                                               dataloaded[14]:=i; // Last Object activated..
                                                                                               //TextColor(ConvertRGB(255,255,255));
                                                                                               draw_field('',objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                               SetLineSettings(0,0,metrics[1]);
                                                                                               DrawRectangle2(objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],8+objectsdat[i,2]+textheight('A'),colors[textbox_in],colors[textbox_in]);
                                                                                               DrawRectangle(objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],8+objectsdat[i,2]+textheight('A'),colors[button_active_text]);
                                                                                               SetLineSettings(0,0,1);
                                                                                               GotoXY(objectsdat[i,1]+4,objectsdat[i,2]+4);
                                                                                               objects[i,3]:=readtext2(objects[i,3],objectsdat[i,3]-objectsdat[i,1],false);
                                                                                               {SetLineSettings(0,0,metrics[1]);
                                                                                               DrawRectangle(objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],8+objectsdat[i,2]+textheight('A'),colors[textbox_out]);
                                                                                               SetLineSettings(0,0,1);   }
                                                                                               draw_field(objects[i,3],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                               
                                                                                               dataloaded[7]:=i;
                                                                                               if dataloaded[6]=1 then begin {Grigori enallagi textbox}
                                                                                                                        i:=dataloaded[7];
                                                                                                                        repeat
                                                                                                                         movefocus;
                                                                                                                         if dataloaded[7]=i then i:=-1;
                                                                                                                         if Upcase(objects[dataloaded[7],2])='TEXTBOX' then begin
                                                                                                                                                                             if dataloaded[7]<>i then begin
                                                                                                                                                                                                      SetMouseXY(objectsdat[dataloaded[7],1]+1,objectsdat[dataloaded[7],2]+1);
                                                                                                                                                                                                      dataloaded[4]:=dataloaded[7];
                                                                                                                                                                                                      dataloaded[5]:=0;
                                                                                                                                                                                                      i:=-1
                                                                                                                                                                                                      end;
                                                                                                                                                                            end;
                                                                                                                        until i=-1;
                                                                                                                       end;
                                                                                               //dataloaded[5]:=0; {TEST dataloaded[4]}
                                                                                              end;
                                                                     end;
                              obj_checkbox:                              begin
                                                                        if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                              GUI_ChangeCursorIcon(mouse_icon_resource('SELECT'));
                                                                                                              if objects[i,3]='1' then draw_chk('small','2',objectsdat[i,1],objectsdat[i,2]);
                                                                                                              dataloaded[5]:=dataloaded[4];
                                                                                                             end;
                                                                        if (userclicktype=1) or (dataloaded[10]<>0) then
                                                                                                begin {CLICK}
                                                                                                 dataloaded[14]:=i; // Last Object activated..
                                                                                                 if objects[i,3]='1' then objects[i,3]:='3' else
                                                                                                 if objects[i,3]='3' then objects[i,3]:='1';
                                                                                                 draw_chk('small',objects[i,3],objectsdat[i,1],objectsdat[i,2]);
                                                                                                 dataloaded[5]:=0;
                                                                                                 dataloaded[7]:=i;
                                                                                                 FlushMouseButtons;
                                                                                                 delay(150);
                                                                                                end;
                                                                       end;
                              obj_button:                             begin
                                                                    if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                          GUI_ChangeCursorIcon(mouse_icon_resource('SELECT'));
                                                                                                          if objects[i,3]='1' then draw_btn('small','2',objectsdat[i,1],objectsdat[i,2]);
                                                                                                          dataloaded[5]:=dataloaded[4];
                                                                                                         end;
                                                                    if (userclicktype=1) or (dataloaded[10]<>0) then
                                                                                            begin {CLICK}
                                                                                             dataloaded[14]:=i; // Last Object activated..
                                                                                             if objects[i,3]='1' then objects[i,3]:='3' else
                                                                                             if objects[i,3]='3' then objects[i,3]:='1';
                                                                                             draw_btn('small',objects[i,3],objectsdat[i,1],objectsdat[i,2]);
                                                                                             dataloaded[5]:=0;
                                                                                             dataloaded[7]:=i;
                                                                                            end;
                                                                   end;
                              obj_button_clp:                      begin
                                                                    button_handling(i,2);
                                                                   end;
                              obj_buttonc:                           begin
                                                                    if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW} 
                                                                                                          GUI_ChangeCursorIcon(mouse_icon_resource('SELECT'));
                                                                                                          if objects[i,3]='1' then draw_btncustom('2',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                                          dataloaded[5]:=dataloaded[4];
                                                                                                         end;
                                                                    if (userclicktype=1) or (dataloaded[10]<>0) then
                                                                                            begin {CLICK}
                                                                                             dataloaded[14]:=i; // Last Object activated..
                                                                                             if objects[i,3]='1' then objects[i,3]:='3' else
                                                                                             if objects[i,3]='4' then objects[i,3]:='3' else
                                                                                             if objects[i,3]='3' then objects[i,3]:='1';
                                                                                             draw_btncustom(objects[i,3],objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);

                                                                                             {delay(50);
                                                                                             if objects[i,3]='1' then objects[i,3]:='3' else
                                                                                             if objects[i,3]='3' then objects[i,3]:='4';
                                                                                             draw_btncustom(objects[i,3],objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                             }

                                                                                           if (dataloaded[10]=0) then
                                                                                            begin
                                                                                             if objects[i,3]='3' then l:=1 else l:=0;
                                                                                             z:=MouseButton(1);
                                                                                             while z<>2 do
                                                                                               begin
                                                                                                 delay(5);
                                                                                                 z:=MouseButton(1);
                                                                                                 if z=2 then break else
                                                                                                  begin
                                                                                                   Set_GUI_MouseX(GetMouseX);
                                                                                                   Set_GUI_MouseY(GetMouseY);
                                                                                                   if ((GUI_MouseX>=objectsdat[i,1]) and (GUI_MouseX<=objectsdat[i,3]) and (GUI_MouseY>=objectsdat[i,2]) and (GUI_MouseY<=objectsdat[i,4])) then
                                                                                                      begin //TO MOUSE EINAI MESA STO KOUMPI
                                                                                                       if l=0 then begin //PREPEI NA KSANAZWGRAFISOUME TO PATIMA :P
                                                                                                                     draw_btncustom('3',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                                                     l:=1;
                                                                                                                   end;
                                                                                                      end else
                                                                                                      begin //TO MOUSE EINAI EKSW APO TO KOUMPI
                                                                                                       if l=1 then begin //PREPEI NA KSANAZWGRAFISOUME OTI TO KOUMPI DN EINAI PATIMENO :P
                                                                                                                     draw_btncustom('1',objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]);
                                                                                                                     l:=0;
                                                                                                                   end;
                                                                                                      end;
                                                                                                  end;
                                                                                               end;
                                                                                             end else
                                                                                             delay(70);  //GIA POIO HARD FEELING STO PATIMA TOU ENTER :)


                                                                                             if ((l=1) or (dataloaded[10]<>0)) then
                                                                                               begin //TO KOUMPI PATITHIKE TELIKA
                                                                                                if objects[i,3]='1' then objects[i,3]:='3' else
                                                                                                if objects[i,3]='3' then objects[i,3]:='4';
                                                                                                draw_btncustom(objects[i,3],objects[i,6],objectsdat[i,1],objectsdat[i,2],objectsdat[i,3],objectsdat[i,4]); 
                                                                                               end else
                                                                                               begin //TO KOUMPI DEN PATITHIKE TELIKA (EINAI SIGOURA ZWGRAFISMENO SWSTA)
                                                                                                objects[i,3]:='1';
                                                                                               end; 


                                                                                             dataloaded[5]:=0;
                                                                                             dataloaded[7]:=i;
                                                                                            end;
                                                                   end;
                         obj_buttonaps:                        begin
                                                                    if dataloaded[5]<>dataloaded[4] then begin  {MOUSE OVER SOMETHING NEW}
                                                                                                          GUI_ChangeCursorIcon(mouse_icon_resource('SELECT'));
                                                                                                          if objects[i,3]='1' then draw_btnaps('2',objects[i,6],objectsdat[i,1],objectsdat[i,2]);
                                                                                                          dataloaded[5]:=dataloaded[4];
                                                                                                         end;
                                                                    if (userclicktype=1) or (dataloaded[10]<>0) then
                                                                                            begin {CLICK}
                                                                                             dataloaded[14]:=i; // Last Object activated..
                                                                                             if objects[i,3]='1' then objects[i,3]:='3' else
                                                                                             if objects[i,3]='3' then objects[i,3]:='1';
                                                                                             draw_btnaps(objects[i,3],objects[i,6],objectsdat[i,1],objectsdat[i,2]);
                                                                                             dataloaded[5]:=0;
                                                                                             dataloaded[7]:=i;
                                                                                            end;
                                                                   end;{ else}
                            end;
                         end;
                     end else begin
                               if dataloaded[5]<>0 then begin
                                                         if Upcase(objects[dataloaded[5],2])<>'WINDOW' then draw_object(dataloaded[5]);
                                                         GUI_ChangeCursorIcon(mouse_icon_resource('ARROW'));
                                                        end;
                               dataloaded[5]:=0;
                              end; 
dataloaded[10]:=0; {stamataei to activate_object}
end;

begin
GetDir(0,curdir);
if Upcase(curdir[Length(curdir)])<>'\' then curdir:=curdir+'\';
start_map:=1;
//ADVANCED READ
advanced_read:=true;
//SPEED SWITCHES
move_snap:=10;
pliktrologisi_speed:=2;{Typing Free Speed oso mikrotero toso grigorotera..}
special_key_speed:=11; // Oso mikrotero toso pio grigora ginetai i enallagi metaksi Shift , Control , Alt, k tou epomenou grammatos..
blink_key_speed:=220; // Oso mikrotero toso pio grigora ginetai to blink tou curosr enw kanoume typing...
cpu_time:=10; //CPU free time on interaction..
//ETC
auto_complete_letter:=3; 
metrics[1]:=2;
//colors[window_border]:=ConvertRGB(0,0,155);
//colors[menu_active]:=ConvertRGB(0,0,155);
//colors[window_background]:=ConvertRGB(0,0,255);
agui_screensaver_disable:=false;

old_style_buttons:=false;
transparent_window_regions:=true;
end.
