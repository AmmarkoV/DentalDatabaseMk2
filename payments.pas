unit payments;

interface
procedure Init_Payments;  
function Calculate_Income(user:string; day1,month1,year1,day2,month2,year2:integer):integer;
procedure Add_2_Income(user:string; day1,month1,year1,money:integer);
procedure GUI_Issue_Payment;

implementation 
uses windows,ammarunit,apsfiles,ammargui,calender,string_stuff,userlogin;
var curendir:string;

procedure Init_Payments;
begin
GetDir(0,curendir); 
if curendir[Length(curendir)]<>'\' then curendir:=curendir+'\'; 
end;

procedure GUI_Issue_Payment;
var user2send:string;
    day,month,year,money,i:integer;
    datesnstuff:array[1..4]of word;
label start_send_message;
begin

if Get_User_Access(Get_Current_User)<500 then MessageBox (0, 'Δεν έχετε αρκετά μεγάλο επίπεδο πρόσβασης για να εκδώσετε πληρωμή..' , ' ', 0 + MB_ICONASTERISK) else
begin 

GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
user2send:=''; 
money:=0;
day:=datesnstuff[1];
month:=datesnstuff[3];
year:=datesnstuff[4];
start_send_message:
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');  

include_object('window1','window','Πληρωμή.. ','no','','',GridX(1,3)-30,300,GridX(2,3)+30,500);
draw_all;
delete_object('window1','name');
include_object('tocmm','comment','Πληρωμή προς : ','no','','',GridX(1,3)+30,360,0,0);
include_object('to','textbox',user2send,'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+100,0);
include_object('towhom','buttonc','Άτομα','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('titlecmm','comment','Ημερομηνία : ','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('day','textbox',Convert2String(day),'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+15+TextWidth('XXX'),0);
include_object('/','comment','/','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('month','textbox',Convert2String(month),'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+15+TextWidth('XXX'),0);
include_object('//','comment','/','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('year','textbox',Convert2String(year),'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+15+TextWidth('XXXXX'),0);
include_object('opencal','buttonc','Ημερολόγιο','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('moncmm','comment','Ποσό : ','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('money','textbox',Convert2String(money),'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+100,0);

include_object('ok','buttonc','Πληρωμή','no','','',GridX(1,3)+45,Y2(last_object)+10,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;
repeat
interact;
if get_object_data('opencal')='4' then begin
                                       set_button('opencal',0);
                                       Val(get_object_data('day'),day,i);
                                       Val(get_object_data('month'),month,i);
                                       Val(get_object_data('year'),year,i);
                                       Val(get_object_data('money'),money,i);
                                       user2send:=get_object_data('to');
                                       i:=1;
                                       GUI_select_day_month(day,month,year,i);
                                       goto start_send_message;
                                      end else
if get_object_data('towhom')='4' then begin
                                       set_button('towhom',0);
                                       Val(get_object_data('day'),day,i);
                                       Val(get_object_data('month'),month,i);
                                       Val(get_object_data('year'),year,i);
                                       Val(get_object_data('money'),money,i);
                                       user2send:=GUI_Select_User;
                                       goto start_send_message;
                                      end else
if get_object_data('ok')='4' then begin 
                                    Val(get_object_data('day'),day,i);
                                    Val(get_object_data('month'),month,i);
                                    Val(get_object_data('year'),year,i);
                                    Val(get_object_data('money'),money,i);
                                    user2send:=get_object_data('to');
                                    if user2send='' then MessageBox (0, 'Δεν έχετε δώσει κάποιον χρήστη  στον οποίο να γίνει η πληρωμή!' , ' ', 0 + MB_ICONASTERISK) else
                                    //if money=0 then MessageBox (0, PChar('Δεν έχετε δώσει κάποιο ποσό για να πληρωθεί ο/η '+user2send+'!'), ' ', 0 + MB_ICONASTERISK) else
                                    if money = 0 then
  MessageBoxA(
    0,
    PAnsiChar(AnsiString(
      'Δεν έχετε δώσει κάποιο ποσό για να πληρωθεί ο/η ' + user2send + '!'
    )),
    PAnsiChar(AnsiString(' ')),
    MB_ICONASTERISK
  )
else
                                    Add_2_Income(user2send,day,month,year,money);
                                    set_button('exit',1);
                                  end; 
until GUI_Exit;

end; //SECURITY CHECK

end;


procedure Add_2_Income(user:string; day1,month1,year1,money:integer);
var fileused:text;
begin
assign(fileused,curendir+'Users\'+Greeklish(user)+'.money');
{$i-}
append(fileused);
{$i+}
if Ioresult=0 then begin
                    writeln(fileused,'pay(',day1,',',month1,',',year1,',',money,')');
                    Send_Message(user,'Πληρωμή '+Convert2String(money)+' €','Πληρωμή '+Convert2String(money)+' €');
                    close(fileused);
                   end else
                   begin
                   // MessageBox (0, PChar('Δεν ήταν δυνατό να προστεθεί η πληρωμή στο αρχείο πληρωμών του χρήστη '+user), ' ', 0 + MB_ICONEXCLAMATION);
                    MessageBoxA (0, PAnsiChar(AnsiString('Δεν ήταν δυνατό να προστεθεί η πληρωμή στο αρχείο πληρωμών του χρήστη '+user)),  PAnsiChar(AnsiString(' ')), 0 + MB_ICONEXCLAMATION);
                   end;

end;

function Calculate_Income(user:string; day1,month1,year1,day2,month2,year2:integer):integer;
var fileused,filedetail:text;
    line:string;
    all_ok:boolean;
    day,month,year,retres:integer;
begin
retres:=0;
assign(fileused,curendir+'Users\'+Greeklish(user)+'.money');
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then begin
                    assign(filedetail,curendir+'Cache\'+Greeklish(user)+'_payments.tmp');
                    rewrite(filedetail);
                    while (not eof(fileused)) do
                     begin
                      readln(fileused,line);
                      seperate_words(line);
                      if Equal(get_memory(1),'PAY') then
                       begin
                         day:=get_memory_int(2);
                         month:=get_memory_int(3);
                         year:=get_memory_int(4); 
                         all_ok:=true;

                         if ((day<day1) or (day>day2)) then all_ok:=false;
                         if ((month<month1) or (month>month2)) then all_ok:=false;
                         if ((year<year1) or (year>year2)) then all_ok:=false;
                         if ((day1=0) and (month1=0) and(year1=0) and (day2=0) and (month2=0) and(year2=0)) then all_ok:=true; 
                         if all_ok then
                          begin
                           retres:=retres+get_memory_int(5);
                           writeln(filedetail,'Πληρωμή ',day,'/',month,'/',year,' - ',get_memory_int(5),' &euro;');
                          end;
                       end; 
                     end;
                    close(filedetail);
                    close(fileused);
                   end else
                   begin
                    //MessageBox (0, PChar('Δεν ήταν δυνατό να ανοιχθεί το αρχείο πληρωμών του χρήστη '+user), ' ', 0 + MB_ICONEXCLAMATION);
                    MessageBoxA(
  0,
  PAnsiChar(AnsiString(
    'Δεν ήταν δυνατό να ανοιχθεί το αρχείο πληρωμών του χρήστη ' + user
  )),
  PAnsiChar(AnsiString(' ')),
  MB_ICONEXCLAMATION
);
                   end;
Calculate_Income:=retres;
end;

begin
end.
