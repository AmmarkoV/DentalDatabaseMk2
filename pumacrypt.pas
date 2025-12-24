unit pumacrypt;
{$Q OFF}
interface
function  PumaCryptVersion:string;
procedure GUI_Switch(onoff:boolean);
procedure GUI_RefreshRate(ret:integer);
procedure Puma_SwitchOutput(onoff:boolean);
function  check_assotiations_pcf_pck:integer;
function  check_label_type(file2checkname,operation:string):integer;
function  check_label(file2checkname,operation:string):boolean;
procedure outputkey(thelen:integer);
procedure makeakey;
procedure readthekey;
procedure savethekey(where2save:string);
procedure loadthekey(where2load:string);
procedure setthekey(keytxt:string);
function getthekey:string;
procedure encodeinput_pumacrpt(nameofinput,nameofoutput:string);
procedure encodeinput_xorkey(nameofinput,nameofoutput:string);
procedure decodeinput_xorkey(nameofinput,nameofoutput:string);
procedure decodeinput_pumacrpt(nameofinput,nameofoutput:string);
procedure ensure_file_existance(filenam:string);
procedure delete_file(filenam:string);
procedure clean_file(filenam:string);
procedure check_files_existance;
procedure test_random_fibonacci;
function  AnalyseFilename(filenam,mode:string):string;
procedure display_chars;
function  brute_search( strlength: integer; thetext: string ):string;
function  create_password(thelength:integer):string;
function encrypt_string(what2encrypt:string):string;

implementation

uses windows,ammargui;
const pumacrypt_version='0.365 win32';
      equation_strength=20;
      keyspeed=1;
      fusespeed=1;
      fuselimit=1000;
      sumlimit=500;
      keyname='key.pck';
      keylimit=4096;

var fileused:text;
    key:array[1..keylimit]of char;
    proramparams:array[1..2]of integer; //TEST
    //virtualfile:array[1..16384]of char; //TEST
    keylength,keyprog,sel:integer;
    inputlimit,inputcount:longint;
    refresh_rate:integer;
    inp:string;
    verbose:boolean;
    gui_on:boolean;

function Convert2String(thenumber:integer):string;
var thestring:string;
begin
Str(thenumber,thestring);
Convert2String:=thestring;
end;

procedure GUI_Switch(onoff:boolean);
begin
gui_on:=onoff;
end;

procedure Puma_SwitchOutput(onoff:boolean);
begin
verbose:=onoff;
end;

procedure Say(smth:string);
begin
if verbose then writeln(smth);
end;

function  PumaCryptVersion:string;
begin
PumaCryptVersion:='PUMA-DECODER+ '+pumacrypt_version;
if verbose then writeln('PUMA-DECODER+ '+pumacrypt_version);
if verbose then writeln('TUNED AT ',fusespeed,'.',keyspeed,'.',fuselimit,'.',sumlimit);
end;

procedure GUI_RefreshRate(ret:integer);
begin
refresh_rate:=ret;
end;
 
function AnalyseFilename(filenam,mode:string):string;
var i1,i2,i3:integer;
    directory1,filenam1,fileextention1,extention1:string;
begin
i2:=0;
i3:=0;
for i1:=1 to Length(filenam) do if filenam[i1]='\' then i2:=i1;
for i1:=i2 to Length(filenam) do if filenam[i1]='.' then i3:=i1;
directory1:=Copy(filenam,1,i2);
filenam1:=Copy(filenam,i2+1,i3-i2-1);
fileextention1:=Copy(filenam,i2+1,Length(filenam)-i2);
extention1:=Copy(filenam,i3+1,Length(filenam)-i3);
if Upcase(mode)='DIRECTORY' then AnalyseFilename:=directory1 else
if Upcase(mode)='FILENAME' then  AnalyseFilename:=filenam1 else
if Upcase(mode)='EXTENTION' then  AnalyseFilename:=extention1 else
if Upcase(mode)='FILENAME+EXTENTION' then AnalyseFilename:=fileextention1; 
end;

{
function check_an_associationOLD(assnam:string):integer;
var reservedword:dword;
    key1:phkey;
    str1:LPTSTR;
    handlekey1,hkey2:hkey;
    succres:integer;
begin 
reservedword:=0;
str1:=Pchar(assnam);
str1[Length(str1)]:=#0;
handlekey1:=HKEY_CLASSES_ROOT; 
succres:=RegOpenKeyEx(handlekey1,str1,reservedword,MAXIMUM_ALLOWED,@hkey2);
if succres<>ERROR_SUCCESS then begin
                                
                                succres:=0;
                               end else
                               begin 
                                //writeln('Located '+str1+' extenetion..!');
                                succres:=1;
                                RegCloseKey(handlekey1);
                               end;
check_an_association:=succres;
end;    }


function check_an_association(assnam: AnsiString): Integer;
var
  hkey2: HKEY;
begin
  if RegOpenKeyExA(
       HKEY_CLASSES_ROOT,
       PAnsiChar(assnam),
       0,
       MAXIMUM_ALLOWED,
       @hkey2
     ) = ERROR_SUCCESS then
  begin
    RegCloseKey(hkey2);
    Result := 1;
  end
  else
    Result := 0;
end;


