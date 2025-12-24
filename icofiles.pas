unit icofiles;
interface
uses ammarunit;

function GetIcoX:integer;
procedure SetIcoX(val:integer);
function GetIcoY:integer;
procedure SetIcoY(val:integer);
function GetIcoPixelColor(curx,cury:integer):integer;
procedure SetIcoPixelColor(curx,cury,color2change:integer);
procedure SaveCoreIco(filename:string);
procedure LoadCoreIco(iconame:string);

implementation
Type
 TIcoFileHeader=
  Record            //6 bytes
   iReserved:       Word; // 0
   iType:           Word; //icon = 1, cursors = 2.
   iCount:          Word;
  End;

 TIcoListHeader=
  Record            //16 bytes
   iWidth:          Byte; //Cursor Width (16, 32 or 64
   iHeight:         Byte; //Cursor Height (16, 32 or 64 , most commonly = Width)
   iColorCount:     Byte; //Number of Colors (2,16, 0=256
   iReserved:       Byte; //=0
   iPlanes:         Word; //=1
   iBitCount:       Word; //	bits per pixel (1, 4, 8)
   iSizeInBytes:    LongInt; //Size of (InfoHeader + ANDbitmap + XORbitmap)
   iFileOffset:     LongInt; //FilePos, where InfoHeader starts
  End;
   

 TIcoMapHeader =
  Record                //40 bytes
   ifSize :             LongInt; //Size of InfoHeader structure = 40
   ifWidth :            LongInt; //Icon Width
   ifHeight :           LongInt; //Icon Height (added height of XOR-Bitmap and AND-Bitmap)
   ifPlanes :           Word;    //number of planes = 1
   ifBitCount :         Word; //bits per pixel = 1, 4, 8
   ifCompression :      LongInt; //Type of Compression = 0
   ifImageSize :        LongInt; //Size of Image in Bytes = 0 (uncompressed)
   ifXpixelsPerM  :     LongInt; //unused = 0
   ifYpixelsPerM :      LongInt; //unused = 0
   ColorsUsed  :        LongInt; //unused = 0
   ColorsImportant :    LongInt; //unused = 0
  End;

 TIcoRGBQ =
  Record
   Bcolor,Gcolor,Rcolor,reserved:byte;
  End;
 
 TIcoRGB =
  Record
   Bcolor,Gcolor,Rcolor:byte;
  End;

const maxxicopaper=256;
      maxyicopaper=256;

var icotmppaper:array[1..maxxicopaper,1..maxyicopaper] of integer;
    IcoFileHeader:TIcoFileHeader;
    IcoList:TIcoListHeader;
    IcoMapHeader:TIcoMapHeader;
    ok2load:boolean;
    tmp_byte:byte;
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

procedure ReverseBits(bits2reverse:integer);
var i,buf:integer;
begin
for i:=0 to bits2reverse-1 do
  begin
   buf:=typebyte[i];
   typebyte[i]:=typebyte[bits2reverse-1-i];
   typebyte[bits2reverse-1-i]:=buf;
  end;
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

function BitsToFillByte(thebyte:integer):integer;
var i:integer;
begin
i:=8-(thebyte mod 8);
if i=8 then i:=0;
BitsToFillByte:=i;
end;

function Byte2mod4(thebyte:integer):integer;
var i:integer;
begin
i:=4-(thebyte mod 4);
if i=4 then i:=0;
Byte2mod4:=i;
end;

procedure ErrorIco(description:string);
begin
MakeMessageBox('Ico Files',description,'OK','!','APPLICATION');
ok2load:=false;
end;

function GetIcoX:integer;
begin
GetIcoX:=IcoList.iWidth;
end;

procedure SetIcoX(val:integer);
begin
IcoList.iWidth:=val;
end;

function GetIcoY:integer;
begin
GetIcoY:=IcoList.iHeight;
end;

procedure SetIcoY(val:integer);
begin
IcoList.iHeight:=val;
end;

function  GetIcoPixelColor(curx,cury:integer):integer;
begin
GetIcoPixelColor:=icotmppaper[curx,cury];
end;

procedure SetIcoPixelColor(curx,cury,color2change:integer);
begin
icotmppaper[curx,cury]:=color2change;
end;


procedure SaveCoreIco(filename:string);
var f:File;
    pix32 :TIcoRGB;
    aref:byte;
    i,x,y,correction,transcorrection:integer;
