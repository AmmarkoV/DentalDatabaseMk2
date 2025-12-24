unit aps3;
interface
Type

 TRGB=
 Record
   RC,GC,BC:byte;
 End;

 TAPS3Header =
  Record 
    idbyte1,idbyte2,idbyte3:byte;
    apsX:word;
    apsY:word;
    Background:TRGB;
    invert:byte;
    labels:byte;
  End;

function get_internal_stats:string;
procedure set_guess(sel,value:integer);
function get_guess(sel:integer):integer; 
function Pack_Repeat_Pixel(x_y,x,y,times:word):string;
function UnPack_Repeat_Pixel(inpstr:string; var x_y,x,y,count:word);
function Pack_Pixel(x,y:word):string;
function UnPack_Pixel(packedpixel:string; var x,y:word);
function Color_2C(R,G,B:byte):string;
function C_2Color(inp:string; var R,G,B:byte);
function is_aps3(apsname:string):boolean; 
procedure TEST_PIXEL_PACK;

implementation 
uses ammarunit,apsfiles,aps3_lowlevel;
const HANDLES_APS=3;
 

      SAME_X_PIXEL=128;
      SAME_Y_PIXEL=129;
      SAME_X_PIXEL_NEIGHBOR=130;
      SAME_Y_PIXEL_NEIGHBOR=131;
      NEIGHBOR_PIXEL=132;
      REPEAT_PIXEL_X=133;
      REPEAT_PIXEL_Y=134; 
      RECTANGLE_FILLED_SMALL=135;
      RECTANGLE_FILLED_BIG=136;
      RECTANGLE_NOFILL_SMALL=137;
      RECTANGLE_NOFILL_BIG=138;
      REAL_RECTANGLE_SMALL=139;
      REAL_RECTANGLE_BIG=140;
      FILL=141;
      SINGLE_FILL=142;
      REPEAT_PIXEL_X_SMALL=143;
      REPEAT_PIXEL_Y_SMALL=144; 
      RECTANGLE_FILLED_SMALL_GUESSED=145;
      CLOSE_NEIGHBOR_PIXEL=146;

      RGB_CODE=150;
      RGB_CLOSE2LAST_CODE=151;

      FRAME=204;
      DUPLICATE_REGION=205;


      LINE_CODE=128;
      RECTANGLE_CODE=129;
      SIZE_RECTANGLE_CODE=6;
      TRIANGLE_CODE=130;
      POLYLINE_CODE=131;
      RECTANGLE_SIZEFILLED_CODE=132;
      RECTANGLE_NOSIZEFILLED_CODE=133;
      REAL_RECTANGLE_NOSIZEFILLED_CODE=134; 
      FILL_CODE=135;
      // COLORS START

     { HSL_CODE=151;
      HSV_CODE=152;
      YUV_CODE=153;
      LAB_CODE=154;
      CMY_CODE=155;
      CMYK_CODE=156;     }
      // COMPRESSION 
      REPEAT_PIXEL_X_CODE=202;
      REPEAT_PIXEL_Y_CODE=203;
      //FRAME
      FRAME_CODE=206;        


var
    paperin:array[1..1024,1..768] of integer;
    picture_x,picture_y,picture_trans:integer;
    guess_x,guess_y:integer;
    guess_color:TRGB;
    internal_stats:array[1..10] of integer;
    //1=PIXEL REPEATS , 2=RAW PIXELS , 3=NEIGHBOR PIXELS , 4 SAMEPIXELS , 5 SAMEPIXELS NEIGHBOR ,6 CLOSE COLORS , 7=SINGLE FILL , 8 CLOSE NEIGHBOR
// BYTE WORD AND GENERIC LOW LEVEL ROUTINES START





// BYTE WORD AND GENERIC LOW LEVEL ROUTINES END



