unit ammargui_draw_functions;

interface
procedure adjust_window_shape_transparency; 
procedure Draw_a_Window(title1:string; active,x,y,sizex1,sizey1:integer);
procedure store_skin_metrics_window;

implementation 
uses windows,ammargui,ammarunit,apsfiles;
const
// COLOR
   window_background=1; 
   window_title=4;
var     //INLINE PARAMETERS FOR EXTRA SPEED
    sxbtnminimize,sxbtnmaximize,sxbtnexit,sybtnminimize,sybtnmaximize,sybtnexit,sxupmiddle,syupmiddle,sxupmiddle2:integer;
    sxupleft,syupleft,sxdownleft,sydownleft,sxuptransection,sxupright,syupright,sxdownright:integer;
    sydownright,sxmiddleright,symiddleright,sxmiddleleft,symiddleleft,sxdownmiddle,sydownmiddle:integer;


procedure store_skin_metrics_window;
begin
sxbtnminimize:=GetApsInfo('btnminimize','SIZEX');
sybtnminimize:=GetApsInfo('btnminimize','SIZEY');
sxbtnmaximize:=GetApsInfo('btnmaximize','SIZEX');
sybtnmaximize:=GetApsInfo('btnmaximize','SIZEY');
sxbtnexit:=GetApsInfo('btnexit','SIZEX');
sybtnexit:=GetApsInfo('btnexit','SIZEY'); 
sxupmiddle2:=GetApsInfo('upmiddle2','SIZEX'); 
sxupright:=GetApsInfo('upright','SIZEX');
syupright:=GetApsInfo('upright','SIZEY');
sxdownright:=GetApsInfo('downright','SIZEX');
sydownright:=GetApsInfo('downright','SIZEY');
sxmiddleright:=GetApsInfo('middleright','SIZEX');
symiddleright:=GetApsInfo('middleright','SIZEY'); 
sxmiddleleft:=GetApsInfo('middleleft','SIZEX');
symiddleleft:=GetApsInfo('middleleft','SIZEY');

sxdownleft:=GetApsInfo('downleft','SIZEX');
sydownleft:=GetApsInfo('downleft','SIZEY');

sxdownmiddle:=GetApsInfo('downmiddle','SIZEX');
sydownmiddle:=GetApsInfo('downmiddle','SIZEY'); 
end;

procedure adjust_window_shape_transparency;
var RgnAll, RgnCtrl: HRGN;
    st_x,st_y,st_x2,st_y2,st_tmp,trans:integer;
    error_occured:boolean; 
begin
// TODO SetWIndows RGN
{
RgnCtrl := CreateRectRgn(Left, Top, Left + Width, Top + Height);
        // Combine the region with all previous ones, if available
        if (RgnCtrl <> 0) and (RgnAll <> 0) then
        begin
          CombineRgn(RgnAll, RgnAll, RgnCtrl, RGN_OR);
          DeleteObject(RgnCtrl);
        end      }
//RgnCtrl := CreateRectRgn(Left, Top, Left + Width, Top + Height);
error_occured:=false;
trans:=ConvertRGB(123,123,0); //TRANSPARENT COLOR
RgnAll := 0;
st_x:=(GetApsInfo('middleleft','x'));
st_y:=(GetApsInfo('middleleft','y'));
st_tmp:=GetApsInfo('middleleft','sizex');
while (trans=GetApsPixelColor(st_x,st_y)) do
   begin
    st_x:=st_x+1;
    if st_tmp<=st_x then break;
   end;     //FTANOUME STIN ARXI  TOU MI TRANSPARENT MEROUS
st_x:=st_x-GetApsInfo('middleleft','x');
st_y:=st_y-GetApsInfo('middleleft','y');

st_x2:=(GetApsInfo('middleright','x2'));
st_y2:=(GetApsInfo('middleright','y'));
st_tmp:=GetApsInfo('middleright','sizex');
while (trans=GetApsPixelColor(st_x,st_y)) do
   begin
    st_x2:=st_x2-1;
    if st_tmp>=st_x2 then break;
   end;     //FTIAXNOUME KAI TO TELOS TOU MI TRANSPARENT MEROUS
st_x2:=st_x2-(GetApsInfo('middleright','x'));
st_y2:=st_y2-(GetApsInfo('middleright','y'));

