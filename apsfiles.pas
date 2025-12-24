{$INFO APSFILES}
unit apsfiles;
interface
uses windows,ammarunit,bmpfiles,jpgfiles,icofiles,legacy_aps;

function  ApsUnitVersion:string;
//procedure APS_out_stats; 
procedure APS_SAFE_MODE;

function aps_get_internal_options(theopt:integer):integer;
procedure aps_set_internal_options(theopt,theval:integer);

function Retrieve_Aps_ID(nameu:string):integer;

procedure OutputFileTxt(apsname,filename,arrayname:string; backgroundcolor,language:integer);
procedure DrawJpeg(AFileName:String; syntx,synty:integer);
procedure DrawJpegTiled(AFileName:String);
procedure DrawJpegCentered(AFileName:String);
function Load_Bitmap_Windows(name:string):boolean;
procedure ReOptimiseAps(name:string);
procedure LoadAps (bufstr3:string);
procedure LoadJpg (bufstr3:string); 
procedure LoadBmp (bufstr3:string);
procedure LoadIco (bufstr3:string);
function SaveAPSRaw (thename,thefile:string):boolean;
function LoadAPSRaw (thename,thefile:string):boolean;
procedure LoadPicture (bufstr3:string);
procedure PassHbitmap2Paper(thebitmap:HBITMAP; x2,y2:integer);
function CreateNonTransparencyRGN(apsname:string; full_rgn:HRgn; screen_x,screen_y:integer):Hrgn;
procedure QuickCopyDc2Paper(thebitmap:HBITMAP; x2,y2:integer);
procedure PasteClipboardAPS(aname:string);
function  ReturnApsName(bufstr3:string):string;
function  RetrieveMemory(bufx,bufy:integer):integer;
procedure SetLoadingXY (bufx,bufy:integer);
function  GetLoadingX:integer;
function  GetLoadingY:integer;
procedure UnloadAps (name:string);
procedure FlushApsMemory;
procedure MoveApsFromToXY(name2:string; x31,y31,x51,y51:integer);
procedure Multiple_APS_init;
function  Multiple_APS_DC:hdc;
procedure Multiple_APS_DrawXY(name:string; x3,y3:integer);
procedure Multiple_APS_close;
procedure DrawAps(name:string);
procedure DrawApsCentered(name:string);
procedure DrawApsCentered2(name:string);
procedure DrawApsXY_i(name,x3,y3:integer);
procedure DrawApsXY(name:string; x3,y3:integer);
procedure DrawApsXY2(name:string; x3,y3:integer);
procedure DrawApsTiled(name:string);
procedure DrawApsTiled2(name:string);
procedure UndrawApsXY(name:string; x3,y3,color:integer);
procedure DrawMove(name:string; x3,y3,x5,y5:integer);
function GetApsPixel(name:string; curx,cury:integer):integer; {colorref}
function  GetApsPixelColor(curx,cury:integer):integer;{colorref}
procedure SetApsPixelColor(curx,cury,color2change:integer);
function  GetApsInfo(name:string; infonum:string):integer;
function  GetApsInfo_i(name,infonum:integer):integer;
procedure DefineAps(name:string; x11,y11,x22,y22:integer);
procedure DuplicateAps(name2,newname:string;x111,y111:integer);
procedure SetTransparentColor(color2change:integer);
function  GetTransparentColor:integer;
procedure DisableTransparency;

function GetInternalOptions(param:integer):integer;

procedure DrawAPSAnimationXY(theanim:string; x,y,speed,frames:integer);
function DrawAPSAnimationXYFrame(theanim:string; x,y,speed,frame,frames:integer):integer;

//Picture Effects
procedure SetBrightness(apsname,color:string; amount:real); 
procedure ChangeApsColor(apsname:string; color1,color2:integer);
procedure InvertAps(apsname,way:string);
function Calc_Tile_Color(tx1,ty1,tx2,ty2:integer):integer;
procedure filter_resize(apsname:string; newx,newy:integer);
procedure set_rotate_quality_APS(thequal:integer);
procedure filter_rotate(apsname:string; start_x,start_y,rotation:integer);
procedure filter_merge(apsname1,apsname2,apsoutput:string; change,detail:integer);
procedure filter_noise(output:string; density:integer);
procedure filter_oldmonitor(output:string; pixelsize:integer);
procedure filter_blur (output:string; stperc:integer);
procedure filter_dissasemble (output:string; xonscreen,yonscreen,speed:integer);
procedure filter_channel(output:string; channel_select:byte);
function compare_2_aps(input1,input2:string; threshold:integer):byte;
procedure filter_edges(output:string; sensitivity:integer); 

implementation
const version='0.752';
      apsmaxpaperx=2348;
      apsmaxpapery=1424;
      max_aps_loaded=256;

Type
 Aps_Info =
  Record 
   name:string;
   x1:integer;
   y1:integer;
   x2:integer;
   y2:integer;
  End;

var i,x,y,x1,y1,x2,y2,loadingx,loadingy:integer;
    transparent:integer;{colorref}
    enabletransp:boolean; 
    {1-x , 2-y , 3-background , 4-different colors,5=memory number(1>),6,7(xy in memory),8y}
    options:array[1..8] of integer;
    paper:array[1..apsmaxpaperx,1..apsmaxpapery] of integer;
   // Picturesloaded:array[1..2,1..max_aps_loaded] of string;
    Picturesloaded:array[1..max_aps_loaded] of Aps_Info;
    //NEW AS OF 14/04/07   DRAW OPTIMISATIONS
    bitmaps_ready:array[1..max_aps_loaded] of hbitmap;
    bitmaps_created:array[1..max_aps_loaded] of byte; 
    bitmaps_masks:array[1..max_aps_loaded] of hbitmap;
    bitmaps_havemasks:array[1..max_aps_loaded] of byte;
    //NEW AS OF 14/04/07 

    hdcScreen,hdcCompatible:hdc;
    hbmScreen:HBITMAP;
    retainobj:hgdiobj; 
    // IMPROVEMENTS
    obj_prediction:string; //Added as of 02-04-06
    obj_pred_int:integer;  //Last object prediction..  Improves performance VERY much..
    rotate_correction:integer; //0 = no correction , 1 = Simple Correction (unperfect) , 2 = Good Correction

    mult_draw_x1,mult_draw_y1,mult_draw_x2,mult_draw_y2:integer;

    // DEBUGGING
    //checks,check_times,predict_saves,sorting_times:integer;
    //TURBO
    switch_binary_search:boolean;
    failsafe_draw:boolean;
    optimise_on_load_windows,no_aps_window_precaching:boolean;




function ApsUnitVersion:string;
begin
ApsUnitVersion:=version;
end;


procedure aps_set_internal_options(theopt,theval:integer);
begin
options[theopt]:=theval;
end;

function aps_get_internal_options(theopt:integer):integer;
begin
aps_get_internal_options:=options[theopt];
end;

procedure Turbo_Cache_APS(theid:integer; thename:string);
begin
obj_prediction:=thename;
obj_pred_int:=theid;
end;

procedure APS_out_stats(reason:string);
var fileused:text;
    i:integer;
begin
assign(fileused,'aps_stats.dat');
{$i-}
append(fileused);
{$i+}
if Ioresult<>0 then rewrite(fileused);
writeln(fileused,'APS SESSION START '+version+'------------------');
writeln(fileused,'APS loaded : ',options[5]);
writeln(fileused,'Reason of output : ',reason);
write(fileused,'BINARY SEARCH WAS ');
if switch_binary_search then writeln(fileused,'ON') else
                             writeln(fileused,'OFF'); 
{writeln(fileused,'Memory Checks : ',checks);
writeln(fileused,'Memory Querys : ',check_times);
writeln(fileused,'Smart Prediction Saves : ',predict_saves);
writeln(fileused,'Sorting Load : ',sorting_times);      }
for i:=1 to options[5] do write(fileused,i,'=',Picturesloaded[i].name,' ');
writeln(fileused,'');
writeln(fileused,'SESSION END---------------------------------');
close(fileused);
end;

procedure APS_Debug(whathappend:string);
var fileused:text;
    i:integer;
begin
assign(fileused,'aps_debug.log');
{$i-}
append(fileused);
{$i+}
if Ioresult<>0 then rewrite(fileused);
writeln(fileused,whathappend);
close(fileused);
end;

function Retrieve_Aps_ID(nameu:string):integer;
var flag1,i,left,mid,right:integer;
    debstr:string;
begin
nameu:=Upcase(nameu);
//check_times:=check_times+1;
if nameu=obj_prediction then begin
                              flag1:=obj_pred_int;
                              //predict_saves:=predict_saves+1;
                             end else   
                             flag1:=0;

if flag1=0 then begin 

          if switch_binary_search then
           begin //BINARY SEARCH
              left:=1;
              right:=options[5];
              while (left <= right) do
                begin
                 //checks:=checks+1;
                 mid := ((right-left) div 2)+left;
                 if mid=0 then break else
                 if Equal(Picturesloaded[mid].name,nameu) then begin
                                                                flag1:=mid;
                                                                break;
                                                               end else
                 if nameu < Picturesloaded[mid].name then right := mid-1 else
                                                          left  := mid+1;
                end;
                //if left>right then flag1:=0;  }
           end else
           begin  //SERIAL SEARCH
                i:=1;
                 while i<=options[5] do
                 begin 
                  //checks:=checks+1;
                  if Equal(nameu,Picturesloaded[i].name) then begin
                                                            flag1:=i;
                                                            break;
                                                           end;
                  i:=i+1;
                 end;
          end;
                end;



if flag1<>0 then begin //Error Correction..
if not Equal(nameu,Picturesloaded[flag1].name) then begin
                                                    debstr:='APSLocate '+nameu+' as '+Convert2String(flag1);
                                                    if flag1>0 then debstr:=debstr+Picturesloaded[flag1].name;
                                                    APS_out_stats(debstr); 
                                                    flag1:=0; 
                                                 end;
                 end;


