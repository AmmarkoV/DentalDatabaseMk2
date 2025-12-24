unit teeth;

interface

procedure Init_Teeth; 
procedure GUI_check_teeth;
function select_some_teeth(teeth_already_selected:string; var teethnum:integer):string;
procedure clear_teeth;


implementation 
uses windows,ammarunit,apsfiles,ammargui,string_stuff,people,settings,userlogin;
const
test=1;
Type
 tooth_area =
  Record
   doctor:string;
   work:string;
   color:integer; 
   changed_color:boolean;
   comments:string;
   technical:string;
   status:string;
  End;
var

teeth_data_aux:array[1..32]of string;
teeth_data:array[1..32,1..6]of tooth_area;
clear_area:tooth_area;
curendir:string;
//TOOTH SELECTION PARSING
teeth_sel:array[1..48] of boolean;

procedure clear_teeth;
var i,x,protect_color:integer;
    protect_color_flag:boolean;
begin 
for i:=1 to 32 do teeth_data_aux[i]:='';
for i:=1 to 32 do
   for x:=1 to 6 do
     begin
      protect_color:=teeth_data[i,x].color;
      protect_color_flag:=teeth_data[i,x].changed_color;
      teeth_data[i,x]:=clear_area;
      teeth_data[i,x].color:=protect_color;
      teeth_data[i,x].changed_color:=protect_color_flag;
     end;
end;

function hum_teeth_mem(theteeth:integer):integer;
var retres:integer;
begin
retres:=0;
if ((theteeth>=41) and (theteeth<=48)) then retres:=theteeth-16  else
if ((theteeth>=31) and (theteeth<=38)) then retres:=theteeth-14  else
if ((theteeth>=21) and (theteeth<=28)) then retres:=theteeth-12  else
if ((theteeth>=11) and (theteeth<=18)) then retres:=theteeth-10;
hum_teeth_mem:=retres;
end;

function mem_teeth_hum(theteeth:integer):integer;
var retres:integer;
begin
retres:=0;
if (theteeth<=8) then retres:=theteeth+10 else
if (theteeth<=16) then retres:=theteeth+12 else
if (theteeth<=24) then retres:=theteeth+14 else
if (theteeth<=32) then retres:=theteeth+16;
mem_teeth_hum:=retres;
end;



procedure change_teeth_color(teeth,part,newcolor:integer);
var mem,colR,colG,colBalt:integer;
begin
mem:=hum_teeth_mem(teeth);
colR:=ConvertR(newcolor);
colG:=ConvertG(newcolor);
if ConvertB(newcolor)>249 then colBalt:=249 else
                               colBalt:=ConvertB(newcolor);
colBalt:=colBalt+part;
newcolor:=ConvertRGB(colR,colG,colBalt);
ChangeApsColor('dont'+Convert2String(teeth),teeth_data[mem,part].color,newcolor);
teeth_data[mem,part].color:=newcolor;
teeth_data[mem,part].changed_color:=true;
end;

procedure default_teeth_color(teeth,part:integer);
var mem:integer;
begin
mem:=hum_teeth_mem(teeth);
ChangeApsColor('dont'+Convert2String(teeth),teeth_data[mem,part].color,ConvertRGB(255,255,249+part));
teeth_data[mem,part].color:=ConvertRGB(255,255,249+part);   // 249+ anti 255- IMPORANT SIMEIO KATA TO SAVE GIATI KSETHWRIAZOUN TA XRWMATA!
teeth_data[mem,part].changed_color:=false;
end;


procedure Save_Teeth;
var fileused:text;
    i,z:integer;