function get_internal_stats:string;
var retres:string;
begin
retres:='******INTERNAL_STATS******'+#10;
retres:=retres+'PIXEL REPEATS '+Convert2String(internal_stats[1])+#10;
retres:=retres+'SINGLE FILLS '+Convert2String(internal_stats[7])+#10;
retres:=retres+'RAW PIXELS '+Convert2String(internal_stats[2])+#10;
retres:=retres+'NEIGHBOR PIXELS '+Convert2String(internal_stats[3])+#10;
retres:=retres+'CLOSE NEIGHBOR PIXELS '+Convert2String(internal_stats[8])+#10;
retres:=retres+'DEMI NEIGHBOR PIXELS '+Convert2String(internal_stats[9])+#10;
retres:=retres+'SAME PIXELS '+Convert2String(internal_stats[4])+#10;
retres:=retres+'SAME PIXELS NEIGHBOR '+Convert2String(internal_stats[5])+#10;
retres:=retres+'CLOSE COLORS '+Convert2String(internal_stats[6])+#10;
get_internal_stats:=retres;
end;
 
function get_guess(sel:integer):integer;
begin
if sel=1 then get_guess:=guess_x else
if sel=2 then get_guess:=guess_y else
              get_guess:=0;
end;

procedure set_guess(sel,value:integer);
begin
if sel=1 then guess_x:=value else
if sel=2 then guess_y:=value else
              begin end;
end;





//REPEAT PIXELS
function UnPack_Repeat_Pixel(inpstr:string; var  x_y,x,y,count:word);
var retres:string;
    tmp:word;
    small_count:boolean;
    b1,b2,posread:byte;
begin
small_count:=false;
posread:=1;
if ord(inpstr[posread])=REPEAT_PIXEL_X then x_y:=1 else
if ord(inpstr[posread])=REPEAT_PIXEL_Y then x_y:=0 else
if ord(inpstr[posread])=REPEAT_PIXEL_X_SMALL then begin x_y:=1; small_count:=true; end else
if ord(inpstr[posread])=REPEAT_PIXEL_Y_SMALL then begin x_y:=0; small_count:=true; end;

if (((small_count)and(Length(inpstr)<>6)) or ((not small_count)and(Length(inpstr)<>7))) then writeln('Error Unpacking Repeat Pixel , input');

posread:=2;
bytes_2_word(ord(inpstr[posread]),ord(inpstr[posread+1]),x); 
writeln(ord(inpstr[posread]),' ',ord(inpstr[posread+1]) );
posread:=4;
bytes_2_word(ord(inpstr[posread]),ord(inpstr[posread+1]),y); 
writeln(ord(inpstr[posread]),' ',ord(inpstr[posread+1]) );

posread:=6;
if small_count then begin
                     count:=ord(inpstr[posread]);
                    end else
                    begin
                     bytes_2_word(ord(inpstr[posread]),ord(inpstr[posread+1]),count);
                    end;
writeln(ord(inpstr[posread]),' ',ord(inpstr[posread+1]) );
end;



function Pack_Repeat_Pixel(x_y,x,y,times:word):string;
var retres:string;
    b1,b2:byte;
begin
internal_stats[1]:=internal_stats[1]+1;
//1=PIXEL REPEATS , 2=RAW PIXELS , 3=NEIGHBOR PIXELS , 4 SAMEPIXELS , 5 SAMEPIXELS NEIGHBOR ,6 CLOSE COLORS
if x_y=1 then begin
               if times<=255 then retres:=chr(REPEAT_PIXEL_X_SMALL) else
                                  retres:=chr(REPEAT_PIXEL_X_CODE);
              end else
              begin
               if times<=255 then retres:=chr(REPEAT_PIXEL_Y_SMALL) else
                                  retres:=chr(REPEAT_PIXEL_Y);
              end;


word_2_bytes(x,b1,b2);
retres:=retres+chr(b1)+chr(b2); // X
word_2_bytes(y,b1,b2);
retres:=retres+chr(b1)+chr(b2); // Y

if times<=255 then begin
                    word_2_byte(times,b1);
                    retres:=retres+chr(b1); //Oikonomia 1 byte an einai poly mikro
                   end else
                   begin
                    word_2_bytes(times,b1,b2);
                    retres:=retres+chr(b1)+chr(b2);
                   end; 
Pack_Repeat_Pixel:=retres;
end;



