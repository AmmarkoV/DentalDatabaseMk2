unit userlogin;

interface

procedure Write_2_Log(msg:string);
procedure Error_Occured(describe:string);

function Get_User_Data(thetype,usrid:integer):string;
function Users_As_A_List:string;
function Get_Total_User_Number:integer;
procedure Init_Login;
procedure Logout;
procedure set_user_state(theuser,state:string);
function get_user_state(theuser:string):string;
function Get_Current_User:string;
function Get_User_Number(thename:string):integer;
function Get_User_Access(tmp:string):integer;
function GUI_Select_User:string;
function login_screen:boolean;
function Incoming_User_Messages:integer;
procedure GUI_User_Command;
procedure Send_Message(recip_user,title,msg:string);
procedure GUI_User_Message;

implementation 
uses windows,ammarunit,apsfiles,pumacrypt,ammargui,string_stuff,tools;
                                 
const title='Login Subsystem';
      Max_Users=13;
      MAX_MSGS=32;
var userusing,curendir:string;
    userlist_count:integer;
    userlist_access:array[1..Max_Users] of integer;
    userlist:array[1..4,1..Max_Users] of string;  //1 Username , 2 Password , Real Name , user status (online,crashed,offline)

 

procedure Error_Occured(describe: string);
begin
  Write_2_Log('ERROR - ' + describe);

  describe := describe + #10 +
    'Λυπύμαστε πολύ για την αναστάτωση , αναφέρετε το πρόβλημα ' +
    'στην A-TECH και βοηθήστε μας να απομακρύνουμε κάθε μικρή ' +
    'ατέλεια από τα εργαλεία σας..';


  MessageBox(
  0,
  PChar(AnsiString(describe)),
  PChar(AnsiString('Σφάλμα κατα την εκτέλεση του προγράμματος..')),
  MB_ICONASTERISK
);
end;


 
 
function Get_Total_User_Number:integer;
begin
Get_Total_User_Number:=userlist_count;
end;

function Get_User_Data(thetype,usrid:integer):string;
begin
Get_User_Data:=userlist[thetype,usrid];
end;

function Users_As_A_List:string;
var i:integer;
    bufstr:string;
begin
bufstr:='';
for i:=1 to Get_Total_User_Number do
  begin
   if i>1 then bufstr:=bufstr+',';
   bufstr:=bufstr+Get_User_Data(1,i);
  end;
Users_As_A_List:=bufstr;
end;

procedure Set_User_Data(thetype,usrid:integer; thedat:string);
begin
userlist[thetype,usrid]:=thedat;
end;

procedure Load_Users_State;
var fileused:text;
    aline:string;
begin
assign(fileused,curendir+'user_state.dat');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                      MessageBox (0, 'Δεν ήταν δυνατή η ανάκτηση της κατάστασης των χρηστών του συστήματος (user_state.dat) !!!' , ' ', 0 + MB_ICONEXCLAMATION);
                      Write_2_Log('ERROR - Could not open user_state.dat');
                    end else
                    begin
                     while not (eof(fileused)) do
                      begin
                        readln(fileused,aline);
                        seperate_words(aline);
                        if Upcase(Get_Memory(1))='USER' then begin
                                                              Set_User_Data(4,get_memory_int(2),get_memory(3));
                                                             end;
                      end;
                    end;
close(fileused);
end;

procedure Save_Users_State;
var fileused:text; 
    i:integer;
begin
assign(fileused,curendir+'user_state.dat');
{$i-}
rewrite(fileused);
{$i+}
if Ioresult<>0 then begin
                      MessageBox (0, 'Δεν ήταν δυνατή η αποθήκευση της κατάστασης των χρηστών του συστήματος (user_state.dat) !!!' , ' ', 0 + MB_ICONEXCLAMATION);
                      Write_2_Log('ERROR - Could not rewrite user_state.dat');
                    end else
                    begin 
                      for i:=1 to Get_Total_User_Number do
                          begin
                           writeln(fileused,'user(',i,',',Get_User_Data(4,i),')');
                          end;  
                    end;
close(fileused);
end;

function get_user_state(theuser:string):string;
var retres:string;
begin
Load_Users_State;
retres:=Get_User_Data(4,Get_User_Number(theuser));
get_user_state:=retres;
end;

