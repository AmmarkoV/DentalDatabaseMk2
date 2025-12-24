unit string_stuff;
{$H+}
interface

function StringShrink(thestr:string; thepix:integer):string;
function IsStringFilesystemCompatible(thestr:string):boolean;
function StringFilterFilesystem(thestr:string):string;
function SerialEqual(serial1,str1:string):byte;
function GreekEqual(bufstr1,bufstr2:string):boolean;
function Greeklish(str1:string):string; 
function TrimSpaces(bufstr:string):string;
function GetRidOfSpaces(bufstr:string):string;
function First_Capital(bufstr3:string):string;
function Sigma_Teliko(bufstr:string):string;
procedure set_mpalanter(thenew:char);
function seperate_words(bufstr4:string):integer;
function get_memory(i:integer):string; 
function get_memory_int(i:integer):integer;
procedure set_memory(i:integer; value:string); 
procedure set_memory_int(i:integer; value:integer);

implementation 
uses ammarunit;
const  seperate_words_strength=30;
       seperate_words_read_strength=1024;
var     memory:array[1..seperate_words_strength] of string;
        memoryinteger:array[1..seperate_words_strength] of integer;
        mpalanter:char;

function CharEqual(char1,char2:char):boolean;
var retres:boolean;
begin
retres:=false;
if char1=char2 then retres:=true else
if Upcase2(char1)=Upcase2(char2) then retres:=true;
CharEqual:=retres;
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
   //xsize := xsize + TextWidth(String(thestr[letter]));
   //xsize := xsize + TextWidth(thestr[letter] + '');
   //xsize := xsize + TextWidth(Copy(thestr, letter, 1));

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

function StringFilterFilesystem(thestr:string):string;
var i:integer;
    retres:string;
begin
retres:='';
// / \ * ? : " > < | filter
if Length(thestr)>0 then
  begin
    for i:=1 to Length(thestr) do
      begin
        if thestr[i]='/' then begin end else
        if thestr[i]='\' then begin end else
        if thestr[i]='*' then begin end else
        if thestr[i]='?' then begin end else
        if thestr[i]=':' then begin end else
        if thestr[i]='<' then begin end else
        if thestr[i]='>' then begin end else
        if thestr[i]='|' then begin end else
         begin
          retres:=retres+thestr[i];
         end;
      end;
  end;
StringFilterFilesystem:=retres;
end;


function IsStringFilesystemCompatible(thestr:string):boolean;
var i:integer;
    retres:boolean;
begin
retres:=true;
// / \ * ? : " > < | filter
if Length(thestr)>0 then
  begin
    for i:=1 to Length(thestr) do
      begin
        if thestr[i]='/' then retres:=false else
        if thestr[i]='\' then retres:=false else
        if thestr[i]='*' then retres:=false else
        if thestr[i]='?' then retres:=false else
        if thestr[i]=':' then retres:=false else
        if thestr[i]='<' then retres:=false else
        if thestr[i]='>' then retres:=false else
        if thestr[i]='|' then retres:=false else
         begin 
         end;
       if retres=false then break;
      end;
  end;
IsStringFilesystemCompatible:=retres;
end;


function SerialEqual(serial1,str1:string):byte;
var z,x:integer;
    retres:byte;
    label end_serial;
begin
retres:=0;
x:=1;
if Length(serial1)=0 then begin
                          end else
if Length(serial1)<=Length(str1) then
   begin
    for z:=1 to Length(str1) do
      begin
       if CharEqual(str1[z],serial1[x]) then begin
                                               x:=x+1;
                                             end else
                                               x:=1;
       if x=Length(serial1)+1 then   begin
                                      retres:=z;
                                      goto end_serial;
                                    end;
      end;
   end;
end_serial:
SerialEqual:=retres;
end;



function IgnoreTunas(bufstr1:string):string; // Afairei tous tonous apo kefalaia..
var retres:string;
    i:integer;
begin
retres:='';
if Length(bufstr1)>0 then begin
for i:=1 to Length(bufstr1) do begin
                                 if bufstr1[i]='ข' then retres:=retres+'A' else
                                 if bufstr1[i]='ธ' then retres:=retres+'ล' else
                                 if bufstr1[i]='บ' then retres:=retres+'ษ' else
                                 if bufstr1[i]='ผ' then retres:=retres+'ฯ' else
                                 if bufstr1[i]='ฟ' then retres:=retres+'ู' else
                                 if bufstr1[i]='พ' then retres:=retres+'ี' else
                                 if bufstr1[i]='น' then retres:=retres+'ว' else
                                 retres:=retres+bufstr1[i];
                               end;
                           end;
IgnoreTunas:=retres;
end;

function IgnoreAnorthografia(bufstr1:string):string; // Aplopoiei tin grammatiki kai epitrepei anaorthografies..
var retres:string;
    i:integer;