begin
assign(fileused,People_Data(0)+'Database\'+People_Data(9)+'.teeth');
{$i-}
rewrite(fileused);
{$i+}
if Ioresult=0 then
  begin
   for i:=1 to 32 do
     begin
      if teeth_data_aux[i]<>'' then writeln(fileused,'TEETH_AUX('+Convert2String(i)+','++teeth_data_aux[i]+')');
      for z:=1 to 6 do
         begin

          if ( (teeth_data[i,z].doctor<>'') or (teeth_data[i,z].work<>'') or (teeth_data[i,z].comments<>'') or (teeth_data[i,z].technical<>'') or (teeth_data[i,z].status<>'') ) then
            begin
             writeln(fileused,'TEETH_DATA('+Convert2String(i)+','+Convert2String(z)+','+teeth_data[i,z].doctor+','+teeth_data[i,z].work+','+teeth_data[i,z].comments+','+teeth_data[i,z].technical+','+teeth_data[i,z].status+')');
            end; 

           if (teeth_data[i,z].changed_color) then
             begin                                                                                                                                                                                                                            //IMPORTANT -z (PART) GIA NA MIN KSETHWRIAZOUN TA XRWMATA LOAD AFTER LOAD ;)
              writeln(fileused,'TEETH_COLOR('+Convert2String(i)+','+Convert2String(z)+','+Convert2String(ConvertR(teeth_data[i,z].color))+','+Convert2String(ConvertG(teeth_data[i,z].color))+','+Convert2String(ConvertB(teeth_data[i,z].color)-z)+')');
             end; 
         end; 
     end;  //TEETH AUXILARY DATA
  end;
close(fileused);
end;

procedure Load_Teeth;
var fileused:text;
    bufstr:string;
    i,z:integer;  
begin
for i:=1 to 32 do
    for z:=1 to 6 do
       if (teeth_data[i,z].changed_color) then  default_teeth_color(mem_teeth_hum(i),z);
clear_teeth;
assign(fileused,People_Data(0)+'Database\'+People_Data(9)+'.teeth');
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then
  begin 
   while (not (eof(fileused))) do
    begin
     readln(fileused,bufstr);
     seperate_words(bufstr);
     if Upcase(get_memory(1))='TEETH_AUX' then
       begin
         if ((get_memory_int(2)>=1) or (get_memory_int(2)<=32)) then teeth_data_aux[get_memory_int(2)]:=get_memory(3) else
                                                                     Write_2_Log('Invalid TEETH_AUX '+get_memory(2));
       end  else
     if Upcase(get_memory(1))='TEETH_DATA' then
       begin 
         if ((get_memory_int(2)<1) or (get_memory_int(2)>32)) then Write_2_Log('Invalid TEETH_DATA '+get_memory(2)) else
         if ((get_memory_int(3)<1) or (get_memory_int(3)>6)) then Write_2_Log('Invalid TEETH_DATA part '+get_memory(3)) else
         begin
          teeth_data[get_memory_int(2),get_memory_int(3)].doctor:=get_memory(4);
          teeth_data[get_memory_int(2),get_memory_int(3)].work:=get_memory(5);
          teeth_data[get_memory_int(2),get_memory_int(3)].comments:=get_memory(6);
          teeth_data[get_memory_int(2),get_memory_int(3)].technical:=get_memory(7);
          teeth_data[get_memory_int(2),get_memory_int(3)].status:=get_memory(8);
         end;
       end else
     if Upcase(get_memory(1))='TEETH_COLOR' then
       begin
        if ((get_memory_int(2)<1) or (get_memory_int(2)>32)) then Write_2_Log('Invalid TEETH_COLOR '+get_memory(2)) else
        if ((get_memory_int(3)<1) or (get_memory_int(3)>6)) then Write_2_Log('Invalid TEETH_COLOR part '+get_memory(3)) else
         change_teeth_color(mem_teeth_hum(get_memory_int(2)),get_memory_int(3),ConvertRGB(get_memory_int(4),get_memory_int(5),get_memory_int(6)));
       end; 
    end; 
   close(fileused);
  end;
end;

procedure Init_Teeth;
var xl,yl,i,z,maxy:integer;
    aps2load,aps2load1:string;
begin 
clear_area.doctor:='';
clear_area.work:='';
clear_area.color:=0;
clear_area.comments:='';
clear_area.technical:='';
clear_area.status:='';
//PREPARE CLEAR_AREA
GetDir(0,curendir); 
if curendir[Length(curendir)]<>'\' then curendir:=curendir+'\';
//CURRENT DIR SET
chdir(curendir+'Teeth\');
xl:=GetLoadingX;
yl:=GetLoadingY;
maxy:=0;
for i:=1 to 8 do
 begin
   aps2load:='dont1'+Convert2String(i);
   loadaps(aps2load);
   xl:=xl+GetApsInfo(aps2load,'sizex')+2;
   if GetApsInfo(aps2load,'sizey')>maxy then maxy:=GetApsInfo(aps2load,'sizey');
   if xl>1680 then begin
                     xl:=1;
                     yl:=yl+maxy+1;
                   end;
   SetLoadingXY(xl,yl);

   aps2load1:=aps2load;
   aps2load:='dont2'+Convert2String(i);
   DuplicateAps(aps2load1,aps2load,GetLoadingX,GetLoadingY);  // aps2load DIPLASIASMOS
   xl:=xl+GetApsInfo(aps2load,'sizex')+2;
   if GetApsInfo(aps2load,'sizey')>maxy then maxy:=GetApsInfo(aps2load,'sizey');
   if xl>1680 then begin
                     xl:=1;
                     yl:=yl+maxy+1;
                   end;
   SetLoadingXY(xl,yl);
   InvertAps(aps2load,'HORIZONTALY'); //INVERTAPS
 end;
for i:=1 to 8 do
 begin
   aps2load:='dont4'+Convert2String(i);
   loadaps(aps2load);
   xl:=xl+GetApsInfo(aps2load,'sizex')+2;
   if GetApsInfo(aps2load,'sizey')>maxy then maxy:=GetApsInfo(aps2load,'sizey');
   if xl>1680 then begin
                     xl:=1;
                     yl:=yl+maxy+1;
                   end;
   SetLoadingXY(xl,yl);

   aps2load1:=aps2load;
   aps2load:='dont3'+Convert2String(i);
   DuplicateAps(aps2load1,aps2load,GetLoadingX,GetLoadingY);  //aps2load DIPLASIASMOS
   xl:=xl+GetApsInfo(aps2load,'sizex')+2;
   if GetApsInfo(aps2load,'sizey')>maxy then maxy:=GetApsInfo(aps2load,'sizey');
   if xl>1680 then begin
                     xl:=1;
                     yl:=yl+maxy+1;
                   end;
   SetLoadingXY(xl,yl);
   InvertAps(aps2load,'HORIZONTALY'); //INVERTAPS 
 end;

  { DuplicateAps(aps2load,aps2load,GetLoadingX,GetLoadingY);  //DIPLASIASMOS
   yl:=GetLoadingY;
   xl:=xl+GetApsInfo(aps2load,'sizex')+2;
   if GetApsInfo(aps2load,'sizey')>maxy then maxy:=GetApsInfo(aps2load,'sizey');
   if xl>1680 then begin
                     xl:=1;
                     yl:=yl+maxy+1;
                   end;
   SetLoadingXY(xl,yl);
   InvertAps(aps2load,'HORIZONTALY'); //INVERTAPS}


 SetLoadingXY(1,GetLoadingY+maxy);
 loadaps('dontiatable');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('dontiatable','sizex'),GetLoadingY); 
 loadaps('arrowdown');
 DuplicateAps('arrowdown','arrowup',GetLoadingX+2+GetApsInfo('arrowdown','sizex'),GetLoadingY);
 InvertAps('arrowup','VERTICALY');
 SetLoadingXY(GetLoadingX+2*GetApsInfo('arrowdown','sizex'),yl+maxy+1);
 loadaps('eth');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('eth','sizex'),GetLoadingY);
 loadaps('riza');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('riza','sizex'),GetLoadingY);
 loadaps('x');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('x','sizex'),GetLoadingY);
 loadaps('mo');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('mo','sizex'),GetLoadingY);
 loadaps('oo');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('oo','sizex'),GetLoadingY);
 loadaps('ra');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('ra','sizex'),GetLoadingY); 
 loadaps('vida');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('vida','sizex'),GetLoadingY);
 loadaps('sealant');
 SetLoadingXY(GetLoadingX+2+GetApsInfo('sealant','sizex'),GetLoadingY);


for i:=1 to 32 do
 for z:=1 to 6 do
 begin
   teeth_data[i,z].color:=ConvertRGB(215,0,z-1);
  end;

for i:=11 to 18 do
 for z:=1 to 6 do
    default_teeth_color(i,z);
   //change_teeth_color(i,z,ConvertRGB(255,255,255-z));
for i:=21 to 28 do
 for z:=1 to 6 do
   default_teeth_color(i,z);
   //change_teeth_color(i,z,ConvertRGB(255,255,255-z));
for i:=31 to 38 do
 for z:=1 to 6 do
   default_teeth_color(i,z);
   //change_teeth_color(i,z,ConvertRGB(255,255,255-z));
for i:=41 to 48 do
 for z:=1 to 6 do
    default_teeth_color(i,z);
   //change_teeth_color(i,z,ConvertRGB(255,255,255-z));
 { for xl:=1 to 1680 do
   for yl:=1 to 1050 do
    Putpixel(xl,yl,GetApsPixelColor(xl,yl));
 readkey;  }
 
chdir(curendir);
end;





procedure teeth_selection_parse(teeth_input:string);
var  last_tooth,this_tooth,i,z,params:integer;
     bufstr:string;
begin
for i:=1 to 48 do teeth_sel[i]:=false;
if Length(teeth_input)>0 then
begin //TEETH INPUT NOT EMPTY
bufstr:=teeth_input;
z:=Length(teeth_input);
while teeth_input[z]=' ' do z:=z-1; //Vrikame pou teleiwnei i leksi..
teeth_input:='';
for i:=1 to z do teeth_input:=teeth_input+bufstr[i]; //REMOVE SPACES FROM END..