//RAW PIXELS
function UnPack_Pixel(packedpixel:string; var x,y:word);
var guidebyte,xbyte,ybyte:byte; 
    i,helpx,helpy:integer; 
begin 
x:=0;
y:=0; 
if Length(packedpixel)<=0 then begin end;
if Length(packedpixel)>=1 then guidebyte:=ord(packedpixel[1]) else guidebyte:=0;
if Length(packedpixel)>=2 then xbyte:=ord(packedpixel[2]) else xbyte:=0;
if Length(packedpixel)>=3 then ybyte:=ord(packedpixel[3]) else ybyte:=0;


if guidebyte>=128 then writeln('Not Valid Pixel Guide');

byte_2_bits(guidebyte);
// X HELP
helpx:=0;
for i:=6 downto 3 do begin
                       helpx:=helpx+return_bit(i)*POW(2,i-3);
                     end; 
helpx:=128*helpx;
// Y HELP
helpy:=0;
for i:=2 downto 0 do begin
                       helpy:=helpy+return_bit(i)*POW(2,i);
                     end;
helpy:=128*helpy;

 

// X PIXEL
byte_2_bits(xbyte);
if return_bit(7)=1 then y:=0 else
                        y:=-1;
set_bit(7,0); //typebyte[7]:=0;
xbyte:=bits_2_byte;

// Y PIXEL
if y=0 then
begin
byte_2_bits(ybyte); 
set_bit(7,0); //typebyte[7]:=0;
ybyte:=bits_2_byte;
end else y:=0;

x:=xbyte+helpx;
y:=ybyte+helpy; 

end;


function Pack_Pixel_Raw(x,y:word):string;
var guidebyte,xbyte,ybyte:byte;
    thisbyte:array[0..7] of byte;
    helpx,helpy:integer;
    retres:string;
begin 
// GUIDE BYTE
thisbyte[7]:=0; // 0 gia pixels

// X HELP
helpx:=x div 128; 
x:=x-helpx*128;//x mod 128;
byte_2_bits(helpx);
thisbyte[6]:=return_bit(3);//typebyte[3];
thisbyte[5]:=return_bit(2);//typebyte[2];
thisbyte[4]:=return_bit(1);//typebyte[1];
thisbyte[3]:=return_bit(0);//typebyte[0];
//  Y HELP
helpy:=y div 128;
y:=y-helpy*128;//y mod 128;
byte_2_bits(helpy);
thisbyte[2]:=return_bit(2);//typebyte[2];
thisbyte[1]:=return_bit(1);//typebyte[1];
thisbyte[0]:=return_bit(0);//typebyte[0];
for guidebyte:=7 downto 0 do set_bit(thisbyte[guidebyte],guidebyte);//typebyte[guidebyte]:=thisbyte[guidebyte];
guidebyte:=bits_2_byte; 

// X PIXEL
byte_2_bits(x);
if y<>0 then set_bit(7,1);//typebyte[7]:=1;
xbyte:=bits_2_byte;

if y<>0 then
begin
// Y PIXEL
byte_2_bits(y);
set_bit(7,1); //typebyte[7]:=1;
ybyte:=bits_2_byte;
end;

retres:='';
retres:=retres+chr(guidebyte);
retres:=retres+chr(xbyte);
if y<>0 then retres:=retres+chr(ybyte);


Pack_Pixel_Raw:=retres;
end;

//SAME PIXEL GENIKA <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
function Pack_SameXPixel(x,y:word):string;
var retres:string;
begin  
retres:='';
retres:=retres+chr(SAME_X_PIXEL);
retres:=retres+word_2_string(y-guess_y);
Pack_SameXPixel:=retres;
end;

function UnPack_SameXPixel(packedpixel:string; var x,y:word);
var collect_dim:string;
label skip_unpack;
begin
if Length(packedpixel)<3 then goto skip_unpack;
if ord(packedpixel[1])<>SAME_X_PIXEL then goto skip_unpack;//REASONS TO SKIP
x:=guess_x;
collect_dim:='';
collect_dim:=collect_dim+packedpixel[2]+packedpixel[3];
y:=string_2_word(collect_dim)+guess_y;
skip_unpack:
end;


