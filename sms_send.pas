unit sms_send;

interface
procedure Init_SMS_Send;

function  SMS_Query_Time:integer;
function  SMS_Days_Before:integer;

procedure InitSMSScript(theuser:string);
procedure CloseSMSScript;
procedure Add2SMSScript(thetel,themsg:string);
//procedure GUI_Prototype(ax,ay,ax2,ay2:integer);
procedure GUI_SMS_Settings(ax,ay,ax2,ay2:integer);

implementation 
uses ammarunit,ammargui,apsfiles,userlogin,settings,tools;
var com_port,carrier_num,msg,user_commanded:string;
    carrier_id,tot_msgs,exec_time,days_before:integer;
    enabled:boolean;
    fileused:text;
    file_opened:boolean;
    msg_cost,tot_msg_cost:real;


function  SMS_Query_Time:integer;
begin
SMS_Query_Time:=exec_time;
end;


function  SMS_Days_Before:integer;
begin
SMS_Days_Before:=days_before;
end;

procedure InitSMSScript(theuser:string);
begin
Write_2_Log('Init SMS Send scripting..');
assign(fileused,AnalyseFilename(get_external_synctool,'directory')+'script.txt');
{$i-}
rewrite(fileused);
{$i+}
 if Ioresult=0 then
    begin
     file_opened:=true;
     user_commanded:=theuser;
     Write_2_Log('SMS Operation Started..');
     writeln(fileused,'CONNECT_COM(COM'+com_port+')');
     writeln(fileused,'SET_MSG_CENTER('+carrier_num+')'); 
     tot_msgs:=0;
    end else
    begin
      Write_2_Log('SMS Operation Failed - Unable to access script file..');
      file_opened:=false;
    end;
end;

procedure CloseSMSScript;
var tmp:string;
begin
if file_opened then
   begin
    Write_2_Log('SMS Operation successfuly ending - Closing Script file..');
    writeln(fileused,'DISCONNECT_COM');
    tot_msg_cost:=msg_cost*tot_msgs;
    Str(tot_msg_cost,tmp);
    Write_2_Log('Upon execution SMS messaging will cost '+tmp+'€.. ');
    Write_2_Log('$'+tmp+','+Convert2String(tot_msgs)+','+user_commanded+'$');
    close(fileused);
   end;

file_opened:=false;
end;


procedure Add2SMSScript(thetel,themsg:string);
begin
if file_opened then
   begin
    writeln(fileused,'EMULATE_SEND_SMS('+thetel+','+themsg+')'); 
    tot_msgs:=tot_msgs+1;
   end; 
file_opened:=false;
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


function bool_2_chkbox(thebool:boolean):string;
begin
if thebool then bool_2_chkbox:='3' else
                bool_2_chkbox:='1';
end;


function chkbox_2_bool(thename:string):boolean;
begin
if get_object_data(thename)='3' then chkbox_2_bool:=true else
                                     chkbox_2_bool:=false;
end;


procedure Save_SMS_form;
var i:integer;
begin
com_port:=get_object_data('comport');
carrier_num:=get_object_data('msgcenter_num');
msg:=get_object_data('msg');
user_commanded:=Get_Current_User;
Val(get_object_data('msgcenter'),carrier_id,i); 
Val(get_object_data('msgcost'),msg_cost,i);
enabled:=chkbox_2_bool('enabled');
end;


procedure Load_SMS_form;
var i:integer;
    bufstr:string;
begin
set_object_data('comport','value',com_port,0);
set_object_data('msgcenter_num','value',carrier_num,0);
set_object_data('msg','value',msg,0);
set_object_data('msgcenter','value',Convert2String(carrier_id),0);
Str(msg_cost:0:2,bufstr);
set_object_data('msgcost','value',bufstr,0);
set_object_data('enabled','value',bool_2_chkbox(enabled),0);

end;


procedure Save_SMS_Settings;
var file2write:text;
begin
assign(file2write,get_central_dir+'sms_settings.dat');
rewrite(file2write);
writeln(file2write,com_port);
writeln(file2write,carrier_num);
writeln(file2write,msg);
writeln(file2write,carrier_id);
writeln(file2write,msg_cost);
writeln(file2write,user_commanded);
writeln(file2write,exec_time); 
if enabled then writeln(file2write,1)  else
                writeln(file2write,0);


close(file2write); 
end;


procedure Load_SMS_Settings;
var file2write:text;
    tmp,i:integer;
begin
assign(file2write,get_central_dir+'sms_settings.dat');
{$i-}
reset(file2write);
{$i+}
if Ioresult=0 then
  begin
    i:=0;
     while not eof(file2write) do
       begin
        i:=i+1;
        case i of
        1:readln(file2write,com_port);
        2:readln(file2write,carrier_num);
        3:readln(file2write,msg);
        4:readln(file2write,carrier_id);
        5:readln(file2write,msg_cost);
        6:readln(file2write,user_commanded);
        7:readln(file2write,exec_time);
        8:begin
             readln(file2write,tmp);
              if tmp=1 then enabled:=true else
                            enabled:=false;
          end;
        end;
       end;
    if i>8 then Write_2_Log('sms_settings.dat error!');
   close(file2write);
  end;
end;

procedure Init_SMS_Send;
begin
Load_SMS_Settings;
end;


procedure GUI_SMS_Settings(ax,ay,ax2,ay2:integer);
var i:integer;
    last_carrier_choice:string;
begin
Load_SMS_Settings;