set_mpalanter(' ');
params:=seperate_words(teeth_input);
set_mpalanter(',');
if params>0 then begin
                   i:=0;
                   last_tooth:=0;
                   this_tooth:=0;
                   while (i<params) do
                     begin
                      i:=i+1;
                      if Equal(Greeklish(get_memory(i)),'ews') then begin
                                                                     if i+1>params then MessageBox (0, 'Υπάρχει `έως` σε μια έκφραση το οποίο δεν τελειώνει!' , ' ', 0 + MB_ICONEXCLAMATION) else
                                                                       begin
                                                                         Val(get_memory(i+1),this_tooth,z);
                                                                         if ((last_tooth<11) or (last_tooth>48)) then MessageBox (0, 'Δεν υπάρχει δόντι για να ξεκινήσει η έκφραση `έως`' , ' ', 0 + MB_ICONASTERISK) else
                                                                         if ((this_tooth<11) or (this_tooth>48)) then MessageBox (0, pchar('Η έκφρασή '+Convert2String(last_tooth)+' έως '+Convert2String(this_tooth)+' δεν είναι σωστή '), ' ', 0 + MB_ICONASTERISK) else
                                                                           begin //OLA OK 
                                                                            if this_tooth<=last_tooth then begin //REVERSE FILL
                                                                                                              for z:=this_tooth to last_tooth do teeth_sel[z]:=true;
                                                                                                            end else
                                                                                                          begin 
                                                                                                            //MessageBox (0, pchar('FILL '+Convert2String(last_tooth)+' έως '+Convert2String(this_tooth)) , ' ', 0);
                                                                                                            for z:=last_tooth to this_tooth do teeth_sel[z]:=true;
                                                                                                          end;  
                                                                           end; 
                                                                       end;
                                                                    end else
                      if Equal(Greeklish(get_memory(i)),'apo') then begin
                                                                      // DEN XREIAZETAI TO APO..
                                                                    end else
                                                                    begin
                                                                      Val(get_memory(i),this_tooth,z);
                                                                      if ((this_tooth<11) or (this_tooth>48)) then begin
                                                                                                                    MessageBox (0,pchar('Η έκφρασή '+get_memory(i)+' δεν είναι σωστή '), ' ', 0 + MB_ICONASTERISK);
                                                                                                                    this_tooth:=0;
                                                                                                                   end else
                                                                                                                   begin
                                                                                                                    teeth_sel[this_tooth]:=true;
                                                                                                                   end; 
                                                                    end;
                      last_tooth:=this_tooth;
                     end;
                 end;
end; //TEETH INPUT NOT EMPTY
end;


function teeth_selection_parse_to_string(var number_teeth:integer):string;
var i,z:integer;
    retres:string;
begin  
retres:='';
number_teeth:=0;
i:=10;
while i<48 do
  begin 
   i:=i+1;
   if (teeth_sel[i]) then begin 
                           //MessageBox (0, pchar('ENA DONTI FAINETAI KALO.. '+Convert2String(i)) , ' ', 0);
                           if ((i+1<=48) and (teeth_sel[i+1])) then
                                                    begin //PAME GIA SEIRA..
                                                     z:=i;
                                                     while ((z<=48)and (teeth_sel[z]))  do
                                                      begin 
                                                        z:=z+1;
                                                      end; 
                                                     number_teeth:=number_teeth+z-i;
                                                     //MessageBox (0, pchar('POLLA DONTIA '+Convert2String(i)+' έως '+Convert2String(z-1)) , ' ', 0);
                                                     retres:=retres+Convert2String(i)+' έως '+Convert2String(z-1)+' ';
                                                     i:=z+1;
                                                    end else
                                                    begin //ENA DONTI MONAXO TOU
                                                     //MessageBox (0, pchar('ENA DONTI MONAXO TOU '+Convert2String(i)) , ' ', 0);
                                                     number_teeth:=number_teeth+1;
                                                     retres:=retres+Convert2String(i)+' ';
                                                    end;
                          end;
  end;
teeth_selection_parse_to_string:=retres;
end;


function select_some_teeth(teeth_already_selected:string; var teethnum:integer):string;
var retres,bufstr,check:string;
    tableend,i,wndx1,wndx2,wndy1,wndy2:integer; 

begin 
teeth_selection_parse(teeth_already_selected);
retres:='';
wndx1:=((GetMaxX-GetApsInfo('dontiatable','sizex')) div 2)-10;
wndx2:=((GetMaxX+GetApsInfo('dontiatable','sizex')) div 2)+10;
wndy1:=200;
wndy2:=wndy1+GetApsInfo('dontiatable','sizey')+120;


flush_gui_memory(0);
include_object('window1','window','Επιλογή δοντιών.. ','no','','',wndx1,wndy1,wndx2,wndy2);
draw_all;
delete_object('window1','name');
DrawAPSXY('dontiatable',wndx1+10,wndy1+50);
tableend:=wndx1+10+GetApsInfo('dontiatable','sizex');

