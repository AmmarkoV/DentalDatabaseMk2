unit gui_typing;

interface
 
function ReadTextGUI(startingtxt:string; sizelength:integer; masked:boolean):string;
function ReadTextGUI2(startingtxt:string; sizelength:integer; masked:boolean):string;  

implementation 
uses windows,ammarunit,apsfiles,ammargui;

const
// COLOR
   window_background=1; 
   window_background_inactive=2;
   window_border=3;
   window_title=4;
   menu_active=5;
   menu_active_text=16;
   textbox_out=6;
   textbox_in=7;
   textbox_text_test_test=8;
   textbox_suggestion=9;
   comments_color=10;
   button_color=11;
   button_text=12;
   button_active_text=13;
   button_activated_text=14;
   progressbar=15;
   MAX_COLORS=16;

var copypaste_mem:string;
    blink_key_speed,special_key_speed,pliktrologisi_speed:integer;
    removed_from_string:boolean;
    cursx,viewpos,lastpos,the_size:integer;
    bufferstring:string; 
    masked_string:boolean;
    borders:array[1..4]of integer;



procedure text_tools(x,y:integer; var texttoalter:string);
const
  prepare_menu: array [1..9] of string =
    ('cut','copy','paste','delete','upcase','lowercase','flip','multiple','A-TECH');
var //prepare_menu:array [1..9] of string =('cut','copy','paste','delete','upcase','lowercase','flip','multiple','A-TECH'); 
    selection,last_selection:integer;
    bufstr:string;
begin
selection:=text_handle_menu(x,y,9,prepare_menu{,texttoalter});
if selection=1 then begin  //CUT
                     copypaste_mem:=texttoalter;
                     CopyToClipboard(copypaste_mem);
                     texttoalter:='';
                    end else
if selection=2 then begin  //COPY
                     copypaste_mem:=texttoalter; 
                     CopyToClipboard(copypaste_mem);
                    end else
if selection=3 then begin //PASTE 
                     texttoalter:=copypaste_mem;
                    end else
if selection=4 then begin //DELETE 
                     texttoalter:='';
                    end else
if selection=5 then begin //UPCASE 
                     texttoalter:=Upcase2(texttoalter);
                    end else
if selection=6 then begin //LOWERCASE 
                     texttoalter:=texttoalter;
                    end else
if selection=7 then begin //FLIP
                     bufstr:='';
                     for last_selection:=Length(texttoalter) downto 1 do bufstr:=bufstr+texttoalter[last_selection]; 
                     texttoalter:=bufstr;
                    end else
if selection=8 then begin //MULTIPLE
                     //
                    end; 
GUI_ChangeCursorIcon(mouse_icon_resource('TYPE'));
end;

function Add2String(thetext,what2add:string; where2add:integer):string;
var retres:string;
    i:integer;
begin
retres:='';
removed_from_string:=false; //AN AFAIRETHEI KATI APO TO STRING GINETAI SET


if where2add=0 then
   begin  // ARXI TIS LEKSIS
            if Equal(what2add,'BACKSPACE') then
               begin 
                retres:=thetext;
               end else //DEN GINETAI BACKSPACE STO TELOS TIS LEKSIS
            if Equal(what2add,'DELETE') then
               begin
                removed_from_string:=true;
                if Length(thetext)<=1 then retres:='' else
                for i:=2 to Length(thetext) do retres:=retres+thetext[i];
               end 
      else
    retres:=what2add+thetext;
   end else


if where2add=Length(thetext) then
   begin //TELOS TIS LEKSIS
    if Equal(what2add,'BACKSPACE') then
      begin
       removed_from_string:=true;
       if Length(thetext)<=1 then retres:='' else
       for i:=1 to Length(thetext)-1 do retres:=retres+thetext[i];
      end else
    if Equal(what2add,'DELETE') then
      begin
       retres:=thetext;
      end else //DEN GINETAI DELETE STO TELOS TIS LEKSIS
    retres:=thetext+what2add;
   end else






   begin // MESI TIS LEKSIS 
              if Equal(what2add,'BACKSPACE') then
               begin 
                 removed_from_string:=true;
                 for i:=1 to where2add-1 do retres:=retres+thetext[i];
                 for i:=where2add+1 to Length(thetext) do retres:=retres+thetext[i];
               end else 
              if Equal(what2add,'DELETE') then
               begin 
                 removed_from_string:=true;
                 for i:=1 to where2add do retres:=retres+thetext[i];
                 for i:=where2add+1 to Length(thetext) do retres:=retres+thetext[i];
               end
      else
     begin
      for i:=1 to where2add do retres:=retres+thetext[i];
      retres:=retres+what2add;
      for i:=where2add+1 to Length(thetext) do retres:=retres+thetext[i];
     end;

   end;
Add2String:=retres;
end;


procedure DrawStringPart(thestring:string; startx,starty,fromwhere,towhere:integer; masked:boolean);
var x,i:integer;
begin
x:=startx;
if fromwhere=0 then fromwhere:=1;
if towhere>Length(thestring) then towhere:=Length(thestring);

if fromwhere<=towhere then
for i:=fromwhere to towhere do
  begin 
   if masked then thestring[i]:='*';
   outtextXY(x,starty,thestring[i]);
   x:=x+TextWidth(thestring[i]); 
  end;