begin
retres:='';
if Length(bufstr1)>0 then begin
                              i:=0;
                              repeat
                               i:=i+1;
                                 if ((bufstr1[i]='ม') and (i+1<=Length(bufstr1)))  then
                                      begin //AI <- difthogkoi se aploi..
                                       if bufstr1[i+1]='ษ' then begin
                                                                 retres:=retres+'ล';
                                                                 i:=i+1;
                                                                end else
                                                                retres:=retres+bufstr1[i];
                                      end else
                                 if ((bufstr1[i]='ล') and (i+1<=Length(bufstr1)))  then
                                      begin //ลI <- difthogkoi se aploi..
                                       if bufstr1[i+1]='ษ' then begin
                                                                 retres:=retres+'ษ';
                                                                 i:=i+1;
                                                                end else
                                                                retres:=retres+bufstr1[i];
                                      end else
                                 if ((bufstr1[i]='ฯ') and (i+1<=Length(bufstr1)))  then
                                      begin //ฯI <- difthogkoi se aploi..
                                       if bufstr1[i+1]='ษ' then begin
                                                                 retres:=retres+'ษ';
                                                                 i:=i+1;
                                                                end else
                                                                retres:=retres+bufstr1[i];
                                      end else
                                 if ((bufstr1[i]='ส') and (i+1<=Length(bufstr1)))  then
                                      begin //สำ <- difthogkoi se aploi..
                                       if bufstr1[i+1]='ำ' then begin
                                                                 retres:=retres+'ฮ';
                                                                 i:=i+1;
                                                                end else
                                                                retres:=retres+bufstr1[i];
                                      end else
                                 if ((bufstr1[i]='ร') and (i+1<=Length(bufstr1)))  then
                                      begin //สำ <- difthogkoi se aploi..
                                       if bufstr1[i+1]='ร' then begin
                                                                 retres:=retres+'รส';
                                                                 i:=i+1;
                                                                end else
                                                                retres:=retres+bufstr1[i];
                                      end else
                                 if bufstr1[i]='ษ' then retres:=retres+'ษ' else
                                 if bufstr1[i]='ว' then retres:=retres+'ษ' else
                                 if bufstr1[i]='ี' then retres:=retres+'ษ' else
                                 if bufstr1[i]='ฯ' then retres:=retres+'ฯ' else
                                 if bufstr1[i]='ู' then retres:=retres+'ฯ' else 
                                 retres:=retres+bufstr1[i]; 
                             until i>=Length(bufstr1);
                           end; 
IgnoreAnorthografia:=retres;
end;


function Greeklish(str1:string):string;
var  bufc1,str2,str3:string; 
     i:integer;
begin
str2:=Upcase2(str1);
str3:='';
for i:=1 to Length(str1) do begin
                             bufc1:=str2[i];
                             if bufc1='ม' then bufc1:='A' else
                             if bufc1='ข' then bufc1:='A' else
                             if bufc1='ย' then bufc1:='B' else 
                             if bufc1='ร' then bufc1:='G' else
                             if bufc1='ฤ' then bufc1:='D' else
                             if bufc1='ล' then bufc1:='E' else
                             if bufc1='ธ' then bufc1:='E' else
                             if bufc1='ฦ' then bufc1:='Z' else
                             if bufc1='ว' then bufc1:='H' else
                             if bufc1='น' then bufc1:='H' else
                             if bufc1='ศ' then bufc1:='8' else
                             if bufc1='ษ' then bufc1:='I' else 
                             if bufc1='บ' then bufc1:='I' else
                             if bufc1='ส' then bufc1:='K' else
                             if bufc1='ห' then bufc1:='L' else
                             if bufc1='ฬ' then bufc1:='M' else
                             if bufc1='อ' then bufc1:='N' else
                             if bufc1='ฮ' then bufc1:='KS' else
                             if bufc1='ฯ' then bufc1:='O' else
                             if bufc1='ผ' then bufc1:='O' else
                             if bufc1='ะ' then bufc1:='P' else
                             if bufc1='ั' then bufc1:='R' else
                             if bufc1='ำ' then bufc1:='S' else
                             if bufc1='ิ' then bufc1:='T' else
                             if bufc1='ี' then bufc1:='Y' else
                             if bufc1='พ' then bufc1:='Y' else
                             if bufc1='ึ' then bufc1:='F' else
                             if bufc1='ื' then bufc1:='X' else
                             if bufc1='ุ' then bufc1:='PS' else
                             if bufc1='ู' then bufc1:='W' else
                             if bufc1='ฟ' then bufc1:='W';
                             str3:=str3+bufc1;
                            end; 
Greeklish:=lowercase(str3);
end;

function GreekEqual(bufstr1,bufstr2:string):boolean;
var retres:boolean;
    i:integer;