include_object('check11-18','checkbox','1','no','','',wndx1+13+(8-8)*(44),wndy1+50+50,0,0);
include_object('cmnt11-18','comment','Επιλογή 11 έως 18','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('checkallup','checkbox','1','no','','',-1,wndy1+50+50,-1,0);
include_object('cmntallup','comment','Επιλογή όλη η άνω γνάθος','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('checkall21-28','checkbox','1','no','','',wndx2-130,wndy1+50+50,-1,0);
include_object('cmntall21-28','comment','Επιλογή 21 έως 28','no','','',X2(last_object)+2,Y1(last_object),0,0);

include_object('check41-48','checkbox','1','no','','',wndx1+13+(8-8)*(44),wndy1+140+184,0,0);
include_object('cmnt41-48','comment','Επιλογή 41 έως 48','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('checkalldown','checkbox','1','no','','',-1,Y1(last_object),-1,0);
include_object('cmntalldown','comment','Επιλογή όλη η κάτω γνάθος','no','','',X2(last_object)+2,Y1(last_object),0,0);
include_object('checkall31-38','checkbox','1','no','','',wndx2-130,Y1(last_object),-1,0);
include_object('cmntall31-38','comment','Επιλογή 31 έως 38','no','','',X2(last_object)+2,Y1(last_object),0,0);

for i:=8 downto 1 do begin
                      bufstr:='dont'+Convert2String(10+i);
                      DrawAPSXY(bufstr,wndx1+13+(8-i)*(44),wndy1+50+93);
                      if (teeth_sel[10+i]) then check:='3' else check:='1';
                      include_object('check('+Convert2String(10+i)+')','checkbox',check,'no','','',wndx1+13+(8-i)*(44),wndy1+50+93,0,0);
                      include_object('cmnt'+Convert2String(10+i)+')','comment',Convert2String(10+i),'no','','',X2(last_object)+2,Y1(last_object),0,0);
                     end;
for i:=8 downto 1 do begin
                      bufstr:='dont'+Convert2String(20+i);
                      DrawAPSXY(bufstr,tableend+3-(9-i)*(44),wndy1+50+93);
                      if (teeth_sel[20+i]) then check:='3' else check:='1';
                      include_object('check('+Convert2String(20+i)+')','checkbox',check,'no','','',tableend+3-(9-i)*(44),wndy1+50+93,0,0);
                      include_object('cmnt'+Convert2String(20+i)+')','comment',Convert2String(20+i),'no','','',X2(last_object)+2,Y1(last_object),0,0);
                     end; 
for i:=8 downto 1 do begin
                      bufstr:='dont'+Convert2String(40+i);
                      DrawAPSXY(bufstr,wndx1+13+(8-i)*(44),wndy1+50+184);
                      if (teeth_sel[40+i]) then check:='3' else check:='1';
                      include_object('check('+Convert2String(40+i)+')','checkbox',check,'no','','',wndx1+13+(8-i)*(44),wndy1+50+184,0,0);
                      include_object('cmnt'+Convert2String(40+i)+')','comment',Convert2String(40+i),'no','','',X2(last_object)+2,Y1(last_object),0,0);
                     end;
for i:=8 downto 1 do begin
                      bufstr:='dont'+Convert2String(30+i);
                      DrawAPSXY(bufstr,tableend+3-(9-i)*(44),wndy1+50+184);
                      if (teeth_sel[30+i]) then check:='3' else check:='1';
                      include_object('check('+Convert2String(30+i)+')','checkbox',check,'no','','',tableend+3-(9-i)*(44),wndy1+50+184,0,0);
                      include_object('cmnt'+Convert2String(30+i)+')','comment',Convert2String(30+i),'no','','',X2(last_object)+2,Y1(last_object),0,0);
                     end; 

include_object('ok','buttonc','Επιλογή','no','','',wndx1-40+(wndx2-wndx1) div 2,wndy2-40,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
set_gui_color(ConvertRGB(0,0,0),'comment');
draw_all; 
repeat
interact; 
if GUI_Exit then begin
                                     retres:=teeth_already_selected;
                                    end else
if get_object_data('ok')='4' then begin
                                    for i:=11 to 18 do
                                       begin 
                                         if get_object_data('check11-18')='3' then teeth_sel[i]:=true else
                                         if get_object_data('checkallup')='3' then teeth_sel[i]:=true else
                                         if get_object_data('check('+Convert2String(i)+')')='3' then teeth_sel[i]:=true else
                                                                                                     teeth_sel[i]:=false;
                                       end;
                                    for i:=21 to 28 do
                                       begin
                                         if get_object_data('check21-28')='3' then teeth_sel[i]:=true else
                                         if get_object_data('checkallup')='3' then teeth_sel[i]:=true else
                                         if get_object_data('check('+Convert2String(i)+')')='3' then teeth_sel[i]:=true else
                                                                                                     teeth_sel[i]:=false;
                                       end;
                                    for i:=31 to 38 do
                                       begin
                                         if get_object_data('check31-38')='3' then teeth_sel[i]:=true else
                                         if get_object_data('checkalldown')='3' then teeth_sel[i]:=true else
                                         if get_object_data('check('+Convert2String(i)+')')='3' then teeth_sel[i]:=true else
                                                                                                     teeth_sel[i]:=false;
                                       end;
                                    for i:=41 to 48 do
                                       begin
                                         if get_object_data('check41-48')='3' then teeth_sel[i]:=true else
                                         if get_object_data('checkalldown')='3' then teeth_sel[i]:=true else
                                         if get_object_data('check('+Convert2String(i)+')')='3' then teeth_sel[i]:=true else
                                                                                                     teeth_sel[i]:=false;
                                       end; 
                                    retres:=teeth_selection_parse_to_string(teethnum);
                                    break;
                                  end; 
until GUI_Exit;


select_some_teeth:=retres;
end;


procedure Save_Teeth_part(mem_teeth,which_part:integer);
begin
teeth_data[mem_teeth,which_part].doctor:=get_object_data('dentist');
teeth_data[mem_teeth,which_part].status:=get_object_data('status');
teeth_data[mem_teeth,which_part].comments:=get_object_data('comments');
teeth_data[mem_teeth,which_part].technical:=get_object_data('technical');
teeth_data[mem_teeth,which_part].work:=get_object_data('work');
teeth_data_aux[mem_teeth]:=get_object_data('sign');

end;



procedure GUI_Open_Teeth_part(which_teeth,which_part:integer);
var userchosen,title,msg,lastobj:string;
    borders:array[1..4] of integer;   
    startx,startx2,lasty,mem_teeth,i:integer;
label start_open_teeth_part;
begin
mem_teeth:=hum_teeth_mem(which_teeth);
borders[1]:=((GetMaxX-GetApsInfo('dontiatable','sizex')) div 2)+30;
borders[2]:=270;
borders[3]:=((GetMaxX+GetApsInfo('dontiatable','sizex')) div 2)-30;
borders[4]:=borders[2]+70+GetAPSInfo('tooth_map','sizey')+20;

start_open_teeth_part:
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');  

include_object('window1','window','Επισκόπηση δοντιού '+Convert2String(which_teeth)+' περιοχή '+Convert2String(which_part),'no','','',borders[1],borders[2],borders[3],borders[4]);
draw_all;
delete_object('window1','name');
DrawApsXY('tooth_map',borders[1]+12,borders[2]+50);
//include_object('toothico','icon','tooth_map,tooth_map','no','','',borders[1]+12,borders[2]+50,0,0);

startx:=borders[1]+12+GetApsInfo('tooth_map','sizex')+5;
lasty:=borders[2]+50;
startx2:=startx+TextWidth('Σημειώσεις :  ');
include_object('partcomm','comment','Τμήμα : ','no','','',startx,lasty,0,0);
include_object('part','textbox',Convert2String(which_part),'no','','',startx2,Y1(last_object),startx2+40,0);
include_object('dentistcomm','comment','Οδοντιατρός : ','no','','',startx,Y2(last_object)+5,0,0);
include_object('dentist','textbox',teeth_data[mem_teeth,which_part].doctor,'no','','',startx2,Y1(last_object),X2(last_object)+100,0);
include_object('me_dentist','buttonc','Εγώ','no','','',X2(last_object)+5,Y1(last_object),startx2+100,0);
include_object('pick_dentist','buttonc','’τομα','no','','',X2(last_object)+5,Y1(last_object),startx2+100,0);

include_object('statuscomm','comment','Κατάσταση : ','no','','',startx,Y2(last_object)+5,0,0);
include_object('status','textbox',teeth_data[mem_teeth,which_part].status,'no','','',startx2,Y1(last_object),borders[3]-15,0);
include_object('commcomm','comment','Σημειώσεις : ','no','','',startx,Y2(last_object)+5,0,0);
include_object('comments','textbox',teeth_data[mem_teeth,which_part].comments,'no','','',startx2,Y1(last_object),borders[3]-15,0);
include_object('techcomm','comment','Μετρήσεις : ','no','','',startx,Y2(last_object)+5,0,0);
include_object('technical','textbox',teeth_data[mem_teeth,which_part].technical,'no','','',startx2,Y1(last_object),borders[3]-15,0);
include_object('workcomm','comment','Εργασίες : ','no','','',startx,Y2(last_object)+5,0,0);
include_object('work','textbox',teeth_data[mem_teeth,which_part].work,'no','','',startx2,Y1(last_object),borders[3]-15,0);
include_object('colorcomm','comment','Χρώμα : ','no','','',startx,Y2(last_object)+5,0,0);
DrawRectangle2(startx2,Y1(last_object),borders[3]-15,Y1(last_object)+15,teeth_data[mem_teeth,which_part].color,teeth_data[mem_teeth,which_part].color);
include_object('signcomm','comment','Σήμανση : ','no','','',startx,Y1(last_object)+20,0,0);
include_object('sign','textbox',teeth_data_aux[mem_teeth],'no','','',startx2,Y1(last_object),startx2+100,0);
include_object('pick_sign','buttonc','Επιλογή Σήμανσης','no','','',X2(last_object)+5,Y1(last_object),startx2+100,0);

include_object('save','buttonc','Αποθήκευση','no','','',startx2-20,borders[4]-30,0,0);
include_object('notes','buttonc','Σημειώσεις','no','','',X2(last_object)+5,borders[4]-30,0,0);
include_object('clear','buttonc','Διαγραφή αλλαγών','no','','',X2(last_object)+5,borders[4]-30,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+5,borders[4]-30,0,0);


draw_all;

repeat
interact;
if get_object_data('notes')='4' then begin
                                     set_button('notes',0);
                                     Deflash_AmmarGUI('teeth_part_tmp');
                                     clrscreen;
                                     RunEXEWait(get_external_editor+' "'+curendir+'Database\'+People_Data(9)+'.nfo"',false);
                                     clrscreen;
                                     MessageBox (0, 'Πατήστε ΟΚ όταν τελείωσετε με την επεξεργασία του κειμένου..' , ' ', 0); 
                                     include_object('window1','window','Επισκόπηση δοντιού '+Convert2String(which_teeth)+' περιοχή '+Convert2String(which_part),'no','','',borders[1],borders[2],borders[3],borders[4]);
                                     draw_object_by_name('window1');
                                     delete_object('window1','name'); 
                                     Flash_AmmarGUI('teeth_part_tmp');  
                                     DrawApsXY('tooth_map',borders[1]+12,borders[2]+50);
                                     draw_all;
                                    end else
if get_object_data('save')='4' then begin
                                     set_button('save',0);
                                     DrawApsXY('greenbtn',X1('save')-GetApsInfo('greenbtn','sizex')-5,Y1('save')+3);
                                     Save_Teeth_part(mem_teeth,which_part);
                                    end else
if get_object_data('me_dentist')='4' then begin
                                     set_button('me_dentist',0);
                                     set_object_data('dentist','value',Get_Current_User,0);
                                     draw_object_by_name('dentist');
                                    end else     
if get_object_data('pick_dentist')='4' then
                                    begin
                                     set_button('pick_dentist',0);
                                     Deflash_AmmarGUI('teeth_part_tmp');
                                     userchosen:=GUI_Select_User;
                                     include_object('window1','window','Επισκόπηση δοντιού '+Convert2String(which_teeth)+' περιοχή '+Convert2String(which_part),'no','','',borders[1],borders[2],borders[3],borders[4]);
                                     draw_object_by_name('window1');
                                     delete_object('window1','name'); 
                                     Flash_AmmarGUI('teeth_part_tmp');
                                     if userchosen<>'' then
                                     set_object_data('dentist','value',userchosen,0); 
                                     set_gui_color(ConvertRGB(0,0,0),'comment');  
                                     DrawApsXY('tooth_map',borders[1]+12,borders[2]+50);
                                     draw_all;
                                    end else  
if get_object_data('clear')='4' then begin
                                     set_button('clear',0); 
                                     i:=MessageBox (0, pchar('Είστε σίγουροι πως θέλετε να διαγράψετε τις πληροφορίες που είναι αποθηκευμένες για την περιοχή '+Convert2String(which_part)+' του δόντιου '+Convert2String(which_teeth)+' ?') , 'Διαγραφή ?', 0 + MB_YESNO + MB_ICONQUESTION);
                                      if i=IDYES then
                                        begin
                                         set_object_data('dentist','value','',0);
                                         set_object_data('status','value','',0);
                                         set_object_data('comments','value','',0);
                                         set_object_data('technical','value','',0);
                                         set_object_data('work','value','',0);
                                         set_object_data('sign','value','',0);
                                         draw_all;
                                       end;
                                    end;
until GUI_Exit;
end;







function Dontia_Aux_APS(name,location:string):string;
var retres:string;
begin
retres:='';
name:=Upcase(name);
location:=Upcase(location);
if name='VIDA' then begin
                        retres:='vida';
                       end else
if name='SEALANT' then begin
                        retres:='sealant';
                       end else
if name='X' then begin
                     retres:='x';
                    end else
if name='O.O.' then begin
                     retres:='oo';
                    end else
if name='M.O.' then begin
                     retres:='mo';
                    end else
if name='RIZ_APOKSISI' then begin
                             retres:='ra';
                            end else
if name='RIZA' then begin
                     retres:='riza';
                    end else
if name='ENDODONTIKI_THERAPEIA' then begin
                                      retres:='eth';
                                     end else
if name='ARROW' then begin
                      if location='UP' then retres:='arrowdown' else
                      if location='DOWN' then retres:='arrowup';
                     end;
Dontia_Aux_APS:=retres;
end;



function Teeth_Part_Selected(thetooth,thepart:integer):boolean;
var retres:boolean;
begin
retres:=false;
if ((thetooth>=21) and (thetooth<=28)) then begin
                                            if thepart=3 then thepart:=4 else
                                            if thepart=4 then thepart:=3;
                                           end;
if ((thetooth>=31) and (thetooth<=38)) then begin
                                            if thepart=3 then thepart:=4 else
                                            if thepart=4 then thepart:=3;
                                           end;

case thepart of
1: begin
    if get_object_data('area(rz')='3'  then retres:=true;
   end;
2: begin
    if get_object_data('area(5y')='3' then retres:=true;
   end;
3: begin
    if get_object_data('area(2e')='3' then retres:=true;
   end;
4: begin
    if get_object_data('area(2a')='3'  then retres:=true;
   end;
5: begin
    if get_object_data('area(1')='3' then retres:=true;
   end;
6: begin
    if get_object_data('area(5p')='3' then retres:=true;
   end;
   end;
Teeth_Part_Selected:=retres;
end;

function No_Teeth_Part_Selected:boolean;
var retres:boolean;
    count:byte;
begin
count:=0;
if get_object_data('area(rz')='3' then count:=count+1;
if get_object_data('area(5y')='3' then count:=count+1;
if get_object_data('area(2e')='3' then count:=count+1;
if get_object_data('area(2a')='3' then count:=count+1;
if get_object_data('area(1')='3' then  count:=count+1;
if get_object_data('area(5p')='3' then count:=count+1;
if count=0 then retres:=true else
                retres:=false;
No_Teeth_Part_Selected:=retres;
end;

function No_Teeth_Info_Found(the_mem_teeth,the_part:integer):boolean;
var retres:boolean;
    count:byte;
begin
count:=0;
the_mem_teeth:=hum_teeth_mem(the_mem_teeth);
if teeth_data[the_mem_teeth,the_part].doctor<>'' then count:=count+1;
if teeth_data[the_mem_teeth,the_part].work<>'' then count:=count+1;
if teeth_data[the_mem_teeth,the_part].comments<>'' then count:=count+1;
if teeth_data[the_mem_teeth,the_part].technical<>'' then count:=count+1;
if teeth_data[the_mem_teeth,the_part].status<>'' then count:=count+1;
if count=0 then retres:=true else
                retres:=false;
No_Teeth_Info_Found:=retres;
end;


procedure draw_hud_teeth_layers(which_teeth,ax,ay:integer);
begin
//6
DrawRectangle2(ax+69,ay+10,ax+111,ay+52,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),6].color);
if not (No_Teeth_Info_Found(which_teeth,6)) then DrawApsXY('tag',ax+69,ay+10);
//DrawApsXY('magnify',ax+79,ay+20);
//5
DrawRectangle2(ax+69,ay+67,ax+111,ay+100,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),5].color);
if not (No_Teeth_Info_Found(which_teeth,5)) then DrawApsXY('tag',ax+69,ay+67);
//DrawApsXY('magnify',ax+79,ay+77);
//4
DrawRectangle2(ax+33,ay+26,ax+62,ay+126,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),4].color);
if not (No_Teeth_Info_Found(which_teeth,4)) then DrawApsXY('tag',ax+33,ay+26);
//DrawApsXY('magnify',ax+33,ay+36);
//3
DrawRectangle2(ax+119,ay+26,ax+151,ay+126,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),3].color);
if not (No_Teeth_Info_Found(which_teeth,3)) then DrawApsXY('tag',ax+119,ay+26);
//DrawApsXY('magnify',ax+130,ay+36);
//2
DrawRectangle2(ax+69,ay+110,ax+111,ay+162,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),2].color);
if not (No_Teeth_Info_Found(which_teeth,2)) then DrawApsXY('tag',ax+69,ay+110);
//DrawApsXY('magnify',ax+79,ay+120);
//1
DrawRectangle2(ax+69,ay+192,ax+111,ay+222,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),1].color);
if not (No_Teeth_Info_Found(which_teeth,1)) then DrawApsXY('tag',ax+69,ay+192);
end;





