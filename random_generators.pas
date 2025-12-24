unit random_generators;

interface
procedure clear_errors_generating;
function error_generating:boolean;

function StringAddUp1(thestr:string):integer;
function make_string_serial_like(thestr:string):string;
function make_serial_string_like(thestr:string):string;
function inflate_code_charset(inflatestr:string):string;
function deflate_code_charset(inflatestr:string):string;
procedure TEst_Converter;
function char_is_letter(thechar:char):boolean;
function create_password(thelength:integer):string;
procedure random_2_diffrence(numeq:integer; var num1,num2:byte);
procedure random_2_addup(numeq:integer; var num1,num2:byte);
implementation 
uses windows,ammarunit,aps3_lowlevel;
var inflation_space:array[0..31]of byte;
    error_gen:boolean;


procedure clear_errors_generating;
begin
 error_gen:=false;
end;

function error_generating:boolean;
begin
error_generating:=error_gen;
end;


function StringAddUp1(thestr:string):integer;
var retres,i:integer;
begin
retres:=0;
if Length(thestr)>0 then
 begin
   for i:=1 to Length(thestr) do
     begin
      retres:=retres+i*ord(thestr[i]);
     end; 
 end; 
StringAddUp1:=retres;
end;

function make_string_serial_like(thestr:string):string;
var retres:string;
    i,count:integer;
begin
count:=0;
for i:=1 to Length(thestr) do
  begin
    count:=count+1;
    retres:=retres+thestr[i];
    if ((i<>Length(thestr)) and (count=6)) then
       begin
        count:=0;
        retres:=retres+'-';
       end; 
  end; 
make_string_serial_like:=retres;
end;

function make_serial_string_like(thestr:string):string;
var retres:string;
    i,count:integer;
begin
count:=0;
retres:='';
for i:=1 to Length(thestr) do
  begin
    count:=count+1;
    if thestr[i]<>'-' then retres:=retres+thestr[i];
  end; 
make_serial_string_like:=retres;
end;



function get_hex_char(thebyte:byte):char;
var retchar:char;
begin
if thebyte<=9 then retchar:=chr(ord('0')+thebyte) else
if thebyte<=34 then retchar:=chr(ord('a')+thebyte-10) else
if thebyte<=59 then retchar:=chr(ord('A')+thebyte-35) else
if thebyte=60 then retchar:='@' else
if thebyte=61 then retchar:='$' else
if thebyte=62 then retchar:='*' else
                   retchar:='?';
get_hex_char:=retchar;
end;

function get_char_hex(thechar:char):byte;
var rethex:byte;
begin
if thechar='?' then rethex:=63 else
if thechar='*' then rethex:=62 else
if thechar='$' then rethex:=61 else
if thechar='@' then rethex:=60 else
if ord(thechar)-ord('a')>=0 then rethex:=ord(thechar)-ord('a')+10 else
if ord(thechar)-ord('A')>=0 then rethex:=ord(thechar)-ord('A')+35 else
if ord(thechar)-ord('0')>=0 then rethex:=ord(thechar)-ord('0');

 
get_char_hex:=rethex;
end;
 
function ConvertInflation2String:string;
var bufstr:string;
    i,z:integer;
begin
bufstr:='';
 for i:=4 downto 1 do
   begin
     for z:=(i*8)-1 downto (i*8)-8 do
       begin
         set_bit(z-(i*8)+8,inflation_space[z]);
         //bufstr:=bufstr+Convert2String(inflation_space[z]);
       end; 
      //bufstr:=bufstr+'='+get_hex_char(bits_2_byte)+',';
      bufstr:=bufstr+get_hex_char(bits_2_byte);
   end;
ConvertInflation2String:=bufstr;
end;

procedure ConvertString2Inflation(inpt:string);
var bufstr:string;
    i,z,u:integer;
    tmp_val:byte;
begin
bufstr:='';
 for i:=4 downto 1 do
   begin
     tmp_val:=get_char_hex(inpt[i]);
     byte_2_bits(tmp_val);
     for z:=(i*8)-1 downto (i*8)-8 do
       begin
         if z>=24 then u:=z-24 else
         if z>=16 then u:=z-8 else
         if z>=8 then u:=z+8 else
         if z>=0 then u:=z+24; //ALLAGI FORAS (BUG FOUND AND FIXED 6-4-07 3:21)
         inflation_space[u]:=return_bit(z-(i*8)+8);
       end; 
   end; 
end; 

 

function inflate_code_charset(inflatestr:string):string;
var bufstr:string;
    i,z:integer;