//PROSTHETOUME TIN MESI TOU PARATHIROY APO ARISTERA EWS DEKSIA
RgnAll := CreateRectRgn(st_x+1,GetApsInfo('upleft','SIZEY'),GetMaxX{-st_x2},GetMaxY-GetApsInfo('downleft','SIZEY'));
//PROSTETHIKE (EINAI PRWTO GIAYTO APOTHIKEYTIKE STO RGNALL)



//PROSTHETOUME TIN GWNIA PANW ARISTERA
RgnCtrl:=CreateNonTransparencyRGN('upleft',RgnAll,1,1);
if (RgnCtrl <> 0) and (RgnAll <> 0) then
        begin
          CombineRgn(RgnAll, RgnAll, RgnCtrl, RGN_OR);
          DeleteObject(RgnCtrl);
        end else error_occured:=true;

//PROSTHETOUME TIN GWNIA KATW ARISTERA
RgnCtrl:=CreateNonTransparencyRGN('downleft',RgnAll,1,GetMaxY-GetApsInfo('downleft','SIZEY')-1);
if (RgnCtrl <> 0) and (RgnAll <> 0) then
        begin
          CombineRgn(RgnAll, RgnAll, RgnCtrl, RGN_OR);
          DeleteObject(RgnCtrl);
        end else error_occured:=true;


//FTIAXNOUME TIN PANW MPARA
st_x:=(GetApsInfo('upmiddle','x'));
st_y:=(GetApsInfo('upmiddle','y'));
st_tmp:=GetApsInfo('upmiddle','sizey'); 
while (trans=GetApsPixelColor(st_x,st_y)) do
   begin
    st_y:=st_y+1;
    if st_tmp<=st_y then break;
   end;     //FTANOUME STIN ARXI  TOU MI TRANSPARENT MEROUS
st_x:=st_x-GetApsInfo('upmiddle','x');
st_y:=st_y-GetApsInfo('upmiddle','y');
RgnCtrl := CreateRectRgn(GetApsInfo('upleft','SIZEX'),st_y+2,GetMaxX-GetApsInfo('upright','sizex'),GetApsInfo('upmiddle','sizey'));
if (RgnCtrl <> 0) and (RgnAll <> 0) then
        begin
          CombineRgn(RgnAll, RgnAll, RgnCtrl, RGN_OR);
          DeleteObject(RgnCtrl);
        end else error_occured:=true;


// PANW DEKSIA KOMMATI
RgnCtrl:=CreateNonTransparencyRGN('upright',RgnAll,GetMaxX-GetApsInfo('upright','SIZEx'),1);
if (RgnCtrl <> 0) and (RgnAll <> 0) then
        begin
          CombineRgn(RgnAll, RgnAll, RgnCtrl, RGN_OR);
          DeleteObject(RgnCtrl);
        end else error_occured:=true;



//FTIAXNOUME TIN KATW MPARA
st_x:=(GetApsInfo('downmiddle','x'));
st_y:=(GetApsInfo('downmiddle','y2'));
st_tmp:=GetApsInfo('downmiddle','y'); 
while (trans=GetApsPixelColor(st_x,st_y)) do
   begin
    st_y:=st_y-1;
    if st_tmp>=st_y then break;
   end;     //FTANOUME STIN ARXI  TOU MI TRANSPARENT MEROUS
st_x:=st_x-GetApsInfo('downmiddle','x');
st_y:=st_y-GetApsInfo('downmiddle','y');
//RgnCtrl := CreateRectRgn(GetApsInfo('downleft','SIZEX'),GetMaxY-GetApsInfo('downmiddle','sizey'),GetMaxX-GetApsInfo('downright','sizex'),GetMaxY-st_y-1);
RgnCtrl := CreateRectRgn(GetApsInfo('downleft','SIZEX'),GetMaxY-GetApsInfo('downmiddle','sizey'),GetMaxX-GetApsInfo('downright','sizex'),GetMaxY);
if (RgnCtrl <> 0) and (RgnAll <> 0) then
        begin
          CombineRgn(RgnAll, RgnAll, RgnCtrl, RGN_OR);
          DeleteObject(RgnCtrl);
        end else error_occured:=true;



//AN YPARXEI DIAFORA STO DOWNLEFT DOWNMIDDLE TIN KALUPTOUME
if GetApsInfo('downleft','SIZEY')>GetApsInfo('downmiddle','SIZEY') then
  begin
   RgnCtrl:= CreateRectRgn(GetApsInfo('middleleft','SIZEX'),GetMaxY-GetApsInfo('downleft','SIZEY'),GetMaxX,GetMaxY-GetApsInfo('middleleft','SIZEY'));
   if (RgnCtrl <> 0) and (RgnAll <> 0) then
        begin
         CombineRgn(RgnAll, RgnAll, RgnCtrl, RGN_OR);
         DeleteObject(RgnCtrl);
        end else error_occured:=true;
  end;