end;

function StringPixelSize(thestring:string; fromwhere,towhere:integer):integer;
var i,retres:integer;
begin
retres:=0;
if fromwhere=0 then fromwhere:=1;
if towhere>Length(thestring) then towhere:=Length(thestring);
if fromwhere<=towhere then
begin
 for i:=fromwhere to towhere do
      begin
       if masked_string then retres:=retres+TextWidth('*') else
                             retres:=retres+TextWidth(thestring[i]);
      end;
end;
StringPixelSize:=retres;
end;

procedure Draw_String_View;
begin
DrawRectangle2(borders[1],borders[2],borders[3],borders[4],Get_GUI_Color(textbox_in),Get_GUI_Color(textbox_in));
DrawStringPart(bufferstring,borders[1],borders[2],viewpos,lastpos,masked_string);
end;

procedure Set_Viewpos_From_Lastpos(oursize:integer);
var calcsize,new_viewpos,i,z:integer;
begin
calcsize:=0;
if lastpos<=0 then viewpos:=0 else
  begin
   new_viewpos:=lastpos;
   for i:=lastpos downto 1 do
     begin
      if masked_string then z:=TextWidth('*') else
                            z:=TextWidth(bufferstring[i]);
      if calcsize+z<oursize then begin
                                  calcsize:=calcsize+z;
                                  new_viewpos:=new_viewpos-1;
                                 end else
                                 break; 
     end;
   viewpos:=new_viewpos;
  end;
end;

procedure Set_Lastpos_From_Viewpos(oursize:integer);
var calcsize,new_lastpos,i,z:integer;
begin
calcsize:=0;
if lastpos<=0 then viewpos:=0 else
  begin
   new_lastpos:=viewpos;
   for i:=viewpos to Length(bufferstring) do
     begin
      if masked_string then z:=TextWidth('*') else
                            z:=TextWidth(bufferstring[i]);
      if calcsize+z<oursize then begin
                                  calcsize:=calcsize+z;
                                  new_lastpos:=new_lastpos+1;
                                 end else
                                 break; 
     end;
   lastpos:=new_lastpos;
  end;
end;


procedure Set_Initial_Viewpos_Lastpos(thetext:string; textlength:integer);
var i2,z2,blinkx:integer;
begin
if TextWidth(thetext)-textlength>0 then
        begin
          if Length(thetext)>0 then
            begin
             i2:=1;
             blinkx:=0;
              while i2<=Length(thetext) do
                begin
                 if masked_string then z2:=TextWidth('*') else
                                       z2:=TextWidth(thetext[i2]);
                 if blinkx+z2<textlength then
                    begin
                     blinkx:=blinkx+z2;
                     i2:=i2+1;
                    end else
                    break;
                end; 
            end;
          cursx:=i2;
          i2:=1;
          //cursx:=Length(startingtxt)-(TextWidth(startingtxt)-sizelength) div TextWidth('A');
        end else
          cursx:=Length(thetext);

lastpos:=cursx;
if i2=1 then cursx:=cursx-1;
end;

procedure View_Set_Right(places:integer);
var center:integer;
begin
center:=(lastpos-viewpos) div 2;
lastpos:=lastpos+center;
if lastpos>Length(bufferstring) then lastpos:=Length(bufferstring);
Set_Viewpos_From_Lastpos(the_size);
end;

procedure View_Set_Left(places:integer);
var center:integer;
begin
center:=(lastpos-viewpos) div 2;
viewpos:=viewpos-center;
if viewpos<0 then viewpos:=0;
Set_Lastpos_From_Viewpos(the_size);
end;


function Check_N_Slide_TextBox(thestring:string):boolean;
var retres:boolean;
begin
retres:=false;
if cursx<0 then cursx:=0;
if cursx>Length(thestring) then cursx:=Length(thestring);

if Length(bufferstring)=0 then begin
                                 viewpos:=0;
                                 cursx:=0;
                                 lastpos:=0; 
                                 DrawRectangle2(borders[1],borders[2],borders[3],borders[4],Get_GUI_Color(textbox_in),Get_GUI_Color(textbox_in));
                               end else
if ((cursx>lastpos) and (lastpos<=Length(thestring)) ) then
                      begin
                       View_Set_Right(cursx-lastpos);
                       retres:=true;
                      end else
if ((cursx<viewpos) and (viewpos>0)) then begin
                                           View_Set_Left(cursx-viewpos);
                                           retres:=true;
                                          end;
if retres then Draw_String_View;
Check_N_Slide_TextBox:=retres;
end;


procedure Control_View_Set_Left_Word;
begin
cursx:=cursx-1;
while ((cursx>0) and (bufferstring[cursx]<>' ') ) do
  begin
   cursx:=cursx-1;
  end;
end;

procedure Control_View_Set_Right_Word;
begin
cursx:=cursx+1;
while ((cursx<=Length(bufferstring)) and (bufferstring[cursx]<>' ') ) do
  begin
   cursx:=cursx+1;
  end;
end;

