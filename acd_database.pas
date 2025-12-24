unit acd_database;

interface
procedure Associate_User(theprog,thecdkey,theusername,thename,thesur,theadd,thetelephon,theemail,theother:string);
function User_Exists(theprog,thecdkey:string):boolean;
implementation 
uses windows,ammarunit,string_stuff;

 
procedure Associate_User(theprog,thecdkey,theusername,thename,thesur,theadd,thetelephon,theemail,theother:string);
var fileused:text;
begin
assign(fileused,'database\'+theprog+'.dat');
{$i-}
 append(fileused);
{$i+}
if Ioresult=0 then
   begin
    writeln(fileused,'user('+theprog+','+thecdkey+','+theusername+','+thename+','+thesur+','+theadd+','+thetelephon+','+theemail+','+theother+')');
    close(fileused);
   end;
end;


function User_Exists(theprog,thecdkey:string):boolean;
var fileused:text;
    bufstr:string;
    retres:boolean;
begin
retres:=false;
assign(fileused,'database\'+theprog+'.dat');
{$i-}
 reset(fileused);
{$i+}
if Ioresult=0 then
   begin
    repeat
     readln(fileused,bufstr);
     seperate_words(bufstr);
     if get_memory(3)=thecdkey then retres:=true;
    until (retres or eof(fileused));
    //writeln(fileused,'user('+theprog+','+thecdkey+','+theusername+','+thename+','+thesur+','+theadd+','+','+theemail+','+','+theother+')');
    close(fileused);
   end;
User_Exists:=retres;
end;


begin
end.
