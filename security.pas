unit security;

interface
 
function GUI_lock:boolean;


implementation 
uses windows,ammarunit;



function DriveSpeed(thepath:string):integer;
var file2test:text;
    retres:integer;
    filesiz,starttime,endtime:integer;
    bufc:char;
begin
retres:=-1;
starttime:=0;
endtime:=0;
assign(file2test,thepath);
{$i-}
reset(file2test);
{$i+}
if Ioresult=0 then
  begin
   filesiz:=0;
   delay(1);
   starttime:=GetTickCount;
   delay(1);
   while (not (eof(file2test)) ) do
    begin
     read(file2test,bufc);
     filesiz:=filesiz+1;
    end;
   delay(1);
   endtime:=GetTickCount;
   delay(1);
   endtime:=endtime-starttime;
   if endtime=0 then retres:=-1 else
    begin
     retres:=filesiz div endtime;
    end; 
   close(file2test);
  end;
DriveSpeed:=retres;
end;



function GUI_lock:boolean;
var security_needed:text;
    speed1,speed2:integer;
    secure_check:string;
    passed,retres:boolean;
label skip_lock;
begin
retres:=true;
assign(security_needed,'security.ini');
{$i-}
reset(security_needed);
{$i+}
if Ioresult<>0 then goto skip_lock; //An den yparxei security.ini feygoume..
readln(security_needed,secure_check);
close(security_needed);

clrscreen;
TextColor(ConvertRGB(0,255,0));
SetFont('Garamond','greek',35,0,0,0);
GotoXY(0,GetMaxY div 2);

OutTextCenter('Παρακαλώ εισάγετε το κλειδί..');
OutTextCenter(' ');
putpixel(1,1,ConvertRGB(0,0,0)); 
passed:=false;
repeat
 delay(1000);
 if Upcase(readkeyfast)='ESCAPE' then begin
                                       retres:=false;
                                       goto skip_lock;
                                      end;
 assign(security_needed,secure_check);
 {$i-} reset(security_needed);{$i+}
 if Ioresult=0 then begin
                     close(security_needed);
                     passed:=true;
                     clrscreen; 
                     GotoXY(0,GetMaxY div 2-TextHeight('A')*3);
                     OutTextCenter('Reading drive..');
                     speed1:=DriveSpeed('C:\My Documents\Pascal Projects\Dental Database Mk2\authorization');
                     speed2:=DriveSpeed(secure_check);
                     OutTextCenter('1 - '+Convert2String(speed1) );
                     OutTextCenter('2 - '+Convert2String(speed2) );
                     if speed2<speed1 then OutTextCenter('Authorization Complete..') else
                                          begin
                                           OutTextCenter('Authorization Failed..');
                                           OutTextCenter('Πατήστε κάποιο πλήκτρο για συνέχεια..');
                                           delay(1000);
                                           readkey;
                                          end;
                    end;
 delay(500);
until passed;
skip_lock:
GUI_lock:=retres;
end;

begin
end.