{procedure Debug_Typing(topic:string);
begin
SetBackgroundMode('OPAQUE');
OutTextXY(1,1,topic+' cursx='+Convert2String(cursx)+' viewpos='+Convert2String(viewpos)+' lastpos='+Convert2String(lastpos)+'   waiting                      ');
readkey;
OutTextXY(1,1,topic+' cursx='+Convert2String(cursx)+' viewpos='+Convert2String(viewpos)+' lastpos='+Convert2String(lastpos)+'   ok                       ');
SetBackgroundMode('TRANSPARENT'); 
end;      }

function ReadTextGUI(startingtxt:string; sizelength:integer; masked:boolean):string;    //READ TEXT ME ENSWMATWMENI TIN GRIGORI PLIKTROLOGISI!
var bufferstring2,bufkey,bufkey2,awrd,addwrd:string;
    blinkx,x,y,i2,z2,txclr,txtchkloop,fastkey:integer;
    selection_start,selection_end:integer;
    mousex,mousey:integer;
    idle_time:byte;
    whole_string_redraw:boolean;
    special_key,shift_down,alt_down,tonos_down,control_down,open_menu,type_suggestion:boolean;
    bufferchar:char;
    label key_examine,internal_return_to_type_wait,skip_type;
begin 
copypaste_mem:=Get_GUI_CopyPaste;

masked_string:=masked; //GIA TA EKSWTERIKA PROCEDURES!
blink_key_speed:=Get_GUI_Parameter(3);
special_key_speed:=Get_GUI_Parameter(2);
pliktrologisi_speed:=Get_GUI_Parameter(1);
 
txclr:=TakeTextColor;
TextColor(Get_GUI_Color(textbox_text_test_test)); 

borders[1]:=GetX;
borders[2]:=GetY;
borders[3]:=GetX+sizelength-TextWidth('A');
borders[4]:=GetY+TextHeight('A');

the_size:=sizelength-17;
selection_start:=0;
selection_end:=0;
viewpos:=0;

Set_Initial_Viewpos_Lastpos(startingtxt,sizelength);


z2:=0;
i2:=0;
blinkx:=0;
idle_time:=0;  
 

SetMouseXY(GetMouseX+1,GetMouseY);
//SetMouseXY(mousex+1,mousey); //Gia na kentrarei to mouse sto textbox

DrawStringPart(startingtxt,borders[1],borders[2],viewpos,lastpos,masked);


shift_down:=false;
alt_down:=false;
control_down:=false; 
tonos_down:=false;
special_key:=false;
open_menu:=false; //Open tooltips menu..
whole_string_redraw:=false; //Draw Whole String
removed_from_string:=false; //Initial Value
type_suggestion:=false; //No text suggestions

FlushMouseButtons;
MouseButton(1);
bufferstring:=startingtxt;  //yparxoysa string -> loaded string
repeat
bufkey:='';
//if (not masked) then awrd:=Suggest_Typing(bufferstring);
{if awrd<>'' then begin
                  TextColor(Get_GUI_Color(textbox_suggestion));
                  OutTextXY(x,y,awrd);
                  TextColor(Get_GUI_Color(textbox_text));
                  bufkey:=readkey; 
                  if Upcase(bufkey)='ENTER' then begin
                                                  bufkey:=awrd;
                                                  type_suggestion:=true;
                                                 end  else
                  if ( (Length(bufkey)>3))then begin //DISCARD TYPING
                                                wait_clear_key(bufkey);
                                                bufkey:=''; 
                                                //awrd:=''; 
                                               end;
                  DrawRectangle2(x,y,x+TextWidth(awrd),y+TextHeight(awrd),Get_GUI_Color(textbox_in),Get_GUI_Color(textbox_in));
                 end;   }
if bufkey='' then begin

{if idle_time>63 then idle_time:=64;
if idle_time=64 then begin
                      DrawLine(1,GetMaxY-5,70,GetMaxY-5,ConvertRGB(255,0,0));
                     end else
                     DrawLine(1,GetMaxY-5,70,GetMaxY-5,ConvertRGB(0,255-4*idle_time,0));    }