function Pack_SameYPixel(x,y:word):string;
var retres:string;
begin  
retres:='';
retres:=retres+chr(SAME_Y_PIXEL);
retres:=retres+word_2_string(x-guess_x);
Pack_SameYPixel:=retres;
end;

function UnPack_SameYPixel(packedpixel:string; var x,y:word);
var collect_dim:string;
label skip_unpack;
begin
if Length(packedpixel)<3 then goto skip_unpack;
if ord(packedpixel[1])<>SAME_Y_PIXEL then goto skip_unpack;//REASONS TO SKIP
y:=guess_y;
collect_dim:='';
collect_dim:=collect_dim+packedpixel[2]+packedpixel[3];
x:=string_2_word(collect_dim)+guess_x;
skip_unpack:
end;




//SAME PIXEL NEIGHBOOR..  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
function Pack_SameXPixel_Neighboor(x,y:word):string;
var retres:string;
begin  
retres:='';
retres:=retres+chr(SAME_X_PIXEL_NEIGHBOR);
retres:=retres+chr(y-guess_y);
Pack_SameXPixel_Neighboor:=retres;
end;

function UnPack_SameXPixel_Neighboor(packedpixel:string; var x,y:word);
label skip_unpack;
begin
if Length(packedpixel)<2 then goto skip_unpack;
if ord(packedpixel[1])<>SAME_X_PIXEL_NEIGHBOR then goto skip_unpack;//REASONS TO SKIP
x:=guess_x;
y:=ord(packedpixel[2])+guess_y;
skip_unpack:
end;

function Pack_SameYPixel_Neighboor(x,y:word):string;
var retres:string;
begin  
retres:='';
retres:=retres+chr(SAME_Y_PIXEL_NEIGHBOR);
retres:=retres+chr(X-guess_x);
Pack_SameYPixel_Neighboor:=retres;
end;

function UnPack_SameYPixel_Neighboor(packedpixel:string; var x,y:word);
label skip_unpack;
begin
if Length(packedpixel)<2 then goto skip_unpack;
if ord(packedpixel[1])<>SAME_Y_PIXEL_NEIGHBOR then goto skip_unpack;//REASONS TO SKIP
y:=guess_y;
x:=ord(packedpixel[2])+guess_x;
skip_unpack:
end;


//PIXEL GENERIC NEIGBORING..
function Pack_Neighboor_Pixel(x,y:word):string;
var retres:string;
begin  
retres:='';
retres:=retres+chr(x-guess_x);
retres:=retres+chr(y-guess_y);
Pack_Neighboor_Pixel:=retres; 
end;

function UnPack_Neighboor_Pixel(packedpixel:string; var x,y:word);
label skip_unpack;
begin
if Length(packedpixel)<3 then goto skip_unpack;
if ord(packedpixel[1])<>NEIGHBOR_PIXEL then goto skip_unpack;//REASONS TO SKIP
x:=guess_x+ord(packedpixel[2]);
y:=guess_y+ord(packedpixel[3]);
skip_unpack:
end;

function Pack_Close_Neighboor_Pixel(x,y:word):string;
var retres:string;
    thisbyte:array[0..7] of byte;
begin  
retres:='';
byte_2_bits(x-guess_x);
thisbyte[3]:=return_bit(3); 
thisbyte[2]:=return_bit(2); 
thisbyte[1]:=return_bit(1); 
thisbyte[0]:=return_bit(0); 
byte_2_bits(y-guess_y);
thisbyte[7]:=return_bit(3);
thisbyte[6]:=return_bit(2);
thisbyte[5]:=return_bit(1);
thisbyte[4]:=return_bit(0);
retres:=retres+chr(CLOSE_NEIGHBOR_PIXEL)+chr(bits_2_byte);
Pack_Close_Neighboor_Pixel:=retres;
end;