function check_assotiations_pcf_pck:integer; 
var tmpres:integer;
begin   
tmpres:=0; 
if check_an_association('.pck')=1 then tmpres:=tmpres+1;
if check_an_association('.pcf')=1 then tmpres:=tmpres+1;
if tmpres=2 then begin
                  Say('Associations with pck and pcf files , OK !');
                 end else
                  Say('Acrypt is not associated with .pcf and .pck files , read Instrucrions.txt ..');

check_assotiations_pcf_pck:=tmpres;
end; 

function fibonacci(g0,g1,limit:longint):integer;
var i3:array[1..3]of longint;
    loop:integer;
    suma,safety:longint;
    fileout:text;
begin 
i3[1]:=g0;
i3[2]:=g1;
loop:=0; suma:=0;
repeat
loop:=loop+1;
i3[3]:=i3[1]+i3[2];
suma:=suma+i3[3]; 
i3[1]:=i3[2];
i3[2]:=i3[3];
until loop>=limit; 
if suma<0 then suma:=-suma; 
if suma>limit then begin
                     safety:=0;
                     repeat 
                      suma:=suma div 2;
                      suma:=suma+(suma mod 2);
                      if safety=suma then suma:=limit else
                                          safety:=suma;
                     until suma<=limit;
                   end;  
fibonacci:=suma; 
end;

function open_get_file_size(filesname:string):longint;
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
                    Say('Filesize is '+Convert2String(filsiz)+' bytes');
                   end else
                   Say('Could not determine filesize of '+filesname);
open_get_file_size:=filsiz; 
end;

procedure selectoutput(whatoutput:string);    //TEST
begin
if Upcase(whatoutput)='FILE' then proramparams[1]:=1 else
if Upcase(whatoutput)='MEMORY' then proramparams[1]:=2;
end;

procedure write2output(what2write:char);      //TEST
begin
if Upcase(what2write)='MEMORY' then begin
                                       Inc(proramparams[2]);
                                      // virtualfile[proramparams[2]]:=what2write;
                                      end;
end;


procedure outputkey(thelen:integer);
var i:integer;
    bufc:char;
    key2op:text;
begin
keylength:=thelen;
assign(key2op,keyname);
{$i-}
rewrite(key2op);
{$i+}
if Ioresult=0 then begin 
                     if keylength>keylimit then keylength:=keylimit;
                     randomize;
                     for i:=1 to keylength do begin
                                               bufc:=chr(Round(random(255)));
                                               if bufc<>'#26' then write(key2op,bufc) else
                                                                   i:=i-1;
                                              end;
                     close(key2op);
                    end;
end;

procedure makeakey; 
begin
say('GIVE ME THE KEY SIZE (MAX '+Convert2String(keylimit)+' BITS)');
say('( RECOMMENDED KEY SIZE > 512 BITS )');
readln(keylength);
outputkey(keylength);
end;

procedure savethekey(where2save:string);
var i:integer;
    bufc:char;
    key2op:text;
begin
assign(key2op,where2save);
{$i-}
rewrite(key2op);
{$i+}
if Ioresult=0 then begin  
                     for i:=1 to keylength do write(key2op,key[i]); 
                     close(key2op);
                    end else
                    say('Error saving the key!');
end;

procedure loadthekey(where2load:string);
var i:integer;
    bufc:char;
    key2op:text;
begin
inputlimit:=open_get_file_size(keyname);
assign(key2op,where2load);
{$i-}
reset(key2op);
{$i+}
if Ioresult=0 then begin   
                     keylength:=0;  
                     repeat 
                      read(key2op,bufc);
                      keylength:=keylength+1;
                      key[keylength]:=bufc; 
                     until (keylength>=inputlimit) or (keylength>=keylimit);
                     say('Key loaded is '+Convert2String(keylength)+' bits long');
                     close(key2op);
                    end else
                    say('Error loading the key!');
end;


procedure setthekey(keytxt:string);
var i:integer;
begin
keylength:=Length(keytxt);
if keylength>0 then begin
                      for i:=1 to keylength do begin
                                                key[i]:=keytxt[i];
                                               end;
                      if keylength<keylimit then begin
                                                  for i:=keylength+1 to keylimit do key[i]:=' ';
                                                 end;
                    end;
say('Key Length '+Convert2String(keylength));
end;


function getthekey:string;
var i:integer;
    retres:string;
begin 
retres:='';
if keylength>0 then begin
                      for i:=1 to keylength do begin
                                                retres:=retres+key[i];
                                               end; 
                    end; 
getthekey:=retres;
end;

procedure readthekey;
var key2op:text; 
    bufc:char;
    actselect:string;
begin
inputlimit:=open_get_file_size(keyname);
assign(key2op,keyname);
{$i-}
reset(key2op);
{$i+}
if Ioresult<>0 then begin
                     say('COULD NOT READ '+Upcase(keyname));
                     say('! Please make a selection !');
                     say('-------------------------------');
                     say('GIVE = Give a new key');
                     say('RANDOM = Create new random key');
                     readln(actselect);
                     actselect:=Upcase(actselect);
                     if actselect='GIVE' then begin
                                               say('Enter password : ');
                                               readln(actselect);
                                               setthekey(actselect); //GIA NA MIN DIMIOURGW EKSWTERIKO ARXEIO!
                                               //rewrite(key2op);
                                               //write(key2op,actselect);
                                               //close(key2op);
                                               //writeln('');
                                               //readthekey;
                                              end else
                                              begin
                                               makeakey;
                                               readthekey;
                                              end;

                    end else