idle_time:=0; 
blinkx:=borders[1]+StringPixelSize(bufferstring,viewpos,cursx); //edw kathorizetai to blinkx 
repeat
 internal_return_to_type_wait:
 bufkey:=readkeyfast; 

 if bufkey='' then
 begin //AN O XRISTIS DEN PATAEI KATI
  idle_time:=idle_time+1; // Metrisi kyklwn mexri input..
  //to blinkx kathorizetai pio prin gia na eksikonomoume CPU
  if (idle_time mod blink_key_speed)=0 then DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_text_test_test)) else //Draw Cursor
  if (idle_time mod blink_key_speed)=(blink_key_speed div 2) then DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_in));

  if idle_time mod 2=0 then goto internal_return_to_type_wait;  // <- ENHANCE SPEED

  if CheckKeyFast(VK_SHIFT)=1 then begin
                                    bufkey:='SHIFT';
                                    SetLastReadKey_Code(VK_SHIFT);
                                    goto key_examine;
                                   end;
  if CheckKeyFast(VK_CONTROL)=1 then begin
                                      bufkey:='CONTROL';
                                      SetLastReadKey_Code(VK_CONTROL);
                                      goto key_examine;
                                     end;


  //Mouse actions.. 
  mousex:=GetMouseX;
  mousey:=GetMouseY;                                                                                  //Eksw sto text box
  if ( (mousex<borders[1]) or (mousex>borders[3]) or (mousey<borders[2]) or (mousey>borders[4]) ) then begin
                                                                                                             if (MouseButton(1)=1) then bufkey:='ENTER';  
                                                                                                       end else
                                                                                                       //Mesa apo to text box
                                                                                                       begin
                                                                                                            if (MouseButton(1)=1) then begin
                                                                                                                                        {lastpos-viewpos}
                                                                                                                                        DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_in));//UNDRAW BLINK

                                                                                                                                        i2:=sizelength div TextWidth('a');
                                                                                                                                        z2:=(mousex-borders[1]) div TextWidth('a');
                                                                                                                                        if Length(bufferstring)<z2 then cursx:=(lastpos)  else
                                                                                                                                        cursx:=z2+1+viewpos;
                                                                                                                                        if viewpos>0 then cursx:=cursx-1;

                                                                                                                                        if cursx<viewpos then cursx:=viewpos;

                                                                                                                                        blinkx:=borders[1]+StringPixelSize(bufferstring,viewpos,cursx); //edw kathorizetai to blinkx
                                                                                                                                        DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_text_test_test));
                                                                                                                                       end else
                                                                                                            if (MouseButton(3)=1) then open_menu:=true; 
                     {Equal(bufkey,'MENU')}                                                            end;
  if ((open_menu) or (93=GetLastReadKey_Code)) then begin
                                                     bufferstring2:=bufferstring;
                                                     text_tools(mousex,mousey,bufferstring);
                                                     Set_Initial_Viewpos_Lastpos(bufferstring,sizelength);
                                                     Draw_String_View;
                                                     bufferstring2:='';
                                                     open_menu:=false;
                                                     bufkey:='';
                                                    end;
  sleep(pliktrologisi_speed);
 end; //AN O XRISTIS DEN PATAEI KATI
 until bufkey<>'';
 key_examine:
 DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_in));  //Undraw Cursor

  if ((idle_time>=special_key_speed) and (special_key)) then   // Aytomatos katharismos Shift , Control , Alt meta apo ligous kyklous..
                       begin
                         shift_down:=false;
                         alt_down:=false;
                         control_down:=false;
                         special_key:=false;
                       end; 

 

   //HOT COMBINATIONS Control + ?
   bufkey2:=bufkey;

   if (Upcase2(bufkey)='Ù') then bufkey2:='V' else
   if (Upcase2(bufkey)='Ø') then bufkey2:='C' else
   if (Upcase2(bufkey)='×') then bufkey2:='X';

   if ((Equal(bufkey2,'X'))and (control_down) and (not masked)) then
                                                   begin
                                                    copypaste_mem:=bufferstring;
                                                    control_down:=false;
                                                    bufferstring:='';
                                                    bufferstring2:='';
                                                    bufkey:='';
                                                    Set_Initial_Viewpos_Lastpos(bufferstring,sizelength);
                                                    Draw_String_View;
                                                    
                                                   end else
   if ((Equal(bufkey2,'C'))and (control_down) and (not masked)) then
                                                   begin
                                                    copypaste_mem:=bufferstring;
                                                    control_down:=false;
                                                    bufkey:='';
                                                   end else
   if ((Equal(bufkey2,'V'))and (control_down) and (not masked)) then
                                                   begin
                                                    bufkey:=copypaste_mem;
                                                    type_suggestion:=TRUE;
                                                    control_down:=false;
                                                   end;



                  end;

