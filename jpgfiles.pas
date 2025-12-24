unit jpgfiles;

interface
uses windows,ammarunit;
procedure DrawJpegCore(AFileName:LPSTR; x,y:integer);
procedure GetJpegFileXY(TheFileName:string);
function  GetJpgX:integer;
function  GetJpgY:integer;
function  GetJpgPixelColor(curx,cury:integer):integer;  
procedure SetJpgPixelColor(curx,cury,color2change:integer);
procedure LoadJpeg1(AFileName:LPSTR);
function  LoadJpeg2(AFileName:LPSTR):HBITMAP;

implementation 
const maxxjpgpaper=2024;
      maxyjpgpaper=1024;
var //jpgpaper:array[1..maxxjpgpaper,1..maxyjpgpaper]of integer;
    jpgx,jpgy:integer; 

function SwapByte(actualbyte:byte):byte;    //LATHOS!
var i,pwr:integer;
    inpbyt,resbyt:byte;
begin
inpbyt:=actualbyte;
resbyt:=0;
for i:=7 downto 0 do begin
                      pwr:=Power(2,i);
                      if inpbyt div pwr=1 then resbyt:=resbyt+(Power(2,7-i));
                      inpbyt:=inpbyt-pwr;
                     end;
SwapByte:=resbyt;
end;

procedure GetJpegFileXY(TheFileName:string); 

var f:file; 
    ID1,ID2,ID3,ID4,tmp:byte;
    height,width:word;
    tmpstring:string;
    swaptoggle:boolean;
    label certain;
begin 
assign(f,TheFileName);
reset(f,1);   
//outtextcenter('CALL GetJpegFileXY '+Convert2String(Filepos(f))+'/'+Convert2String(Filesize(f)));

if Filesize(f)<10 then begin
                        height:=0;
                        width:=0;
                        goto certain;
                       end;
blockread(f,ID1,1);
blockread(f,ID2,1);
blockread(f,ID3,1);
blockread(f,ID4,1);
tmpstring:=Convert2String(ID1)+','+Convert2String(ID2)+','+Convert2String(ID3)+','+Convert2String(ID4);
//MessageBox (0, Pchar(tmpstring), '  ', 0);
blockread(f,ID1,1);
blockread(f,ID2,1);
tmpstring:=Convert2String(ID1)+','+Convert2String(ID2);
//MessageBox (0, Pchar(tmpstring), '  ', 0);

blockread(f,ID1,1);
blockread(f,ID2,1);
blockread(f,ID3,1);
blockread(f,ID4,1);
swaptoggle:=false;
swaptoggle:=true;
//MessageBox (0, Pchar(Convert2String(ID1)+','+Convert2String(ID2)+','+Convert2String(ID3)+','+Convert2String(ID4)), '  ', 0);
if (ID1=70) and (ID2=73) and (ID3=70) and (ID4=74) then swaptoggle:=false else
if (ID1=74) and (ID2=70) and (ID3=73) and (ID4=70) then swaptoggle:=true;

while Filepos(f)<Filesize(f) do begin 
 blockread(f,ID1,1); 
 blockread(f,ID2,1); 

 if ((ID1=255) and (ID2=192))then
		begin
         //  outtextcenter('FOUND SOF @ '+Convert2String(Filepos(f)));
         //  outtextcenter(' SIZEOF(HEIGHT)='+Convert2String(height));
          blockread(f,tmp,1); 
          blockread(f,tmp,1);  
          blockread(f,tmp,1); 
          blockread(f,ID1,1);
          blockread(f,ID2,1); 

          height:=ID1+ID2*256;
          blockread(f,ID1,1); 
          blockread(f,ID2,1); 

          width:=ID1+ID2*256;
          //blockread(f,height,2);
          //blockread(f,width,2);
          //blockread(f,ID1,1);
          //blockread(f,ID2,1);
          //MessageBox (0, Pchar(Convert2String(SwapByte(ID1))+','+Convert2String(SwapByte(ID2))), '  ', 0);
          //MessageBox (0, Pchar(Convert2String(height)+','+Convert2String(width)+' // '+Convert2String(swap(height))+','+Convert2String(swap(width))), '  ', 0);
          break;
          goto certain;
        end; 
                                end;