Turbo_Cache_APS(flag1,nameu);  //STORE RESULTS FOR A NEW PREDICTION.. 
Retrieve_Aps_ID:=flag1;
end;

procedure Add_New_Aps(theapsname:string; x1,y1,x2,y2:integer);
var where2add,i:integer;
    done:boolean; 
    label skip_add;
begin

if options[5]>=max_aps_loaded-1 then begin
                                       APS_Debug('APS Memory Full');
                                       goto skip_add;
                                     end;

theapsname:=Upcase(theapsname);
options[5]:=options[5]+1;
if options[5]=1 then where2add:=options[5] else
                     begin
                      i:=options[5];
                      done:=false;
                      repeat 
                       i:=i-1;
                       //sorting_times:=sorting_times+1;
                       if Picturesloaded[i].name>theapsname then begin
                                                                Picturesloaded[i+1]:=Picturesloaded[i];
                                                              end else
                                                              begin
                                                                i:=i+1;
                                                                done:=true;
                                                              end;
                      until ((done) or (i<=1));
                      where2add:=i;
                     end;

Picturesloaded[where2add].name:=theapsname;
Picturesloaded[where2add].x1:=x1;
Picturesloaded[where2add].y1:=y1;
Picturesloaded[where2add].x2:=x2;
Picturesloaded[where2add].y2:=y2;
obj_prediction:=theapsname;
obj_pred_int:=where2add;

if ((optimise_on_load_windows) and (not no_aps_window_precaching)) then
   begin
     //ReOptimiseAps(theapsname); //GIATI PERILAMVANEI K TO EPOMENO..
     Load_Bitmap_Windows(theapsname);
   end;
skip_add:
end;

procedure Remove_Aps(theapsname:string);
var where2delete,i:integer;
begin
where2delete:=Retrieve_Aps_ID(theapsname);
             //<
if where2delete>0 then
begin
if options[5]=where2delete then begin
                                 Picturesloaded[options[5]].name:='';
                                 Picturesloaded[options[5]].x1:=0;
                                 Picturesloaded[options[5]].y1:=0;
                                 Picturesloaded[options[5]].x2:=0;
                                 Picturesloaded[options[5]].y2:=0;
                                end else
                                begin
for i:=where2delete to options[5] do begin
                                      //sorting_times:=sorting_times+1;
                                      Picturesloaded[i]:=Picturesloaded[i+1]; 
                                     end; 
                                end;
options[5]:=options[5]-1;
end;
end;


function loadpicturememxy_i(nameu:integer):integer;
var flag1:integer;
begin
flag1:=nameu;
if flag1>0 then
begin
  x1:=Picturesloaded[flag1].x1;
  y1:=Picturesloaded[flag1].y1;
  x2:=Picturesloaded[flag1].x2;
  y2:=Picturesloaded[flag1].y2;

  x2:=x2-1;     //ISOS AYTO NA INE LATHOS!!!!!!!!
  y2:=y2-1;
  loadpicturememxy_i:=flag1;
end
else
loadpicturememxy_i:=0;

end;

function loadpicturememxy(nameu:string):integer;
var flag1:integer;
begin
flag1:=0;
if Equal(nameu,'ALL') then begin
                           flag1:=1;
                           x1:=1;
                           y1:=1;
                           x2:=options[1];
                           y2:=options[2];
                           end
                           else
                           begin 
                            flag1:=Retrieve_Aps_ID(nameu);
                            loadpicturememxy:=loadpicturememxy_i(flag1);
                           end;
end;

function GetInternalOptions(param:integer):integer;
begin
if param=100 then GetInternalOptions:=apsmaxpaperx else
if param=101 then GetInternalOptions:=apsmaxpapery else
begin
GetInternalOptions:=options[param];
end;
end;

procedure paint_a_pixel(pixx,pixy,colorus:integer);
begin
if enabletransp=false then putpixel(pixx,pixy,colorus) else
                      begin
                       if colorus<>transparent then putpixel(pixx,pixy,colorus);
                      end;
end;


procedure SetTransparentColor(color2change:integer);
begin
enabletransp:=true;
transparent:=color2change;
end;

function GetTransparentColor:integer;
begin
GetTransparentColor:=transparent;
end;

procedure DisableTransparency;
begin
enabletransp:=false;
end;

procedure DefineAps(name:string;x11,y11,x22,y22:integer); 
begin 
Add_New_Aps(name,x11,y11,x22,y22);
end;



procedure LoadAps (bufstr3:string);
begin
LoadAps_internal(bufstr3);
Add_New_Aps(bufstr3,loadingx+options[6],loadingy+options[7],loadingx+options[6]+options[1],loadingy+options[7]+options[2]);
end;




procedure PassHbitmap2Paper(thebitmap:HBITMAP; x2,y2:integer);
var
hdcCompatible:hdc; 
retainobj:hgdiobj;
x,y:integer;
bm:BITMAP;
begin
GetObject(thebitmap, sizeof(BITMAP), @bm);
x2:=bm.bmWidth;      // WORKS BUT NOT READY
y2:=bm.bmHeight;
//TEST CODE OI PARAPANW 3 grammes!!
hdcCompatible:=CreateCompatibleDC(GraphDcUsed); 
retainobj:=SelectObject(hdcCompatible,thebitmap);
if ((loadingx+x2>apsmaxpaperx) or (loadingy+y2>apsmaxpapery)) then
                                                 begin
                                                  MessageBox (0, pchar('A picture ('+Convert2String(x2)+','+Convert2String(y2)+') is too large, partial load..'), 'ApsFiles', 0 + MB_ICONEXCLAMATION);
                                                  if (x2>apsmaxpaperx) then x2:=apsmaxpaperx;
                                                  if (y2>apsmaxpapery) then y2:=apsmaxpapery;
                                                 end;
for x:=1 to x2 do
for y:=1 to y2 do begin
                   paper[loadingx+x,loadingy+y]:=GetPixel(hdcCompatible,x,y);
                  end;
SelectObject(hdcCompatible,retainobj);
DeleteObject(thebitmap);
ReleaseDC(WindowHandle, hdcCompatible);
DeleteDC(hdcCompatible);
GlobalFree(HGLOBAL(thebitmap));
end;


function CreateNonTransparencyRGN(apsname:string; full_rgn:HRgn; screen_x,screen_y:integer):Hrgn;
//Intended After Call
//CombineRgn(RgnAll, RgnAll, RgnCtrl, RGN_OR);
//DeleteObject(RgnCtrl);
var part_rgn:HRGN;
    passed:array[0..640,0..480] of boolean;
    ax,ay,ax2,clr:integer;
begin
for x:=0 to 640 do
for y:=0 to 480 do begin
                    passed[x,y]:=false;
                   end;
full_rgn:=0;
clr:=80;

y1:=y1+1;
y2:=y2+1;
x1:=x1+1;
x2:=x2+1;

for y:=y1 to y2 do
for x:=x1 to x2 do 
                  begin
                    if ((paper[x,y]<>transparent) and (passed[x-x1,y-y1]=false)) then
                      begin
                       ax:=x;
                       ay:=y; 
                        while ((ax<=x2) and (ay<=y2)) do
                          begin
                           if ((paper[ax,ay]<>transparent) and (passed[ax-x1,ay-y1]=false)) then
                              begin
                               passed[ax-x1,ay-y1]:=true; 
                               //PutPixel(ax-x1+screen_x,ay-y1+screen_y,ConvertRGB(0,clr,0));
                               clr:=clr+1;
                              end else break;
                           ax:=ax+1;
                           if ax>x2 then begin
                                            ax2:=ax;//GIA NA MPORESW NA EPISTREPSW!
                                            ax:=x;
                                            ay:=ay+1;
                                            if ay>y2 then begin
                                                           ax:=ax2;//PAME PISW
                                                           ay:=ay-1;//PAME PISW
                                                           break;
                                                          end else
                                            if ((paper[ax,ay]=transparent) or (passed[ax-x1,ay-y1]=true)) then
                                                          begin
                                                           ax:=ax2;//PAME PISW
                                                           ay:=ay-1;//PAME PISW
                                                           break;
                                                          end;

                                          end; 
                          end;
                       if full_rgn=0 then  full_rgn:=CreateRectRgn(x-x1+screen_x,y-y1+screen_y,ax-x1+screen_x,ay-y1+screen_y+1) else
                                           begin
                                            part_rgn:=CreateRectRgn(x-x1+screen_x,y-y1+screen_y,ax-x1+screen_x,ay-y1+screen_y+1);
                                            CombineRgn(full_rgn, full_rgn, part_rgn, RGN_OR);
                                            DeleteObject(part_rgn);
                                           end;
                       //DrawRectangle2(x-x1+screen_x,y-y1+screen_y,ax-x1+screen_x,ay-y1+screen_y,ConvertRGB(clr,clr,0),ConvertRGB(clr,clr,0));
                       //PutPixel(x-x1+screen_x,y-y1+screen_y,ConvertRGB(255,0,0));
                       //PutPixel(ax-x1+screen_x,ay-y1+screen_y,ConvertRGB(255,0,0));
                      end;
                     passed[x-x1,y-y1]:=true;
                   end;
y1:=y1-1;
y2:=y2-1;
x1:=x1-1;
x2:=x2-1;

//readkey;

CreateNonTransparencyRGN:=full_rgn;
end;

procedure QuickCopyDc2Paper(thebitmap:HBITMAP; x2,y2:integer);
var
hdcCompatible:hdc; 
begin
hdcCompatible:=CreateCompatibleDC(GraphDcUsed); 
for x:=1 to x2 do
for y:=1 to y2 do begin
                   PutPixel(x,y,GetPixel(thebitmap,x,y));
                   paper[loadingx+x,loadingy+y]:=GetPixel(thebitmap,x,y);
                  end;
DeleteDC(hdcCompatible);
end;


procedure PasteClipboardAPS(aname:string);
var  thebitmap:HBITMAP;
     hdcCompatible:hdc;  
     bm:BITMAP;