if RgnAll <> 0 then SetWindowRgn(WindowHandle, RgnAll, True);
end;


function ReturnWindowText(original_text:string; sizex:integer):string;
var title:string; 
    tmpx:integer;
begin
if TextWidth(original_text)>sizex then begin  {Na xoraei o titlos}
                                        tmpx:=(TextWidth(original_text)-sizex) div TextWidth('A');
                                        tmpx:=Length(original_text)-tmpx-2;
                                        if tmpx>1 then title:=Copy(original_text,1,tmpx);
                                        title:=String(title+'..');
                                       end else
                                        title:=original_text;
ReturnWindowText:=title;
end;

 
procedure Draw_a_Windowold(title1:string; active,x,y,sizex1,sizey1:integer);
var tmpx,tmpy,borderx,bordery,realsizex,realsizey:integer;
    sizeup1,sizeup2,sizeright,sizeleft,sizedown:integer;
    sizex,sizey,b:integer;  {b anti gia i}
    title,upmiddle,middleleft,uptransection,downleft,upleft:string; 
    tmp_id:integer;
begin 
if active=1 then begin {KAthorismos ton eikonon analoga me to an to parathiro einai energo}
                  upmiddle:='upmiddle'; middleleft:='middleleft';
                  uptransection:='uptransection'; downleft:='downleft'; upleft:='upleft';
                 end else
                 begin
                  upmiddle:='up2middle'; middleleft:='middle2left';
                  uptransection:='up2transection'; downleft:='down2left'; upleft:='up2left';
                 end;

//LOADING TWN DIASTASEWN TOU SKIN.. 
sxupleft:=GetApsInfo(upleft,'SIZEX');
syupleft:=GetApsInfo(upleft,'SIZEY');
sxupmiddle:=GetApsInfo(upmiddle,'SIZEX');
sxuptransection:=GetApsInfo(uptransection,'SIZEX');
sxmiddleleft:=GetApsInfo(middleleft,'SIZEX');
symiddleleft:=GetApsInfo(middleleft,'SIZEY');

//FORES POU EPANALAMVANONTAI OI EIKONES
sizeup2:=(sxbtnminimize+sxbtnmaximize+sxbtnexit) div sxupmiddle2;
sizeup2:=sizeup2+3;
{To sizex einai to megethos tou kyrios tmimatos tis mparas (upmiddle)}
sizex:=sizex1-sxupleft-sxuptransection-sxupright-sizeup2*sxupmiddle2;
sizey:=sizey1-syupright-sydownright;
{Fores pou epanalamvanontai oi eikones}
sizeup1:=sizex div sxupmiddle;
title:='';

//FIXING TOU TITLOU WSTE NA XWRAEI!..
title:=ReturnWindowText(title1,sizex);


sizeright:=sizey div symiddleright;
realsizex:=sxupleft+sizeup1*sxupmiddle+sxuptransection+sizeup2*sxupmiddle2+sxupright;
realsizey:=GetApsInfo('upright','SIZEY')+sizeright*GetApsInfo('middleright','SIZEY')+GetApsInfo('downright','SIZEY');

sizeleft:=(sizey-GetApsInfo(downleft,'SIZEY')) div GetApsInfo(middleleft,'SIZEY');
sizeleft:=sizeleft+3;
//sizeleft:=sizey div GetApsInfo(middleleft,'SIZEY');

sizedown:=(realsizex-GetApsInfo(downleft,'SIZEX')-GetApsInfo('downright','SIZEX')) div GetApsInfo('downmiddle','SIZEX');


//DRAWING TO BACKGROUND TOU PARATHIROU..                                                                                                      
DrawRectangle2(x+GetApsInfo(middleleft,'SIZEX')+2,y+GetApsInfo(upleft,'SIZEY'),x+realsizex-GetApsInfo('middleright','SIZEX'),y+realsizey-GetApsInfo('downmiddle','SIZEY'){4},Get_GUI_Color(window_background),Get_GUI_Color(window_background));


{Oi akres tou parathirou}
DrawApsXY(upleft,x,y);
borderx:=GetApsInfo(upleft,'SIZEX');