begin
bufstr:='';
i:=1;
while i<Length(inflatestr) do
 begin 
   byte_2_bits(ord(inflatestr[i]));

   // PART #1 / 4
   inflation_space[31]:=0;
   inflation_space[30]:=0;
   inflation_space[29]:=return_bit(7);
   inflation_space[28]:=return_bit(6);
   inflation_space[27]:=return_bit(5);
   inflation_space[26]:=return_bit(4);
   inflation_space[25]:=return_bit(3);
   inflation_space[24]:=return_bit(2);

   // PART #2 / 4
   inflation_space[23]:=0;
   inflation_space[22]:=0;
   inflation_space[21]:=return_bit(1);
   inflation_space[20]:=return_bit(0);
   byte_2_bits(ord(inflatestr[i+1]));
   inflation_space[19]:=return_bit(7);
   inflation_space[18]:=return_bit(6);
   inflation_space[17]:=return_bit(5); 
   inflation_space[16]:=return_bit(4);

   // PART #3 / 4
   inflation_space[15]:=0;
   inflation_space[14]:=0;
   inflation_space[13]:=return_bit(3);
   inflation_space[12]:=return_bit(2);
   inflation_space[11]:=return_bit(1);
   inflation_space[10]:=return_bit(0);
   byte_2_bits(ord(inflatestr[i+2]));
   inflation_space[9]:=return_bit(7);
   inflation_space[8]:=return_bit(6);

   // PART #4 / 4
   inflation_space[7]:=0;
   inflation_space[6]:=0;
   inflation_space[5]:=return_bit(5);
   inflation_space[4]:=return_bit(4);
   inflation_space[3]:=return_bit(3);
   inflation_space[2]:=return_bit(2);
   inflation_space[1]:=return_bit(1);
   inflation_space[0]:=return_bit(0);

   bufstr:=bufstr+ConvertInflation2String; 
   i:=i+3;
 end;

inflate_code_charset:=bufstr;
end;



function deflate_code_charset(inflatestr:string):string;
var bufstr,retres:string;
    i,z:integer;
    possible_error:boolean;
begin
possible_error:=false;
retres:='';
i:=1;
while i<Length(inflatestr) do
 begin 
   bufstr:='';
   bufstr:=inflatestr[i];
   bufstr:=bufstr+inflatestr[i+1];
   bufstr:=bufstr+inflatestr[i+2];
   bufstr:=bufstr+inflatestr[i+3];
   
   ConvertString2Inflation(bufstr);
 
   // PART #1 / 4 
   if ((inflation_space[31]<>0) or (inflation_space[30]<>0)) then possible_error:=true;
   set_bit(7,inflation_space[29]);//:=return_bit(7);
   set_bit(6,inflation_space[28]);//:=return_bit(6);
   set_bit(5,inflation_space[27]);//:=return_bit(5);
   set_bit(4,inflation_space[26]);//:=return_bit(4);
   set_bit(3,inflation_space[25]);//:=return_bit(3);
   set_bit(2,inflation_space[24]);//:=return_bit(2);

   // PART #2 / 4 
   if ((inflation_space[23]<>0) or (inflation_space[22]<>0)) then possible_error:=true;
   set_bit(1,inflation_space[21]);//:=return_bit(1);
   set_bit(0,inflation_space[20]);//:=return_bit(0);
   retres:=retres+chr(bits_2_byte); 
 
   set_bit(7,inflation_space[19]);//:=return_bit(7);
   set_bit(6,inflation_space[18]);//:=return_bit(6);
   set_bit(5,inflation_space[17]);//:=return_bit(5);
   set_bit(4,inflation_space[16]);//:=return_bit(4);

   // PART #3 / 4
   if ((inflation_space[15]<>0) or (inflation_space[14]<>0)) then possible_error:=true; 
   set_bit(3,inflation_space[13]);//:=return_bit(3);
   set_bit(2,inflation_space[12]);//:=return_bit(2);
   set_bit(1,inflation_space[11]);//:=return_bit(1);
   set_bit(0,inflation_space[10]);//:=return_bit(0);
   retres:=retres+chr(bits_2_byte); 
  
   set_bit(7,inflation_space[9]);//:=return_bit(7);
   set_bit(6,inflation_space[8]);//:=return_bit(6);

   // PART #4 / 4
   if ((inflation_space[7]<>0) or (inflation_space[6]<>0)) then possible_error:=true;
   set_bit(5,inflation_space[5]);//:=return_bit(5);
   set_bit(4,inflation_space[4]);//:=return_bit(4);
   set_bit(3,inflation_space[3]);//:=return_bit(3);
   set_bit(2,inflation_space[2]);//:=return_bit(2);
   set_bit(1,inflation_space[1]);//:=return_bit(1);
   set_bit(0,inflation_space[0]);//:=return_bit(0);
   retres:=retres+chr(bits_2_byte);  

   i:=i+4;
 end;
if possible_error then MessageBox (0, 'Error Deflating..' , ' ', 0 + MB_ICONEXCLAMATION);
deflate_code_charset:=retres;
end;


