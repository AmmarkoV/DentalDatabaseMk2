unit tools;



interface

procedure RunExeInItsDir(itsdir,thecmd:string);
function FixDir(dirin:string):string;  
procedure CopyFile(fromfile,tofile:string);
function check_file_existance(filename:string):boolean;
function create_file(filename:string):boolean;
function get_file_size(filesname:string):longint;
procedure clear_file(thefile:string);
procedure delete_file(filenam:string);

implementation
uses ammarunit;


procedure RunExeInItsDir(itsdir,thecmd:string);
var ourdir:string;
    retres:boolean;
begin
retres:=true;
getdir(0,ourdir);
chdir(itsdir);
 RunExe(thecmd,'normal');
chdir(ourdir); 
end;

function FixDir(dirin:string):string;
begin
if dirin[Length(dirin)]<>'\' then dirin:=dirin+'\';
FixDir:=dirin;
end;


function get_file_size(filesname:string):longint;
var filsiz:longint;
    filtmp:file of byte;
begin
filsiz:=-1;
assign(filtmp,filesname);
{$i-}
reset(filtmp);
{$i+}
if Ioresult=0 then begin
                    filsiz:=(filesize(filtmp));
                    close(filtmp); 
                   end else
                   filsiz:=-1;
get_file_size:=filsiz;
end;

function create_file(filename:string):boolean;
var fileused:text;
    res:boolean;
begin
res:=false;
assign(fileused,filename);
{$i-}
rewrite(fileused);
{$i+}
if Ioresult=0 then
   begin
    res:=true;
    close(fileused);
   end;
create_file:=res;
end;

procedure clear_file(thefile:string);
var fileused:text;
begin
assign(fileused,thefile);
rewrite(fileused);
close(fileused);
end;

procedure delete_file(filenam:string);
var filetst:text;
begin
assign(filetst,filenam);
{$i-}
 reset(filetst);
{$i+}
if Ioresult=0 then begin
                    close(filetst);
                    erase(filetst);
                   end;
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

procedure CopyFile(fromfile,tofile:string);
var file1,file2:file;
    buffer1:byte;
    i,ifinal:integer;
begin
if (not Equal(fromfile,tofile) ) then  //an einai ta idia prospername to copy afou dn xreiazetai..
begin
assign(file1,fromfile);
{$i-}
reset(file1,1);
{$i+}
if Ioresult=0 then begin
                    assign(file2,tofile);
                    {$i-}
                    rewrite(file2,1);
                    {$i+}
                 if Ioresult=0 then begin
                    i:=0;
                    ifinal:=Filesize(file1);
                    while i<ifinal do  begin
                                         blockread(file1,buffer1,1);
                                         blockwrite(file2,buffer1,1);
                                         i:=i+1;
                                       end;
                    close(file2);
                                    end;
                    close(file1);  
                   end;
end;
end;

begin
end.