flush_gui_memory(0);
repeat
flush_gui_memory(0);
include_object('a_not_main_window','window','SMS - Ρυθμίσεις..','','','',ax,ay,ax2-1,ay2-1);
draw_all;
delete_object('a_not_main_window','NAME');

//PREPEARTION
include_object('comm1','comment','Ρυθμίσεις COM πόρτας GSM Modem : ','','','',ax+15,ay+40,0,0);
include_object('comport','textbox','','','','',X2(last_object)+10,Y1(last_object)-3,X2(last_object)+50,0);

include_object('comm11','comment','Αποστολή SMS Ενεργοποιημένη : ','','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('enabled','checkbox',bool_2_chkbox(enabled),'','','',X2(last_object)+10,Y1(last_object)-3,X2(last_object)+50,0);


include_object('comm2','comment','Κέντρο μηνυμάτων : ','','','',ax+15,Y2('comport')+8,0,0);
include_object('msgcenter','dropdown','Vodafone Greece,WIND Greece,Cosmote Greece','','','',X2(last_object)+10,Y1(last_object)-3,X2(last_object)+150,0);
include_object('msgcenter_num','textbox','+3069xxxxxxxx','','','',X2(last_object)+10,Y1(last_object),X2(last_object)+150,0);

include_object('comm3','comment','Κόστος μηνύματος : ','','','',ax+15,Y2(last_object)+8,0,0);
include_object('msgcost','textbox','','','','',X2(last_object)+10,Y1(last_object)-3,X2(last_object)+50,0);

include_object('comm31','comment','Αποστολή του μηνύματος ','','','',X2(last_object)+10,Y1(last_object)+3,0,0);
include_object('daysbefore','textbox','4','','','',X2(last_object)+10,Y1(last_object)-3,X2(last_object)+50,0);
include_object('comm32','comment',' ημέρες πρίν ραντεβού','','','',X2(last_object)+10,Y1(last_object)+3,0,0);

include_object('comm333','comment','Το ραντεβού πρέπει να απέχει : ','','','',ax+15,Y2('daysbefore')+8,0,0);
include_object('daysafter','textbox','10','','','',X2(last_object)+10,Y1(last_object)-3,X2(last_object)+50,0);
include_object('comm332','comment',' ημέρες από την τελευταία επίσκεψη ','','','',X2(last_object)+10,Y1(last_object)+3,0,0);


include_object('comm32','comment','Κείμενο μηνύματος : ','','','',ax+15,Y2('daysafter')+8,0,0);
include_object('msg','textbox','%c , Αγαπητέ/ή %n %s σας υπενθυμίζουμε το ραντεβού μας στις %d και ώρα %t .','','','',X2(last_object)+10,Y1(last_object)-3,ax2-15,0);

include_object('comm4','comment','Χρήστες  : ','','','',ax+15,Y2(last_object)+8,0,0);
for i:=1 to Get_Total_User_Number do
  begin
   include_object('comm5'+Convert2String(i),'comment',Get_User_Data(3,i)+'  : ','','','',X2(last_object)+10,Y1(last_object)+3,0,0);
   include_object('user('+Convert2String(i),'checkbox','1','','','',X2(last_object)+10,Y1(last_object)-3,X2(last_object)+50,0);
   if X2(last_object)+100>ax2 then begin
                                      include_object('spc'+Convert2String(i),'comment',' ','','','',ax+15,Y2(last_object)+8,0,0);
                                   end;
  end;


include_object('exit','buttonc','Αποθήκευση','','','',-1,ay2-30,-1,0);

  //END PREPERATION
  GUI_Enter_Form('GUI_Prototype');


  Flash_AmmarGUI('GUI_Prototype');
  Load_SMS_form;
  last_carrier_choice:=get_object_data('msgcenter');
  draw_all;
 repeat
  interact;
  if last_carrier_choice<>get_object_data('msgcenter') then
                  begin
                   last_carrier_choice:=get_object_data('msgcenter');                             // +3094219000
                   if last_carrier_choice='1' then  set_object_data('msgcenter_num','value','+306942190000',0) else
                   if last_carrier_choice='2' then  set_object_data('msgcenter_num','value','+30693599000',0) else
                   if last_carrier_choice='3' then  set_object_data('msgcenter_num','value','+3097100000',0);
                   draw_object_by_name('msgcenter_num');
                  end;


 until GUI_Exit or window_needs_redraw; 
 DeFlash_AmmarGUI('GUI_Prototype');


until GUI_Exit;
Save_SMS_form;
GUI_Exit_Form('GUI_Prototype'); 
Save_SMS_Settings;
end;

{
procedure GUI_Prototype(ax,ay,ax2,ay2:integer);
begin
flush_gui_memory(0);
include_object('a_not_main_window','window','SMS - Ρυθμίσεις..','','','',ax,ay,ax2-1,ay2-1);
draw_all;
delete_object('a_not_main_window','NAME');

//PREPEARTION
include_object('comm1','comment','Ρυθμίσεις COM πόρτας GSM Modem : ','','','',ax+5,ay+40,0,0);
include_object('comport','textbox','','','','',X2(last_object)+10,Y1(last_object)-3,X2(last_object)+50,0);
//END PREPERATION

GUI_Enter_Form('GUI_Prototype');
repeat 

  Flash_AmmarGUI('GUI_Prototype');
  draw_all;
 repeat
  interact;

 until GUI_Exit or window_needs_redraw; 
  DeFlash_AmmarGUI('GUI_Prototype');

until GUI_Exit;
GUI_Exit_Form('GUI_Prototype'); 
end;

}


begin
end.