if (not Equal(bufkey,'ENTER')) then  begin
                                   fastkey:=GetLastReadKey_Code;
                                   case fastkey of
                                   vk_back{Equal(bufkey,'BACKSPACE')} : begin type_suggestion:=true; end;
                                   vk_delete{Equal(bufkey,'DELETE')} :  begin type_suggestion:=true; end;//ETSI WSTE NA PERASOUN STO INNER TYPING
                                   vk_escape{Equal(bufkey,'ESCAPE')}: begin end;
                                   vk_left{Equal(bufkey,'LEFT ARROW')}:  begin
                                                                          wait_clear_key('LEFT ARROW');
                                                                       if cursx>0 then
                                                                         begin 
                                                                          if not control_down then cursx:=cursx-1 else
                                                                                                   begin
                                                                                                    Control_View_Set_Left_Word;
                                                                                                    control_down:=false;
                                                                                                   end;
                                                                          Check_N_Slide_TextBox(bufferstring);
                                                                          blinkx:=borders[1]+StringPixelSize(bufferstring,viewpos,cursx);
                                                                          DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_text_test_test));
                                                                          delay(80);
                                                                          DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_in));

                                                                         end;
                                                                      end;
                                   vk_right{Equal(bufkey,'RIGHT ARROW')}:
                                                                      begin
                                                                       wait_clear_key('RIGHT ARROW');
                                                                       if cursx<Length(bufferstring) then
                                                                         begin
                                                                          if not control_down then cursx:=cursx+1 else
                                                                                                   begin
                                                                                                    Control_View_Set_Right_Word;
                                                                                                    control_down:=false;
                                                                                                   end; 
                                                                          Check_N_Slide_TextBox(bufferstring);
                                                                          blinkx:=borders[1]+StringPixelSize(bufferstring,viewpos,cursx); 
                                                                          DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_text_test_test));
                                                                          delay(80);
                                                                          DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_in));
                                                                          
                                                                         end;
                                                                      end;
                                   vk_F1{Equal(bufkey,'F1')}:  begin
                                                                if Upcase(GetInternalKeyboardLanguage)='ENGLISH' then SetInternalKeyboardLanguage('GREEK') else
                                                                                                                      SetInternalKeyboardLanguage('ENGLISH');
                                                                draw_language(GetInternalKeyboardLanguage); 
                                                                bufkey:='';
                                                               end;
                                   vk_shift{Equal(bufkey,'SHIFT')}:  begin
                                                                    if not shift_down then
                                                                         begin 
                                                                          draw_button_complimentary(-1,shift_down,control_down,alt_down,bufkey); 
                                                                          shift_down:=true;
                                                                          special_key:=true;
                                                                          draw_button_complimentary(1,shift_down,control_down,alt_down,bufkey);
                                                                         end;
                                                                  end;
                                   vk_menu{Equal(bufkey,'ALT')}:  begin
                                                                     if not alt_down then
                                                                         begin
                                                                          draw_button_complimentary(-1,shift_down,control_down,alt_down,bufkey); 
                                                                          alt_down:=true;
                                                                          special_key:=true;
                                                                          draw_button_complimentary(1,shift_down,control_down,alt_down,bufkey);
                                                                         end; 
                                                                end;
                                   vk_control{Equal(bufkey,'CONTROL')}:  begin
                                                                     if not control_down then
                                                                         begin
                                                                          draw_button_complimentary(-1,shift_down,control_down,alt_down,bufkey); 
                                                                          control_down:=true;
                                                                          special_key:=true;
                                                                          draw_button_complimentary(1,shift_down,control_down,alt_down,bufkey);
                                                                         end;  
                                                                    end;

                                    //else fastkey:=-999;
                                   end;

                                   //if fastkey<>-999 then begin end else 
                                    if ((Equal(bufkey,';')) and (not shift_down) and (tonos_down)  ) then begin
                                                                                                                bufkey:=chr(39);
                                                                                                              end else
                                    if ((Equal(bufkey,';')) and (not shift_down) and (Upcase(GetInternalKeyboardLanguage)='GREEK') ) then begin
                                                                                                                                           tonos_down:=true;
                                                                                                                                           goto skip_type;
                                                                                                                                         end;
                                  
                                   if ((Length(bufkey)<=2) or (type_suggestion)) then //PLIKTROLOGISI POU EPIRREAZEI TO STRING!
                                    begin  
                                          draw_button_complimentary(1,shift_down,control_down,alt_down,bufkey);
                                          //Draw operation type control,shift,alt etc..
                                          if shift_down then bufkey:=shift_mask(bufkey);
                                          // If needed add the tuna.. :) (Tuna = Tonos XOXOXO)
                                          if tonos_down then bufkey:=Greek_Tone(bufkey); 
                                          //make all needed changes..


                                          if Length(bufferstring)>cursx then whole_string_redraw:=true; // SE PERIPTWSI POU GRAFOUME ANAMESA STO STRING NA ZWGRAFISTEI OLO TO STRING
                                          
                                          bufferstring:=Add2String(bufferstring,bufkey,cursx); //TO STRING ALLAKSE ANALOGA ME TO PLIKTRO POU PATITHIKE
                                         
                                          
                                          // PWS EPIRREAZETAI AYTO POU VLEPEI O XRISTIS ANALOGA ME TA PLIKTRA POU PATIOUNTAI!
                                          if fastkey=vk_back{Equal(bufkey,'BACKSPACE')} then
                                                                            begin
                                                                             cursx:=cursx-1; 
                                                                             Check_N_Slide_TextBox(bufferstring);
                                                                             Set_Lastpos_From_Viewpos(sizelength);
                                                                             whole_string_redraw:=true;
                                                                            end else
                                          if fastkey=vk_delete{Equal(bufkey,'DELETE')} then
                                                                            begin
                                                                              if Length(bufferstring)>lastpos then begin end //GIA NA ZWGRAFISTOUN PIO MPROSTA GRAMMATA
                                                                                                             else
                                                                                                             lastpos:=lastpos-1; 
                                                                              Check_N_Slide_TextBox(bufferstring);
                                                                            end else
                                           begin
                                            cursx:=cursx+Length(bufkey);
                                            if lastpos<cursx then lastpos:=cursx;
                                            if StringPixelSize(bufferstring,viewpos,cursx)>sizelength-17 then begin
                                                                                                               View_Set_Right(Length(bufkey));
                                                                                                               whole_string_redraw:=true;
                                                                                                              end;{  else
                                                                                                               lastpos:=lastpos+Length(bufkey);}
                                           end;
 
                                          if cursx<0 then cursx:=0;
                                          if lastpos<0 then lastpos:=0;
                                          if removed_from_string then whole_string_redraw:=true; //GIA NA ZWGRAFISTEI TO SVISIMO!

                                          if not (whole_string_redraw) then //AN DEN XREIAZETE FULL REDRAW PAME GIA MERIKO
                                                                      begin //PARTIAL - FASTER DRAW !
                                                                         if fastkey=vk_back{Equal(bufkey,'BACKSPACE')} then begin  end else //TO BACKSPACE DEN ZWGRAFIZETAI TO whole_string_redraw exei eksasfalistei pio panw
                                                                         if fastkey=vk_delete{Equal(bufkey,'DELETE')} then begin  end else   //TO DELETE DEN ZWGRAFIZETAI TO whole_string_redraw exei eksasfalistei pio panw
                                                                         if (not masked) then begin
                                                                                               if x+TextWidth(bufkey)>=sizelength-17 then whole_string_redraw:=true else //TELIKA XREIAZETAI OLO TO STRING REDRAW GIATI DN XWRAEI
                                                                                                 begin
                                                                                                  outtextXY(x,y,bufkey);
                                                                                                  x:=x+TextWidth(bufkey);
                                                                                                 end;
                                                                                              end else
                                                                                              begin //Masked , yparxei password kai prepei na min fainetai..
                                                                                               if x+TextWidth('*')>=sizelength then whole_string_redraw:=true else //TELIKA XREIAZETAI OLO TO STRING REDRAW GIATI DN XWRAEI
                                                                                                 begin
                                                                                                  outtextXY(x,y,'*');
                                                                                                  x:=x+TextWidth('*');
                                                                                                 end;
                                                                                              end;
                                                                       end;

                                        if whole_string_redraw then begin //WHOLE STRING - SLOW DRAW !
                                                                        Draw_String_View;
                                                                        whole_string_redraw:=false; //Whole string just drawed
                                                                      end;
                                           
                                          
                                        type_suggestion:=false; //OTI KAI AN EGINE SUGGEST TO DEXTIKAME!

                                        shift_down:=false;
                                        alt_down:=false;
                                        control_down:=false;
                                        special_key:=false; //CLears all status..
                                        tonos_down:=false; //Clears tonos.. 
                                       // draw_button_complimentary(-1,shift_down,control_down,alt_down,bufkey);
                                    end; //TELOS PLIKTROLOGISIS POU EPIRREAZEI TO STRING
                                  end;