function UnPack_Close_Neighboor_Pixel(packedpixel:string; var x,y:word);
label skip_unpack;
begin
{if Length(packedpixel)<3 then goto skip_unpack;
if ord(packedpixel[1])<>NEIGHBOR_PIXEL then goto skip_unpack;//REASONS TO SKIP
x:=guess_x+ord(packedpixel[2]);
y:=guess_y+ord(packedpixel[3]);
skip_unpack:           }
end;


//PIXEL SELECTION
function Pack_Pixel(x,y:word):string;
var retres:string;
begin
retres:='';
if ((x=guess_x) and (y=guess_y)) then
                  begin
                   retres:=retres+chr(SINGLE_FILL);
                   internal_stats[7]:=internal_stats[7]+1; 
                  end else
if x=guess_x then begin // samexpixel_kati 
                   if abs(y-guess_y)<255 then
                      begin // samexpixel_neighbor
                        retres:=Pack_SameXPixel_Neighboor(x,y);
                        internal_stats[5]:=internal_stats[5]+1; 
                      end else
                      begin //samexpixel sketo
                        retres:=Pack_SameXPixel(x,y);
                        internal_stats[4]:=internal_stats[4]+1;
                      end;
                  end else
if y=guess_y then begin // samexpixel_kati
                   if abs(x-guess_x)<255 then
                      begin // sameypixel_neighbor
                         retres:=Pack_SameYPixel_Neighboor(x,y);
                         internal_stats[5]:=internal_stats[5]+1; 
                      end else
                      begin //sameypixel sketo
                         retres:=Pack_SameYPixel(x,y);
                         internal_stats[4]:=internal_stats[4]+1; 
                      end;
                  end else 
if ((abs(x-guess_x)<16)  and (abs(y-guess_y)<16)) then
  begin //PAIZEI CLOSE NEIGHBOORING..
   retres:=Pack_Close_Neighboor_Pixel(x,y);
   internal_stats[8]:=internal_stats[8]+1;
  end else
if ((abs(x-guess_x)<32)  and (abs(y-guess_y)<32)) then
  begin //PAIZEI DEMI NEIGHBOORING..
   retres:=Pack_Neighboor_Pixel(x,y);
   internal_stats[9]:=internal_stats[9]+1;
  end else
if ((abs(x-guess_x)<255)  and (abs(y-guess_y)<255)) then
  begin //PAIZEI GENIKO NEIGHBOORING..
   retres:=Pack_Neighboor_Pixel(x,y);
   internal_stats[3]:=internal_stats[3]+1; 
  end else
  begin
   retres:=Pack_Pixel_Raw(x,y);
   internal_stats[2]:=internal_stats[2]+1; 
  end;
guess_x:=x+1;
guess_y:=y;
Pack_Pixel:=retres;
end;






//COLORS
function Color_2C(R,G,B:byte):string;
begin
Color_2C:=chr(RGB_CODE)+chr(R)+chr(G)+chr(B);
end;

function C_2Color(inp:string; var R,G,B:byte);
begin
if (ord(inp[1])=RGB_CODE) and (Length(inp)=4) then
                                         begin
                                          R:=ord(inp[2]);
                                          G:=ord(inp[3]);
                                          B:=ord(inp[4]);
                                         end; 
end;

function PackColor(R,G,B:byte):string;
var retres:string;
begin
retres:='';
if ((abs(guess_color.RC-r)<=8) and (abs(guess_color.GC-g)<=8) and (abs(guess_color.BC-b)<=4)) then
    begin
    retres:=Color_2C(R,G,B);
    internal_stats[6]:=internal_stats[6]+1;
    //1=PIXEL REPEATS , 2=RAW PIXELS , 3=NEIGHBOR PIXELS , 4 SAMEPIXELS , 5 SAMEPIXELS NEIGHBOR ,6 CLOSE COLORS 
    end else
    retres:=Color_2C(R,G,B);
guess_color.RC:=R;
guess_color.GC:=G;
guess_color.BC:=B;
PackColor:=retres;
end;




procedure TEST_PIXEL_PACK;
var x,y,x1,y1,x2,y2:word;
    aword,bword,cword:word;
    abyte,bbyte,cbyte,dbyte:byte;
    a1byte,b1byte,c1byte:byte;
    tmpbool:boolean;
    tmpstr:string;
    fileused:text;