begin
assign(f,filename);
{$i-}
rewrite(f,1);
{$i+} if Ioresult<>0 then ErrorIco('Could not save ico file '+filename) else
  begin
    //CORRECTION
    correction:=IcoList.iWidth*IcoMapHeader.ifBitCount;
    correction:=correction+BitsToFillByte(correction);
    correction:=correction div 8;
    correction:=Byte2mod4(correction);
    //TRANSPARENT CORRECTION 
    transcorrection:=IcoList.iWidth div 8;
    if IcoList.iWidth mod 8<>0 then transcorrection:=transcorrection+1;
    transcorrection:=transcorrection div 8;
    transcorrection:=Byte2mod4(transcorrection);
    MakeMessageBox('Ico Files',Convert2String(transcorrection),'OK','!','APPLICATION'); 


    IcoFileHeader.iReserved:=0;  
    IcoFileHeader.iType:=1;     
    IcoFileHeader.iCount:=1;
    BlockWrite(f,IcoFileHeader,6);

    //IcoList.iWidth:
    //IcoList.iHeight:
    IcoList.iColorCount:=0;
    IcoList.iReserved:=0; 
    IcoList.iPlanes:=1; 
    IcoList.iBitCount:=24;
    IcoList.iSizeInBytes:=40+IcoList.iWidth*IcoList.iHeight*3+correction*IcoList.iHeight+((IcoList.iWidth div 8)+transcorrection)*(IcoList.iHeight );
    IcoList.iFileOffset:=6+16;
    BlockWrite(f,IcoList,16);

    IcoMapHeader.ifSize:=40;
    IcoMapHeader.ifWidth:=IcoList.iWidth; 
    IcoMapHeader.ifHeight:=IcoList.iHeight * 2;
    IcoMapHeader.ifPlanes:=1;
    IcoMapHeader.ifBitCount:=24;
    IcoMapHeader.ifCompression:=0;      
    IcoMapHeader.ifImageSize:=IcoList.iSizeInBytes-40;
    IcoMapHeader.ifXpixelsPerM:=0;     
    IcoMapHeader.ifYpixelsPerM:=0;     
    IcoMapHeader.ColorsUsed:=0;     
    IcoMapHeader.ColorsImportant:=0;  
    BlockWrite(f,IcoMapHeader,40);
    aref:=0;
            // OR MAP
     y:=IcoList.iHeight;
         while y>=1 do
             begin
               x:=1;
               while x<=IcoList.iWidth  do 
                 begin
                  pix32.Rcolor:=ConvertR(icotmppaper[x,y]);
                  pix32.Gcolor:=ConvertG(icotmppaper[x,y]);
                  pix32.Bcolor:=ConvertB(icotmppaper[x,y]); 
                  BlockWrite(f,pix32,3);
                  x:=x+1;
                 end;

                if correction>0 then
                begin
                  for i:=1 to correction do begin
                                             BlockWrite(f,aref,1);
                                            end;
                end;
              y:=y-1;
             end; 

             // AND MAP
      aref:=0; 
      for y:=IcoList.iHeight downto 1 do
        begin 
         i:=IcoList.iWidth div 8;
         if IcoList.iWidth mod 8<>0 then i:=i+1;
         for x:=1 to i do BlockWrite(f,aref,1);
         if transcorrection>0 then
          begin 
           for x:=1 to transcorrection do BlockWrite(f,aref,1);
          end;
        end;
   close(f);
  end;

end;


procedure LoadCoreIco(iconame:string);
var f:File;
    aref:byte; 
    x,y,correction,i:integer;
    pix32 :TIcoRGB;
    palette:array [0..256] of TIcoRGBQ;
    bufbyte:array[0..15] of byte;
    usedpalette:integer;
    label term_load;
begin
ok2load:=true;
assign(f,iconame);
{$i-}
reset(f,1);
{$i+} if Ioresult<>0 then ErrorIco('Could not open ico file '+iconame) else
begin
BlockRead(f,IcoFileHeader,SizeOf(IcoFileHeader));
BlockRead(f,IcoList,SizeOf(IcoList));
BlockRead(f,IcoMapHeader,SizeOf(IcoMapHeader));
if IcoMapHeader.ifBitCount=1 then usedpalette:=2 else
if IcoMapHeader.ifBitCount=4 then usedpalette:=16 else
if IcoMapHeader.ifBitCount=8 then usedpalette:=256 else
                                  usedpalette:=0;