procedure set_user_state(theuser,state:string);
begin
Set_User_Data(4,Get_User_Number(theuser),state); 
Save_Users_State;
end;

procedure Write_2_Log(msg:string);
var fileused:text; 
    datesnstuff:array[1..8]of word;
    
begin 
assign(fileused,curendir+'log.dat');
{$i-}
append(fileused);
{$i+}
if Ioresult<>0 then begin 
                       MessageBox (0, 'Πρόβλημα κατα την εγγραφή στο Log' , ' ', 0+ MB_ICONEXCLAMATION);
                      //Den yparxei arxeio.. ,poso mallon mynimata
                    end else
                    begin  
                     GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
                     GetLTime(datesnstuff[5],datesnstuff[6],datesnstuff[7],datesnstuff[8]);
                     write(fileused,Convert2String(datesnstuff[1])+'/'+Convert2String(datesnstuff[3])+'/'+Convert2String(datesnstuff[4])+' ');
                     write(fileused,Convert2String(datesnstuff[5])+':'+Convert2String(datesnstuff[6]));
                     writeln(fileused,+' - '+userusing+' - '+msg);
                     close(fileused);
                    end; 
end;


procedure Add_User(name,pass,real_name:string; access:integer);
begin
userlist_count:=userlist_count+1;
userlist[1,userlist_count]:=name;
userlist[2,userlist_count]:=pass;
userlist[3,userlist_count]:=real_name;
userlist_access[userlist_count]:=access;
end;

function Get_Current_User:string;
begin
Get_Current_User:=userusing;
end;



function Get_User_Number(thename:string):integer;
var i,retres:integer;
begin
retres:=-1;
for i:=1 to userlist_count do
       begin
         if Equal(thename,userlist[1,i]) then begin 
                                               retres:=i;
                                               break;
                                              end;
       end;
Get_User_Number:=retres;
end;

function User_Exists(thename:string):boolean;
var retres:boolean;
begin

if Get_User_Number(thename)=-1 then User_Exists:=false else
                                    User_Exists:=true;
end;

function Get_User_Access(tmp:string):integer;
var retres,i:integer;
begin
for i:=1 to userlist_count do
       begin
         if (userlist[1,i]=tmp) then begin
                                      retres:=userlist_access[i];
                                      break;
                                     end;
       end;
Get_User_Access:=retres;
end;


function GUI_Select_User:string;
var i,yexit,space:integer;
    retres,lastobj:string;
begin
flush_gui_memory(0);
//save_graph_window;
space:=30;
include_object('GUI_Select_User','window','Επιλογή χρήστη','GUI_Select_User','','',(GetMaxX div 2)-150,200,(GetMaxX div 2)+150,300+(userlist_count+2)*space);
draw_all;
yexit:=Y2('GUI_Select_User')-40;
flush_gui_memory(0);

if userlist_count>0 then
     begin
      for i:=1 to userlist_count do
       begin
       retres:=+userlist[3,i]+' ('+userlist[1,i]+') - '+Convert2String(userlist_access[i]);
       include_object('GUI_Select_BTN('+Convert2String(i),'buttonc',retres,'GUI_Select_User','','',-1,250+i*space,-1,0);
       end;
     end else
      begin
        include_object('GUI_Select_BTN('+Convert2String(i),'buttonc','','GUI_Select_User','','',-1,378+5+get_object_size('OK','Y'),-1,0);
      end;
include_object('exit','buttonc','Έξοδος','GUI_Select_User','','',-1,yexit,-1,0);
draw_all;


retres:='';
repeat
interact;
lastobj:=return_last_mouse_object;  
if get_object_data(lastobj)='4' then begin
                                       if (lastobj<>'') then seperate_words(lastobj);
                                       if (get_memory(1)='GUI_Select_BTN') then
                                                                                  begin
                                                                                    Val(get_memory(2),i,space);
                                                                                    if ((i>0) and (i<=userlist_count)) then retres:=userlist[1,i] else
                                                                                                                            retres:='';
                                                                                    set_button('exit',1);
                                                                                  end; 
                                      end;
until get_object_data('exit')='4';
//delete_object('GUI_Select_User','windows');
//load_graph_window;
if retres='' then retres:=userusing;
GUI_Select_User:=retres;
end;