skip_type:
until (Upcase(bufkey)='TAB') or (Upcase(bufkey)='ENTER') or (Upcase(bufkey)='ESCAPE');
if Upcase(bufkey)='ESCAPE' then bufferstring:=startingtxt;
if Upcase(bufkey)='TAB' then movefocus;
TextColor(txclr); 

Set_GUI_CopyPaste(copypaste_mem);

ReadTextGUI:=bufferstring;
end;


 {














           OLD ZONE \/

















}

function ReadTextGUI2(startingtxt:string; sizelength:integer; masked:boolean):string;    //READ TEXT ME ENSWMATWMENI TIN GRIGORI PLIKTROLOGISI!
var bufferstring,bufferstring2,bufkey,bufkey2,awrd,addwrd:string;
    blinkx,cursx,x,y,i2,z2,txclr,txtchkloop:integer;
    mousex,mousey:integer;
    idle_time:byte;
    borders:array[1..4]of integer;
    special_key,shift_down,alt_down,tonos_down,control_down,open_menu,type_suggestion:boolean;
    bufferchar:char;
    label skip_type;
begin
blink_key_speed:=Get_GUI_Parameter(3);
special_key_speed:=Get_GUI_Parameter(2);
pliktrologisi_speed:=Get_GUI_Parameter(1);

//ReadText2:=ReadTextOLD(startingtxt,sizelength,masked);
txclr:=TakeTextColor;
TextColor(Get_GUI_Color(textbox_text_test_test));
{x:=GetX;
y:=GetY;
bufferstring:='';}
borders[1]:=GetX;
borders[2]:=GetY;
borders[3]:=GetX+sizelength;
borders[4]:=GetY+TextHeight('A');


cursx:=Length(startingtxt);
x:=GetX+TextWidth(startingtxt);
y:=GetY;
mousex:=x;
mousey:=y+4;

//DrawRectangle2(GetX,GetY,x+sizelength,GetY+TextHEight('A'),ConvertRGB(255,0,0),ConvertRGB(255,0,0));

SetMouseXY(GetMouseX+1,GetMouseY);
//SetMouseXY(mousex+1,mousey); //Gia na kentrarei to mouse sto textbox
if (not masked) then outtextXY(GetX,GetY,startingtxt) else //Na grafei to arxiko periexomeno an dn einai password..
                begin
                 bufferstring2:='';
                 if (Length(startingtxt)>0) then
                               begin
                                for i2:=1 to Length(startingtxt) do
                                             begin
                                               bufferstring2:=bufferstring2+'*';
                                             end;
                               end;
                 x:=GetX+TextWidth(bufferstring2); //* is smaller than letters so size may vary , this fixes it
                 outtextXY(GetX,GetY,bufferstring2);
                 bufferstring2:='';
                end;