procedure GUI_Open_Teeth(which_teeth:integer);
var user2send,title,msg,lastobj:string;
    borders:array[1..4] of integer; 
    butlabels:array[1..2,1..10]of string;
    butcolors:array[1..10]of integer;

    startx,bigx,lasty,spacey,i,z,ax,ay:integer;
label start_open_teeth;
begin
user2send:='';
title:='';
msg:=''; 
borders[1]:=((GetMaxX-GetApsInfo('dontiatable','sizex')) div 2)+30;
borders[2]:=270;
borders[3]:=((GetMaxX+GetApsInfo('dontiatable','sizex')) div 2)-30;
borders[4]:=borders[2]+70+GetAPSInfo('tooth_map','sizey')+20;
startx:=borders[1]+GetAPSInfo('tooth_map','sizex')+20;
spacey:=5;
butlabels[1,1]:='butRA';
butlabels[2,1]:='Ριζική Απόξεση';
butcolors[1]:=ConvertRGB(255,255,255);
butlabels[1,2]:='butemfytevma';
butlabels[2,2]:='Εμφύτευμα';
butcolors[2]:=ConvertRGB(255,255,255);
butlabels[1,3]:='butgefyra';
butlabels[2,3]:='Γέφυρα';
butcolors[3]:=ConvertRGB(255,255,255);
butlabels[1,4]:='buteksagogi';
butlabels[2,4]:='Εξαγωγή';
butcolors[4]:=ConvertRGB(255,255,255);
butlabels[1,5]:='butthiki';
butlabels[2,5]:='Θήκη - Στεφάνη';
butcolors[5]:=ConvertRGB(255,255,255);
butlabels[1,6]:='butsealant';
butlabels[2,6]:='Sealant';
butcolors[6]:=ConvertRGB(255,255,255);
butlabels[1,7]:='teridon';
butlabels[2,7]:='Τερηδόνα'; //red
butcolors[7]:=ConvertRGB(255,0,0);
butlabels[1,8]:='amalgam';
butlabels[2,8]:='Έμφραξη αμαλγάματος';//blu
butcolors[8]:=ConvertRGB(0,0,240);
butlabels[1,9]:='rytini';
butlabels[2,9]:='Έμφραξη ρητίνης';//green
butcolors[9]:=ConvertRGB(0,255,0);
butlabels[1,10]:='clear';
butlabels[2,10]:='Καθαρισμός';
butcolors[10]:=ConvertRGB(255,255,255);