begin
retres:=true;
//if (Length(bufstr1)<>Length(bufstr2)) then retres:=false else
//STO GREEK EQUAL OXI LENGTH CHECK GIATI MPOREI NA YPARXOUN anorthografies tou typou EI -> I opote to megethos tis leksis na einai diaforetiko
//FIXED @ 4:-3 6-5-07
              begin
               //MakeMessageBox ('','Greek Equal '+bufstr1+' '+bufstr2,'OK','','');
               bufstr1:=Upcase2(bufstr1);
               bufstr1:=IgnoreTunas(bufstr1);
               bufstr1:=IgnoreAnorthografia(bufstr1);
               bufstr1:=Greeklish(bufstr1); //+ GREEKLISH SUPPORT!
               bufstr2:=Upcase2(bufstr2);
               bufstr2:=IgnoreTunas(bufstr2);
               bufstr2:=IgnoreAnorthografia(bufstr2);
               bufstr2:=Greeklish(bufstr2); //+ GREEKLISH SUPPORT!
               //MakeMessageBox ('','Greek Equal After '+bufstr1+' '+bufstr2,'OK','','');
               if bufstr2<>bufstr1 then begin
                                         retres:=false; 
                                        end;
               {for i:=1 to Length(bufstr1) do
                  if (IgnoreTunas(Upcase2(bufstr1[i]))<>IgnoreTunas(Upcase2(bufstr2[i]))) then
                                                                  begin
                                                                    retres:=false;
                                                                    break;
                                                                   end;   }
              end;
GreekEqual:=retres;
end;


function TrimSpaces(bufstr:string):string;
var retres:string;
    i,s1,s2:integer;
begin
retres:='';
if Length(bufstr)>0 then
  begin
   s1:=1;
   i:=1;
   while ( (i<=Length(bufstr)) and (bufstr[i]=' ') ) do
    begin
      i:=i+1;
    end;
    s1:=i;

   i:=Length(bufstr);
   while ( (i>0) and (bufstr[i]=' ') ) do
    begin
      i:=i-1;
    end;
    s2:=i;

   if ((s1>0) and (s2<=Length(bufstr)) ) then
     begin 
      for i:=s1 to s2 do
      begin
       retres:=retres+bufstr[i];
      end;
    end;

  end;
TrimSpaces:=retres;
end;


function GetRidOfSpaces(bufstr:string):string;
var retres:string;
    i:integer;
begin
retres:='';
if Length(bufstr)>0 then
  begin
   for i:=1 to Length(bufstr) do
    begin
     if bufstr[i]<>' ' then retres:=retres+bufstr[i];
    end;
  end;
  GetRidOfSpaces:=retres;
end;

function First_Capital(bufstr3:string):string;      
var tmpstr,tmpstr2:string;
begin
tmpstr:=bufstr3;
tmpstr2:='';
if Length(bufstr3)>=1 then begin
                            tmpstr2:=tmpstr2+tmpstr[1];
                            tmpstr2:=Upcase2(tmpstr2);
                            tmpstr[1]:=tmpstr2[1];
                           end;
First_Capital:=tmpstr;
end;
 
function Sigma_Teliko(bufstr:string):string;
var tmpstr:string;
    i1:integer;
begin
tmpstr:='';
if Length(bufstr)>1 then begin
                            for i1:=1 to Length(bufstr) do begin
                                                             if i1<Length(bufstr) then  begin
                                                                                          if (bufstr[i1]='๓') and (bufstr[i1+1]=' ') then tmpstr:=tmpstr+'๒' else
                                                                                                                                        tmpstr:=tmpstr+bufstr[i1];
                                                                                        end else
                                                                                        begin
                                                                                          if (bufstr[i1]='๓') then tmpstr:=tmpstr+'๒' else
                                                                                                                   tmpstr:=tmpstr+bufstr[i1];
                                                                                        end;
                                                            end; 
                           end;
Sigma_Teliko:=tmpstr;
end;

procedure set_mpalanter(thenew:char);
begin
mpalanter:=thenew;
end;

function get_memory(i:integer):string;
begin
get_memory:=memory[i];
end;

function get_memory_int(i:integer):integer;
begin
get_memory_int:=memoryinteger[i];
end;

procedure set_memory(i:integer; value:string);
begin
memory[i]:=value;
end;

procedure set_memory_int(i:integer; value:integer);
begin
memoryinteger[i]:=value;
end;


function seperate_words(bufstr4:string):integer;
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
  if buf[buffers[4]]=mpalanter then buffers[3]:=buffers[3]+1
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
seperate_words:=buffers[6];
end;


{
procedure seperate_words (bufstr4:string);
var buffers:array [1..5] of integer;
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
repeat
  buffers[4]:=buffers[4]+1;
  buffers[5]:=buffers[3];
  if buf[buffers[4]]='(' then buffers[3]:=buffers[3]+1
          else 
  if buf[buffers[4]]=',' then buffers[3]:=buffers[3]+1
          else
  if buf[buffers[4]]=')' then buffers[3]:=buffers[3]+1;

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
end;  }


begin
mpalanter:=',';
end.