shift_down:=false;
alt_down:=false;
control_down:=false; 
tonos_down:=false;
special_key:=false;
open_menu:=false; //Open tooltips menu..
type_suggestion:=false; //No text suggestions
FlushMouseButtons;
MouseButton(1);
bufferstring:=startingtxt;  //yparxoysa string -> loaded string
repeat
bufkey:='';
if (not masked) then awrd:=Suggest_Typing(bufferstring);
if awrd<>'' then begin
                  TextColor(Get_GUI_Color(textbox_suggestion));
                  OutTextXY(x,y,awrd);
                  TextColor(Get_GUI_Color(textbox_text_test_test));
                  bufkey:=readkey; 
                  if Upcase(bufkey)='ENTER' then begin
                                                  bufkey:=awrd;
                                                  type_suggestion:=true;
                                                 end  else                 {(Upcase(bufkey)=' ') or}
                  if ( (Length(bufkey)>3))then begin //DISCARD TYPING
                                                wait_clear_key(bufkey);
                                                bufkey:=''; 
                                                //awrd:=''; 
                                               end;
                  DrawRectangle2(x,y,x+TextWidth(awrd),y+TextHeight(awrd),Get_GUI_Color(textbox_in),Get_GUI_Color(textbox_in));
                 end;
if bufkey='' then begin
idle_time:=0;
blinkx:=x+2;
 repeat
  bufkey:=readkeyfast; 

 if bufkey='' then
 begin //AN O XRISTIS DEN PATAEI KATI
  idle_time:=idle_time+1; // Metrisi kyklwn mexri input..

  if (idle_time mod blink_key_speed)=0 then DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_text_test_test)) else //Draw Cursor
  if (idle_time mod blink_key_speed)=(blink_key_speed div 2) then DrawLine(blinkx,borders[2],blinkx,borders[4],Get_GUI_Color(textbox_in));
  //Mouse actions..
  mousex:=GetMouseX;
  mousey:=GetMouseY;                                                                                  //Mesa sto text box
  if ( (mousex<borders[1]) or (mousex>borders[3]) or (mousey<borders[2]) or (mousey>borders[4]) ) then begin
                                                                                                             if (MouseButton(1)=1) then bufkey:='ENTER';  
                                                                                                       end else
                                                                                                       //Eksw apo to text box
                                                                                                       begin
                                                                                                            if (MouseButton(1)=1) then begin
                                                                                                                                       //  mousex-borders[1]
                                                                                                                                       //  cursx:=
                                                                                                                                       end else
                                                                                                            if (MouseButton(3)=1) then open_menu:=true;
                                                                                                       end;
  if ((open_menu) or (Equal(bufkey,'MENU'))) then begin
                                                   bufferstring2:=bufferstring;
                                                   text_tools(mousex,mousey,bufferstring);
                                                   cursx:=Length(bufferstring);
                                                   DrawRectangle2(x-TextWidth(bufferstring2),y,x+2,y+TextHEight('A'),Get_GUI_Color(textbox_in),Get_GUI_Color(textbox_in));
                                                   outtextXY(x-TextWidth(bufferstring2),y,bufferstring);  //Redraw
                                                   x:=x-TextWidth(bufferstring2)+TextWidth(bufferstring);
                                                   bufferstring2:='';
                                                   open_menu:=false;
                                                   bufkey:='';
                                                  end;
  sleep(pliktrologisi_speed);
 end; //AN O XRISTIS DEN PATAEI KATI
 until bufkey<>'';
 DrawLine(x+2,borders[2],x+2,borders[4],Get_GUI_Color(textbox_in));  //Undraw Cursor

  if ((idle_time>=special_key_speed) and (special_key)) then   // Aytomatos katharismos Shift , Control , Alt meta apo ligous kyklous..
                       begin
                         shift_down:=false;
                         alt_down:=false;
                         control_down:=false;
                         special_key:=false;
                       end; 

 

   //HOT COMBINATIONS Control + ?
   bufkey2:=bufkey;

   if (Upcase2(bufkey)='Ù') then bufkey2:='V' else
   if (Upcase2(bufkey)='Ø') then bufkey2:='C' else
   if (Upcase2(bufkey)='×') then bufkey2:='X';

   if ((Equal(bufkey2,'X'))and (control_down) and (not masked)) then
                                                   begin
                                                    copypaste_mem:=bufferstring;
                                                    control_down:=false;
                                                    DrawRectangle2(borders[1],y,x,y+TextHeight('A'),Get_GUI_Color(textbox_in),Get_GUI_Color(textbox_in));
                                                    x:=borders[1];
                                                    bufferstring:='';
                                                    bufferstring2:='';
                                                    bufkey:='';
                                                   end else
   if ((Equal(bufkey2,'C'))and (control_down) and (not masked)) then
                                                   begin
                                                    copypaste_mem:=bufferstring;
                                                    control_down:=false;
                                                    bufkey:='';
                                                   end else
   if ((Equal(bufkey2,'V'))and (control_down) and (not masked)) then
                                                   begin
                                                    bufkey:=copypaste_mem;
                                                    type_suggestion:=TRUE;
                                                    control_down:=false;
                                                   end;



                  end;