procedure Init_Login;
var fileused:text;
    line:string;
    user_overflow:boolean;
begin
GetDir(0,curendir); 
if curendir[Length(curendir)]<>'\' then curendir:=curendir+'\';
userusing:='';
user_overflow:=false;
assign(fileused,'login.dat');
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then begin
                      while not eof(fileused) do
                            begin
                             readln(fileused,line);
                             seperate_words(line);
                             if Upcase2(get_memory(1))='USER' then
                                            begin
                                              if userlist_count>=Max_Users then user_overflow:=true else
                                                                                Add_User(get_memory(2),get_memory(3),get_memory(4),get_memory_int(5));
                                            end;
                            end;
                      close(fileused);
                      if user_overflow then MessageBox (0, pchar('Το ανώτατο όριο των  '+Convert2String(Max_Users)+' ξεπεράστηκε.. Επικοινωνήστε με την A-TECH για αναβάθμιση του προγράμματος'),title, 0);
                    end else
                     MessageBox (0, 'Δεν είναι δυνατόν να βρεθεί το αρχείο με την λίστα χρηστών - Επικοινωνήστε με την A-TECH' ,title, 0);

end;

procedure Save_Login;
var fileused:text;
    i:integer;
begin
assign(fileused,'login.dat');
{$i-}
rewrite(fileused);
{$i+}
if Ioresult=0 then
  begin
   for i:=1 to userlist_count do writeln(fileused,'user('+userlist[1,i]+','+userlist[2,i]+','+userlist[3,i]+','+Convert2String(userlist_access[i])+')');
   close(fileused);
  end;
end;

procedure Logout;
begin
Write_2_Log('Loging out - Session end');
end;

function check_user_pass(user,pass:string):boolean;
var i:integer;
    retres:boolean;
    thehiddenpass:string;
begin
retres:=false;
if userlist_count>0 then begin
                          setthekey('nh3d2e9SJ07@#sF_@*');
                          thehiddenpass:=encrypt_string(user+pass);
                          for i:=1 to userlist_count do
                                      begin
                                        if ((userlist[1,i]=user) and (userlist[2,i]=thehiddenpass)) then begin
                                                                                                          retres:=true;
                                                                                                         end;
                                      end;
                         end;
check_user_pass:=retres;
end;


{
function check_user_pass(user,pass:string):boolean;
var i:integer;
    retres:boolean;
    thehiddenpass:string;
begin
retres:=false;
if userlist_count>0 then begin
                          setthekey('nh3d2e9SJ07@#sF_@*');
                          thehiddenpass:=encrypt_string(user+pass);
                          for i:=1 to userlist_count do
                                      begin
                                        if ((userlist[1,i]=user) and (userlist[2,i]=pass)) then begin 
                                                                                                 retres:=true;
                                                                                                end;
                                      end;
                         end;
check_user_pass:=retres;
end;
}

function login_screen:boolean;
var i,retainparam8,failcount:integer;
    reservebuf:dword;
    usersel,bufstr:string;
    memory:array[1..2]of string;
    updateprogram,updatedatabase,retres:boolean;
label exit_program,restart_login_screen;
begin 
retres:=true;
failcount:=0;
clrscreen; 
restart_login_screen:
flush_gui_memory(0);

draw_background(3);
ChangeCursorIcon(mouse_icon_resource('arrow'));
LoadAps('atechlogo');
DrawAPSXY2('atechlogo',GetMaxX-GetApsInfo('atechlogo','sizex')-20,GetMaxY-GetApsInfo('atechlogo','sizey')-20);
UnLoadAps('atechlogo');


SetFont('arial','greek',30,0,0,0);
GotoXY(1,30);
OutTextCenter('Login');
SetFont('arial','greek',15,0,0,0);