if Ioresult=0 then begin
                     keylength:=0;
                    // keyprog:=1; TST DEN XREIAZETAI
                     inputcount:=0;
                     repeat
                      inputcount:=inputcount+1;
                      read(key2op,bufc);
                      keylength:=keylength+1;
                      key[keylength]:=bufc;
                     if inputlimit<128 then say(bufc); // Gia na min emfanizontai skoupidia stin othoni
                     until (inputcount>=inputlimit) or (inputcount>=keylimit);
                     if inputlimit<128 then begin end; //writeln(''); // Gia na min emfanizontai skoupidia stin othoni
                     say('Key is '+Convert2String(keylength)+' bits long');
                     close(key2op);
                    end;
end;

function equations(typeofeq,x1,fuse:integer):integer;
var fx:real;
begin
case typeofeq of 
0:                 begin
                    fx:=(x1*x1)*3;
                   end;
1:                 begin
                    fx:=x1*x1+11;
                   end;
2:                 begin
                    fx:=7*x1;
                   end;
3:                 begin
                    fx:=x1*x1+14{exp(x1)};
                   end;
4:                 begin
                    fx:=x1*x1*2;
                   end;
5:                 begin
                    fx:=x1*x1;
                   end;
6:                 begin
                    fx:=x1;
                   end;
7:                 begin
                    fx:=x1*5;
                   end;
8:                 begin
                    fx:=x1*x1;
                   end;
9:                 begin
                    fx:=x1*x1;
                   end;
10:                 begin
                     fx:=x1+99;
                    end;
11:                 begin
                     fx:=x1*3+3;
                    end;
12:                 begin
                     fx:=x1*2+1;
                    end;
13:                 begin
                     fx:=x1*4+9;
                    end;
14:                 begin
                     fx:=x1+1;
                    end;
15:                 begin
                     fx:=x1*x1+2;
                    end;
16:                 begin
                     fx:=x1;
                    end;
17:                 begin
                     fx:=x1+13;
                    end;
18:                 begin
                     fx:=x1*2;
                    end;
19:                 begin
                     fx:=x1+111;
                    end;
20:                 begin
                     fx:=x1*2;
                    end;
end;
equations:=Round(fx)+fuse;
//writeln('Equation f(',x1,')=',Round(fx),' type ',typeofeq);
end;

function invertequations(typeofeq,fxgiven,fuse:integer):integer;
var xr,fx:real;
    prax1,prax2:real;
    fxtmp:integer;
begin
fxtmp:=fxgiven-fuse;
case typeofeq of 
0:                 begin
                    fx:=fxtmp div 3;
                    fx:=sqrt(fx);
                    //fx:=x1*x1+53*x1;
                   end;
1:                 begin
                    fx:=fxtmp-11;
                    fx:=sqrt(fx);
                    //fx:=x1*x1+11;
                   end;
2:                 begin
                    fx:=fxtmp div 7;
                    //fx:=7*x1;
                   end;
3:                 begin
                    fx:=fxtmp-14;
                    if fx>0 then fx:=sqrt(fx) else say('ERROR');
                    //fx:=x1*x1+14 exp(x1);
                   end;
4:                 begin
                    fx:=fxtmp div 2;
                    fx:=sqrt(fx);
                    //fx:=x1*x1*2;
                   end;
5:                 begin
                    fx:=sqrt(fxtmp);
                    //fx:=x1*x1;
                   end;
6:                 begin
                    fx:=fxtmp;
                   end;
7:                 begin
                    fx:=fxtmp div 5;
                   end;
8:                 begin
                    fx:=sqrt(fxtmp);
                    //fx:=x1*x1;
                   end;
9:                 begin
                    fx:=sqrt(fxtmp);
                    //fx:=x1*x1;
                   end;
10:                 begin
                     fx:=fxtmp-99;
                     //fx:=x1+99;
                    end;
11:                 begin
                     fx:=fxtmp-3;
                     fx:=fx / 3;
                     //fx:=x1*x1*3+3;
                    end;
12:                 begin
                     fx:=fxtmp-1;
                     fx:=fxtmp div 2;
                     //fx:=x1*2+1;
                    end;
13:                 begin
                     fx:=fxtmp-9;
                     fx:=fx / 4;
                     //fx:=x1*4+9;
                    end;
14:                 begin
                      fx:=fxtmp-1;
                     //fx:=x1+1;
                    end;
15:                 begin
                     fx:=fxtmp-2;
                     fx:=sqrt(fxtmp);
                     //fx:=x1*x1+2;
                    end;
16:                 begin
                     fx:=fxtmp;
                     //fx:=x1;
                    end;
17:                 begin
                     fx:=fxtmp-13;
                     //fx:=x1+13;
                    end;
18:                 begin
                     fx:=fxtmp div 2;
                     //fx:=x1*2;
                    end;
19:                 begin
                     fx:=fxtmp-111;
                     //fx:=x1+111;
                    end;