tmp_id:=Retrieve_Aps_ID(upmiddle); // Gia epitaxynsi k na min xanoume CPU cycles kathe fora gia kati pou kseroume...
for b:=1 to sizeup1 do begin
                        DrawApsXY_i(tmp_id,x+borderx+(b-1)*sxupmiddle,y);
                       end;
borderx:=borderx+sizeup1*sxupmiddle;

{O Titlos}
b:=TakeTextColor;
TextColor(Get_GUI_Color(window_title));
OutTextXY(x+GetApsInfo(upleft,'SIZEX')+1,y+(GetApsInfo(upmiddle,'SIZEY')-TextHeight('A')) div 2,title);
TextColor(b);
{Ypoloipes akres tou parathirou}
DrawApsXY_i(Retrieve_Aps_ID(uptransection),x+borderx,y); //FIX YPARXEI 1 PIXEL DIAFORA STO YPSOS
borderx:=borderx+GetApsInfo(uptransection,'SIZEX');

for b:=1 to sizeup2 do DrawApsXY('upmiddle2',x+borderx+(b-1)*sxupmiddle2,y);
borderx:=borderx+sizeup2*sxupmiddle2;

DrawApsXY('upright',x+borderx,y);
borderx:=borderx+sxupright;
bordery:=syupright;

tmp_id:=Retrieve_Aps_ID('middleright'); // Gia eptaxynsi k na min xanoume CPU cycles kathe fora gia kati pou kseroume...
for b:=1 to sizeright do DrawApsXY_i(tmp_id,x+borderx-sxmiddleright,y+bordery+(b-1)*symiddleright);
bordery:=bordery+sizeright*symiddleright;


tmp_id:=Retrieve_Aps_ID(middleleft); // Gia eptaxynsi k na min xanoume CPU cycles kathe fora gia kati pou kseroume...
for b:=1 to sizeleft do DrawApsXY_i(tmp_id,x,y+syupleft+(b-1)*symiddleleft);

DrawApsXY(downleft,x,y+realsizey-GetApsInfo(downleft,'SIZEY'));
borderx:=GetApsInfo(downleft,'SIZEX');

tmp_id:=Retrieve_Aps_ID('downmiddle'); // Gia eptaxynsi k na min xanoume CPU cycles kathe fora gia kati pou kseroume...
for b:=1 to sizedown do DrawApsXY_i(tmp_id,x+borderx+(b-1)*sxdownmiddle,y+realsizey-sydownmiddle);
borderx:=borderx+sizedown*sxdownmiddle;

DrawApsXY('downright',x+realsizex-GetApsInfo('downright','SIZEX'),y+realsizey-GetApsInfo('downright','SIZEY'));
bordery:=bordery+GetApsInfo('downright','SIZEY');

//DRAWING FIX!
DrawRectangle2(x+GetApsInfo(upleft,'SIZEX')+1,y+GetApsInfo(upmiddle,'SIZEY')+1,x+sizex1-GetApsInfo('upright','SIZEX')-2,y+GetApsInfo(upmiddle,'SIZEY')+10,Get_GUI_Color(window_background),Get_GUI_Color(window_background));
//DRAWING FIX!