begin 
assign(fileused,'debug.txt');
rewrite(fileused);

writeln (' Start Power Test');
for x:=0 to 7 do
    begin
     aword:=POW(2,x);
     bword:=POW_BIG(2,x);
     if aword<>bword then writeln(aword,' Power Error ',bword);
    end; 
 
writeln ('Start Byte-Words Test');
for abyte:=0 to 255 do begin
  for bbyte:=0 to 255 do begin
                          bytes_2_word(abyte,bbyte,aword);
                          word_2_bytes(aword,cbyte,dbyte);
                          if ((abyte<>cbyte)or(dbyte<>bbyte)) then writeln (abyte,',',bbyte,'  Error !! ',cbyte,',',dbyte);
                         end;
                       end;
 
writeln (' Start Words-Byte Test');
for aword:=0 to 65534 do
    begin 
     word_2_bytes(aword,abyte,bbyte);
     bytes_2_word(abyte,bbyte,bword);
     if aword<>bword then writeln(aword,' Binary-Words Error ',bword);
    end;

writeln ('Start Repeat Test');
aword:=0; bword:=0; cword:=0;
for x:=0 to 512 do
 for y:=0 to 512 do
      begin
       tmpstr:=Pack_Repeat_Pixel(0,x,y,123);
       writeln('?',aword,',',bword,',',cword);
       //UnPack_Repeat_Pixel(tmpstr,abyte,aword,bword,cword,cword);
       writeln('/',aword,',',bword,',',cword);
       if ((aword<>x)or(bword<>y)or(cword<>123)) then writeln (x,',',y,',',123,' REPEAT ERROR ',aword,',',bword,',',cword); 
      end;
                
writeln (' Start Binary Test');
for x:=0 to 255 do
    begin
     byte_2_bits(x);
     x1:=bits_2_byte;
     if x<>x1 then writeln(x,' Binary Error ',x1);
    end; 



writeln (' Start Binary-Words Test');
for aword:=0 to 65534 do
    begin 
     word_2_bits(aword); 
     bword:=bits_2_word; 
     if aword<>bword then writeln(aword,' Binary-Words Error ',bword);
    end; 

writeln (' Start Pack Test');
writeln('Check debug.txt - Please Wait');
for x:=1 to 2048 do
    begin
 for y:=1 to 1024 do
        begin 
         tmpstr:=Pack_Pixel(x,y);
         //writeln (' ( ',x,',',y,' ) = ',tmpstr);
         UnPack_Pixel(tmpstr,x1,y1);
         if x1<>x then begin
                        //writeln (x,' Error X ',x1);
                        writeln (fileused,x,' Error X ',x1,' help was ',x2,' pixel ',x1-x2);
                       end;
         if y1<>y then begin
                        //writeln (y,' Error Y ',y1);
                        writeln (fileused,y,' Error Y ',y1,' help was ',y2,' pixel ',y1-y2);
                       end;

        end;
    end;
close(fileused);


for abyte:=0 to 255 do begin
  for bbyte:=0 to 255 do begin
    for cbyte:=0 to 255 do begin
                            C_2Color(Color_2C(abyte,bbyte,cbyte),a1byte,b1byte,c1byte);
                            if ((abyte<>a1byte)or(bbyte<>b1byte)or(cbyte<>c1byte)) then writeln (abyte,',',bbyte,',',cbyte,'  Error !! ');
                           end;
                          end;
                       end;




writeln('Done.'); 
end;




function is_aps3(apsname:string):boolean; 
var f:file; 
    header1:TAPS3Header;
begin
assign(f,apsname);
reset(f,1);
blockread(f,header1,sizeof(header1));
close(f);
if ((header1.idbyte1=ord('a')) and (header1.idbyte2=ord('p')) and (header1.idbyte3=HANDLES_APS))  then is_aps3:=true else
                                                                                                       is_aps3:=false;
end;





begin
for guess_x:=1 to 10 do internal_stats[guess_x]:=0;
guess_x:=0;
end.