20:                 begin
                     fx:=fxtmp div 2;
                     //fx:=x1*2;
                    end;
end;
invertequations:=Round(fx);
//writeln('InvertEquation f-1(',fxtmp,')=',Round(fx),' type ',typeofeq);
end;

function check_label_type(file2checkname,operation:string):integer;
var file2check:text;
    filelabel,tmp1:string;
    readlp:integer;
begin
assign(file2check,file2checkname);
{$i-}
reset(file2check);
{$i+}
if Ioresult<>0 then check_label_type:=0 else
                    begin
                     if Upcase(operation)='CHECK' then begin
                     filelabel:='';
                     for readlp:=1 to 15 do begin
                                               read(file2check,tmp1);
                                               filelabel:=filelabel+tmp1;
                                            end;
                     read(file2check,tmp1);
                     if Upcase(filelabel)='*ID=PUMA-CRYPT*' then     check_label_type:=1 else
                     if Upcase(filelabel)='*ID=PUMA-CRYPT EXE*' then check_label_type:=2 else
                                                                     check_label_type:=0;
                     close(file2check);
                                                        end else
                     if Upcase(operation)='WRITE'  then begin
                    close(file2check);
                    rewrite(file2check);
                    //if Upcase(AnalyseFilename(file2checkname,'EXTENTION'))='EXE' then writeln(file2check,'*id=puma-crypt exe*') else
                                                                                      writeln(file2check,'*id=puma-crypt*');
                    close(file2check); 
                                                        end;
                    end;
end;

function check_label(file2checkname,operation:string):boolean;
var spdtmp:integer;
begin
spdtmp:=check_label_type(file2checkname,operation);
if (spdtmp=1) or (spdtmp=2) then check_label:=true else
if (spdtmp=0) then check_label:=false; 
end;

function equations_forward(equnow,equforwrd:integer):integer;
var tmpequ:integer;
begin
tmpequ:=equnow+equforwrd;
if tmpequ>equation_strength then tmpequ:=tmpequ-equation_strength;
equations_forward:=tmpequ;
end;

function floatthekey(var keyplace,speed:integer):integer;
var nextkeypos:integer;
begin
nextkeypos:=keyplace+ord(key[keyplace]);
if nextkeypos>keylength then nextkeypos:=nextkeypos-(nextkeypos div keylength)*keylength;
if nextkeypos+speed<keylength then nextkeypos:=nextkeypos+speed else //Metavliti taxitita (AmmaroFloating key :-) )
                                   speed:=1; 
floatthekey:=nextkeypos;
end;

procedure encodeinput_pumacrpt_tst(nameofinput,nameofoutput:string);
var inputtxt,outtxt:text;
    bufc:char;
    x3s:string;
    equloop,fusecount,startnkey,speedstartn,speedkey,sumkey,lastpercent:integer;
    encar,enc,i,x2,x3,x5,x6,z:integer;
begin 
inputlimit:=open_get_file_size(nameofinput); 
lastpercent:=-1; 
assign(inputtxt,nameofinput);
{$i-}
reset(inputtxt);
{$i+}
check_label(nameofoutput,'WRITE');
assign(outtxt,nameofoutput); //'tmp.txt'
append(outtxt);
if Ioresult<>0 then begin
                     say('COULD NOT READ INPUT.TXT');
                     say('ABORTING ENCODING PROCEDURE!');
                     exit;
                    end
                     else
if Ioresult=0 then begin
                     z:=0;
                     equloop:=0;
                     fusecount:=0;
                     say('');
                     say('Encoding');
                     say('Key '+Convert2String(keylength));
                     startnkey:=0;
                     speedstartn:=keyspeed;
                     sumkey:=0;
                     inputcount:=0; 
                     repeat 
                     inputcount:=inputcount+1;
                     //write('*');
                                                 begin
                                                  if z<=0 then z:=1;  //an z<=0 den ginetai error!
                                                  floatthekey(z,speedkey);
                                                  equloop:=equations_forward(equloop,1);
                                                  fusecount:=fusecount+fusespeed;

                                                  read(inputtxt,bufc); 
                                                  sumkey:=sumkey+(ord(key[z]) div 100);
                                                  x3:=equations(equloop,ord(key[z])+ord(bufc),fusecount+sumkey+fibonacci(fusecount,ord(key[z]),fusecount+sumkey));
                                                  Str(x3,x3s);  
                                                  if Length(x3s)<6 then begin
                                                                         for i:=1 to (6-Length(x3s)) do x3s:='0'+x3s;
                                                                        end  else
                                                  if Length(x3s)>6 then say('ERROR (C0)!!');
                                                  if odd(ord(key[z]))=true then begin
                                                                                 if Upcase(key[z])=key[z] then speedkey:=speedkey+1 else
                                                                                                               speedkey:=speedkey+3;

                                                                                end
                                                                                 else
                                                                                begin
                                                                                 if Upcase(key[z])=key[z] then speedkey:=speedkey+2 else
                                                                                                               speedkey:=speedkey+4;
                                                                                end;
                                                  //speedstartn:=speedkey;
                                                  startnkey:=startnkey+speedstartn;
                                                  if startnkey>=keylength then begin
                                                                                 startnkey:=0;
                                                                                 z:=0;
                                                                               end
                                                                                 else
                                                                                begin
                                                                                 z:=startnkey;
                                                                                end;  
                                                  if fusecount>fuselimit then fusecount:=0; //epanafora tis epiprosthetis metavlitis sto 1 (0+1)
                                                  if sumkey>sumlimit then sumkey:=0; //epanafora tis epiprosthetis metavlitis
                                                  write(outtxt,x3s);
                                                  say('.');
                                                  close(outtxt);
                                                  append(outtxt);
                                                  if inputlimit<>0 then
                                                  if lastpercent<>(100*inputcount div inputlimit) then begin
                                                                                                        lastpercent:=(100*inputcount div inputlimit);
                                                                                                        if verbose then say(Convert2String(lastpercent)+'% ');
                                                                                                        if gui_on then begin
                                                                                                                        set_object_data('progress','value',Convert2String(lastpercent),lastpercent);
                                                                                                                        draw_object_by_name('progress');
                                                                                                                       end;
                                                                                                       end;
                                                 end;
                     until inputcount>=inputlimit; //eof(inputtxt)=true
                     close(inputtxt);
                     close(outtxt);
                    end;
