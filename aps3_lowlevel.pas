unit aps3_lowlevel;
interface  
 
function POW(base,power:byte):byte;
function POW_BIG(base,power:byte):word;
function return_bit(thebit:byte):byte;
procedure set_bit(thebit,theval:byte);
procedure byte_2_bits(thebyte:byte);
function bits_2_byte:byte;
procedure word_2_bits(theworde:word);
function bits_2_word:word;
procedure word_2_bytes(theword:word; var byte1,byte2:byte);
procedure word_2_byte(theword:word; var byte2:byte);
procedure bytes_2_word(byte1,byte2:byte; var theword:word);
function word_2_string(theword:word):string;
function string_2_word(thestring:string):word;

implementation  

var tmp_byte:byte;
    typebyte:array[0..15] of byte;

function POW(base,power:byte):byte;
var   i:integer;
      retres:byte;
begin 
retres:=1;
 if power=0 then retres:=1 else 
            begin
             for i:=1 to (power) do retres:=retres*base;
            end;
 POW:=retres;
end;

function POW_BIG(base,power:byte):word;
var   i:integer;
      retres:word;
begin 
retres:=1;
 if power=0 then retres:=1 else 
            begin
             for i:=1 to (power) do retres:=retres*base;
            end;
 POW_BIG:=retres;
end;

function return_bit(thebit:byte):byte;
begin
return_bit:=typebyte[thebit];
end;

procedure set_bit(thebit,theval:byte);
begin
typebyte[thebit]:=theval;
end;

procedure byte_2_bits(thebyte:byte);
var i:integer; 
    power:byte;
begin 
for i:=7 downto 0 do begin
                      power:=POW(2,i);
                      if (thebyte div power)=0 then typebyte[i]:=0 else
                                                    begin
                                                     typebyte[i]:=1;
                                                     thebyte:=thebyte-power;
                                                    end;
                     end; 
end;

function bits_2_byte:byte;
var i:integer;
    retres:byte;
begin
retres:=0;
for i:=7 downto 0 do begin
                      retres:=retres+typebyte[i]*POW(2,i);
                     end;
bits_2_byte:=retres;
end;

procedure word_2_bits(theworde:word);
var i:integer; 
    power:word;
begin 
for i:=15 downto 0 do begin
                       power:=POW_BIG(2,i);
                       if (theworde div power)=0 then typebyte[i]:=0 else
                                                     begin
                                                       typebyte[i]:=1;
                                                       theworde:=theworde-power;
                                                     end;
                      end;
end;

function bits_2_word:word;
var i:integer;
    retres:word;
begin
retres:=0;
for i:=15 downto 0 do begin
                       retres:=retres+typebyte[i]*POW_BIG(2,i);
                      end;
bits_2_word:=retres;
end;


procedure word_2_bytes(theword:word; var byte1,byte2:byte);
var i:integer;
    res1,res2:byte;
begin
word_2_bits(theword);
res1:=0;
for i:=15 downto 8 do begin
                       res1:=res1+typebyte[i]*POW(2,i-8);
                     end; 
res2:=0;
for i:=7 downto 0 do begin
                       res2:=res2+typebyte[i]*POW(2,i);
                     end;
byte1:=res1;
byte2:=res2;
end;

procedure word_2_byte(theword:word; var byte2:byte);
var i:integer;
    res2:byte;
begin
word_2_bits(theword); 
res2:=0;
for i:=7 downto 0 do begin
                       res2:=res2+typebyte[i]*POW(2,i);
                     end; 
byte2:=res2;
end;


procedure bytes_2_word(byte1,byte2:byte; var theword:word);
var i:integer;
    thisbyte:array[0..15] of byte;
begin
byte_2_bits(byte1);
for i:=15 downto 8 do thisbyte[i]:=typebyte[i-8];

byte_2_bits(byte2);
for i:=7 downto 0 do thisbyte[i]:=typebyte[i];

for i:=15 downto 0 do typebyte[i]:=thisbyte[i];
theword:=bits_2_word; 
 
end;


function word_2_string(theword:word):string;
var retres:string;
    the_byte1,the_byte2:byte; 
begin
retres:=''; 
word_2_bytes(theword,the_byte1,the_byte2);
retres:=retres+chr(the_byte1)+chr(the_byte2); 
word_2_string:=retres;
end;

function string_2_word(thestring:string):word;
var retres:word;
    the_byte1,the_byte2:byte;
label skip_convertion;
begin
retres:=0;
if Length(thestring)<2 then goto skip_convertion;
the_byte1:=ord(thestring[1]);
the_byte2:=ord(thestring[2]); 
bytes_2_word(the_byte1,the_byte2,retres); 
skip_convertion:
string_2_word:=retres;
end;


begin
end.