include_object('LoginWindow','window','Login','LoginWindow','','',(GetMaxX div 2)-100,200,(GetMaxX div 2)+100,470);  
draw_all;
delete_object('LoginWindow','NAME'); 
set_gui_color(ConvertRGB(0,0,0),'comment');
include_object('usercom','comment','Χρήστης : ','','','',(GetMaxX div 2)-70,257,(GetMaxX div 2),0);
include_object('passcom','comment','Κωδικός : ','','','',(GetMaxX div 2)-70,297,(GetMaxX div 2),0);
{include_object('username','textbox','','LoginWindow','','',(GetMaxX div 2)-70,254,(GetMaxX div 2)+70,283);
include_object('password','textbox-password','','LoginWindow','','',(GetMaxX div 2)-70,294,(GetMaxX div 2)+70,313);}
include_object('username','textbox','','LoginWindow','','',X2('usercom')+5,254,(GetMaxX div 2)+70,283);
include_object('password','textbox-password','','LoginWindow','','',X2('passcom')+5,294,(GetMaxX div 2)+70,313);
include_object('OK','buttonc','Ok','LoginWindow','','',-1,378,-1,0);
include_object('exit','buttonc','Exit','LoginWindow','','',-1,378+5+get_object_size('OK','Y'),-1,0);


SetInternalKeyboardLanguage('English');
draw_all; 

bufstr:=get_object_data('username');
repeat
interact;
if get_object_data('username')<>bufstr then begin
                                                activate_object('password');
                                                bufstr:=get_object_data('username');
                                               end;
until (get_object_data('OK')='4') or (GUI_Exit);
if (GUI_Exit) then begin
                    retres:=false;
                    goto exit_program;
                   end;
if (check_user_pass(get_object_data('username'),get_object_data('password'))) then begin
                                                                                     usersel:=get_object_data('username'); 
                                                                                     Write_2_Log(' Successful Login as user '+get_object_data('username'));
                                                                                   end else
                                                                                               begin
                                                                                                 ChangeCursorIcon(mouse_icon_resource('arrow'));  
                                                                                                 failcount:=failcount+1; 
                                                                                                 MessageBox (0, 'Wrong Username/Password' ,title, 0 + MB_ICONHAND + MB_SYSTEMMODAL);
                                                                                                 Write_2_Log('Wrong Username/Password for user '+get_object_data('username'));
                                                                                                 if failcount>=3 then begin
                                                                                                                       Write_2_Log('Maximum login attempts reached locking down..');
                                                                                                                       //MessageBox (0, 'Maximum login attempts reached :-P !' , title, 0);
                                                                                                                       outtextcenter('Program Locked - The owner of the computer will be informed for your attempt!');
                                                                                                                       delay(1000);
                                                                                                                       failcount:=0;
                                                                                                                       repeat
                                                                                                                       delay(700);
                                                                                                                       clrscreen;
                                                                                                                       if Random<0.1 then  bufstr:='LOCKED DOWN' else
                                                                                                                       if Random<0.125 then bufstr:='DATABASE SECURED' else
                                                                                                                       if Random<0.15 then bufstr:='SECURE' else
                                                                                                                       if Random<0.2 then  bufstr:=':-P' else
                                                                                                                                           bufstr:='!';
                                                                                                                       for i:=1 to 30 do begin 
                                                                                                                                          OutTextXY(random(GetMaxX),random(GetMaxY),bufstr);
                                                                                                                                         end;
                                                                                                                       if (GetAsyncKeyState(VK_SHIFT)=1) or (GetAsyncKeyState(VK_CONTROL)=1) or (GetAsyncKeyState(VK_MENU)=1) then failcount:=failcount+1;
                                                                                                                       if (GetAsyncKeyState(VK_CANCEL)=1) or (GetAsyncKeyState(VK_TAB)=1) or (GetAsyncKeyState(VK_ESCAPE)=1) then failcount:=failcount+1;
                                                                                                                       if failcount>2 then begin
                                                                                                                                            reservebuf:=0;
                                                                                                                                            ExitWindowsEx(EWX_SHUTDOWN,reservebuf);
                                                                                                                                            exit; 
                                                                                                                                            failcount:=0; 
                                                                                                                                           end;
                                                                                                                       until i=21;  
                                                                                                                       ShutDownComputer;
                                                                                                                       retres:=false;
                                                                                                                       goto exit_program;
                                                                                                                      end;
                                                                                                 goto restart_login_screen; 
                                                                                               end;




SetInternalKeyboardLanguage('Greek');
userusing:=get_object_data('username'); 