say('');
end;



procedure encodeinput_pumacrpt(nameofinput,nameofoutput:string);
var inputtxt,outtxt:text;
    bufc:char;
    x3s:string;
    equloop,fusecount,startnkey,speedstartn,speedkey,sumkey,lastpercent:integer;
    encar,enc,i,x2,x3,x5,x6,z:integer;
begin
inputlimit:=open_get_file_size(nameofinput);
lastpercent:=-1;
assign(inputtxt,nameofinput);
{$i-}
reset(inputtxt);
{$i+}
check_label(nameofoutput,'WRITE');
assign(outtxt,nameofoutput); //'tmp.txt'
append(outtxt);
if Ioresult<>0 then begin
                     say('COULD NOT READ INPUT.TXT');
                     say('ABORTING ENCODING PROCEDURE!');
                     exit;
                    end
                     else
if Ioresult=0 then begin
                     z:=0;
                     equloop:=0;
                     fusecount:=0;
                     say('');
                     say('Encoding');
                     startnkey:=0;
                     speedstartn:=keyspeed;
                     sumkey:=0;
                     inputcount:=0;
                     repeat
                     inputcount:=inputcount+1;
                     //write('*');
                                                 begin
                                                  if z<=0 then z:=1;  //an z<=0 den ginetai error!
                                                  floatthekey(z,speedkey);
                                                  equloop:=equations_forward(equloop,1);
                                                  fusecount:=fusecount+fusespeed;

                                                  read(inputtxt,bufc); 
                                                  sumkey:=sumkey+(ord(key[z]) div 100);
                                                  x3:=equations(equloop,ord(key[z])+ord(bufc),fusecount+sumkey+fibonacci(fusecount,ord(key[z]),fusecount+sumkey));
                                                  Str(x3,x3s);  
                                                  if Length(x3s)<6 then begin
                                                                         for i:=1 to (6-Length(x3s)) do x3s:='0'+x3s;
                                                                        end  else
                                                  if Length(x3s)>6 then say('ERROR (C0)!!');
                                                  if odd(ord(key[z]))=true then begin
                                                                                 if Upcase(key[z])=key[z] then speedkey:=speedkey+1 else
                                                                                                               speedkey:=speedkey+3;

                                                                                end
                                                                                 else
                                                                                begin
                                                                                 if Upcase(key[z])=key[z] then speedkey:=speedkey+2 else
                                                                                                               speedkey:=speedkey+4;
                                                                                end;
                                                  //speedstartn:=speedkey;
                                                  startnkey:=startnkey+speedstartn;
                                                  if startnkey>=keylength then begin
                                                                                 startnkey:=0;
                                                                                 z:=0;
                                                                               end
                                                                                 else
                                                                                begin
                                                                                 z:=startnkey;
                                                                                end;  
                                                  if fusecount>fuselimit then fusecount:=0; //epanafora tis epiprosthetis metavlitis sto 1 (0+1)
                                                  if sumkey>sumlimit then sumkey:=0; //epanafora tis epiprosthetis metavlitis
                                                  write(outtxt,x3s);
                                                  //write('.');
                                                  if lastpercent+refresh_rate<(100*inputcount div inputlimit) then
                                                                                                       begin
                                                                                                        lastpercent:=(100*inputcount div inputlimit);
                                                                                                        if verbose then say(Convert2String(lastpercent)+'% ');
                                                                                                        if (gui_on) then
                                                                                                                       begin
                                                                                                                        set_object_data('progress','value',Convert2String(lastpercent),lastpercent);
                                                                                                                        draw_object_by_name('progress');
                                                                                                                       end;
                                                                                                       end;
                                                 end;
                     until inputcount>=inputlimit; //eof(inputtxt)=true
                     close(inputtxt);
                     close(outtxt);
                    end;
say('');
if gui_on then begin
                 set_object_data('progress','value','100' ,100);
                 draw_object_by_name('progress');
               end;
end;