{GotoXY(0,300);
OuttextCenter(Convert2String(IcoList.iWidth)+'x'+Convert2String(IcoList.iHeight));

OuttextCenter('iSizeInBytes Count '+Convert2String(IcoList.iSizeInBytes));
OuttextCenter('iFileOffset Count '+Convert2String(IcoList.iFileOffset)); 

OuttextCenter('Color Count '+Convert2String(IcoList.iColorCount));
OuttextCenter('Bit Count '+Convert2String(IcoList.iBitCount));
OuttextCenter('Palette '+Convert2String(usedpalette));
OuttextCenter('ifBitCount '+Convert2String(IcoMapHeader.ifBitCount));
OuttextCenter('ifCompression '+Convert2String(IcoMapHeader.ifCompression));
OuttextCenter('ifImageSize '+Convert2String(IcoMapHeader.ifImageSize));
OuttextCenter('ifXpixelsPerM '+Convert2String(IcoMapHeader.ifXpixelsPerM));
OuttextCenter('ifYpixelsPerM '+Convert2String(IcoMapHeader.ifYpixelsPerM));
OuttextCenter('ColorsUsed '+Convert2String(IcoMapHeader.ColorsUsed));
OuttextCenter('ColorsImportant '+Convert2String(IcoMapHeader.ColorsImportant));       
OuttextCenter('ifWidth '+Convert2String(IcoMapHeader.ifWidth));
OuttextCenter('ifHeight '+Convert2String(IcoMapHeader.ifHeight));     }

correction:=IcoList.iWidth*IcoMapHeader.ifBitCount;
//OuttextCenter('Real Bits '+Convert2String(correction));
correction:=correction+BitsToFillByte(correction);
//OuttextCenter('Full Bits '+Convert2String(correction));
correction:=correction div 8;
//OuttextCenter('Full Bytes '+Convert2String(correction));
correction:=Byte2mod4(correction);
//OuttextCenter('Correction Bytes '+Convert2String(correction));


if usedpalette>0 then
 begin
  for i:=1 to usedpalette do
   begin
    BlockRead(f,palette[i-1],SizeOf(TIcoRGBQ));
   end;
 end; //READ PALETTE 

y:=IcoList.iHeight;
while y>=1 do
 begin
 x:=1;
 while x<=IcoList.iWidth  do
   begin 
    if usedpalette>0 then
        begin
         if eof(f) then goto term_load;
         BlockRead(f,aref,1); 
         if usedpalette=2 then begin  // 2 colors
                                  byte_2_bits(aref); 
                                  i:=0;
                                  while ((i<=7) and (x+1<=IcoList.iWidth)) do
                                       begin
                                        x:=x+1;
                                        icotmppaper[x,y]:=ConvertRGB(palette[typebyte[i]].Rcolor,palette[typebyte[i]].Gcolor,palette[typebyte[i]].Bcolor); 
                                        i:=i+1;
                                       end; 
                                end  else
         if usedpalette=16 then begin //16 colors
                                  byte_2_bits(aref);
                                  for i:=0 to 15 do bufbyte[i]:=typebyte[i];
                                  for i:=4 to 15 do typebyte[i]:=0;
                                  //ReverseBits(4);
                                  tmp_byte:=bits_2_byte;
                                  icotmppaper[x,y]:=ConvertRGB(palette[tmp_byte].Rcolor,palette[tmp_byte].Gcolor,palette[tmp_byte].Bcolor);
                                   

                                  for i:=0 to 3 do typebyte[i]:=bufbyte[i+4];
                                  //ReverseBits(4);
                                  tmp_byte:=bits_2_byte;
                                  x:=x+1;
                                  icotmppaper[x,y]:=ConvertRGB(palette[tmp_byte].Rcolor,palette[tmp_byte].Gcolor,palette[tmp_byte].Bcolor);
                                 
                                end  else  // 256 colors
         icotmppaper[x,y]:=ConvertRGB(palette[aref].Rcolor,palette[aref].Gcolor,palette[aref].Bcolor); 
        end else 
    if ((IcoMapHeader.ifBitCount=24) or (IcoMapHeader.ifBitCount=32)) then
        begin   // True Color
         BlockRead(f,pix32,3);
         icotmppaper[x,y]:=ConvertRGB(pix32.Rcolor,pix32.Gcolor,pix32.Bcolor);
        end;
    //putpixel(x,y,icotmppaper[x,y]);
    x:=x+1;
   end; 

   if correction>0 then
    begin
     for i:=1 to correction do begin
                                 BlockRead(f,aref,1);
                               end;
    end;
   y:=y-1;
 end;
 term_load: 
close(f);
end;
end;

//begin
end.