begin
OpenClipboard(0);
thebitmap:=GetClipboardData(CF_BITMAP);
if thebitmap<>0 then
begin
GetObject(thebitmap, sizeof(BITMAP), @bm);
x2:=bm.bmWidth;
y2:=bm.bmHeight;   
OuttextCenter('Found size '+Convert2String(x2)+','+Convert2String(y2));
hdcCompatible:=CreateCompatibleDC(GraphDcUsed); 
retainobj:=SelectObject(hdcCompatible,thebitmap);


if ((loadingx+x2>apsmaxpaperx) or (loadingy+y2>apsmaxpapery)) then
                                                 begin
                                                  MessageBox (0, pchar('A picture ('+Convert2String(x2)+','+Convert2String(y2)+') is too large, partial load..'), 'ApsFiles', 0 + MB_ICONEXCLAMATION);
                                                  if (x2>apsmaxpaperx) then x2:=apsmaxpaperx;
                                                  if (y2>apsmaxpapery) then y2:=apsmaxpapery;
                                                 end;
for x:=1 to x2 do
for y:=1 to y2 do begin
                   paper[loadingx+x,loadingy+y]:=GetPixel(hdcCompatible,x,y);
                   PutPixel(x,y,paper[loadingx+x,loadingy+y]);
                  end;
ReleaseDC(WindowHandle, hdcCompatible);
DeleteDC(hdcCompatible);
Add_New_Aps(aname,loadingx+1,loadingy+1,loadingx+x2,loadingy+y2);
end;
//SetClipboardData(CF_TEXT,)
CloseClipboard;

end;

procedure LoadBmp (bufstr3:string);
var x,y:integer;
begin
LoadCoreBmp(bufstr3+'.bmp');
if (not BMP_Error_Occured) then
  begin 
   if ((loadingx+GetBmpX<apsmaxpaperx) and (loadingy+GetBmpY<apsmaxpapery)) then
    begin
     for y:=1 to GetBmpY do
     for x:=1 to GetBmpX do begin
                            paper[loadingx+x,loadingy+y]:=GetBmpPixelColor(x,y);
                          end;
     DefineAps(bufstr3,loadingx+1,loadingy+1,loadingx+GetBmpX,loadingy+GetBmpY);
    end;
  end;
end;

procedure LoadIco (bufstr3:string);
var x,y:integer; 
begin
LoadCoreIco(bufstr3+'.ico');
for y:=1 to GetIcoY do
for x:=1 to GetIcoX do begin
                        paper[loadingx+x,loadingy+y]:=GetIcoPixelColor(x,y);
                       end; 
DefineAps(bufstr3,loadingx+1,loadingy+1,loadingx+GetIcoX,loadingy+GetIcoY);
end;

procedure LoadCur (bufstr3:string);
var x,y:integer; 
begin
LoadCoreIco(bufstr3+'.cur');
for y:=1 to GetIcoY do
for x:=1 to GetIcoX do begin
                        paper[loadingx+x,loadingy+y]:=GetIcoPixelColor(x,y);
                       end; 
DefineAps(bufstr3,loadingx+1,loadingy+1,loadingx+GetIcoX,loadingy+GetIcoY);
end;
 
procedure LoadJpg (bufstr3:string);       //NEW !!!!
var x,y:integer; 
    filenam,extention:string;
begin
for x:=1 to Length(bufstr3) do if bufstr3[x]='.' then y:=x;
extention:=Copy(bufstr3,y+1,Length(bufstr3)-y);
filenam:=Copy(bufstr3,1,y-1);   
GetJpegFileXY(bufstr3); 
PassHbitmap2Paper(LoadJpeg2(Pchar(bufstr3)),GetJpgX,GetJpgY); 
DefineAps(filenam,loadingx+1,loadingy+1,loadingx+GetJpgX,loadingy+GetJpgY);
end;


function LoadAPSRaw (thename,thefile:string):boolean;
begin
 LoadAPSRaw:=Load_RAW_File_Internal(thename,thefile);
end;

function SaveAPSRaw (thename,thefile:string):boolean;
begin
 SaveAPSRaw:=Save_RAW_File_Internal(thename,thefile);
end;


procedure DrawJpeg(AFileName:String; syntx,synty:integer);
begin
GetJpegFileXY(AFileName);
DrawJpegCore(Pchar(AFileName),syntx,synty);
end;

procedure DrawJpegCentered(AFileName:String);
begin
GetJpegFileXY(AFileName);
DrawJpeg(AFileName,(GetMaxX-GetJpgX)div 2,(GetMaxY-GetJpgY)div 2);
end; 

procedure DrawJpegTiled(AFileName:String);
var x1,y1:integer;
begin
GetJpegFileXY(AFileName);
x1:=-1;
y1:=0;
repeat
x1:=x1+1;
DrawJpeg(AFileName,x1*GetJpgX,y1*GetJpgY);
if (x1+1)*GetJpgX>=GetMaxX then begin
                                 x1:=-1;
                                 y1:=y1+1;
                                end;
if (y1)*GetJpgY>=GetMaxY then break;

until (y1)*GetJpgY>=GetMaxY ;
end; 

function ReturnApsName(bufstr3:string):string;
var x,y:integer;
    filenam,extention:string;
begin
y:=0;
for x:=1 to Length(bufstr3) do if bufstr3[x]='.' then y:=x;
filenam:=Copy(bufstr3,1,y-1);
if y=0 then ReturnApsName:=bufstr3 else
            ReturnApsName:=filenam;
end;

procedure LoadPicture (bufstr3:string);
var x,y:integer;
    filenam,extention:string;
begin
for x:=1 to Length(bufstr3) do if bufstr3[x]='.' then y:=x;
extention:=Copy(bufstr3,y+1,Length(bufstr3)-y);
filenam:=Copy(bufstr3,1,y-1);  
if Upcase(extention)='APS' then LoadAps(filenam) else
if (Upcase(extention)='BMP') or (Upcase(extention)='RLE') then LoadBmp(filenam) else
if (Upcase(extention)='ICO') then LoadIco(filenam) else
if (Upcase(extention)='CUR') then LoadCur(filenam) else
if (Upcase(extention)='APSRAW') then Load_RAW_File_Internal(filenam,filenam) else
if (Upcase(extention)='JPG') or (Upcase(extention)='JPEG') then LoadJpg(bufstr3){DrawJpegCore(Pchar(bufstr3))} else
MakeMessageBox('Error',' Cannot open files of filetype "'+extention+'"','OK','!','APPLICATION');
end;



function RetrieveMemory(bufx,bufy:integer):integer;
begin
RetrieveMemory:=paper[bufx,bufy];
end;

procedure SetLoadingXY (bufx,bufy:integer);
begin
loadingx:=bufx;
loadingy:=bufy;
end;

function GetLoadingX:integer;
begin
GetLoadingX:=loadingx;
end;

function GetLoadingY:integer;
begin
GetLoadingY:=loadingy;
end;

procedure DuplicateAps(name2,newname:string;x111,y111:integer);
begin
loadpicturememxy(name2);
 

for x:=1 to x2-x1 do
for y:=1 to y2-y1 do begin
                      paper[x+x111,y+y111]:=paper[x+x1,y+y1];
                     end;
DefineAps(newname,x111+1,y111+1,x111+x2-x1,y111+y2-y1);
 
end;


procedure FlushApsMemory;
begin 
x1:=0;
y1:=0;
x2:=0;
y2:=0;
loadingx:=0;
loadingy:=0;
for i:=1 to 8 do options[i]:=0;
FillDWord(paper,apsmaxpaperx*apsmaxpapery,0);
{for x:=1 to apsmaxpaperx do
for y:=1 to apsmaxpapery do
paper[x,y]:=0;      }
for i:=1 to max_aps_loaded do
begin
if bitmaps_created[i]=1 then begin
                                DeleteObject(bitmaps_ready[i]);
                                bitmaps_created[i]:=0;
                             end;
if bitmaps_havemasks[i]=1 then begin
                                DeleteObject(bitmaps_masks[i]);
                                bitmaps_havemasks[i]:=0;
                               end;
Picturesloaded[i].name:='';
Picturesloaded[i].x1:=0;
Picturesloaded[i].y1:=0;
Picturesloaded[i].x2:=0;
Picturesloaded[i].y2:=0; 
end;
i:=0;
x:=0;
y:=0;
end;

procedure UnloadAps (name:string);
var thespot,i:integer;
begin
switch_binary_search:=false; //DEBUG..
thespot:=loadpicturememxy(name);
if ((thespot<=0) or (thespot>max_aps_loaded) ) then
                   begin // ERROR
                    APS_Debug('Could not unload APS '+name+' , '+Convert2String(thespot));
                   end else
  begin
   if bitmaps_created[thespot]=1 then begin
                                       if not DeleteObject(bitmaps_ready[thespot]) then APS_Debug('Could not DeleteObject DC ready '+name);
                                       bitmaps_created[thespot]:=0;
                                      end;
   if bitmaps_havemasks[thespot]=1 then begin
                                         if not DeleteObject(bitmaps_masks[thespot]) then APS_Debug('Could not DeleteObject DC masked '+name);
                                         bitmaps_havemasks[thespot]:=0;
                                        end;
   i:=ConvertRGB(0,0,0);
   for x:=x1+1 to x2+1 do
    for y:=y1+1 to y2+1 do
      paper[x,y]:=i; 
 
   Remove_Aps(name); 
   
  end;

switch_binary_search:=true;
end;

procedure Multiple_APS_init;
begin
hdcScreen:=GraphDcUsed;
hdcCompatible:=CreateCompatibleDC(hdcScreen);
hbmScreen:=CreateCompatibleBitmap(hdcScreen,GetDeviceCaps(hdcScreen,HORZRES),GetDeviceCaps(hdcScreen,VERTRES));
retainobj:=SelectObject(hdcCompatible,hbmScreen);
BitBlt(hdcCompatible,0,0,GetMAXX,GetMAXY,hdcScreen,0,0,SRCCOPY);