start_open_teeth:
lastobj:=''; 
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');  

include_object('window1','window','Επισκόπηση δοντιού '+Convert2String(which_teeth),'no','','',borders[1],borders[2],borders[3],borders[4]);
draw_all;
delete_object('window1','name');

include_object('epilogescom','comment','Σημειώσεις :','no','','',borders[1]+12+10,borders[2]+50-TextHeight('A')-5,0,0);
DrawApsXY('tooth_map',borders[1]+12,borders[2]+50);
include_object('area(2a','checkbox','1','no','','',borders[1]+10+43,borders[2]+50+62,0,0);
include_object('area(5p','checkbox','1','no','','',borders[1]+10+84,borders[2]+50+10,0,0);
include_object('area(5y','checkbox','1','no','','',borders[1]+10+84,borders[2]+50+99,0,0);
include_object('area(1','checkbox','1','no','','',borders[1]+10+84,borders[2]+50+62,0,0);
include_object('area(2e','checkbox','1','no','','',borders[1]+10+120,borders[2]+50+62,0,0);
include_object('area(rz','checkbox','1','no','','',borders[1]+10+84,borders[2]+50+140,0,0);

include_object('clear_selections','buttonc','Καθαρισμός Επιλογών','no','','',X1('area(2a')-20,Y2('area(rz')+40,0,0);


include_object('leptomcom','comment','’νοιγμα λεπτομερειών :','no','','',borders[3]-GetApsInfo('tooth_map_2','sizex')-12,borders[2]+50-TextHeight('A')-5,0,0);
ax:=borders[3]-GetApsInfo('tooth_map_2','sizex')-12;
ay:=borders[2]+50;
DrawApsXY('tooth_map_2',ax,ay);


draw_hud_teeth_layers(which_teeth,ax,ay);
//6
include_object('zoom(6','layer','1','','','MAGNIFY',ax+69,ay+10,ax+111,ay+52);
//DrawRectangle2(ax+69,ay+10,ax+111,ay+52,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),6].color);
//DrawApsXY('magnify',ax+79,ay+20);
//5
include_object('zoom(5','layer','1','','','MAGNIFY',ax+69,ay+67,ax+119,ay+100);
//DrawRectangle2(ax+69,ay+67,ax+111,ay+100,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),5].color);
//DrawApsXY('magnify',ax+79,ay+77);
//4
include_object('zoom(4','layer','1','','','MAGNIFY',ax+33,ay+26,ax+62,ay+126);
//DrawRectangle2(ax+33,ay+26,ax+62,ay+126,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),4].color);
//DrawApsXY('magnify',ax+33,ay+36);
//3
include_object('zoom(3','layer','1','','','MAGNIFY',ax+128,ay+26,ax+151,ay+126);
//DrawRectangle2(ax+119,ay+26,ax+151,ay+126,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),3].color);
//DrawApsXY('magnify',ax+130,ay+36);
//2
include_object('zoom(2','layer','1','','','MAGNIFY',ax+69,ay+110,ax+111,ay+162);
//DrawRectangle2(ax+69,ay+110,ax+111,ay+162,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),2].color);
//DrawApsXY('magnify',ax+79,ay+120);
//1
include_object('zoom(1','layer','1','','','MAGNIFY',ax+69,ay+192,ax+111,ay+222);
//DrawRectangle2(ax+69,ay+192,ax+111,ay+222,ConvertRGB(0,0,255),teeth_data[hum_teeth_mem(which_teeth),1].color);
//DrawApsXY('magnify',ax+79,ay+200);