{BUTTONS! Minimize , maximize , exit}
borderx:=GetApsInfo(upleft,'SIZEX')+sizeup1*GetApsInfo(upmiddle,'SIZEX')+GetApsInfo(uptransection,'SIZEX')+2;
DrawApsXY('btnminimize',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnminimize','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnminimize','SIZEX');
DrawApsXY('btnmaximize',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnmaximize','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnmaximize','SIZEX');
DrawApsXY('btnexit',x+borderx,y+(GetApsInfo('upmiddle2','SIZEY')-GetApsInfo('btnexit','SIZEY')) div 2);
borderx:=borderx+2+GetApsInfo('btnexit','SIZEX');
end;


procedure Draw_a_Window(title1:string; active,x,y,sizex1,sizey1:integer);
var sizeup1,sizeup2,sizeright,sizeleft,sizedown:integer;
    sizex,sizey,b,ax,ay,limitx,limity:integer;  {b anti gia i}
    title,upmiddle,middleleft,uptransection,downleft,upleft:string; 
    tmp_id:integer;
begin 
if active=1 then begin {KAthorismos ton eikonon analoga me to an to parathiro einai energo}
                  upmiddle:='upmiddle'; middleleft:='middleleft';
                  uptransection:='uptransection'; downleft:='downleft'; upleft:='upleft';
                 end else
                 begin
                  upmiddle:='up2middle'; middleleft:='middle2left';
                  uptransection:='up2transection'; downleft:='down2left'; upleft:='up2left';
                 end;

//LOADING TWN DIASTASEWN TOU SKIN.. 
sxupleft:=GetApsInfo(upleft,'SIZEX');
syupleft:=GetApsInfo(upleft,'SIZEY');
sxupmiddle:=GetApsInfo(upmiddle,'SIZEX');
syupmiddle:=GetApsInfo(upmiddle,'SIZEY');
sxuptransection:=GetApsInfo(uptransection,'SIZEX');
sxmiddleleft:=GetApsInfo(middleleft,'SIZEX');
symiddleleft:=GetApsInfo(middleleft,'SIZEY');

SetLineSettings(1,1,1);
DrawRectangle2(x+sxmiddleleft,y+syupmiddle,x+sizex1-sxmiddleright+1,y+sizey1-sydownmiddle,Get_GUI_Color(window_background),Get_GUI_Color(window_background));


//ARISTERA
DrawApsXY(upleft,x,y); //PANW ARISTERA GWNIA
DrawApsXY(downleft,x,y+sizey1-GetApsInfo(downleft,'SIZEY')); //KATW ARISTERA GWNIA

//ARISTERA GRAMMI
ax:=x; ay:=y+syupleft;
limity:=y+sizey1-GetApsInfo(downleft,'SIZEY');
tmp_id:=Retrieve_Aps_ID('middleleft');
while (ay<limity) do
 begin
  DrawApsXY_i(tmp_id,ax,ay);
  ay:=ay+symiddleleft;
 end;

//DEKSIA
DrawApsXY('upright',x+sizex1-sxupright,y); //PANW ARISTERA GWNIA
DrawApsXY('downright',x+sizex1-sxdownright,y+sizey1-sydownright); //KATW ARISTERA GWNIA

//ARISTERA GRAMMI
ax:=x+sizex1-sxupright; ay:=y+syupright;
limity:=y+sizey1-sydownright;
tmp_id:=Retrieve_Aps_ID('middleright');
while (ay<limity) do
 begin
  DrawApsXY_i(tmp_id,ax,ay);
  ay:=ay+symiddleright;
 end;


//KATW GRAMMI
ax:=x+sxdownleft; ay:=y+sizey1-sydownmiddle;
limitx:=x+sizex1-sxdownright;
tmp_id:=Retrieve_Aps_ID('downmiddle');
while (ax<limitx) do
 begin
  DrawApsXY_i(tmp_id,ax,ay);
  ax:=ax+sxdownmiddle;
 end;


//PANW GRAMMI 2
ax:=x+sizex1-sxupright-sxupmiddle2; ay:=y;
limitx:=ax-sxbtnexit-2-sxbtnmaximize-2-sxbtnminimize-2-sxupmiddle2;

DrawApsXY(uptransection,limitx-GetApsInfo(uptransection,'sizex')+4,ay);

//DrawRectangle2(limitx,ay,ax,ay+30,ConvertRGB(255,0,0),ConvertRGB(255,0,0));
tmp_id:=Retrieve_Aps_ID('upmiddle2');
while (ax>limitx) do
 begin
  DrawApsXY_i(tmp_id,ax,ay);
  ax:=ax-sxupmiddle2;
 end;

ax:=x+sxupleft; ay:=y;
limitx:=limitx-GetApsInfo(uptransection,'sizex')+4;
tmp_id:=Retrieve_Aps_ID(upmiddle);
while (ax<limitx) do
 begin
  DrawApsXY(upmiddle,ax,ay);
  ax:=ax+sxupmiddle;
 end;

b:=TakeTextColor;
ax:=x+sxupleft+6; ay:=y-4+(syupmiddle-TextWidth('A')) div 2;
TextColor(Get_GUI_Color(window_title));
OutTextXY(ax,ay,ReturnWindowText(title1,limitx-ax-4));
TextColor(b);

//GARBAGE NEEDS FIX
DrawLine(x+sxmiddleleft+2,y+syupmiddle+1,x+sizex1-sxmiddleright-1,y+syupmiddle+1,Get_GUI_Color(window_background));

ax:=x+sizex1-sxbtnexit-2-sxbtnmaximize-2-sxbtnminimize-2-sxupmiddle2; ay:=y+2;
DrawApsXY('btnminimize',ax+2,ay);
DrawApsXY('btnmaximize',ax+4+sxbtnminimize,ay);
DrawApsXY('btnexit',ax+6+sxbtnminimize+sxbtnmaximize,ay);
     

end;



begin
end.