mult_draw_x1:=GetMaxX;
mult_draw_y1:=GetMaxY;
mult_draw_x2:=0;
mult_draw_y2:=0; 
end;

function Multiple_APS_DC:hdc;
begin
Multiple_APS_DC:=hdcCompatible;
end;

procedure Multiple_APS_DrawXY(name:string; x3,y3:integer);
var newx,newy:integer; 
begin
loadpicturememxy(name);
newx:=x3-x1;
newy:=y3-y1; 

if (x3)<mult_draw_x1 then mult_draw_x1:=x3;
if (y3)<mult_draw_y1 then mult_draw_y1:=y3;
if (x3+x2-x1)>mult_draw_x2 then mult_draw_x2:=x3+x2-x1;
if (y3+y2-y1)>mult_draw_y2 then mult_draw_y2:=y3+y2-y1;

 
for x:=x1+1 to x2+1 do
for y:=y1+1 to y2+1 do begin
                        if enabletransp=false then SetPixelV(hdcCompatible,newx+x,newy+y,paper[x,y]) else
                        begin
                         if paper[x,y]<>transparent then SetPixelV(hdcCompatible,newx+x,newy+y,paper[x,y]);
                        end; 
                       end; 
end;

procedure Multiple_APS_close;
begin
//BitBlt(hdcScreen,0,0,GetMAXX,GetMAXY,hdcCompatible,0,0,SRCCOPY);
//BitBlt(hdcCompatible,mult_draw_x1,mult_draw_y1,mult_draw_x2-mult_draw_x1,mult_draw_y2-mult_draw_y1,hdcScreen,mult_draw_x1,mult_draw_y1,SRCCOPY);

BitBlt(hdcScreen,mult_draw_x1,mult_draw_y1,mult_draw_x2-mult_draw_x1,mult_draw_y2-mult_draw_y1,hdcCompatible,mult_draw_x1,mult_draw_y1,SRCCOPY);
//MessageBox (0, pchar('Drawing From '+Convert2String(mult_draw_x1)+','+Convert2String(mult_draw_y1)+' to '+Convert2String(mult_draw_x2)+','+Convert2String(mult_draw_y2)) , ' ', 0);
SelectObject(hdcCompatible,retainobj);
DeleteDC(hdcCompatible);
DeleteObject(hbmScreen);
end;

procedure DrawApsXY_i(name,x3,y3:integer);
var newx,newy,handl:integer;
begin
loadpicturememxy_i(name);
newx:=x3-x1;
newy:=y3-y1;
handl:=GraphDcUsed;
for x:=x1+1 to x2+1 do    
for y:=y1+1 to y2+1 do
    SetPixelV(handl,newx+x,newy+y,paper[x,y]); 
end;


procedure DrawApsXY(name:string; x3,y3:integer);
var newx,newy:integer; 
begin 
loadpicturememxy(name);
newx:=x3-x1;
newy:=y3-y1;
for x:=x1+1 to x2+1 do    
for y:=y1+1 to y2+1 do   
paint_a_pixel(newx+x,newy+y,paper[x,y]); 
end;

    
        
function Load_Bitmap_Windows(name:string):boolean;
var thespot:integer;
    retres:boolean;
    retain2,retain3:hgdiobj;
    hdcCompatible,hdcMem,hdcMem2:hdc;  
begin
retres:=true;
thespot:=loadpicturememxy(name);
if (no_aps_window_precaching) then begin retres:=false; end else
if thespot<=0 then begin {DEN YPARXEI BITMAP GIA NA FORTWSOUME!} end else
if bitmaps_created[thespot]=0 then
  begin 
   bitmaps_ready[thespot]:=CreateCompatibleBitmap(GraphDcUsed,x2-x1+1,y2-y1+1);
   if bitmaps_ready[thespot]=0 then MessageBox (0, pchar('Error Creating Bitmap'+name) , ' ', 0);
   begin
      hdcCompatible:=CreateCompatibleDC(0);
      retainobj:=SelectObject(hdcCompatible,bitmaps_ready[thespot]);
      bitmaps_created[thespot]:=1;
       for x:=x1+1 to x2+1 do
        for y:=y1+1 to y2+1 do begin
                                 SetPixelV(hdcCompatible,x-x1-1,y-y1-1,paper[x,y]);
                               end;
       SelectObject(hdcCompatible,retainobj); 
       DeleteDC(hdcCompatible); 

       if enabletransp=true then
         begin
           bitmaps_havemasks[thespot]:=1; 
           bitmaps_masks[thespot]:=CreateBitmap(x2-x1+1,y2-y1+1,1,1,NULL);

           hdcMem := CreateCompatibleDC(0);
           hdcMem2 := CreateCompatibleDC(0);

           retain2:=SelectObject(hdcMem, bitmaps_ready[thespot] );
           retain3:=SelectObject(hdcMem2, bitmaps_masks[thespot]);
 

           // Set the background colour of the colour image to the colour
           // you want to be transparent.
           SetBkColor(hdcMem, transparent);

           // Copy the bits from the colour image to the B+W mask... everything
           // with the background colour ends up white while everythig else ends up
           // black...Just what we wanted.

           BitBlt(hdcMem2, 0, 0,x2-x1+1,y2-y1+1, hdcMem, 0, 0, SRCCOPY);

           // Take our new mask and use it to turn the transparent colour in our
           // original colour image to black so the transparency effect will
           // work right.
           BitBlt(hdcMem, 0, 0,x2-x1+1,y2-y1+1, hdcMem2, 0, 0, SRCINVERT);

           // Clean up.

           SelectObject(hdcMem,retain2);
           SelectObject(hdcMem2,retain3);
 
           DeleteDC(hdcMem);
           DeleteDC(hdcMem2);
 
         end;

   end;
  end;
Load_Bitmap_Windows:=retres;
end;
 
procedure ReOptimiseAps(name:string);
var thespot:integer;
    hdcCompatible:hdc; 
begin 
//if optimise_on_load_windows then
if (not no_aps_window_precaching) then
 begin
  thespot:=loadpicturememxy(name);
  hdcCompatible:=CreateCompatibleDC(0);
  retainobj:=SelectObject(hdcCompatible,bitmaps_ready[thespot]);
  if bitmaps_created[thespot]=1 then begin
                                      SelectObject(hdcCompatible,bitmaps_ready[thespot]);
                                      DeleteObject(bitmaps_ready[thespot]);
                                      bitmaps_created[thespot]:=0;
                                     end;
  if bitmaps_havemasks[thespot]=1 then begin
                                         SelectObject(hdcCompatible,bitmaps_masks[thespot]);
                                         DeleteObject(bitmaps_masks[thespot]);
                                         bitmaps_havemasks[thespot]:=0;
                                       end;
 
  SelectObject(hdcCompatible,retainobj);
  DeleteDC(hdcCompatible);

 // Load_Bitmap_Windows(name);
 end;
end;

procedure DrawApsXY2(name:string; x3,y3:integer);
const force_trasparency_off=false;
var thespot,newx,newy:integer;
    tmp_bitmap:hbitmap;
    transdc,imagedc:hdc;
    retain1,retain2:hgdiobj; 
begin
thespot:=loadpicturememxy(name);
newx:=x3-x1;
newy:=y3-y1;

          
if Load_Bitmap_Windows(name) then
    begin
      {hdcScreen:=GraphDcUsed;      TASPASE :)))))
      hdcCompatible:=CreateCompatibleDC(hdcScreen);
      retainobj:=SelectObject(hdcCompatible,bitmaps_ready[thespot]);
      BitBlt(hdcCompatible,0,0,x2-x1,y2-y1,bitmaps_ready[thespot],0,0,SRCCOPY);
      BitBlt(hdcScreen,newx+x1+1,newy+y1+1,x2-x1+1,y2-y1+1,hdcCompatible,0,0,SRCCOPY);
      SelectObject(hdcCompatible,retainobj);
      DeleteDC(hdcCompatible); 
      }
      hdcScreen:=GraphDcUsed;

      if ((bitmaps_havemasks[thespot]=0) or (force_trasparency_off)) then
        begin
         hdcCompatible:=CreateCompatibleDC(hdcScreen);
         retainobj:=SelectObject(hdcCompatible,bitmaps_ready[thespot]);
         BitBlt(hdcCompatible,0,0,x2-x1,y2-y1,bitmaps_ready[thespot],0,0,SRCCOPY);
         BitBlt(hdcScreen,newx+x1+1,newy+y1+1,x2-x1+1,y2-y1+1,hdcCompatible,0,0,SRCCOPY);
         SelectObject(hdcCompatible,retainobj);
         DeleteDC(hdcCompatible);
        end else
        begin   
           
         hdcCompatible:=CreateCompatibleDC(hdcScreen);
         tmp_bitmap:=CreateCompatibleBitmap(hdcScreen,x2-x1,y2-y1);
         retainobj:=SelectObject(hdcCompatible,tmp_bitmap); 
                                                                  //+1 +1 Vlakeies , lathos :P
         BitBlt(hdcCompatible,0,0,x2-x1+1,y2-y1+1,GraphDcUsed,newx+x1,newy+y1,SRCCOPY);
         //EXOUME STO HDCOMPATIBLE TO BACKGROUND

         transdc:=CreateCompatibleDC(hdcScreen);
         retain1:=SelectObject(transdc,bitmaps_masks[thespot]);
          
          
         imagedc:=CreateCompatibleDC(hdcScreen); 
         retain2:=SelectObject(imagedc,bitmaps_ready[thespot]);
 
         BitBlt(hdcCompatible,0,0,x2-x1+1,y2-y1+1,transdc,0,0,SRCAND);
         BitBlt(hdcCompatible,0,0,x2-x1+1,y2-y1+1,imagedc,0,0,SRCPAINT);         
  
         //EXOUME STO HDCOMPATIBLE TO BACKGROUND + TRANSPARENT BITMAP KAI TO VGAZOUME STIN OTHONI
         BitBlt(hdcScreen,newx+x1+1,newy+y1+1,x2-x1,y2-y1,hdcCompatible,1,1,SRCCOPY);
 

         SelectObject(transdc,retain1);
         DeleteDC(transdc);
          SelectObject(imagedc,retain2);
         DeleteDC(imagedc);             

         DeleteObject(tmp_bitmap);
         DeleteDC(hdcCompatible); 
        end;


    end else 
