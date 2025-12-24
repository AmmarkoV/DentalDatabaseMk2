unit bmpfiles;
interface
uses ammarunit;
                                 
function BMP_Error_Occured:boolean;
function GetBmpX:integer;
function GetBmpY:integer;
procedure SetBMPSizeXY(thex,they:integer);
function GetBmpPixelColor(curx,cury:integer):integer;
procedure SetBmpPixelColor(curx,cury,color2change:integer);
procedure LoadCoreBmp(bmpname:string);
procedure SaveCoreBmp(bmpname:string);

implementation
Type
 TBitMapHeader =
  Record
   bfType :             Word;
   bfSize :             LongInt;
   bfReserved :         LongInt;   
   bfOffBits :          LongInt;
   biSize :             LongInt;
   biWidth :            LongInt;
   biHeight :           LongInt;
   biPlanes :           Word;    
   biBitCount :         Word;    
   biCompression :      LongInt;
   biSizeImage :        LongInt;    
   biXPelsPerMeter :    LongInt;
   biYPelsPerMeter :    LongInt;
   biClrUsed :          LongInt;
   biClrImportant :     LongInt;
  End;

 TBitMapRGB =
  Record
   Bcolor,Gcolor,Rcolor:byte;
  End;

const maxxbmppaper=2048;
      maxybmppaper=1200;
var bmptmppaper:array[0..maxxbmppaper,0..maxybmppaper] of integer;
    BitMapHeader:TBitMapHeader;
    sz_x,sz_y:integer;
    ok2load:boolean;



function BMP_Error_Occured:boolean;
begin
BMP_Error_Occured:=not ok2load;
end;

procedure SetBMPSizeXY(thex,they:integer);
begin
sz_x:=thex;
sz_y:=they;
end;

procedure ErrorBMP(description:string);
begin
MakeMessageBox('Bmp Files',description,'OK','!','APPLICATION');
ok2load:=false;
end;

function GetBmpX:integer;
begin
GetBmpX:=BitMapHeader.biWidth;
end;

function GetBmpY:integer;
begin
GetBmpY:=BitMapHeader.biHeight;
end;

function  GetBmpPixelColor(curx,cury:integer):integer;
begin
GetBmpPixelColor:=bmptmppaper[curx,cury];
end;

procedure SetBmpPixelColor(curx,cury,color2change:integer);
begin
bmptmppaper[curx,cury]:=color2change;
end;

procedure LoadCoreBmp(bmpname:string);
var f:File;
    manr{,mang,manb}:byte;
    rgbtriplet:TBitMapRGB;
    x,y,correction,i:integer;
begin
ok2load:=true;
assign(f,bmpname);
{$i-}
reset(f,1);
{$i+} if Ioresult<>0 then ErrorBMP('Could not open bmp file '+bmpname) else
begin
BlockRead(f,BitMapHeader,SizeOf(BitMapHeader));


if (BitMapHeader.biWidth>maxxbmppaper) or (BitMapHeader.biHeight>maxybmppaper) then ErrorBMP('This BMP file is very large ('+Convert2String(BitMapHeader.biWidth)+'x'+Convert2String(BitMapHeader.biHeight)+')');
 
if BitMapHeader.biCompression<>0 then ErrorBMP('Cannot load compressed bmp files !');
if BitMapHeader.biBitCount=1 then ErrorBMP('Cannot load 1 bit bmp files !') else
if BitMapHeader.biBitCount=4 then ErrorBMP('Cannot load 4 bit bmp files !') else
if BitMapHeader.biBitCount=8 then ErrorBMP('Cannot load 8 bit bmp files !');
if (BitMapHeader.biBitCount=24) and (ok2load=true)then
                                   begin 
                                    if (BitMapHeader.biWidth)*3  mod 4=0 then correction:=0 else
                                                                              correction:=4-(BitMapHeader.biWidth)*3  mod 4;
                                    for y:=BitMapHeader.biHeight downto 1 do begin
                                     for x:=1 to BitMapHeader.biWidth do begin  
                                                                          BlockRead(f,rgbtriplet,3);
                                                                          bmptmppaper[x,y]:=ConvertRGB(rgbtriplet.Rcolor,rgbtriplet.Gcolor,rgbtriplet.Bcolor); 
                                                                         end;
                                                                              if correction<>0 then
                                                                              for i:=1 to correction do BlockRead(f,manr,SizeOf(manr));
                                                                             end;

                                   end;  

close(f);
end;
end;




procedure SaveCoreBmp(bmpname:string);
var f:File;
    manr{,mang,manb}:byte;
    rgbtriplet:TBitMapRGB;
    x,y,correction,i:integer;
begin
ok2load:=true;
assign(f,bmpname);
{$i-}
rewrite(f,1);
{$i+} if Ioresult<>0 then ErrorBMP('Could not open bmp file '+bmpname) else
begin

BitMapHeader.biCompression:=0;
BitMapHeader.biBitCount:=24;
BitMapHeader.biWidth:=sz_x; //maxxbmppaper
BitMapHeader.biHeight:=sz_y; //maxybmppaper
BlockWrite(f,BitMapHeader,SizeOf(BitMapHeader));

 
                                   begin 
                                    if (BitMapHeader.biWidth)*3  mod 4=0 then correction:=0 else
                                                                              correction:=4-(BitMapHeader.biWidth)*3  mod 4;
                                    for y:=BitMapHeader.biHeight downto 1 do begin
                                     for x:=1 to BitMapHeader.biWidth do begin  
                                                                          rgbtriplet.Rcolor:=ConvertR(bmptmppaper[x,y]);
                                                                          rgbtriplet.Gcolor:=ConvertG(bmptmppaper[x,y]);
                                                                          rgbtriplet.Bcolor:=ConvertB(bmptmppaper[x,y]); 
                                                                          BlockWrite(f,rgbtriplet,3);
                                                                         end;
                                                                              if correction<>0 then
                                                                              for i:=1 to correction do BlockWrite(f,manr,SizeOf(manr));
                                                                             end;

                                   end;  

close(f);
end;
end;


//begin
end.