bigx:=0;
lasty:=0;
include_object(butlabels[1,1],'buttonc',butlabels[2,1],'no','','',startx,borders[2]+50,0,0);

for i:=2 to 7 do
  begin
   if X1(last_object)>bigx then bigx:=X2(last_object);
   include_object(butlabels[1,i],'buttonc',butlabels[2,i],'no','','',startx,Y2(last_object)+spacey,0,0);
  end;
lasty:=Y2(last_object);
include_object('newline','layer','1','no','','',bigx+10,borders[2]+45,bigx+10,borders[2]+50);
for i:=8 to 10 do
  begin
  include_object(butlabels[1,i],'buttonc',butlabels[2,i],'no','','',X1(last_object),Y2(last_object)+spacey,0,0);
  end; 
//include_object('ok','buttonc','Αποθήκευση','no','','',startx,lasty+60,0,0);
include_object('clear','buttonc','Διαγραφή αλλαγών','no','','',startx,lasty+60,0,0); //X2(last_object)+10  Y1(last_object)
include_object('notes','buttonc','Σημειώσεις','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;
repeat
interact;
lastobj:=return_last_mouse_object;



if (get_object_data(butlabels[1,1])='4') then begin //Ryziki Apoksisi
                                                set_button(butlabels[1,1],0);
                                                teeth_data_aux[hum_teeth_mem(which_teeth)]:='RIZ_APOKSISI';
                                              end else
if (get_object_data(butlabels[1,2])='4') then begin //Emfytevma
                                                set_button(butlabels[1,2],0);
                                                teeth_data_aux[hum_teeth_mem(which_teeth)]:='VIDA';
                                              end else
if (get_object_data(butlabels[1,3])='4') then begin //Gefyra
                                                set_button(butlabels[1,3],0);
                                                teeth_data_aux[hum_teeth_mem(which_teeth)]:='ARROW';
                                              end else
if (get_object_data(butlabels[1,4])='4') then begin //Eksagwgi
                                                set_button(butlabels[1,4],0);
                                                teeth_data_aux[hum_teeth_mem(which_teeth)]:='X'; 
                                                for i:=1 to 6 do change_teeth_color(which_teeth,i,ConvertRGB(0,0,0));
                                                draw_hud_teeth_layers(which_teeth,ax,ay);
                                              end else 
if (get_object_data(butlabels[1,5])='4') then begin //Thiki
                                                set_button(butlabels[1,5],0);
                                                teeth_data_aux[hum_teeth_mem(which_teeth)]:='ARROW';
                                              end else
if (get_object_data(butlabels[1,6])='4') then begin //Sealants
                                                set_button(butlabels[1,6],0);
                                                teeth_data_aux[hum_teeth_mem(which_teeth)]:='SEALANT';
                                              end else
if (get_object_data(butlabels[1,7])='4') then begin //Teridona
                                                set_button(butlabels[1,7],0);
                                                if No_Teeth_Part_Selected then MessageBox (0, 'Επιλέξτε τις περιοχές οι οποίες θέλετε να μαρκαριστούν με την συγκεκριμένη εργασία απο την εικόνα αριστερά και στην συνέχεια πατήστε το κουμπί εργασίας..'+#10+' Για περισσότερες πληροφορίες ανατρέξτε στο εγχειρίδιο χρήσης..' , 'Πρέπει να γίνει επιλογή περιοχής..', 0 + MB_ICONASTERISK);
                                                for i:=1 to 6 do
                                                  begin
                                                   if Teeth_Part_Selected(which_teeth,i) then change_teeth_color(which_teeth,i,butcolors[7]);
                                                  end;
                                                draw_hud_teeth_layers(which_teeth,ax,ay);
                                              end else
if (get_object_data(butlabels[1,8])='4') then begin //Emfraksi amalgamatos
                                                set_button(butlabels[1,8],0);  
                                                if No_Teeth_Part_Selected then MessageBox (0, 'Επιλέξτε τις περιοχές οι οποίες θέλετε να μαρκαριστούν με την συγκεκριμένη εργασία απο την εικόνα αριστερά και στην συνέχεια πατήστε το κουμπί εργασίας..'+#10+' Για περισσότερες πληροφορίες ανατρέξτε στο εγχειρίδιο χρήσης..' , 'Πρέπει να γίνει επιλογή περιοχής..', 0 + MB_ICONASTERISK);
                                                for i:=1 to 6 do
                                                  begin
                                                   if Teeth_Part_Selected(which_teeth,i) then change_teeth_color(which_teeth,i,butcolors[8]);
                                                  end;
                                                draw_hud_teeth_layers(which_teeth,ax,ay);
                                              end else
if (get_object_data(butlabels[1,9])='4') then begin //Emfraksi rytinis
                                                set_button(butlabels[1,9],0);
                                                if No_Teeth_Part_Selected then MessageBox (0, 'Επιλέξτε τις περιοχές οι οποίες θέλετε να μαρκαριστούν με την συγκεκριμένη εργασία απο την εικόνα αριστερά και στην συνέχεια πατήστε το κουμπί εργασίας..'+#10+' Για περισσότερες πληροφορίες ανατρέξτε στο εγχειρίδιο χρήσης..' , 'Πρέπει να γίνει επιλογή περιοχής..', 0 + MB_ICONASTERISK);
                                                for i:=1 to 6 do
                                                  begin
                                                   if Teeth_Part_Selected(which_teeth,i) then change_teeth_color(which_teeth,i,butcolors[9]);
                                                  end;
                                                draw_hud_teeth_layers(which_teeth,ax,ay);
                                              end else
if get_object_data('clear')='4' then begin
                                      set_button('clear',0);
                                      i:=MessageBox (0, pchar('Είστε σίγουροι πως θέλετε να διαγράψετε τις πληροφορίες που είναι αποθηκευμένες για το δόντι '+Convert2String(which_teeth)+' ?') , 'Διαγραφή ?', 0 + MB_YESNO + MB_ICONQUESTION);
                                      if i=IDYES then
                                        begin
                                         teeth_data_aux[hum_teeth_mem(which_teeth)]:='';
                                         for i:=1 to 6 do default_teeth_color(which_teeth,i);
                                         draw_hud_teeth_layers(which_teeth,ax,ay);
                                        end;
                                     end else
if get_object_data('clear_selections')='4' then begin
                                                   set_button('clear_selections',0); 
                                                   set_object_data('area(2a','value','1',1);
                                                   draw_object_by_name('area(2a');
                                                   set_object_data('area(5p','value','1',1);
                                                   draw_object_by_name('area(5p');
                                                   set_object_data('area(5y','value','1',1);
                                                   draw_object_by_name('area(5y');
                                                   set_object_data('area(1','value','1',1);
                                                   draw_object_by_name('area(1');
                                                   set_object_data('area(2e','value','1',1);
                                                   draw_object_by_name('area(2e');
                                                   set_object_data('area(rz','value','1',1); 
                                                   draw_object_by_name('area(rz');
                                                end else
if (get_object_data('notes')='4') then begin
                                        set_button('notes',0); 
                                        clrscreen;
                                        RunEXE(get_external_editor+' "'+People_Data(0)+'Database\'+People_Data(9)+'.nfo"','normal');
                                        MessageBox (0, 'Πατήστε ΟΚ όταν τελείωσετε με την επεξεργασία του κειμένου..' , ' ', 0); 
                                        clrscreen;
                                        goto start_open_teeth;
                                       end; {else
if get_object_data('ok')='4' then begin 
                                    set_button('ok',1);
                                    Save_Teeth;
                                    //set_button('exit',1);
                                  end;    }

if (lastobj<>'') then  begin
                         if get_object_data(lastobj)='4' then
                         begin
                          seperate_words(lastobj);
                                       if Equal(get_memory(1),'zoom') then    begin
                                                                               set_object_data(lastobj,'VALUE','1',1);
                                                                               GUI_Open_Teeth_part(which_teeth,get_memory_int(2));
                                                                               flush_last_object_activated;
                                                                               lastobj:='';
                                                                               goto start_open_teeth;
                                                                              end;

                         end;
                         flush_last_object_activated;
                         lastobj:=''; 
                        end;

until GUI_Exit;
Save_Teeth;
end;




procedure GUI_check_teeth;
var lastobj,bufstr:string;
    tableend,i,wndx1,wndx2,wndy1,wndy2,ix1,ix2,iy1,iy2:integer;
    save_flag:boolean;
    label start_check_teeth;
begin
wndx1:=((GetMaxX-GetApsInfo('dontiatable','sizex')) div 2)-10;
wndx2:=((GetMaxX+GetApsInfo('dontiatable','sizex')) div 2)+10;
wndy1:=200;
wndy2:=wndy1+GetApsInfo('dontiatable','sizey')+120;
tableend:=wndx1+10+GetApsInfo('dontiatable','sizex');

save_flag:=true;
start_check_teeth: 
flush_gui_memory(0);
include_object('window1','window','Επιλογή δοντιών.. ','no','','',wndx1,wndy1,wndx2,wndy2);
draw_all;
delete_object('window1','name');
DrawAPSXY('dontiatable',wndx1+10,wndy1+50);


//include_object('instructions','comment','Κάντε κλίκ σε ένα δόντι για να αλλάξετε τα στοιχεία του','no','','',-1,wndy1+34,-1,0);

Load_Teeth;

for i:=8 downto 1 do begin
                      bufstr:='dont'+Convert2String(10+i);
                      ix1:=wndx1+13+(8-i)*(44);
                      ix2:=ix1+GetApsInfo(bufstr,'sizex');
                      iy1:=wndy1+50+93;
                      iy2:=iy1+GetApsInfo(bufstr,'sizey');
                      DrawAPSXY(bufstr,ix1,iy1);  
                      bufstr:=Dontia_Aux_APS(teeth_data_aux[hum_teeth_mem(10+i)],'up');
                      if bufstr<>'' then DrawAPSXY(bufstr,ix1+3,iy1-93+7);
                      include_object('teeth('+Convert2String(10+i)+')','layer','1','no','','select',ix1,iy1,ix2,iy2);
                     end;
for i:=8 downto 1 do begin
                      bufstr:='dont'+Convert2String(20+i);
                      ix1:=tableend+3-(9-i)*(44);
                      ix2:=ix1+GetApsInfo(bufstr,'sizex');
                      iy1:=wndy1+50+93;
                      iy2:=iy1+GetApsInfo(bufstr,'sizey');
                      DrawAPSXY(bufstr,ix1,iy1);
                      bufstr:=Dontia_Aux_APS(teeth_data_aux[hum_teeth_mem(20+i)],'up');
                      if bufstr<>'' then DrawAPSXY(bufstr,ix1,iy1-93+7);
                      include_object('teeth('+Convert2String(20+i)+')','layer','1','no','','select',ix1,iy1,ix2,iy2);
                     end;
for i:=8 downto 1 do begin
                      bufstr:='dont'+Convert2String(40+i);
                      ix1:=wndx1+13+(8-i)*(44);
                      ix2:=ix1+GetApsInfo(bufstr,'sizex');
                      iy1:=wndy1+50+184;
                      iy2:=iy1+GetApsInfo(bufstr,'sizey');
                      DrawAPSXY(bufstr,ix1,iy1);
                      bufstr:=Dontia_Aux_APS(teeth_data_aux[hum_teeth_mem(40+i)],'down');
                      if bufstr<>'' then DrawAPSXY(bufstr,ix1,iy1+93+7);
                      include_object('teeth('+Convert2String(40+i)+')','layer','1','no','','select',ix1,iy1,ix2,iy2);
                    end;
for i:=8 downto 1 do begin
                      bufstr:='dont'+Convert2String(30+i);
                      ix1:=tableend+3-(9-i)*(44);
                      ix2:=ix1+GetApsInfo(bufstr,'sizex');
                      iy1:=wndy1+50+184;
                      iy2:=iy1+GetApsInfo(bufstr,'sizey');
                      DrawAPSXY(bufstr,ix1,iy1);
                      bufstr:=Dontia_Aux_APS(teeth_data_aux[hum_teeth_mem(30+i)],'down');
                      if bufstr<>'' then DrawAPSXY(bufstr,ix1,iy1+93+7);
                      include_object('teeth('+Convert2String(30+i)+')','layer','1','no','','select',ix1,iy1,ix2,iy2);
                     end;

//include_object('ok','buttonc','Αποθήκευση','no','','',wndx1-40+(wndx2-wndx1) div 2,wndy2-40,0,0);
//include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('instructions2','comment','Κάντε κλίκ σε ένα δόντι για να αλλάξετε τα στοιχεία του','no','','',-1,wndy2-65,-1,0);
include_object('exit','buttonc','Πίσω','no','','',-1,wndy2-40,-1,0);
set_gui_color(ConvertRGB(0,0,0),'comment');
draw_all; 
repeat
interact; 
lastobj:=last_object_activated;
if lastobj<>'' then begin
                     seperate_words(lastobj);
                     if Equal(get_memory(1),'TEETH') then
                        begin
                         flush_last_object_activated;
                         save_flag:=false;
                         GUI_Open_Teeth(get_memory_int(2));
                         flush_last_object_activated;
                         //MessageBox (0,pchar('H Epilogi den einai akoma etoimi '+get_memory(2)+' ..'), ' ', 0);
                         goto start_check_teeth;
                        end;
                         
                    end;
//if GUI_Exit then begin end else
if get_object_data('ok')='4' then begin
                                    set_button('ok',1);
                                    DrawApsXY('greenbtn',X1('ok')-GetApsInfo('greenbtn','sizex')-5,Y1('ok')+3);
                                    save_flag:=true;
                                    Save_Teeth;
                                    //break;
                                  end; 
until GUI_Exit;
save_flag:=true;
Save_Teeth;
if not (save_flag) then begin
                            i:=MessageBox (0, 'Θέλετε να αποθηκευτούν τυχόν αλλαγές? ' , ' ', 0 + MB_YESNO + MB_ICONQUESTION);
                            if i=IDYES then Save_Teeth;
                        end;

end;



begin
end.