if (not check_file_existance('Users\'+usersel+'.jpg')) then usersel:='default'; 
if check_file_existance('Users\'+usersel+'.jpg') then
begin
                                                              
   LoadPicture('Users\'+usersel+'.jpg');

   //draw_background(3); EINAI SPASTIKO GIATI TA JPG DN EXOUN TRANSPARENCY K FAINONTAI PSILO XALIA..
   clrscreen;
   DrawApsCentered2('Users\'+usersel);
 
   flush_gui_memory(0);

   SetFont('arial','greek',50,0,0,0);
   GotoXY(0,30+(GetMaxY Div 2)+((GetApsInfo(userusing,'sizey')) Div 2) );
   OutTextCenter('Καλωσήρθες '+First_Capital(userusing)+'..');
   interact;
   delay(700);
end;

exit_program:
ChangeCursorIcon(mouse_icon_resource('arrow'));
if check_file_existance('Users\'+usersel+'.jpg') then UnloadAps('Users\'+usersel);
SetFont('arial','greek',15,0,0,0); 
login_screen:=retres; 
end;



function Incoming_User_Messages:integer;
var fileused:text;
    aline:string;
    rest:integer;
begin
rest:=0;
assign(fileused,'Users\'+userusing+'_msgs.dat');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                      rest:=0;
                      //Den yparxei arxeio.. ,poso mallon mynimata
                    end else
                    begin
                     while (not eof(fileused)) do
                        begin
                         readln(fileused,aline);
                         seperate_words(aline);
                         if Upcase(get_memory(1))='MSG' then rest:=rest+1;
                        end;
                     close(fileused);
                    end;
Incoming_User_Messages:=rest;
end;

 
procedure Send_User_Message(send_user,recip_user,title,msg:string);
var fileused:text; 
    datesnstuff:array[1..4]of word;
    
begin 
assign(fileused,'Users\'+recip_user+'_msgs.dat');
{$i-}
append(fileused);
{$i+}
if Ioresult<>0 then begin 
                       MessageBox (0, 'Πρόβλημα κατα την αποστολή του μηνύματος , το μήνυμα δεν έφτασε στον παραλήπτη..' , ' ', 0+ MB_ICONEXCLAMATION);
                      //Den yparxei arxeio.. ,poso mallon mynimata
                    end else
                    begin  
                     GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
                     writeln(fileused,'MSG('+send_user+','+title+','+msg+','+Convert2String(datesnstuff[1])+'/'+Convert2String(datesnstuff[3])+'/'+Convert2String(datesnstuff[4])+')');
                     close(fileused);
                    end; 
end;

procedure Send_User_Old_Message(send_user,recip_user,title,msg:string);
var fileused:text; 
    datesnstuff:array[1..4]of word;
    
begin 
assign(fileused,'Users\'+recip_user+'_old_msgs.dat');
{$i-}
append(fileused);
{$i+}
if Ioresult<>0 then begin 
                       MessageBox (0, 'Πρόβλημα κατα την αποθήκευση του μηνύματος..' , ' ', 0+ MB_ICONEXCLAMATION);
                      //Den yparxei arxeio.. ,poso mallon mynimata
                    end else
                    begin  
                     GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
                     writeln(fileused,'MSG('+send_user+','+title+','+msg+','+Convert2String(datesnstuff[1])+'/'+Convert2String(datesnstuff[3])+'/'+Convert2String(datesnstuff[4])+')');
                     close(fileused);
                    end; 
end;

procedure Send_Message(recip_user,title,msg:string);
begin
Send_User_Message(Get_Current_User,recip_user,title,msg);
end;

procedure GUI_Send_Message_Person;
var user2send,title,msg:string;
label start_send_message;
begin
user2send:='';
title:='';
msg:='';
start_send_message:
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');  

include_object('window1','window','Αποστολή μηνύματος.. ','no','','',GridX(1,3),300,GridX(2,3),500);
draw_all;
delete_object('window1','name');
include_object('tocmm','comment','Προς : ','no','','',GridX(1,3)+30,360,0,0);
include_object('to','textbox',user2send,'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+100,0);
include_object('towhom','buttonc','’τομα','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('titlecmm','comment','Τίτλος : ','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('title','textbox',title,'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+140,0);
include_object('datacmm','comment','Περιεχόμενο : ','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('data','textbox',msg,'no','','',X2(last_object)+10,Y1(last_object),GridX(2,3)-10,0);

include_object('ok','buttonc','Αποστολή','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;
repeat
interact;

if get_object_data('towhom')='4' then begin
                                       set_button('towhom',0);
                                       user2send:=GUI_Select_User;
                                       goto start_send_message;
                                      end else
if get_object_data('ok')='4' then begin 
                                    if (not User_Exists(get_object_data('to'))) then MessageBox (0, pchar('O Χρήστης '+get_object_data('to')+' δεν υπάρχει'), ' ', 0);
                                     begin
                                      Send_User_Message(Get_Current_User,get_object_data('to'),get_object_data('title'),get_object_data('data'));
                                     end;
                                    set_button('exit',1);
                                  end; 
until GUI_Exit;
end;


procedure GUI_Save_User(id_num:integer; new_usr:boolean);
var user2send,title,msg:string;
    startx,start_text,i,z:integer;
    files2create:array[1..4] of string;
label start_send_message;
begin



if userlist_access[id_num]>userlist_access[Get_User_Number(Get_Current_User)] then MessageBox (0, 'Δεν έχετε αρκετά μεγάλο επίπεδο πρόσβασης για να δείτε τα στοιχεία..' , ' ', 0 + MB_ICONASTERISK) else
begin
user2send:='';
title:='';
msg:='';
start_send_message:
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');  

startx:=GridX(1,3);
include_object('window1','window','Χρήστης '+Convert2String(id_num)+'.. ','no','','',startx,300,GridX(2,3),600);
draw_all;
delete_object('window1','name'); 
startx:=startx+30;
start_text:=startx+130;
include_object('username_comm','comment','Username : ','no','','',startx,360,0,0);
include_object('username','textbox',userlist[1,id_num],'no','','',start_text,Y1(last_object),GridX(2,3)-10,0);
include_object('pass_comm','comment','Κωδικός','no','','',startx,Y2(last_object)+10,0,0);
include_object('password','textbox-password',userlist[2,id_num],'no','','',start_text,Y1(last_object),GridX(2,3)-10,0);
include_object('pass2_comm','comment','Επανάληψη κωδικού','no','','',startx,Y2(last_object)+10,0,0);
include_object('password2','textbox-password',userlist[2,id_num],'no','','',start_text,Y1(last_object),GridX(2,3)-10,0);
include_object('realnname_comm','comment','Πραγματικό Όνομα','no','','',startx,Y2(last_object)+10,0,0);
include_object('realname','textbox',userlist[3,id_num],'no','','',start_text,Y1(last_object),GridX(2,3)-10,0);
include_object('access_comm','comment','Επίπεδο Πρόσβασης','no','','',startx,Y2(last_object)+10,0,0);
include_object('access','textbox',Convert2String(userlist_access[id_num]),'no','','',start_text,Y1(last_object),GridX(2,3)-10,0);

include_object('ok','buttonc','Αποθήκευση','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all; 
repeat
interact;
 
if get_object_data('ok')='4' then begin 
                                    Val(get_object_data('access'),z,i);
                                    if z>userlist_access[Get_User_Number(Get_Current_User)] then MessageBox (0, 'Δεν έχετε το δικαίωμα να δώσετε τόσο μεγάλο βαθμό πρόσβασης..' , ' ', 0 + MB_ICONEXCLAMATION)  else
                                    if get_object_data('password')<>get_object_data('password2') then MessageBox (0, 'Ο κωδικός που δώσατε δεν συμφωνεί με την επανάληψη του..' , ' ', 0 + MB_ICONEXCLAMATION) else
                                    if User_Exists(get_object_data('username')) then MessageBox (0, 'Ο χρήστης αυτός υπάρχει ήδη..' , ' ', 0 + MB_ICONEXCLAMATION) else
                                    begin
                                     userlist[1,id_num]:=get_object_data('username');

                                     setthekey('nh3d2e9SJ07@#sF_@*'); 
                                     userlist[2,id_num]:=encrypt_string(get_object_data('username')+get_object_data('password'));
                                     //userlist[2,id_num]:= get_object_data('password');
                                     userlist[3,id_num]:=get_object_data('realname');
                                     Val(get_object_data('access'),userlist_access[id_num],i);
                                     if new_usr then begin
                                                      files2create[1]:=curendir+'Users\'+Greeklish(userlist[1,id_num])+'.money';
                                                      files2create[2]:=curendir+'Users\'+Greeklish(userlist[1,id_num])+'_msgs.dat';
                                                      for i:=1 to 2 do
                                                       begin
                                                        //if check_file_existance(files2create[i]) then MessageBox (0, PChar('Το αρχείο αυτό '+files2create[i]+' υπάρχει ήδη!'), ' ', 0 + MB_ICONASTERISK) else
                                                         if check_file_existance(files2create[i]) then
  MessageBoxA(
    0,
    PAnsiChar(AnsiString(
      'Το αρχείο αυτό ' + files2create[i] + ' υπάρχει ήδη!'
    )),
    PAnsiChar(AnsiString(' ')),
    MB_ICONASTERISK
  )
else


                                                           begin
                                                            //if (not (create_file(files2create[i]))) then MessageBox (0, PChar('Το αρχείο '+files2create[i]+' δεν μπόρεσε να δημιουργηθεί!'), ' ', 0 + MB_ICONASTERISK);
                                                           if not create_file(files2create[i]) then
  MessageBoxA(
    0,
    PAnsiChar(AnsiString(
      'Το αρχείο ' + files2create[i] + ' δεν μπόρεσε να δημιουργηθεί!'
    )),
    PAnsiChar(AnsiString(' ')),
    MB_ICONASTERISK
  );
                                                           end;
                                                       end;
                                                     end;
                                     Save_Login;
                                    end; 
                                     set_button('exit',1);
                                  end; 
until (GUI_Exit);
end; //ACCESS CHECK
end;


procedure GUI_User_Command;
var bufstr,lastobj,retres:string;
    i,space:integer; 
begin  
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');  

include_object('window1','window','Χρήστες.. ','no','','',GridX(1,3),230,GridX(2,3),230+30+((userlist_count+2)*30));
draw_all;
delete_object('window1','name');

for i:=1 to userlist_count do
       begin
       bufstr:=+userlist[3,i]+' ('+userlist[1,i]+') - '+Convert2String(userlist_access[i]);
       include_object('GUI_Select_BTN('+Convert2String(i),'buttonc',bufstr,'GUI_Select_User','','',-1,250+i*30,-1,0);
       end;

include_object('new','buttonc','Νέος χρήστης','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;

retres:='';
repeat
interact;
lastobj:=return_last_mouse_object;  
if get_object_data('new')='4' then begin
                                    set_button('new',1);
                                    if userlist_access[Get_User_Number(Get_Current_User)]<500 then MessageBox (0, pchar('Δεν έχετε αρκετά μεγάλο επίπεδο πρόσβασης για να δημιουργήσετε νέο χρήστη') , ' ', 0 + MB_ICONHAND) else
                                    if userlist_count+1>Max_Users then MessageBox (0, pchar('Δεν μπορείτε να έχετε παραπάνω από '+Convert2String(Max_Users)+' χρήστες') , ' ', 0 + MB_ICONHAND) else
                                             begin
                                              userlist_count:=userlist_count+1;
                                              GUI_Save_User(userlist_count,true);
                                             end;

                                   end else
if get_object_data(lastobj)='4' then begin
                                       if (lastobj<>'') then
                                       begin
                                        seperate_words(lastobj);
                                        if (get_memory(1)='GUI_Select_BTN') then
                                                                                  begin
                                                                                    Val(get_memory(2),i,space);
                                                                                    if ((i>0) and (i<=userlist_count)) then GUI_Save_User(i,false) else
                                                                                                                            retres:='';
                                                                                    set_button('exit',1);
                                                                                  end;
                                       end;
                                      end;
until GUI_Exit;
 
end;

procedure GUI_User_Message;
var fileused:text;
    aline,lastobj:string;
    themsgs:array[1..4,1..MAX_MSGS] of string;
    msgs_read:array[1..MAX_MSGS]of byte;
    msgs,yexit,space,i:integer;
    label start_user_message;
begin 
start_user_message:
assign(fileused,'Users\'+userusing+'_msgs.dat');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin                                                                 
                       MessageBox (0, 'Πρόβλημα κατα την ανάγνωση του αρχείου μηνυμάτων..' , ' ', 0+ MB_ICONEXCLAMATION+MB_YESNO);
                       i:=MessageBox (0, 'Θέλετε να δημιουργηθεί καινούργιο αρχείο μηνυμάτων (Υπάρχει περίπτωση να χαθούν τα μηνύματα που σας έχουν σταλεί)..' , ' ', 0+ MB_ICONASTERISK);
                       if i=IDYES then begin
                                      rewrite(fileused);
                                      close(fileused);
                                      Send_User_Message('System',Get_Current_User,'System msg','Δημιουργία καινούργιου αρχείου μηνυμάτων..');
                                     end;
                      //Den yparxei arxeio.. ,poso mallon mynimata
                    end else
                    begin  
                     msgs:=0;
                     while (not eof(fileused)) do
                        begin
                         readln(fileused,aline);
                         if aline<>'' then seperate_words(aline);
                         if Upcase(get_memory(1))='MSG' then begin
                                                              msgs:=msgs+1;
                                                              if (msgs<=MAX_MSGS) then
                                                                 begin
                                                                  themsgs[1,msgs]:=get_memory(2);
                                                                  themsgs[2,msgs]:=get_memory(3);
                                                                  themsgs[3,msgs]:=get_memory(4);
                                                                  themsgs[4,msgs]:=get_memory(5);
                                                                  msgs_read[msgs]:=0;
                                                                 end; 
                                                             end;
                        end; 
                     close(fileused);

                     space:=30;
                     flush_gui_memory(0);
                     include_object('GUI_Select_User','window','Μηνύματα','','','',(GetMaxX div 2)-250,200,(GetMaxX div 2)+250,300+(msgs+2)*space);
                     draw_all;
                     yexit:=Y2('GUI_Select_User')-40;
                     delete_object('GUI_Select_User','NAME');

                     if msgs>0 then
                          begin
                             for i:=1 to msgs do
                                      begin 
                                        aline:='Μήνυμα από '+themsgs[1,i]+' - '+themsgs[4,i]+'  -  ';
                                        aline:=aline+themsgs[2,i];
                                        include_object('Message('+Convert2String(i),'comment',aline,'','','',(GetMaxX div 2)-200,250+i*space,0,0);
                                        include_object('OK('+Convert2String(i),'buttonc','Ανάγνωση','','','',X2(last_object)+7,Y1(last_object),0,0);
                                      end;
                           end else
                           begin
                             include_object('nomsgs','comment','Δεν υπάρχουν εισερχόμενα μηνύματα..','','','',(GetMaxX div 2)-200,250+1*space,0,0);
                           end;

                      include_object('send','buttonc','Αποστολή','GUI_Select_User','','',-1,yexit,-1,0);
                      include_object('ok_all','buttonc','Αναγνωσμένα όλα','GUI_Select_User','','',X2(last_object)+7,yexit,-1,0);
                      include_object('exit','buttonc','Έξοδος','GUI_Select_User','','',X2(last_object)+7,yexit,-1,0);
                      set_gui_color(ConvertRGB(0,0,0),'comment');
                      draw_all;
                      repeat
                       interact;
                       lastobj:=return_last_mouse_object;  
                       if get_object_data('send')='4' then begin
                                                            GUI_Send_Message_Person;
                                                            goto start_user_message;
                                                           end else
                       if get_object_data('ok_all')='4' then begin
                                                              for i:=1 to msgs do msgs_read[i]:=1;
                                                              assign(fileused,'Users\'+userusing+'_msgs.dat');
                                                               {$i-}
                                                                 rewrite(fileused);
                                                               {$i+}
                                                               close(fileused);
                                                               break;
                                                             end;
                       if get_object_data(lastobj)='4' then begin
                                                              if (lastobj<>'') then seperate_words(lastobj);
                                                              if (get_memory(1)='OK') then
                                                                                  begin
                                                                                    Val(get_memory(2),i,space);
                                                                                    if ((i>0) and (i<=msgs)) then msgs_read[i]:=1;  
                                                                                    set_button('lastobj',1);
                                                                                  end; 
                                                            end;
                      until GUI_Exit;


                     end;
end;


 



begin
end.