procedure encodeinput_xorkey(nameofinput,nameofoutput:string);
var inputtxt,outtxt:text;
    bufc:char;
    bufci,i,z,lastpercent:integer;
    triadaint:integer; 
begin
inputlimit:=open_get_file_size(nameofinput);
lastpercent:=-1;
assign(inputtxt,nameofinput);
{$i-}
reset(inputtxt);
{$i+}
assign(outtxt,nameofoutput);
rewrite(outtxt);
if Ioresult<>0 then say('COULD NOT READ OUTPUT.TXT') else
if Ioresult=0 then begin 
                     z:=0;
                     inputcount:=0;
                     repeat
                      inputcount:=inputcount+1;
                      z:=z+1; 
                      read(inputtxt,bufc);
                      triadaint:=ord(bufc);
                      bufci:=ord(key[z]);
                      i:=bufci xor triadaint;
                      write(outtxt,Chr(i));
                      if z>=keylength then z:=0;
                      //write('.');
                       if lastpercent<>(100*inputcount div inputlimit) then begin
                                                                               lastpercent:=(100*inputcount div inputlimit);
                                                                               say(Convert2String(lastpercent)+'% ');
                                                                            end;
                     until inputcount>=inputlimit; //eof(inputtxt)=true
                     close(inputtxt);
                     close(outtxt);
                    end;
say('');
end;

procedure decodeinput_xorkey(nameofinput,nameofoutput:string);
var inputtxt,outtxt:text;
    bufc:char;
    bufci,i,z,lastpercent:integer;
    triadaint:integer; 
begin
inputlimit:=open_get_file_size(nameofinput);
lastpercent:=-1;
assign(inputtxt,nameofinput{'input.txt'});
{$i-}
reset(inputtxt);
{$i+}
if Ioresult<>0 then say('COULD NOT READ '+nameofinput) else
if Ioresult=0 then begin 
                     {$i-}
                     assign(outtxt,nameofoutput); //'tmp.txt'
                     rewrite(outtxt);
                     {$i+}
                     if Ioresult<>0 then
                     begin
                           //MessageBox (0, pchar('Could not write '+nameofoutput) , ' ', 0 + MB_ICONHAND)
                           MessageBoxA(0, PAnsiChar(AnsiString('Could not write ' + nameofoutput)),  PAnsiChar(' '),   MB_ICONHAND );
                     end
                           else
                     begin
                      z:=0;
                      inputcount:=0;
                      repeat
                       inputcount:=inputcount+1;
                                                 begin
                                                  z:=z+1;
                                                  read(inputtxt,bufc);
                                                  triadaint:=ord(bufc);
                                                  bufci:=ord(key[z]); 
                                                  i:=triadaint xor bufci;
                                                  write(outtxt,chr(i));
                                                  if z>=keylength then z:=0;
                                                  //write('.');
                                                  if inputlimit<>0 then
                                                  if lastpercent<>(100*inputcount div inputlimit) then begin
                                                                                                        lastpercent:=(100*inputcount div inputlimit);
                                                                                                        say(Convert2String(lastpercent)+'% ');
                                                                                                       end;
                                                 end;
                      until inputcount>=inputlimit; //eof(inputtxt)=true;
                      close(inputtxt);
                      close(outtxt);
                     end;
                    end;
//writeln('');
end;



procedure decodeinput_pumacrpt(nameofinput,nameofoutput:string);
var inputtxt,outtxt:text;
    bufc:char;
    x3s:string;
    equloop,fusecount,startnkey,speedstartn,speedkey,sumkey,lastpercent:integer;
    encar,enc,i,x2,x3,x5,x6,z:integer; 
    eksadaint:integer;
    haslabel:boolean;
    eksada:string;
begin
haslabel:=check_label(nameofinput,'CHECK');
if haslabel=true then say('Decoding Puma-Crypted file') else
                      begin
                       say('Attention , the file doesn`t appear to be Puma-Crypted !!!');
                       say('Press enter to continue operation');
                       readln;
                      end;