procedure TEst_Converter;
var i,z,l:integer;
    tmp,tmp2,descr,gather:string;
    inflation_space_test:array[0..31]of byte;

begin
 for i:=0 to 63 do
   begin
     if get_char_hex(get_hex_char(i))<>i then MessageBox (0, pchar('Error in basic deflation routine '+Convert2String(i)) , ' ', 0);
   end;


 for i:=0 to 60 do
   begin
     tmp:=get_hex_char(i)+get_hex_char(i+1)+get_hex_char(i+2)+get_hex_char(i+3);
     ConvertString2Inflation(tmp);
     for z:=0 to 31 do inflation_space_test[z]:=inflation_space[z];
     tmp2:=ConvertInflation2String;
     descr:='';    
     for z:=1 to 4 do begin
                        if tmp[z]<>tmp2[z] then
                          descr:=descr+' '+Convert2String(z)+'('+Convert2String(abs(ord(tmp[z])-ord(tmp2[z])))+') '+Convert2String(ord(tmp[z]))+','+Convert2String(ord(tmp2[z]));
                      end;    
     if tmp2<>tmp then MessageBox (0, Pchar('Error in convertor , value '+Convert2String(i)+' '+descr) , ' ', 0);
   end;

  gather:='';
  for i:=1 to 255 do
   begin
     tmp:=get_hex_char(i)+get_hex_char(i)+get_hex_char(i);
     tmp2:=inflate_code_charset(tmp);
     tmp2:=deflate_code_charset(tmp2);  
     descr:='';    
     for z:=1 to Length(tmp) do begin
                        if tmp[z]<>tmp2[z] then
                          descr:=descr+' '+Convert2String(z)+'('+Convert2String(abs(ord(tmp[z])-ord(tmp2[z])))+') '+Convert2String(ord(tmp[z]))+','+Convert2String(ord(tmp2[z]));
                      end;    
     if tmp2<>tmp then gather:=gather+'Error in convertor , value '+Convert2String(i)+' '+descr+#10; 
   end;
   //if gather<>'' then MessageBox (0, PChar(gather) , ' ', 0);
   if gather <> '' then
  MessageBoxA(
    0,
    PAnsiChar(AnsiString(gather)),
    PAnsiChar(AnsiString(' ')),
    0
  );

end;

function char_is_letter(thechar:char):boolean;
var chr_ok:boolean;
    chri:integer;