certain: 

if swaptoggle then jpgx:=Swap(width) else jpgx:=width;
if swaptoggle then jpgy:=Swap(height) else jpgy:=height;
close(f); 
end;

Function LoadJPEG (AFileName:LPSTR):HBITMAP;external 'JpegLib.dll' name 'LoadJPEG';

procedure DrawJpegCore(AFileName:LPSTR; x,y:integer);
var    hdcCompatible:hdc;
       hbmScreen:HBITMAP;
       retainobj:hgdiobj;
      // dll2load:HANDLE;
     //  reserva:HANDLE;
begin 
hdcCompatible:=CreateCompatibleDC(GraphDcUsed);
//dll2load:=LoadLibraryEX('JpegLib.dll',reserva,0);

hbmScreen:=LoadJPEG(AFileName);
retainobj:=SelectObject(hdcCompatible,hbmScreen); 
BitBlt(GraphDcUsed,x,y,x+jpgx,y+jpgy,hdcCompatible,0,0,SRCCOPY);
SelectObject(hdcCompatible,retainobj);
DeleteObject(hbmScreen);
DeleteDC(hdcCompatible);
//FreeLibrary(dll2load);
end;

function GetJpgX:integer;
begin
GetJpgX:=jpgx;
end;

function GetJpgY:integer;
begin
GetJpgY:=jpgy;
end;

function  GetJpgPixelColor(curx,cury:integer):integer;
begin
//GetJpgPixelColor:=jpgpaper[curx,cury];
end;


procedure SetJpgPixelColor(curx,cury,color2change:integer);
begin
//jpgpaper[curx,cury]:=color2change;
end;

{procedure LoadJpeg1(AFileName:LPSTR);
var    hdcCompatible:hdc;
       hbmScreen:HBITMAP;
       retainobj:hgdiobj;  
       x,y:integer;  
begin
//GetJpegFileXY(String(AFileName));
hdcCompatible:=CreateCompatibleDC(0);
hbmScreen:=LoadJPEG(AFileName); 
retainobj:=SelectObject(hdcCompatible,hbmScreen);   
if (jpgx<=0) or (jpgx>=maxxjpgpaper) then jpgx:=maxxjpgpaper div 2;
if (jpgy<=0) or (jpgy>=maxyjpgpaper) then jpgy:=maxyjpgpaper div 2; 
for x:=1 to jpgx do
for y:=1 to jpgy do begin
                         jpgpaper[x,y]:=GetPixel(hdcCompatible,x,y);
                        // putpixel(x,y,jpgpaper[x,y])
                        end; 
readkey;
SelectObject(hdcCompatible,retainobj); 
DeleteObject(hbmScreen); 
DeleteDC(hdcCompatible);  
end;       }

procedure LoadJpeg1(AFileName:LPSTR);
var    hdcCompatible:hdc;
       hbmScreen:HBITMAP;
       retainobj:hgdiobj;  
       x,y:integer;
begin
hdcCompatible:=CreateCompatibleDC(GraphDcUsed);
hbmScreen:=LoadJPEG(AFileName);
retainobj:=SelectObject(hdcCompatible,hbmScreen);
//BitBlt(hdcCompatible,x,y,x+jpgx,y+jpgy,hdcCompatible,0,0,SRCCOPY);
for x:=1 to jpgx do
for y:=1 to jpgy do begin
                         //jpgpaper[x,y]:=GetPixel(hdcCompatible,x,y);
                        // putpixel(x,y,jpgpaper[x,y])
                        end;
SelectObject(hdcCompatible,retainobj);
DeleteObject(hbmScreen);
DeleteDC(hdcCompatible);
end;    

function LoadJpeg2(AFileName:LPSTR):HBITMAP;
begin 
LoadJpeg2:=LoadJPEG(AFileName); 
end;    

//begin
{jpgx:=GetMaxX;
jpgy:=GetMaxY;}
end.