begin  //OLD FASHIONED DRAW :P
hdcScreen:=GraphDcUsed;
hdcCompatible:=CreateCompatibleDC(hdcScreen);
hbmScreen:=CreateCompatibleBitmap(hdcScreen,GetDeviceCaps(hdcScreen,HORZRES),GetDeviceCaps(hdcScreen,VERTRES));
retainobj:=SelectObject(hdcCompatible,hbmScreen);
//BitBlt(hdcCompatible,newx+x1+1,newy+y1+1,newx+x2+1,newy+y2+1,hdcScreen,newx+x1+1,newy+y1+1,SRCCOPY);
BitBlt(hdcCompatible,newx+x1+1,newy+y1+1,x2-x1+1,y2-y1+1,hdcScreen,newx+x1+1,newy+y1+1,SRCCOPY);
for x:=x1+1 to x2+1 do
for y:=y1+1 to y2+1 do begin
                        if enabletransp=false then SetPixelV(hdcCompatible,newx+x,newy+y,paper[x,y]) else
                        begin
                         if paper[x,y]<>transparent then SetPixelV(hdcCompatible,newx+x,newy+y,paper[x,y]);
                        end; 
                       end;
//BitBlt(hdcScreen,newx+x1+1,newy+y1+1,newx+x2+1,newy+y2+1,hdcCompatible,newx+x1+1,newy+y1+1,SRCCOPY);
BitBlt(hdcScreen,newx+x1+1,newy+y1+1,x2-x1+1,y2-y1+1,hdcCompatible,newx+x1+1,newy+y1+1,SRCCOPY);
SelectObject(hdcCompatible,retainobj);
DeleteDC(hdcCompatible);
DeleteObject(hbmScreen);
end;
 
end;  

procedure DrawAps(name:string);
begin
loadpicturememxy(name);
for x:=x1 to x2 do
for y:=y1 to y2 do
paint_a_pixel(x,y,paper[x,y]);
end;

procedure DrawApsCentered(name:string);
var newx,newy:integer;
begin
loadpicturememxy(name);
newx:=(GetMaxX Div 2)-((x2-x1) Div 2)-x1;
newy:=(GetMaxY Div 2)-((y2-y1) Div 2)-y1;
for x:=x1+1 to x2+1 do
for y:=y1+1 to y2+1 do
paint_a_pixel(newx+x,newy+y,paper[x,y]);
end;

procedure DrawApsCentered2(name:string);
var newx,newy:integer;
begin
loadpicturememxy(name);
newx:=(GetMaxX Div 2)-((x2-x1) Div 2)-x1;
newy:=(GetMaxY Div 2)-((y2-y1) Div 2)-y1;
DrawApsXY2(name,newx+x1,newy+y1); 
end;


procedure DrawMove(name:string; x3,y3,x5,y5:integer);
var x4,y4,temx,colr:integer;
begin
colr:=ConvertRGB(0,0,0);
loadpicturememxy(name);
if x5<0 then begin
              x4:=x3+x2-x1;
              y4:=y3+y2-y1;
              {for temx:=x4 to x4-x5 do         old
              for temy:=y3 to y4 do
              putpixel(temx,temy,colr);}
              for temx:=x4+x5 to x4+1 do    {new-bugless}
              DrawLine (temx,y3,temx,y4,colr);        {lines are faster than pixels}
             end else
if x5>0 then begin
              x4:=x3;
              y4:=y3+y2-y1;
              {for temx:=x4-x5 to x4+x5 do
              for temy:=y3 to y4 do
              putpixel(temx,temy,colr);}
              for temx:=x4-x5 to x4+x5+1 do
              DrawLine (temx,y3,temx,y4,colr);
             end;
if y5>0 then begin    {picture(name,x1,y1,x2,y2)}
              x4:=x3+x2-x1;
              y4:=y3+y2-y1;
              {for temx:=x3 to x4 do
              for temy:=y3 to y3+y5 do
              putpixel(temx,temy,colr); }
              for temx:=x3 to x4+1 do
              DrawLine (temx,y3,temx,y3+y5+1,colr);
             end else
if y5<0 then begin
              x4:=x3+x2-x1;
              y4:=y3+y2-y1;
              {for temx:=x3 to x4 do
              for temy:=y4 to y4-y5 do
              putpixel(temx,temy,colr);}
              for temx:=x3 to x4+1 do
              DrawLine (temx,y4,temx,y4+y5+1,colr);
             end;

end;

procedure MoveApsFromToXY(name2:string; x31,y31,x51,y51:integer);
begin
loadpicturememxy(name2);
DrawMove(name2,x31,y31,x51-x31,y51-y31); 
DrawApsXY2(name2,x51,y51);
end;

procedure UndrawApsXY(name:string; x3,y3,color:integer);
var newx,newy:integer;
begin
loadpicturememxy(name);
newx:=x3-x1;
newy:=y3-y1;
for x:=x1+1 to x2+1 do DrawLine(newx+x,newy+y1,newx+x,newy+y2,color);
end;

procedure DrawApsTiled2(name:string);
var newx,newy,x3,y3,z,z2:integer;
begin
if loadpicturememxy(name)<>0 then
begin
z2:=x2-x1;
z:=y2-y1;
x3:=1;
y3:=1;
Multiple_APS_init;
repeat
 newx:=x3-x1;
 newy:=y3-y1; 
 //DrawApsXY2(name,x3+1,y3+1);
 for x:=x1+1 to x2+1 do
 for y:=y1+1 to y2+1 do begin
                         SetPixelV(hdcCompatible,newx+x,newy+y,paper[x,y]);
                        end; 

 x3:=x3+z2;
 if x3+z2>=GetMaxX+z2 then begin
                        x3:=1;
                        y3:=y3+z;
                       end;
until y3>=GetMaxY;
end;
Multiple_APS_close;
end;

procedure DrawApsTiled(name:string);
var newx,newy,x3,y3,z,z2:integer;
begin
if loadpicturememxy(name)<>0 then
begin
z2:=x2-x1;
z:=y2-y1;
x3:=1;
y3:=1;
{if transparent<>-1 then begin}
repeat
 newx:=x3-x1;
 newy:=y3-y1;
 for x:=x1+1 to x2+1 do
 for y:=y1+1 to y2+1 do
 paint_a_pixel(newx+x,newy+y,paper[x,y]);
 x3:=x3+z2;
 if x3+z2>=GetMaxX+z2 then begin
                        x3:=1;
                        y3:=y3+z;
                       end;
until y3>=GetMaxY; 
end;
end;


function GetApsPixel(name:string; curx,cury:integer):integer; {colorref}
begin
loadpicturememxy(name);
GetApsPixel:=paper[x1+curx,y1+cury];
end; 

function GetApsPixelColor(curx,cury:integer):integer; {colorref}
begin
GetApsPixelColor:=paper[curx,cury];
end;

procedure SetApsPixelColor(curx,cury,color2change:integer);
begin
paper[curx,cury]:=color2change;
end;

function GetApsInfo(name:string; infonum:string):integer; 
begin

if ((Equal(name,'BMP_CORE')) and (Equal(infonum,'SIZEX')) ) then GetApsInfo:=GetBmpX else
if ((Equal(name,'BMP_CORE')) and (Equal(infonum,'SIZEY')) ) then GetApsInfo:=GetBmpY else
 begin
   loadpicturememxy(name);
   if Equal(infonum,'NUMBER') then GetApsInfo:=x2 else
   if Equal(infonum,'MAXX')  or (Equal(infonum,'X2')) then GetApsInfo:=x2 else
   if Equal(infonum,'MAXY')  or (Equal(infonum,'Y2')) then GetApsInfo:=y2 else
   if Equal(infonum,'SIZEX') then GetApsInfo:=x2-x1 else  //+1
   if Equal(infonum,'SIZEY') then GetApsInfo:=y2-y1 else  //+1
   if Equal(infonum,'X') or (Equal(infonum,'X1')) then GetApsInfo:=x1 else
   if Equal(infonum,'Y') or (Equal(infonum,'Y1')) then GetApsInfo:=y1 else
   if Equal(infonum,'CENTERX') then GetApsInfo:=(GetMaxX Div 2)-((x2-x1) Div 2)-x1 else
   if Equal(infonum,'CENTERY') then GetApsInfo:=(GetMaxY Div 2)-((y2-y1) Div 2)-y1 else
   if Equal(infonum,'CENTERX2') then GetApsInfo:=(GetMaxX Div 2)-((x2-x1) Div 2)-x1+x2 else
   if Equal(infonum,'CENTERY2') then GetApsInfo:=(GetMaxY Div 2)-((y2-y1) Div 2)-y1+y2;
 end;
end;

function GetApsInfo_i(name,infonum:integer):integer; 
begin
loadpicturememxy_i(name);
// 1=NUMBER , 2=MAXX , 3=MAXY ,4=SIZEX , 5=SIZEY , 6=X , 7=Y , 8=CENTERX , 9=CENTERY , 10=CENTERX2 , 11=CENTERY2
if infonum=1 then GetApsInfo_i:=x2 else
if infonum=2 then GetApsInfo_i:=x2 else
if infonum=3 then GetApsInfo_i:=y2 else
if infonum=4 then GetApsInfo_i:=x2-x1 else  //+1
if infonum=5 then GetApsInfo_i:=y2-y1 else  //+1
if infonum=6 then GetApsInfo_i:=x1 else
if infonum=7 then GetApsInfo_i:=y1 else
if infonum=8 then GetApsInfo_i:=(GetMaxX Div 2)-((x2-x1) Div 2)-x1 else
if infonum=9 then GetApsInfo_i:=(GetMaxY Div 2)-((y2-y1) Div 2)-y1 else
if infonum=10 then GetApsInfo_i:=(GetMaxX Div 2)-((x2-x1) Div 2)-x1+x2 else
if infonum=11 then GetApsInfo_i:=(GetMaxY Div 2)-((y2-y1) Div 2)-y1+y2;
end;