inputlimit:=open_get_file_size(nameofinput); 
lastpercent:=-1;
assign(inputtxt,nameofinput);
{$i-}
reset(inputtxt);
{$i+}
assign(outtxt,nameofoutput); //'output.txt'
rewrite(outtxt);
if Ioresult<>0 then say('COULD NOT MAKE OUTPUT.TXT') else
if Ioresult=0 then begin
                     if haslabel=true then for i:=1 to 17 do read(inputtxt,bufc);
                     inputcount:=17; //LOGW TIS LABEL 
                     bufc:=' ';
                     z:=0;
                     equloop:=0;
                     fusecount:=0;
                     say('');
                     say('Decoding');
                     startnkey:=0;
                     speedstartn:=keyspeed;
                     sumkey:=0; 
                     repeat 
                   //if eoln(inputtxt)=false then 
                      begin
                                                  if z<=0 then z:=1;  //an z<=0 den ginetai error!
                                                  floatthekey(z,speedkey);
                                                  equloop:=equations_forward(equloop,1);
                                                  fusecount:=fusecount+fusespeed;
                                                  eksada:='';
                                                  for i:=1 to 6 do begin
                                                                    inputcount:=inputcount+1;
                                                                    read(inputtxt,bufc);
                                                                    eksada:=eksada+bufc;
                                                                   end;
                                                  Val(eksada,eksadaint,i); if i<>0 then                         begin //antiperispasmos
                                                                                                                 fusecount:=fusecount+233;
                                                                                                                 equloop:=equloop+2;
                                                                                                                 speedkey:=speedkey+4;
                                                                                                                 eksadaint:=650005+random(512);
                                                                                                                 startnkey:=startnkey+2;
                                                                                                                end;
                                                  sumkey:=sumkey+(ord(key[z]) div 100);
                                                  x3:=invertequations(equloop,eksadaint,fusecount+sumkey+fibonacci(fusecount,ord(key[z]),fusecount+sumkey));
                                                  x3:=x3-ord(key[z]);  
                                                  if odd(ord(key[z]))=true then begin
                                                                                 if Upcase(key[z])=key[z] then speedkey:=speedkey+1 else
                                                                                                               speedkey:=speedkey+3;

                                                                                end
                                                                                 else
                                                                                begin
                                                                                 if Upcase(key[z])=key[z] then speedkey:=speedkey+2 else
                                                                                                               speedkey:=speedkey+4;
                                                                                end;
                                                  //speedstartn:=speedkey;
                                                  startnkey:=startnkey+speedstartn;
                                                  if startnkey>=keylength then begin
                                                                                 startnkey:=0;
                                                                                 z:=0;
                                                                               end
                                                                                 else
                                                                                begin
                                                                                 z:=startnkey;
                                                                                end;  
                                                  if fusecount>fuselimit then fusecount:=0; //epanafora tis epiprosthetis metavlitis sto 1 (0+1)
                                                  if sumkey>sumlimit then sumkey:=0; //epanafora tis epiprosthetis metavlitis
                                                  write(outtxt,chr(x3)); 
                                                  if lastpercent+refresh_rate<(100*inputcount div inputlimit) then begin
                                                                                                        lastpercent:=(100*inputcount div inputlimit);
                                                                                                        if verbose then say(Convert2String(lastpercent)+'% ');
                                                                                                        if gui_on then begin
                                                                                                                        set_object_data('progress','value',Convert2String(lastpercent),lastpercent);
                                                                                                                        draw_object_by_name('progress');
                                                                                                                       end;
                                                                                                       end;
                                                 end;
                     until inputcount>=inputlimit{eof(inputtxt)=true};
                     close(inputtxt);
                     close(outtxt);
                    end;
say('');
end;


procedure ensure_file_existance(filenam:string);
var filetst:text;
begin
assign(filetst,filenam);
{$i-}
 reset(filetst);
{$i+}
if Ioresult<>0 then rewrite(filetst);
close(filetst);
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

procedure clean_file(filenam:string);
var filetst:file;
    thesize,i:integer;
begin
assign(filetst,filenam);
{$i-}
 reset(filetst);
{$i+}
if Ioresult=0 then begin
                    thesize:=Filesize(filetst);
                    close(filetst);
                    rewrite(filetst,1);
                    for i:=1 to thesize do blockwrite(filetst,'0',1);
                    close(filetst); 
                   end;
end;

procedure check_files_existance;
var filetst:text;
    i:integer;
begin
for i:=1 to 3 do begin
                  if i=1 then ensure_file_existance('input.txt') else
                  if i=2 then ensure_file_existance('tmp.txt') else
                  if i=3 then ensure_file_existance('output.txt');
                 end;
end;

procedure test_random_fibonacci;
var testa,testb,testc,limitbeg,limitend,tmpres:integer;
    fibres:array[1..200]of integer;
begin
repeat
//for testa:=1 to 20 do writeln('');
say('Give me check range start');
readln(limitbeg);
say('Give me check range end');
readln(limitend);
for testa:=1 to 200 do fibres[testa]:=0;
for testa:=limitbeg to limitend do
for testb:=limitbeg to limitend do
for testc:=limitbeg to limitend do
                       begin
                        tmpres:=fibonacci(testb,testb,testc);
                        if (tmpres>0) and (tmpres<=200) then inc(fibres[tmpres]);
                       end;
for testa:=1 to 200 do write('[',testa,'=',fibres[testa],']');
readln;
until (limitbeg=0) and (limitend=0);
end;

procedure display_chars; 
var i:integer;
begin
for i:=1 to 255 do write('|'+Convert2String(i)+'='+chr(i)+'|');
readln;
end;

function brute_search( strlength: integer; thetext: string ):string;
const db=47; ub=175; //Down/Up Barrier..
var count:longint;
    depth,i,tmp,guistf:integer;
    times:array[1..4]of integer; //3,4 precentage
    tmptxt:string;
    done:boolean;
    label start_dial,abort_search;
begin  
done:=false;
say('Calculating ...');
if strlength<5 then say(Convert2String(Power(ub-db,strlength))+' combinations');

tmptxt:='';
for count:=1 to strlength do tmptxt:=tmptxt+chr(db);
depth:=strlength;
count:=0;
tmp:=power((ub-db),3)*3;
times[1]:=GetTickCount; //Xrwnos ekkinisis
times[3]:=0;
guistf:=0;
repeat
count:=count+1;
tmptxt[depth]:=chr(ord(tmptxt[depth])+1);