begin
chr_ok:=false;
chri:=ord(thechar);
if ((ord(thechar)>=48) and (ord(thechar)<=122)) then
  begin
   chr_ok:=true;
   if chri=ord('_') then chr_ok:=false else
   if chri=ord('@') then chr_ok:=false else
   if chri=ord('-') then chr_ok:=false else
   if chri=ord('=') then chr_ok:=false else
   if chri=ord('+') then chr_ok:=false else
   if chri=ord('!') then chr_ok:=false else
   if chri=ord('#') then chr_ok:=false else
   if chri=ord('%') then chr_ok:=false else
   if chri=ord('^') then chr_ok:=false else
   if chri=ord('&') then chr_ok:=false else
   if chri=ord('*') then chr_ok:=false else
   if chri=ord('(') then chr_ok:=false else
   if chri=ord(')') then chr_ok:=false else
   if chri=ord('[') then chr_ok:=false else
   if chri=ord(']') then chr_ok:=false else
   if chri=ord('{') then chr_ok:=false else
   if chri=ord('}') then chr_ok:=false else
   if chri=ord('|') then chr_ok:=false else
   if chri=ord('\') then chr_ok:=false else
   if chri=ord('/') then chr_ok:=false else
   if chri=ord('?') then chr_ok:=false else
   if chri=ord(';') then chr_ok:=false else
   if chri=ord(':') then chr_ok:=false else
   if chri=ord(',') then chr_ok:=false else
   if chri=ord('.') then chr_ok:=false else
   if chri=ord('~') then chr_ok:=false else
   if chri=ord('`') then chr_ok:=false else
   if chri=ord('<') then chr_ok:=false else
   if chri=ord('>') then chr_ok:=false;
  end;
char_is_letter:=chr_ok;
end;




function create_password(thelength:integer):string;
var outputstr:string;
    i,chri:integer;
    chr_ok:boolean;
begin
if thelength>254 then thelength:=254;
outputstr:='';
for i:=1 to thelength do begin
                           chri:=0;
                           chr_ok:=false;
                           //while (chri<48) or (chri>122) or (not chr_ok) do
                                                             begin
                                                              chri:=Round(random(255));
                                                              //chr_ok:=char_is_letter(chr(chri));
                                                             end;
                           outputstr:=outputstr+chr(chri); 
                         end;
create_password:=outputstr;
end;


 
procedure random_2_diffrence(numeq:integer; var num1,num2:byte);   //numeq = num1 - num2
var numok:boolean;
    attempts:cardinal;
    i,z,l:integer;
    label adynaton;
begin
numok:=false; 
attempts:=0;

z:=0;
for i:=0 to 255 do begin //DIAPISTWSI TOU AN YPARXEI LYSI
                     if ((i-numeq<=255) and (i-numeq>=0)) then z:=z+1;
                   end;

if z=0 then begin //DEN YPARXEI LYSI
               error_gen:=true;
               //MessageBox (0, pchar('Adynaton '+Convert2String(numeq)+'= x - y  (0<=x<=255 , 0<=y<=255)') , ' ', 0); 
               num1:=0;
               num2:=0;
               goto adynaton;
              end else
if z<20 then  begin //YPARXOUN ELAXISTES LYSEIS , AS VOITHISOUME TIN RANDOM
                l:=0;
                for i:=0 to 255 do begin
                                      if ((i-numeq<=255) and (i-numeq>=0)) then 
                                           begin
                                            l:=l+1;
                                            if l=z div 2 then
                                               begin
                                                num1:=i;
                                                num2:=i-numeq;
                                                goto adynaton;
                                               end;
                                           end;
                                   end;
              end;

while (not numok) do
   begin
     attempts:=attempts+1;
     num1:=Round(random(255));
     numok:=true;//char_is_letter(chr(num1));
      if numok then
        begin  
          numok:=true; 
          if ((num1-numeq<=255) and (num1-numeq>=0)) then num2:=num1-numeq else
                                                          numok:=false;
          //numok:=char_is_letter(chr(num2));
        end; 
    if attempts>210123 then begin
                              //MessageBox (0, 'Could not find solution for random difference' , ' ', 0 + MB_ICONEXCLAMATION);
                              error_gen:=true;
                              break;
                            end;
   end;
adynaton:
end;

procedure random_2_addup(numeq:integer; var num1,num2:byte);   //numeq = num1 + num2
var numok:boolean; 
    i,z,l:integer;
    attempts:cardinal;
    label adynaton;
begin
numok:=false; 
attempts:=0;


z:=0;
for i:=0 to 255 do begin //DIAPISTWSI TOU AN YPARXEI LYSI
                     if ((numeq-i<=255) and (numeq-i>=0)) then z:=z+1;
                   end;

if z=0 then begin //DEN YPARXEI LYSI
               error_gen:=true;
               //MessageBox (0, pchar('Adynaton '+Convert2String(numeq)+'= x + y  (0<=x<=255 , 0<=y<=255)') , ' ', 0);
               num1:=0;
               num2:=0;
               goto adynaton;
              end else
if z<20 then  begin //YPARXOUN ELAXISTES LYSEIS , AS VOITHISOUME TIN RANDOM
                l:=0;
                for i:=0 to 255 do begin
                                      if ((numeq-i<=255) and (numeq-i>=0)) then
                                           begin 
                                            l:=l+1;
                                            if l=z div 2 then
                                               begin
                                                num1:=i;
                                                num2:=numeq-i;
                                                goto adynaton;
                                               end;
                                           end;
                                   end;
              end;


while (not numok) do
   begin
     attempts:=attempts+1;
     num1:=Round(random(255));
     numok:=true;//char_is_letter(chr(num1));
      if numok then
        begin  
          numok:=true;
          if (numeq-num1<0) then numok:=false else
                                 num2:=numeq-num1;
          //numok:=char_is_letter(chr(num2));
        end; 
      if attempts>210343 then begin
                                 //MessageBox (0, 'Could not find solution for random difference' , ' ', 0 + MB_ICONEXCLAMATION);
                                 error_gen:=true;
                                 break;
                              end;
   end; 

 adynaton:
end;


procedure random_2_xor(numeq:integer; var num1,num2:byte);   //numeq = num1 - num2
var numok:boolean;
begin
numok:=false;

while (not numok) do
   begin
     num1:=Round(random(255));
     numok:=char_is_letter(chr(num1));
      if numok then
        begin 
          if (numeq+num1<=255) then num2:=numeq+num1 else
                                    num2:=num1-numeq;

        end;

   end; 
end;




{bufstr:=bufstr+'Ord(z) - Ord(a) = '+Convert2String(ord('z'))+' - '+Convert2String(ord('a'))+' = '+Convert2String(ord('z')-ord('a'))+#10;
bufstr:=bufstr+'Ord(Z) - Ord(A) = '+Convert2String(ord('Z'))+' - '+Convert2String(ord('A'))+' = '+Convert2String(ord('Z')-ord('A'))+#10;
bufstr:=bufstr+'Ord(9) - Ord(0) = '+Convert2String(ord('9'))+' - '+Convert2String(ord('0'))+' = '+Convert2String(ord('9')-ord('0'))+#10;
MessageBox (0, pchar(bufstr) , ' ', 0);}

begin
end.
