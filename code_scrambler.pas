unit code_scrambler;

interface
 

implementation 
uses windows,ammarunit,ammargui,apsfiles;
const MAX_COMMANDS=123;
var commands:array[1..MAX_COMMANDS]of string;
    commands_place:array[1..MAX_COMMANDS]of integer;


procedure scramble_commands(inpt,outpt:string);
var fileused:text;
    i:integer;
    bufstr:string;
begin
assign(fileused,inpt);
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then
 begin
   i:=1;
   while ((i<=MAX_COMMANDS) and (not eof(fileused)) ) do
     begin
      readln(fileused,bufstr);
      commands[i]:=bufstr;
      commands_place[i]:=i;
      i:=i+1;
     end;
 end;
end;
 


begin
end.