procedure DrawAPSAnimationXY(theanim:string; x,y,speed,frames:integer);
var i:integer;
begin
i:=0;
while (not(readkeyfast<>'')) do
  begin
   i:=i+1;
   DrawAPSXY2(theanim+'_'+Convert2String(i),x,y);
   delay(speed);
   if i>=frames then i:=0;
  end; 
end;

function DrawAPSAnimationXYFrame(theanim:string; x,y,speed,frame,frames:integer):integer;
begin 
DrawAPSXY2(theanim+'_'+Convert2String(frame),x,y);
frame:=frame+1;
if frame>=frames then frame:=1;
delay(speed); 
DrawAPSAnimationXYFrame:=frame;
end;



procedure OutputFileTxt(apsname,filename,arrayname:string; backgroundcolor,language:integer);
// language 1 = pascal , 2 = C++
var fout:text;
    target_x,target_y:integer;
begin
assign(fout,filename);
{$i-}
rewrite(fout);
{$i+}
if Ioresult=0 then begin
                    loadpicturememxy(apsname);
                   if (language=1) then
                   begin
                    writeln(fout,'var');
                    writeln(fout,arrayname,':array[1..',x2-x1+1,',',y2-y1+1,'..] of integer;');
                    writeln(fout,'for x:=1 to ',x2-x1+1,' do ');
                    writeln(fout,' for y:=1 to ',y2-y1+1,' do ',arrayname,'[x,y]:=',backgroundcolor,';');
                    for x:=x1+1 to x2+1 do
                     for y:=y1+1 to y2+1 do begin
                                             if backgroundcolor<>paper[x,y] then
                                              writeln(fout,arrayname,'[',x-x1,',',y-y1,']:=',paper[x,y],';');
                                            end;
                   end else
                   if (language=2) then
                   begin 
                    writeln(fout,'//using namespace std;');
                    writeln(fout,'void draw_logo(int xdraw,int ydraw) {');
                    writeln(fout,'int ',arrayname,'[',x2-x1+2,'][',y2-y1+2,'];');
                    writeln(fout,'int i=0;');
                    writeln(fout,'for (int x=0; x<',x2-x1+1,'; x++) { ');
                    writeln(fout,' for (int y=0; y<',y2-y1+1,'; y++) { ',arrayname,'[x][y]=',backgroundcolor,'; }');
                    writeln(fout,'                                  }  ');
                    for x:=x1+1 to x2+1 do
                     for y:=y1+1 to y2+1 do begin
                                             target_x:=x;
                                             target_y:=y;


                                             if (backgroundcolor=paper[x,y]) then begin
                                             while (target_x<=x2+1) do
                                                begin
                                                  target_x:=target_x+1;
                                                  if (paper[target_x,target_y]=paper[x,y])  then begin end else
                                                                                                 begin
                                                                                                  target_x:=target_x-1;
                                                                                                  break;
                                                                                                 end;
                                                end;
                                                                                  end;//DONT BOTHER FOR BACKGROUND!

                                             if (((target_x<>x) or (target_y<>y)) and false) then
                                                     begin
                                                       writeln(fout,'for (i=',x-x1-1,'; i<=',target_x-x1-1,'; i++) { ',arrayname,'[i][',y,']=',paper[x,y],';',' }');
                                                     end else
                                                     begin
                                                      if backgroundcolor<>paper[x,y] then
                                                         writeln(fout,arrayname,'[',x-x1-1,'][',y-y1-1,']=',paper[x,y],';');
                                                     end;
                                            end;

                    writeln(fout,'for (int x=xdraw; x<xdraw+',x2-x1+1,'; x++) { ');
                    writeln(fout,' for (int y=ydraw; y<ydraw+',y2-y1+1,'; y++) { PutPixel(x,y,',arrayname,'[x-xdraw][y-ydraw]); }');
                    writeln(fout,'                                              }  ');
                    writeln(fout,'}');
                   end;
                    close(fout);
                   end;
end;


procedure SetBrightness(apsname,color:string; amount:real);
var red,green,blue:real;
begin
amount:=amount/100;
loadpicturememxy(apsname);
for x:=x1+1 to x2+1 do
for y:=y1+1 to y2+1 do begin
                     red:=ConvertR(paper[x,y]);
                     green:=ConvertG(paper[x,y]);
                     blue:=ConvertB(paper[x,y]);
                     if (Upcase(color)='ALL') or (Upcase(color)='RED') then begin
                                                                              red:=red*amount;
                                                                              if red>=255 then red:=255 else
                                                                              if red<=0 then red:=0;
                                                                              {red:=Round(red);  }
                                                                            end;
                     if (Upcase(color)='ALL') or (Upcase(color)='GREEN') then begin 
                                                                              green:=green*amount;
                                                                              if green>=255 then green:=255 else
                                                                              if green<=0 then green:=0;
                                                                              {green:=Round(green); }
                                                                            end;
                     if (Upcase(color)='ALL') or (Upcase(color)='BLUE') then begin
                                                                              blue:=blue*amount;
                                                                              if blue>=255 then blue:=255 else
                                                                              if blue<=0 then blue:=0;
                                                                             { blue:=Round(blue);}
                                                                            end;
                     paper[x,y]:=ConvertRGB(Round(red),Round(green),Round(blue));
                   end; 

ReOptimiseAps(apsname); //GIATI ALLAKSAN OI PLIROFORIES OPOTE NA EPANAFORTWTHEI ENA BITMAP..
end;

procedure ChangeApsColor(apsname:string; color1,color2:integer);
var changes_made:boolean;
begin
changes_made:=false;
loadpicturememxy(apsname);
for x:=x1+1 to x2+1 do
for y:=y1+1 to y2+1 do begin
                        if paper[x,y]=color1 then
                           begin
                            paper[x,y]:=color2;
                            changes_made:=true;
                           end;
                       end;
if changes_made then ReOptimiseAps(apsname); //GIATI ALLAKSAN OI PLIROFORIES OPOTE NA EPANAFORTWTHEI ENA BITMAP..
end;

procedure InvertAps(apsname,way:string);
var rsizex,rsizey,grid,tmp:integer;
begin 
loadpicturememxy(apsname);
rsizex:=x2-x1;
rsizey:=y2-y1;
if Upcase(way)='HORIZONTALY' then begin
grid:=(rsizex div 2);
for x:=x1+1 to x2-grid do                  {TODODDODODODO}
for y:=y1+1 to y2 do begin
                        tmp:=paper[x,y];
                        paper[x,y]:=paper[x2+x1-x+1,y];
                        paper[x2+x1-x+1,y]:=tmp;
                       end;
                                  end else
if Upcase(way)='VERTICALY' then begin
grid:=(rsizey div 2);
for x:=x1+1 to x2+1 do
for y:=y1+1 to y2-grid  do begin
                        tmp:=paper[x,y];
                        paper[x,y]:=paper[x,y1+y2-y+1];
                        paper[x,y1+y2-y+1]:=tmp;
                       end;
                                  end else
if Upcase(way)='COLOR' then begin 
for x:=x1+1 to x2+1 do
for y:=y1+1 to y2+1 do begin
                        paper[x,y]:=ConvertRGB(255-ConvertR(paper[x,y]),255-ConvertG(paper[x,y]),255-ConvertB(paper[x,y]));
                       end;
                                  end;

ReOptimiseAps(apsname); //GIATI ALLAKSAN OI PLIROFORIES OPOTE NA EPANAFORTWTHEI ENA BITMAP.. 
end;

function Calc_Tile_Color(tx1,ty1,tx2,ty2:integer):integer;
var midR,midG,midB:integer;
    x,y:integer;
begin  
midR:=0;
midG:=0;
midB:=0;
for x:=tx1 to tx2 do
 for y:=ty1 to ty2 do
       begin
        midR:=midR+ConvertR(paper[x,y]);
        midG:=midG+ConvertG(paper[x,y]);
        midB:=midB+ConvertB(paper[x,y]);
       end;
x:=(tx2-tx1+1)*(ty2-ty1+1);
midR:=midR div x;
midG:=midG div x;
midB:=midB div x; 
Calc_Tile_Color:=ConvertRGB(midR,midG,midB);
end;

procedure filter_resize(apsname:string; newx,newy:integer);
var rsizex,rsizey,x,y:integer;
    abs_new_x,abs_new_y:integer;
    ratio_x,ratio_y:real;
    s_x,s_y:real;
    allow_operation:boolean;
begin
allow_operation:=true;
loadpicturememxy(apsname);
rsizex:=x2-x1;
rsizey:=y2-y1;
abs_new_x:=x1;
abs_new_y:=y1;
if ((newx=0) and (newy=0) ) then begin
                                  OuttextCenter('Resize to 0 ?');
                                  allow_operation:=false;
                                 end else
if (newx=0) then begin
                   ratio_y:=(rsizey/newy);
                   ratio_x:=ratio_y;
                   newx:=round(rsizex/ratio_x);
                 end else
if (newy=0) then begin
                   ratio_x:=(rsizex/newx);
                   ratio_y:=ratio_x;
                   newy:=round(rsizey/ratio_y);
                 end else
                 begin
                   ratio_x:=(rsizex/newx);
                   ratio_y:=(rsizey/newy); 
                 end;

if ((newx>rsizex) or (newy>rsizey)) then begin
                                          allow_operation:=false;
                                          //OuttextCenter('Not ready for image to become larger ');
                                         end;