if (not Equal(bufkey,'ENTER')) then  begin
                                   if ((Equal(bufkey,';')) and (not shift_down) and (Upcase(GetInternalKeyboardLanguage)='GREEK') ) then begin
                                                                                                                                           tonos_down:=true;
                                                                                                                                           goto skip_type;
                                                                                                                                         end;
                                   

                                   if Equal(bufkey,'LEFT ARROW') then begin
                                                                       wait_clear_key('LEFT ARROW');
                                                                       if cursx>0 then
                                                                         begin 
                                                                          cursx:=cursx-1;
                                                                         end;
                                                                      end else
                                   if Equal(bufkey,'RIGHT ARROW') then begin
                                                                       wait_clear_key('RIGHT ARROW');
                                                                       if cursx<Length(bufferstring) then
                                                                         begin
                                                                          cursx:=cursx+1;
                                                                         end;
                                                                      end else
                                   if Equal(bufkey,'F1') then begin
                                                                if Upcase(GetInternalKeyboardLanguage)='ENGLISH' then SetInternalKeyboardLanguage('GREEK') else
                                                                                                                      SetInternalKeyboardLanguage('ENGLISH');
                                                                draw_language(GetInternalKeyboardLanguage); 
                                                               end else
                                   {if Equal(bufkey,'SHIFT') then begin
                                                                    if not shift_down then
                                                                         begin 
                                                                          draw_button_complimentary(-1,shift_down,control_down,alt_down,bufkey); 
                                                                          shift_down:=true;
                                                                          special_key:=true;
                                                                          draw_button_complimentary(1,shift_down,control_down,alt_down,bufkey);
                                                                         end;
                                                                  end else      }
                                   if Equal(bufkey,'ALT') then begin
                                                                     if not alt_down then
                                                                         begin
                                                                          draw_button_complimentary(-1,shift_down,control_down,alt_down,bufkey); 
                                                                          alt_down:=true;
                                                                          special_key:=true;
                                                                          draw_button_complimentary(1,shift_down,control_down,alt_down,bufkey);
                                                                         end; 
                                                                end else
                                   if Equal(bufkey,'CONTROL') then begin
                                                                     if not control_down then
                                                                         begin
                                                                          draw_button_complimentary(-1,shift_down,control_down,alt_down,bufkey); 
                                                                          control_down:=true;
                                                                          special_key:=true;
                                                                          draw_button_complimentary(1,shift_down,control_down,alt_down,bufkey);
                                                                         end;  
                                                                    end else  
                                   if Equal(bufkey,'ESCAPE') then begin end else 
                                   if Equal(bufkey,'BACKSPACE') then begin
                                                                      bufferstring2:=''; 
                                    if Length(bufferstring)>0 then begin 
                                                                    cursx:=cursx-1;
                                                                    if (not masked) then begin
                                                                                          for i2:=x-TextWidth(bufferstring[Length(bufferstring)]) to x do drawline(i2,y,i2,y+TextHeight(bufferstring),Get_GUI_Color(textbox_in){GetBackgroundColor});
                                                                                          x:=x-TextWidth(bufferstring[Length(bufferstring)])
                                                                                         end else
                                                                                         begin
                                                                                          for i2:=x-TextWidth('*') to x do drawline(i2,y,i2,y+TextHeight('*'),Get_GUI_Color(textbox_in){GetBackgroundColor});
                                                                                          x:=x-TextWidth('*');
                                                                                         end;
                                                                    for i2:=1 to Length(bufferstring)-1  do bufferstring2:=bufferstring2+bufferstring[i2];
                                                                    bufferstring:=bufferstring2;
                                                                   end;
                                                                      end else
                                    if ((Length(bufkey)<=2) or (type_suggestion)) then
                                    begin 
                                     if ((x+TextWidth(bufkey)-GetX)<sizelength-2)  then //-2 gia na min svinetai tpt.. (enoxlitikes mavres grammes..)
                                         begin
                                          draw_button_complimentary(1,shift_down,control_down,alt_down,bufkey);
                                          //Draw operation type control,shift,alt etc..
                                          if shift_down then bufkey:=shift_mask(bufkey);
                                          // If needed add the tuna.. :) (Tuna = Tonos XOXOXO)
                                          if tonos_down then bufkey:=Greek_Tone(bufkey); 
                                          //make all needed changes..
                                          if (not masked) then begin
                                                                outtextXY(x,y,bufkey);
                                                                x:=x+TextWidth(bufkey);
                                                               end else
                                                               begin //Masked , yparxei password kai prepei na min fainetai..
                                                                outtextXY(x,y,'*');
                                                                x:=x+TextWidth('*');
                                                               end;
                                          cursx:=cursx+1;
                                          bufferstring:=bufferstring+bufkey;
                                          ////bufferstring:=Add2String(bufferstring,bufkey,cursx);
                                          type_suggestion:=false;
                                         end;
                                        shift_down:=false;
                                        alt_down:=false;
                                        control_down:=false;
                                        special_key:=false; //CLears all status..
                                        tonos_down:=false; //Clears tonos..
                                       // draw_button_complimentary(-1,shift_down,control_down,alt_down,bufkey);
                                    end;
                                  end;
skip_type:
until (Upcase(bufkey)='TAB') or (Upcase(bufkey)='ENTER') or (Upcase(bufkey)='ESCAPE');
if Upcase(bufkey)='ESCAPE' then bufferstring:=startingtxt;
if Upcase(bufkey)='TAB' then movefocus;
TextColor(txclr); 

ReadTextGUI2:=bufferstring;
//GoToXY(GetX,GetY+TextHeight(bufferstring)+1);
end;















 
begin
end.