if gui_on then begin
                 guistf:=guistf+1;
                 if guistf>=120000 then begin
                                       guistf:=0;
                                       interact;
                                       if GUI_Exit then goto abort_search;
                                      end;
               end;

//writeln(count,' - ',tmptxt);
if tmptxt=thetext then done:=true;
if count mod tmp=0 then begin
                         say('.');
                         times[4]:=(ord(tmptxt[1])-db)*100 div (ub-db);
                         if times[4]<>times[3] then
                                                    begin
                                                     times[3]:=times[4];
                                                     say('');
                                                     say(Convert2String(times[3])+' %');
                                                     if gui_on then begin  
                                                                     set_object_data('progress','value',Convert2String(times[3]),0);
                                                                     draw_object_by_name('progress');
                                                                     set_object_data('progress-text','value',tmptxt,0);
                                                                     draw_object_by_name('progress-text');
                                                                     interact;
                                                                     if GUI_Exit then goto abort_search;
                                                                    end;
                                                    end;
                        end; 
while ord(tmptxt[depth])>=ub do begin
                                  start_dial: 
                                  if depth=1 then begin
                                                   if (ord(tmptxt[depth])<ub) then   begin
                                                                                      tmptxt[depth]:=chr(ord(tmptxt[depth])+1);
                                                                                      depth:=strlength;
                                                                                      tmptxt[depth]:=chr(db);
                                                                                     end else
                                                                                       done:=true;
                                                   break;
                                                  end else
                                                  begin
                                                   tmptxt[depth]:=chr(db); 
                                                   depth:=depth-1;
                                                   tmptxt[depth]:=chr(ord(tmptxt[depth])+1);
                                                  end;
                                   //writeln(count,' - ',tmptxt);
                                   if tmptxt=thetext then done:=true; 
                                   count:=count+1;
                                   if (ord(tmptxt[depth])>=ub) and (depth<>1) then goto start_dial else
                                                                                        depth:=strlength;
                                 end; 


until (done=true);
times[2]:=GetTickCount; //Xrwnos telous
say('');
say('Result = "'+tmptxt+'"');
if strlength<5 then say('Scanned '+Convert2String(count)+'/'+Convert2String(Power(ub-db,strlength))+' combinations');
say(Convert2String((times[2]-times[1]) div 1000)+' seconds');

if gui_on then begin
                 include_object('commenta1','comment','Result = "'+tmptxt+'"','no','','',25,Y2(last_object)+5,0,0);
                 if strlength<5 then include_object('commenta2','comment','Scanned '+Convert2String(count)+'/'+Convert2String(Power(ub-db,strlength))+' combinations','no','','',25,Y2(last_object)+5,0,0);
                 include_object('commenta3','comment',Convert2String((times[2]-times[1]) div 1000)+' seconds','no','','',25,Y2(last_object)+5,0,0);
               end;

if tmptxt<>thetext then begin
                          if gui_on then include_object('commenta4','comment','Failed :-(','no','','',25,Y2(last_object)+5,0,0);
                          say('Failed :-(');
                         tmptxt:='FAILED';
                        end;
if gui_on then begin
                include_object('commenta5','comment','Press any key to continue','no','','',25,Y2(last_object)+5,0,0);
                include_object('exit','buttonc','Done','no','','',25,Y2(last_object)+5,0,0);
                draw_all;
                repeat
                 interact;
                until GUI_Exit;
               end;
abort_search:
brute_search:=tmptxt;
end;

function create_password(thelength:integer):string;
var outputstr:string;
    i,chri:integer;
begin
if thelength>254 then thelength:=254;
randomize;
outputstr:='';
for i:=1 to thelength do begin
                           chri:=0;
                           while (chri<48) or (chri>122) do begin
                                                              chri:=Round(random(255))
                                                             end;
                           outputstr:=outputstr+chr(chri); 
                         end;
create_password:=outputstr;
end;

function encrypt_string(what2encrypt:string):string;
var outputstr:string;
    fileused:textfile;
    i,chri:integer;
begin
outputstr:='';
assign(fileused,'puma_crypt_tmp_file_encryption_123');
{$i-}
  rewrite(fileused);
{$i+}
if Ioresult<>0 then MessageBox (0, 'Could not perform encryption' , 'Encryption Error', 0 + MB_ICONEXCLAMATION) else
  begin
    write(fileused,what2encrypt);
    close(fileused);
    encodeinput_xorkey('puma_crypt_tmp_file_encryption_123','puma_crypt_tmp_file_encryption_123_1');
    encodeinput_pumacrpt('puma_crypt_tmp_file_encryption_123_1','puma_crypt_tmp_file_encryption_123');
    delete_file('puma_crypt_tmp_file_encryption_123_1');
    {$i-}
      reset(fileused);
    {$i+}
     if Ioresult<>0 then MessageBox (0, 'Could not perform encryption' , 'Encryption Error', 0 + MB_ICONEXCLAMATION) else
      begin
        readln(fileused,outputstr);
        readln(fileused,outputstr);
        close(fileused);
        delete_file('puma_crypt_tmp_file_encryption_123');
      end;
  end;
encrypt_string:=outputstr;
end;

 
begin  
verbose:=true;
gui_on:=false;
refresh_rate:=0;
end.