if allow_operation then
 begin
  { if rsizex mod newx<>0 then OuttextCenter('Not ready for not round resizing X') else
   if rsizey mod newy<>0 then OuttextCenter('Not ready for not round resizing Y') else  }
       begin
         s_x:=x1; // x:=x1;
         s_y:=y1; // y:=y1; 
         repeat 
            repeat
             paper[abs_new_x,abs_new_y]:=Calc_Tile_Color(round(s_x),round(s_y),round(s_x+ratio_x),round(s_y+ratio_y));
             abs_new_x:=abs_new_x+1;
             s_x:=s_x+ratio_x;
            until abs_new_x-x1>newx;//x>=x2;
           s_x:=x1;
           abs_new_x:=x1;
           abs_new_y:=abs_new_y+1;
           s_y:=s_y+ratio_y;
         until abs_new_y-y1>newy;//y>=y2;
       end;
   //CLEAR OLD PICTURE
   for x:=x1+newx to x2+1 do
     for y:=y1 to y2+1 do paper[x,y]:=0;

   for x:=x1 to x2+1 do
     for y:=y1+newy to y2+1 do paper[x,y]:=0;

   x:=Retrieve_Aps_ID(apsname);
   Picturesloaded[x].x2:=Picturesloaded[x].x1+newx;
   Picturesloaded[x].y2:=Picturesloaded[x].y1+newy;
 end;
ReOptimiseAps(apsname); //GIATI ALLAKSAN OI PLIROFORIES OPOTE NA EPANAFORTWTHEI ENA BITMAP..
end;


procedure set_rotate_quality_APS(thequal:integer);
begin
if thequal<0 then MessageBox (0, 'Wrong Argument For Rotation Quality , Rotation Quality off!' , 'ApsFiles', 0 + MB_ICONASTERISK) else
if thequal>3 then
   begin
    thequal:=3;
    MessageBox (0, 'So high Rotation Quality is not supported!' , 'ApsFiles', 0 + MB_ICONASTERISK);
   end;
rotate_correction:=thequal;

end;

procedure filter_rotate(apsname:string; start_x,start_y,rotation:integer);
var st_x,st_y,x,y:integer;
    trans_x,trans_y,last_x,last_y,rot_rad:real;
begin
loadpicturememxy(apsname);
st_x:=(x2-x1) div 2;
st_y:=(y2-y1) div 2;
rot_rad:=rotation*pi/180;
last_x:=cos(rot_rad)*(x1-st_x)-sin(rot_rad)*(y1-st_y)+st_x;
last_y:=sin(rot_rad)*(x1-st_x)+cos(rot_rad)*(y1-st_y)+st_y;
for x:=x1 to x2 do
 for y:=y1 to y2 do
  begin
   trans_x:=cos(rot_rad)*(x-st_x)-sin(rot_rad)*(y-st_y)+st_x;
   trans_y:=sin(rot_rad)*(x-st_x)+cos(rot_rad)*(y-st_y)+st_y;
   putpixel(start_x+round(trans_x),start_y+round(trans_y),paper[x,y]);
   if rotate_correction=1 then begin
                         if ((abs(last_x-trans_x)>1) and (abs(last_y-trans_y)>1) ) then putpixel(start_x+round(trans_x)+1,start_y+round(trans_y)+1,paper[x,y]);
                         if abs(last_x-trans_x)>1 then putpixel(start_x+round(trans_x)+1,start_y+round(trans_y),paper[x,y]);
                         if abs(last_y-trans_y)>1 then putpixel(start_x+round(trans_x),start_y+round(trans_y)+1,paper[x,y]);
                        end else
   if rotate_correction=2 then begin
                         if ((abs(last_x-trans_x)>1) and (abs(last_y-trans_y)>1) ) then putpixel(start_x+round(trans_x)+1,start_y+round(trans_y)+1,Calc_Tile_Color(x,y,x+1,y+1));
                         if abs(last_x-trans_x)>1 then putpixel(start_x+round(trans_x)+1,start_y+round(trans_y),Calc_Tile_Color(x,y,x+1,y));
                         if abs(last_y-trans_y)>1 then putpixel(start_x+round(trans_x),start_y+round(trans_y)+1,Calc_Tile_Color(x,y,x,y+1));
                        end else
   if rotate_correction=3 then begin
                         if ((abs(last_x-trans_x)>1) and (abs(last_y-trans_y)>1) ) then putpixel(start_x+round(trans_x)+1,start_y+round(trans_y)+1,Calc_Tile_Color(x,y,x+1,y+1));
                         if abs(last_x-trans_x)<0 then putpixel(start_x+round(trans_x)-1,start_y+round(trans_y),Calc_Tile_Color(x-1,y,x,y)) else
                         if abs(last_x-trans_x)>1 then putpixel(start_x+round(trans_x)+1,start_y+round(trans_y),Calc_Tile_Color(x,y,x+1,y));
                         if abs(last_y-trans_y)<0 then putpixel(start_x+round(trans_x),start_y+round(trans_y)-1,Calc_Tile_Color(x,y-1,x,y)) else
                         if abs(last_y-trans_y)>1 then putpixel(start_x+round(trans_x),start_y+round(trans_y)+1,Calc_Tile_Color(x,y,x,y+1));
                        end;
   last_y:=trans_y;
  end;
  last_x:=cos(rot_rad)*(x1-st_x)-sin(rot_rad)*(y+1-st_y)+st_x;

end;


procedure filter_merge(apsname1,apsname2,apsoutput:string; change,detail:integer);
var a_x1,a_y1,a_x2,a_y2:integer;
    b_x1,b_y1,b_x2,b_y2:integer; 
    clr1,clr2,x,y,res_x,res_y,target_x,target_y:integer;
    mergedR,mergedG,mergedB:integer;
begin
loadpicturememxy(apsname1);
a_x1:=x1; a_y1:=y1; a_x2:=x2; a_y2:=y2;
loadpicturememxy(apsname2);
b_x1:=x1; b_y1:=y1; b_x2:=x2; b_y2:=y2;
if (a_x2-a_x1)>(b_x2-b_x1) then res_x:=b_x2-b_x1 else
                                res_x:=a_x2-a_x1;
if (a_y2-a_y1)>(b_y2-b_y1) then res_y:=b_y2-b_y1 else
                                res_y:=a_y2-a_y1;
loadpicturememxy(apsoutput); 
target_x:=x1;
target_y:=y1;
for x:=0 to res_x do
 for y:=0 to res_y do
   begin
      clr1:=Calc_Tile_Color(x+a_x1,y+a_y1,x+a_x1+detail,y+a_y1+detail);
      clr2:=Calc_Tile_Color(x+b_x1,y+b_y1,x+b_x1+detail,y+b_y1+detail);  
      mergedR:=(  (ConvertR(clr1)*(100-change) div 100)+(ConvertR(clr2)*(change) div 100)  ); //div 2;
      mergedG:=(  (ConvertG(clr1)*(100-change) div 100)+(ConvertG(clr2)*(change) div 100)  ); //div 2;
      mergedB:=(  (ConvertB(clr1)*(100-change) div 100)+(ConvertB(clr2)*(change) div 100)  ); //div 2;
      //mergedB:=(ConvertB(clr1)+ConvertB(clr2)) div 2;
      paper[target_x+x,target_y+y]:=ConvertRGB(mergedR,mergedG,mergedB);
      //putpixel(1+x,1+y,ConvertRGB(mergedR,mergedG,mergedB));
   end; 
ReOptimiseAps(apsoutput); //GIATI ALLAKSAN OI PLIROFORIES OPOTE NA EPANAFORTWTHEI ENA BITMAP..
end;



procedure filter_noise(output:string; density:integer);
var curpixelx,curpixely,outnum:integer;
    prcent:real;
    rect2scan:array[1..4]of integer;
begin
prcent:=(100-density)/100;
if Upcase(output)='SCREEN' then outnum:=0 else
                                outnum:=loadpicturememxy(output);
if outnum=0 then begin
                  rect2scan[1]:=1;
                  rect2scan[2]:=1;
                  rect2scan[3]:=GetMaxX;
                  rect2scan[4]:=GetMaxY;
                  Multiple_APS_init;
                 end else
                 begin
                  rect2scan[1]:=x1+1;
                  rect2scan[2]:=y1+1;
                  rect2scan[3]:=x2+1;
                  rect2scan[4]:=y2+1;
                 end; 
randomize;
for curpixelx:=rect2scan[1] to rect2scan[3] do
for curpixely:=rect2scan[2] to rect2scan[4] do
                              begin 
                               if random>prcent then
                                                  begin
                                                     if outnum=0 then SetPixelV(hdcCompatible,curpixelx,curpixely,ConvertRGB(0,0,0)) else
                                                                      paper[curpixelx,curpixely]:=ConvertRGB(0,0,0);
                                                  end;
                              end;
if outnum=0 then Multiple_APS_close;
end;

procedure filter_oldmonitor(output:string; pixelsize:integer);
var curpixel,pixloop,outnum:integer;
    rect2scan:array[1..4]of integer;
begin
if Upcase(output)='SCREEN' then outnum:=0 else
                                outnum:=loadpicturememxy(output);
if outnum=0 then begin
                  rect2scan[1]:=1;
                  rect2scan[2]:=1;
                  rect2scan[3]:=GetMaxX;
                  rect2scan[4]:=GetMaxY;
                 end else
                 begin
                  rect2scan[1]:=x1+1;
                  rect2scan[2]:=y1+1;
                  rect2scan[3]:=x2+1;
                  rect2scan[4]:=y2+1;
                 end;
SetLineSettings(pixelsize,pixelsize,pixelsize);
for curpixel:=rect2scan[2] to rect2scan[4] do
                              begin
                               if outnum=0 then drawline(rect2scan[1],curpixel,rect2scan[3],curpixel,ConvertRGB(0,0,0)) else  
                                                for pixloop:=rect2scan[1] to rect2scan[3] do paper[pixloop,curpixel]:=ConvertRGB(0,0,0);
                               curpixel:=curpixel+pixelsize;
                              end;
