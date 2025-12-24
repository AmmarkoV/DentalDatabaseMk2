unit user_tutorials;

interface
 
procedure gui_open_tutorial;


implementation 
uses ammarunit,apsfiles,ammargui,userlogin,settings;


function get_quotes_num:integer;
var fileused:text;
    thenum:integer;
begin
assign (fileused,get_central_dir+'advice');
reset(fileused);
readln(fileused,thenum);
close(fileused);
get_quotes_num:=thenum;
end;

function get_quote(count:integer):string;
var fileused:text;
    retres:string;
    i:integer;
begin
retres:='';
assign (fileused,get_central_dir+'advice');
reset(fileused);
readln(fileused,retres);

i:=0;
while  ( (not (eof (fileused))) and (i<count) ) do
 begin
  readln(fileused,retres);
  i:=i+1;
 end;

close(fileused);
get_quote:=retres;
end;

procedure gui_open_tutorial;
var windx,windy,spot:integer;
    fileused:text;
    quote:string;
    label restart_tutorial;
begin 
spot:=1;
windx:=(GetMaxX div 2)-250;
windy:=200;

restart_tutorial:

flush_gui_memory(0); 
set_gui_color(ConvertRGB(0,0,0),'COMMENT');
include_object('gui_open_tutorial','window','Συμβουλές Χρήσης','','','',windx,windy,(GetMaxX div 2)+250,windy+400);
draw_all; 
delete_object('gui_open_tutorial','NAME');
DrawJpeg('Art\info',windx+50,windy+60);
include_object('back','buttonc','<- Προηγούμενο','no','','',windx+120,windy+350,0,0);
include_object('next','buttonc','Επόμενο ->','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+5,Y1(last_object),0,0);
draw_all;

draw_text_area(get_quote(spot),windx+50+160,windy+60,(GetMaxX div 2)+230,windy+350);
repeat
interact;
if get_object_data('next')='4' then
   begin
    set_button('next',0);
    spot:=spot+1;
    if spot>get_quotes_num then spot:=1;
    goto restart_tutorial;
   end else
if get_object_data('back')='4' then
   begin
    set_button('back',0);
    spot:=spot-1;
    if spot<1 then spot:=get_quotes_num;
    goto restart_tutorial;
   end;

until GUI_Exit;
end;

begin
end.