SetLineSettings(1,1,1);
end;

procedure filter_blur (output:string; stperc:integer);
var screen:array[1..2048,1..1600]of integer;
    neighborpixels:array[1..6,1..4]of integer;
    rect2scan:array[1..4]of integer;
    scx,scy,tmp,tmpx,tmpy,outnum:integer;
begin 
if Upcase(output)='SCREEN' then outnum:=0 else
                                outnum:=loadpicturememxy(output);
if outnum=0 then begin
                  rect2scan[1]:=1;
                  rect2scan[2]:=1;
                  rect2scan[3]:=GetMaxX-2;
                  rect2scan[4]:=GetMaxY-2;
                  Multiple_APS_init;
                 end else
                 begin
                  rect2scan[1]:=x1+1;
                  rect2scan[2]:=y1+1;
                  rect2scan[3]:=x2-1;
                  rect2scan[4]:=y2-1;
                 end; 

for scx:=rect2scan[1] to rect2scan[3] do begin
for scy:=rect2scan[2] to rect2scan[4] do begin
                            if outnum=0 then begin
                                              screen[scx,scy]:=GetPixel(hdcCompatible,scx,scy);
                                              screen[scx+1,scy]:=GetPixel(hdcCompatible,scx+1,scy);
                                              screen[scx,scy+1]:=GetPixel(hdcCompatible,scx,scy+1);
                                              screen[scx+1,scy+1]:=GetPixel(hdcCompatible,scx+1,scy+1);
                                             end else
                                             begin
                                              screen[scx,scy]:=paper[scx,scy];
                                              screen[scx+1,scy]:=paper[scx+1,scy];
                                              screen[scx,scy+1]:=paper[scx,scy+1];
                                              screen[scx+1,scy+1]:=paper[scx+1,scy+1];
                                             end;
                            for tmp:=1 to 3 do begin
                                                if tmp=1 then begin
                                                              tmpx:=scx+1;
                                                              tmpy:=scy;
                                                            end else
                                                if tmp=2 then begin
                                                              tmpx:=scx;
                                                              tmpy:=scy+1;
                                                            end else
                                                if tmp=3 then begin
                                                              tmpx:=scx+1;
                                                              tmpy:=scy+1;
                                                            end;
                                                neighborpixels[tmp,1]:=(ConvertR(screen[scx,scy])+ConvertR(screen[tmpx,tmpy])) div 2;
                                                neighborpixels[tmp,2]:=(ConvertG(screen[scx,scy])+ConvertG(screen[tmpx,tmpy])) div 2;
                                                neighborpixels[tmp,3]:=(ConvertB(screen[scx,scy])+ConvertB(screen[tmpx,tmpy])) div 2;
                                                neighborpixels[tmp,4]:=ConvertRGB(neighborpixels[tmp,1],neighborpixels[tmp,2],neighborpixels[tmp,3]);
                                               end; 
                            neighborpixels[6,1]:=(neighborpixels[1,1]+neighborpixels[2,1]+neighborpixels[3,1]) div 3;
                            neighborpixels[6,2]:=(neighborpixels[1,2]+neighborpixels[2,2]+neighborpixels[3,2]) div 3;
                            neighborpixels[6,3]:=(neighborpixels[1,3]+neighborpixels[2,3]+neighborpixels[3,3]) div 3;
                            neighborpixels[6,4]:=ConvertRGB(neighborpixels[6,1],neighborpixels[6,2],neighborpixels[6,3]);
                            //Putpixel(scx,scy,neighborpixels[6,4]);
                            if outnum=0 then SetPixelV(hdcCompatible,scx,scy,neighborpixels[6,4]) else
                                             paper[scx,scy]:=neighborpixels[6,4];
                            {inc(scy);}
                           end; {inc(scx); }
                                  end;
if outnum=0 then Multiple_APS_close;
end;

procedure filter_dissasemble (output:string; xonscreen,yonscreen,speed:integer);
var screen:array[1..2048,1..400]of integer;
    origscreen:array[1..2048,1..1024]of integer;
    scanline:integer;  
begin 

loadpicturememxy(output);
 
SetBackgroundMode('OPAQUE');


for x:=xonscreen to xonscreen+x2-x1+1 do
 for y:=yonscreen to GetMaxY do origscreen[x,y]:=GetPixelColor(x,y);

for x:=1 to x2-x1+1 do
 for y:=1 to y2-y1+1 do screen[x,y]:=yonscreen+y;


DrawApsXY2(output,xonscreen,yonscreen);
scanline:=yonscreen;
repeat      
scanline:=scanline+1;
for x:=1 to x2-x1+1 do
for y:=1 to y2-y1+1 do
                      begin
                        if screen[x,y]<GetMaxY then
                        begin  
                         PutPixel(xonscreen+x,screen[x,y],origscreen[xonscreen+x,screen[x,y]]); //backcolor
                         screen[x,y]:=screen[x,y]+Round(Random(speed));
                         paint_a_pixel(xonscreen+x,screen[x,y],paper[x1+x,y1+y]);
                        end;
                      end;  
 

until scanline>GetMaxY;
SetBackgroundMode('TRANSPARENT');

end;



procedure filter_channel(output:string; channel_select:byte);
begin
loadpicturememxy(output); 

for x:=x1+1 to x2-1 do
 for y:=y1+1 to y2-1 do
   begin 
    case channel_select of
    1: begin
        paper[x,y]:=ConvertRGB(ConvertR(paper[x,y]),ConvertR(paper[x,y]),ConvertR(paper[x,y]));
       end;
    2: begin
        paper[x,y]:=ConvertRGB(ConvertG(paper[x,y]),ConvertG(paper[x,y]),ConvertG(paper[x,y]));
       end;
    3: begin
        paper[x,y]:=ConvertRGB(ConvertB(paper[x,y]),ConvertB(paper[x,y]),ConvertB(paper[x,y]));
       end; 
    end;
   end;
ReOptimiseAps(output); //GIATI ALLAKSAN OI PLIROFORIES OPOTE NA EPANAFORTWTHEI ENA BITMAP..

end;



function compare_2_aps(input1,input2:string; threshold:integer):byte;
var pict_coordinates:array[1..2,1..4]of integer;
    smaller_pic,clr1,clr2,changes,diff:integer;
begin
loadpicturememxy(input1);
pict_coordinates[1,1]:=x1+1;
pict_coordinates[1,2]:=x2-1;
pict_coordinates[1,3]:=y1+1;
pict_coordinates[1,4]:=y2-1;
loadpicturememxy(input2);
pict_coordinates[2,1]:=x1+1;
pict_coordinates[2,2]:=x2-1;
pict_coordinates[2,3]:=y1+1;
pict_coordinates[2,4]:=y2-1;

if ((pict_coordinates[1,2]-pict_coordinates[1,1]<pict_coordinates[2,2]-pict_coordinates[2,1]) and (pict_coordinates[1,4]-pict_coordinates[1,3]<pict_coordinates[2,4]-pict_coordinates[2,3]))
   then  smaller_pic:=1 else
         smaller_pic:=2;

changes:=0;
for x:=1 to pict_coordinates[smaller_pic,2]-pict_coordinates[smaller_pic,1] do
 for y:=1 to pict_coordinates[smaller_pic,4]-pict_coordinates[smaller_pic,3] do
   begin
    clr1:=paper[x+pict_coordinates[1,1],y+pict_coordinates[1,3]];
    clr2:=paper[x+pict_coordinates[2,1],y+pict_coordinates[2,3]];

    diff:=Abs(ConvertR(clr2)-ConvertR(clr1));
    if threshold<diff then changes:=changes+1;
    diff:=Abs(ConvertG(clr2)-ConvertG(clr1));
    if threshold<diff then changes:=changes+1;
    diff:=Abs(ConvertB(clr2)-ConvertB(clr1));
    if threshold<diff then changes:=changes+1;
   end;
diff:=(pict_coordinates[smaller_pic,2]-pict_coordinates[smaller_pic,1]) * (pict_coordinates[smaller_pic,4]-pict_coordinates[smaller_pic,3]);
diff:=(255*changes) div diff;
compare_2_aps:=diff;
end;


procedure filter_edges(output:string; sensitivity:integer);
var     origscreen:array[1..640,1..480]of integer;
        edge:boolean;
begin
loadpicturememxy(output);

for x:=x1+1 to x2-1 do
 for y:=y1+1 to y2-1 do
   begin
    origscreen[x-x1,y-y1]:=paper[x,y];
   end;

for x:=x1+1 to x2-1 do
 for y:=y1+1 to y2-1 do
   begin
    edge:=false;
    if Abs(ConvertR(origscreen[x-x1,y-y1])-ConvertR(origscreen[x-x1+1,y-y1]))>sensitivity then edge:=true else
    if Abs(ConvertG(origscreen[x-x1,y-y1])-ConvertG(origscreen[x-x1+1,y-y1]))>sensitivity then edge:=true else
    if Abs(ConvertB(origscreen[x-x1,y-y1])-ConvertB(origscreen[x-x1+1,y-y1]))>sensitivity then edge:=true;


    if edge then paper[x,y]:=ConvertRGB(0,0,0) else
                 paper[x,y]:=ConvertRGB(255,255,255);
   end;
ReOptimiseAps(output); //GIATI ALLAKSAN OI PLIROFORIES OPOTE NA EPANAFORTWTHEI ENA BITMAP..

end;



procedure APS_SAFE_MODE;
begin
optimise_on_load_windows:=false;  
no_aps_window_precaching:=false;
end;




begin  
switch_binary_search:=true;
failsafe_draw:=false;
enabletransp:=false;
optimise_on_load_windows:=false; //false
no_aps_window_precaching:=false;
rotate_correction:=2;
for i:=1 to max_aps_loaded do begin
                               bitmaps_created[i]:=0;
                               bitmaps_havemasks[i]:=0;
                              end;
end.

