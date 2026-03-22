unit the_works;

interface

function Get_Work_Str(the_mem,slot:integer):string; 
function Get_Work_Int(the_mem,slot:integer):integer;
procedure GUI_prices;
//procedure Get_Work(the_mem:integer; var the_code,price:integer; the_str_code,the_alias:string  );
procedure Set_Work(the_mem,the_code:integer; the_str_code,the_alias:string; price:integer );
procedure Init_Works;
procedure Save_Works;
function Select_Works(category_only:boolean):string;
function Get_Work_Mem_From_Code(bufstr:string):integer;
function Get_Str_From_Mem(the_type,the_mem:integer):string;
function Get_Int_From_Mem(the_type,the_mem:integer):integer;

implementation 
uses windows,ammarunit,ammargui,apsfiles,string_stuff,userlogin,settings;
const MAX_ALIAS_TYPES=15;
      MAX_ALIASES=200;
var alias_types:array[1..MAX_ALIAS_TYPES] of string;
    alias_types_add:array[1..2,1..MAX_ALIAS_TYPES] of integer;
    alias_types_count,alias_count:integer;
    alias_str:array[1..2,1..MAX_ALIASES] of string;
    alias_int:array[1..2,1..MAX_ALIASES] of integer;

procedure Add_Alias_Type(the_alias:string; pointsto:integer);
begin
alias_types_count:=alias_types_count+1;
if alias_types_count<=MAX_ALIAS_TYPES then begin
                                            alias_types[alias_types_count]:=the_alias;
                                            alias_types_add[1,alias_types_count]:=pointsto;
                                           end;
end;

procedure Add_Alias(the_code:integer; the_str_code,the_alias:string; price:integer );
begin
alias_count:=alias_count+1;
if alias_count<=MAX_ALIASES then begin
                                  alias_str[1,alias_count]:=the_str_code;
                                  alias_str[2,alias_count]:=the_alias;
                                  alias_int[1,alias_count]:=the_code; 
                                  alias_int[2,alias_count]:=price;
                                 end;
end;

function Get_Work_Str(the_mem,slot:integer):string;
begin  // slot = 1 = string code , slot = 2 = alias dld perigrafi
Get_Work_Str:=alias_str[slot,the_mem];
end;

function Get_Work_Int(the_mem,slot:integer):integer;
begin  // slot = 1 = the_code , slot = 2 = price
Get_Work_Int:=alias_int[slot,the_mem];
end;


{procedure Get_Work(the_mem:integer; var the_code,price:integer; the_str_code,the_alias:string  );
begin
the_str_code:=alias_str[1,the_mem];
the_alias:=alias_str[2,the_mem];
the_code:=alias_int[1,the_mem];
price:=alias_int[2,the_mem];
end;              }

procedure Set_Work(the_mem,the_code:integer; the_str_code,the_alias:string; price:integer );
begin
alias_str[1,the_mem]:=the_str_code;
alias_str[2,the_mem]:=the_alias;
alias_int[1,the_mem]:=the_code;
alias_int[2,the_mem]:=price;
end;

function Get_Str_From_Mem(the_type,the_mem:integer):string;
begin
Get_Str_From_Mem:=alias_str[the_type,the_mem];
end;

function Get_Int_From_Mem(the_type,the_mem:integer):integer;
begin
Get_Int_From_Mem:=alias_int[the_type,the_mem];
end;

function Get_Work_Mem_From_Code(bufstr:string):integer;
var i,z,retres:integer;
begin
Val(bufstr,z,retres); 
retres:=-1;
i:=1;
while i<=alias_count do
        begin
         if alias_int[1,i]=z then begin 
                                   retres:=i;
                                   break;
                                  end;
         i:=i+1;
        end; 
Get_Work_Mem_From_Code:=retres;
end;

procedure Init_Works;
var fileused:text;
    aline:string;
    i,z,y:integer;
begin
alias_types_count:=0;
alias_count:=0;
assign(fileused,'Database\works_list.dat');
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then begin
                    while (not eof(fileused)) do
                          begin
                           readln(fileused,aline);
                           seperate_words(aline);
                           if Upcase(get_memory(1))='ALIAS_TYPE' then begin
                                                                       if ((alias_types_count>0) and (alias_types_count<MAX_ALIAS_TYPES)) then
                                                                             begin
                                                                               alias_types_add[2,alias_types_count]:=alias_count; 
                                                                             end;
                                                                          Add_Alias_Type(get_memory(2),alias_count+1);
                                                                      end;
                           if Upcase(get_memory(1))='ALIAS' then begin
                                                                   Val(get_memory(2),i,z);
                                                                   Val(get_memory(5),y,z);
                                                                   Add_Alias(i,get_memory(3),get_memory(4),y);
                                                                 end;
                          end;
                    close(fileused); 
                    alias_types_add[2,alias_types_count]:=alias_count; // O Teleytaios alias type pianei mexri kai tin teleytaia eggrafi..
                   end;

end;


procedure Print_Works;
var fileused:text;
    datesnstuff:array[1..4]of word;  
    i,z:integer;
begin
GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]); 
assign(fileused,'Cache\works_printout.html');
{$i-}
rewrite(fileused);
{$i+}
if Ioresult=0 then
  begin
   writeln(fileused,'<html><head><title>Κατάλογος εργασιών</title><meta http-equiv="Content-Type" content="text/html; charset=windows-1253"></head>');
writeln(fileused,'<body bgcolor=#FFFFFF text=#000000><BASEFONT face="Verdana">');

writeln(fileused,'<center><table><tr><td width=700><center><h2>');
writeln(fileused,'Κατάλογος διαθέσιμων εργασιών '+Convert2String(datesnstuff[1])+'/'+Convert2String(datesnstuff[3])+'/'+Convert2String(datesnstuff[4])+'</center>');
writeln(fileused,'</td><td><center><img src="../logo.jpg" height=50><br><font bgcolor=#CCCCCC size=1>Powered by A-TECH</font></center></td></tr>');
writeln(fileused,'<tr><td>');

writeln(fileused,'<table>');
for i:=1 to alias_types_count do
   begin
     writeln(fileused,'<tr bgcolor=#CCCCCC><td colspan=4>'+alias_types[i]+' - '+Convert2String(alias_types_add[2,i]-alias_types_add[1,i]+1)+'</td></tr>');
     writeln(fileused,'<tr><td>Κωδικός</td><td>Όνομα Εργασίας</td><td>Τιμή</td><td>Συντ.</td></tr>');
     for z:=alias_types_add[1,i] to alias_types_add[2,i] do
        begin
          writeln(fileused,'<tr>');
          writeln(fileused,'<td>'+Convert2String(alias_int[1,z])+'</td>');
          writeln(fileused,'<td>'+alias_str[2,z]+'</td>');
          writeln(fileused,'<td>'+Convert2String(alias_int[2,z])+'&euro;</td>');
          writeln(fileused,'<td>'+alias_str[1,z]+'</td>');
          writeln(fileused,'</tr>');
        end;
      
   end;

writeln(fileused,'</table>');

writeln(fileused,'</td></tr></table></center><hr>');
writeln(fileused,'</body>');
writeln(fileused,'</html>');
close(fileused);
RunEXEWait(get_external_browser+' "'+get_central_dir+'Cache\works_printout.html"',false);
MessageBox (0, 'Πατήστε OK όταν τελειώσετε με την διαδικασία εκτύπωσης' , ' ', 0 + MB_ICONASTERISK);
  end;
end;


procedure Save_Works;
var fileused:text;
    aline:string;
    i,z,y:integer;
    datesnstuff:array[1..4]of word;  
begin
GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]); 
assign(fileused,'Database\works_list.dat');
{$i-}
rewrite(fileused);
{$i+}
if Ioresult=0 then begin
                    writeln(fileused,'/////// Generated by Dental Database ///////');
                    writeln(fileused,'/////// Last Change '+Convert2String(datesnstuff[1])+'/'+Convert2String(datesnstuff[3])+'/'+Convert2String(datesnstuff[4])+'   ////////');
                    writeln(fileused,'/////// by '+Get_Current_User+'   ////////');
                    for i:=1 to alias_types_count do
                     begin
                      writeln(fileused,'/////// '+alias_types[i]+' ////////');
                      writeln(fileused,'alias_type('+alias_types[i]+')');
                      for z:=alias_types_add[1,i] to alias_types_add[2,i]do
                            begin 
                             write(fileused,'alias(',alias_int[1,z],',');
                             write(fileused,alias_str[1,z],',');
                             write(fileused,alias_str[2,z],',');
                             writeln(fileused,alias_int[2,z],')');
                            end;
                     end;
                    close(fileused);  
                   end;

end;


function Select_A_Work(startfrom,endfrom:integer):string;
var i,x,ypos,yexit,space:integer;
    lastobj,retres:string;
begin
flush_gui_memory(0);
space:=30;
//ypos:=100 300+(endfrom-startfrom+2)*space

include_object('Window_Works_Select_A_Work','window','Επιλογή εργασίας','Works_Select_A_Work','','',(GetMaxX div 2)-350,000,(GetMaxX div 2)+350,200+(endfrom-startfrom+3)*space);
yexit:=Y2('Window_Works_Select_A_Work');
draw_all;
flush_gui_memory(0);
if ((startfrom>0)and(endfrom<=MAX_ALIASES)and(startfrom<endfrom)) then
     begin
      for i:=startfrom to endfrom do
       begin
       retres:=alias_str[2,i]+' - '+Convert2String(alias_int[2,i]);
       if ((alias_str[2,i]='') and (alias_int[2,i]=0) ) then retres:='κενό';
       include_object('Works_Select_BTN('+Convert2String(i),'buttonc',retres,'Works_Select_A_Work','','',-1,50+(i-startfrom)*space,-1,0);
       end;
     end; 
include_object('exit2','buttonc','Έξοδος','Works_Select_A_Work','','',-1,Y2(last_object)+20,-1,0);
draw_all; 
repeat
interact;
lastobj:=return_last_mouse_object;
if get_object_data('exit2')='4' then begin
                                       retres:='';
                                     end else
if get_object_data(lastobj)='4' then begin
                                       if (lastobj<>'') then seperate_words(lastobj);  
                                       if (get_memory(1)='Works_Select_BTN') then
                                                                                  begin 
                                                                                    Val(get_memory(2),i,space); 
                                                                                    retres:=Convert2String(alias_int[1,i]);
                                                                                    set_button('exit2',1);
                                                                                    break;
                                                                                  end; 
                                      end;
until get_object_data('exit2')='4';  
Select_A_Work:=retres;
end;



function Select_Works(category_only:boolean):string;
var i,x,space,yexit:integer;
    lastobj,retres:string;
    label start_select_works,return_select_works;
begin
start_select_works:
flush_gui_memory(0);
space:=30;
include_object('Window_Works_Select_Work','window','Επιλογή κατηγορίας εργασίας','Works_Select_Work','','',(GetMaxX div 2)-150,200,(GetMaxX div 2)+150,300+(alias_types_count+2)*space);
yexit:=Y2('Window_Works_Select_Work');
draw_all;
flush_gui_memory(0);
if alias_types_count>0 then
     begin
      for i:=1 to alias_types_count do
       begin
       retres:=alias_types[i]; 
       include_object('Works_Select_BTN('+Convert2String(i),'buttonc',retres,'Works_Select_Work','','',-1,250+i*space,-1,0);
       end;
     end; 
include_object('exit','buttonc','Έξοδος','Works_Select_Work','','',-1,yexit-40,-1,0);
draw_all;
repeat
interact;
lastobj:=return_last_mouse_object;
if GUI_Exit then begin
                   retres:='';
                   goto return_select_works;
                 end else
if get_object_data(lastobj)='4' then begin
                                       if (lastobj<>'') then seperate_words(lastobj);  
                                       if (get_memory(1)='Works_Select_BTN') then
                                                                                  begin 
                                                                                   if ( not (category_only) ) then
                                                                                      begin
                                                                                       Val(get_memory(2),i,space);
                                                                                       retres:=Select_A_Work(alias_types_add[1,i],alias_types_add[2,i]);

                                                                                        if retres='' then goto start_select_works else
                                                                                                          goto return_select_works;
                                                                                        set_button('exit',1);
                                                                                        break;
                                                                                      end else
                                                                                      begin
                                                                                      //Epistrefoume tin katigoria pou epilexthike mono (category_only)!
                                                                                        retres:=get_memory(2);
                                                                                        goto return_select_works;
                                                                                      end;
                                                                                  end; 
                                      end;
until GUI_Exit;
return_select_works:
Select_Works:=retres; 
end;

function Insert_Alias(category:integer):integer;
var i,retres:integer;
begin
retres:=-1;
if MAX_ALIASES>alias_count+1 then
begin 
alias_count:=alias_count+1; 
for i:=alias_count-1 downto alias_types_add[2,category] do //pane oles oi kataxwriseis mia thesi deksia
   begin
    alias_str[1,i+1]:=alias_str[1,i];
    alias_str[2,i+1]:=alias_str[2,i];
    alias_int[1,i+1]:=alias_int[1,i];
    alias_int[2,i+1]:=alias_int[2,i]; 
   end;
alias_types_add[2,category]:=alias_types_add[2,category]+1;
retres:=alias_types_add[2,category];
alias_str[1,retres]:='';
alias_str[2,retres]:='';
alias_int[1,retres]:=0;
alias_int[2,retres]:=0;

if alias_types_count>category then
   begin
    for i:=category+1 to alias_types_count do  //Move addresses if necessary..
       begin
        alias_types_add[1,category]:=alias_types_add[1,category]+1;
        alias_types_add[2,category]:=alias_types_add[2,category]+1;
       end;
   end;

end else
 MessageBox (0,pchar('Η συγκεκριμένη έκδοση της βάσης υποστηρίζει χρήση έως και '+Convert2String(MAX_ALIASES)+' εργασιών.. '), 'Όριο Εργασιών', 0 + MB_ICONASTERISK);

Insert_Alias:=retres;
end;




function Remove_Alias(themem:integer):integer;
var i,z,retres:integer;
begin
retres:=-1;
if alias_count>0 then
begin 
alias_count:=alias_count-1;
for i:=themem+1 to alias_count+1 do //pane oles oi kataxwriseis mia thesi deksia
   begin
    alias_str[1,i-1]:=alias_str[1,i];
    alias_str[2,i-1]:=alias_str[2,i];
    alias_int[1,i-1]:=alias_int[1,i];
    alias_int[2,i-1]:=alias_int[2,i];
   end;

z:=0;
for i:=1 to alias_types_count do
  begin
   if ( (alias_types_add[1,i]<=themem) and (themem<=alias_types_add[2,i]) )   then
      begin
       //TODO
      end;
  end;

       {
if alias_types_count>category then
   begin
    for i:=category+1 to alias_types_count do  //Move addresses if necessary..
       begin
        alias_types_add[1,category]:=alias_types_add[1,category]+1;
        alias_types_add[2,category]:=alias_types_add[2,category]+1;
       end;
   end;        }

end else
 MessageBox (0,pchar('Η συγκεκριμένη έκδοση της βάσης υποστηρίζει χρήση έως και '+Convert2String(MAX_ALIASES)+' εργασιών.. '), 'Όριο Εργασιών', 0 + MB_ICONASTERISK);

Remove_Alias:=retres;
end;


procedure GUI_Set_A_Work(mem_spot:integer);
var the_mem,the_code,price:integer;
    startx,starty,blocky,tbox,i,z:integer;
    the_str_code,the_alias:string;
begin
blocky:=30;
the_str_code:=Get_Work_Str(mem_spot,1);
the_alias:=Get_Work_Str(mem_spot,2);
the_code:=Get_Work_Int(mem_spot,1);
price:=Get_Work_Int(mem_spot,2);
flush_gui_memory(0);
tbox:=TextWidth('XXXX');
startx:=GridX(1,3)-70;
starty:=200;
include_object('window1','window','Αλλαγή στo '+Convert2String(mem_spot),'no','','',startx,starty,GetMaxX-startx,starty+300);
draw_all;
delete_object('window1','name');
starty:=starty+60;
include_object('code','textbox',Convert2String(the_code),'no','','',startx+20,starty,startx+tbox*5,0);
include_object('strcode','textbox',the_str_code,'no','','',X2(last_object)+20,starty,X2(last_object)+tbox*7,0);
include_object('price','textbox',Convert2String(price),'no','','',X2(last_object)+20,starty,X2(last_object)+tbox*5,0);
starty:=starty+2*blocky;
include_object('description','textbox',the_alias,'no','','',startx+20,starty,GetMaxX-startx-20,0);
                                                    
include_object('comment_code','comment','Κωδικός','no','','',X1('code'),Y1('code')-22,0,0);
include_object('comment_strcode','comment','Συντόμευση','no','','',X1('strcode'),Y1('strcode')-22,0,0);
include_object('comment_price','comment','Τιμή','no','','',X1('price'),Y1('price')-22,0,0);
include_object('comment_Ergasia','comment','Περιγραφή','no','','',X1('description'),Y1('description')-22,0,0);

include_object('ok','buttonc','Αλλαγή','no','','',-1,starty+blocky*4,-1,0);
include_object('exit','buttonc','Έξοδος','no','','',-1,starty+blocky*5,-1,0);
draw_all;
repeat
 interact;
 if get_object_data('ok')='4' then begin
                                    set_button('ok',0);
                                    Val(get_object_data('code'),z,i);
                                    if ( (Get_Work_Mem_From_Code(get_object_data('code'))<>-1) and (Get_Work_Mem_From_Code(get_object_data('code'))<>mem_spot) ) then
                                     begin
                                      MessageBox (0, pchar('Έχετε δηλώσει λάθος κωδικό εργασία '+Convert2String(Get_Work_Mem_From_Code(get_object_data('code')))) , ' ', 0+ MB_ICONASTERISK + MB_SYSTEMMODAL);
                                     end else
                                    if z<>0 then
                                     begin  
                                      set_button('exit',1);
                                      Val(get_object_data('code'),z,i);
                                      the_code:=z;
                                      Val(get_object_data('price'),z,i);
                                      price:=z;
                                      the_alias:=get_object_data('description');
                                      the_str_code:=get_object_data('strcode');
                                      Set_Work(mem_spot,the_code,the_str_code,the_alias,price);
                                      break;
                                     end else
                                     MessageBox (0, 'Δεν μπορείτε να χρησιμοποιήσετε τον κωδικό 0 , είναι δεσμευμένος' , ' ', 0 + MB_ICONASTERISK + MB_SYSTEMMODAL);
                                  end;
 until GUI_Exit;
end;



procedure GUI_prices;
var startx,starty,blocky,tbox,i,z:integer;
    retres:string;
    mem_spot,the_mem,the_code,price:integer;
    the_str_code,the_alias:string;
label start_gui_prices;
begin 
start_gui_prices:

 flush_gui_memory(0);
 set_gui_color(ConvertRGB(0,0,0),'comment');
 draw_background(3);

 tbox:=TextWidth('XXXX');
 startx:=GridX(1,3)-70;
 starty:=200; 
 blocky:=30;
 include_object('window1','window','Αλλαγή στις τιμές','no','','',startx,starty,GetMaxX-startx,starty+230);
 draw_all;
 delete_object('window1','name');
 starty:=starty+40;
 include_object('new','buttonc','Προσθήκη κάποιας τιμής σε κατηγορία','no','','',-1,starty+blocky*0,-1,0);
 include_object('start','buttonc','Αλλαγή σε κάποια τιμή','no','','',-1,starty+blocky*1,-1,0);
 include_object('print','buttonc','Εκτύπωση καταλόγων τιμών','no','','',-1,starty+blocky*2,-1,0);
 include_object('save','buttonc','Αποθήκευση','no','','',-1,starty+blocky*3,-1,0);
 include_object('exit','buttonc','Έξοδος','no','','',-1,starty+blocky*4,-1,0);
 draw_all;
 repeat
  interact;
    if get_object_data('new')='4' then begin
                                        set_button('new',0); 
                                        retres:=Select_Works(true);
                                        Val(retres,mem_spot,i);
                                        mem_spot:=Insert_Alias(mem_spot);
                                        if mem_spot<>-1 then
                                           begin
                                            GUI_Set_A_Work(mem_spot);
                                            goto start_gui_prices;
                                           end; 
                                       end else
    if get_object_data('print')='4' then begin
                                            set_button('print',0);
                                            Print_Works;
                                            goto start_gui_prices;
                                           end else
    if get_object_data('save')='4' then begin
                                            set_button('save',0);
                                            DrawApsXY('greenbtn',X1('save')-GetApsInfo('greenbtn','sizex')-5,Y1('save')+3);
                                            Save_Works;
                                           end else
    if get_object_data('start')='4' then begin
                                          set_button('start',0);
                                          retres:=Select_Works(false);
                                          if retres<>'' then
                                           begin
                                            mem_spot:=0;
                                            mem_spot:=Get_Work_Mem_From_Code(retres);
                                            if mem_spot<>0 then
                                                 begin
                                                   //Get_Work(mem_spot,the_code,price,the_str_code,the_alias); 
                                                    GUI_Set_A_Work(mem_spot);
                                                   {the_str_code:=Get_Work_Str(mem_spot,1);
                                                   the_alias:=Get_Work_Str(mem_spot,2); 
                                                   the_code:=Get_Work_Int(mem_spot,1); 
                                                   price:=Get_Work_Int(mem_spot,2); 
                                                    flush_gui_memory(0);
                                                    startx:=GridX(1,3)-70;
                                                    starty:=200; 
                                                    include_object('window1','window','Αλλαγή στo '+retres,'no','','',startx,starty,GetMaxX-startx,starty+300);
                                                    draw_all;
                                                    delete_object('window1','name');
                                                    starty:=starty+60;
                                                    include_object('code','textbox',Convert2String(the_code),'no','','',startx+20,starty,startx+tbox*5,0);
                                                    include_object('strcode','textbox',the_str_code,'no','','',X2(last_object)+20,starty,X2(last_object)+tbox*7,0);
                                                    include_object('price','textbox',Convert2String(price),'no','','',X2(last_object)+20,starty,X2(last_object)+tbox*5,0);
                                                    starty:=starty+2*blocky;
                                                    include_object('description','textbox',the_alias,'no','','',startx+20,starty,GetMaxX-startx-20,0);
                                                    
                                                    include_object('comment_code','comment','Κωδικός','no','','',X1('code'),Y1('code')-22,0,0);
                                                    include_object('comment_strcode','comment','Συντόμευση','no','','',X1('strcode'),Y1('strcode')-22,0,0);
                                                    include_object('comment_price','comment','Τιμή','no','','',X1('price'),Y1('price')-22,0,0);
                                                    include_object('comment_Ergasia','comment','Περιγραφή','no','','',X1('description'),Y1('description')-22,0,0);

                                                    include_object('ok','buttonc','Αλλαγή','no','','',-1,starty+blocky*4,-1,0);
                                                    include_object('exit','buttonc','Έξοδος','no','','',-1,starty+blocky*5,-1,0);
                                                    draw_all; 
                                                    repeat
                                                     interact;
                                                     if get_object_data('ok')='4' then begin
                                                                                        set_button('ok',0); 
                                                                                        set_button('exit',1);
                                                                                        Val(get_object_data('code'),z,i);
                                                                                        the_code:=z;
                                                                                        Val(get_object_data('price'),z,i);
                                                                                        price:=z;
                                                                                        the_alias:=get_object_data('description');
                                                                                        the_str_code:=get_object_data('strcode'); 
                                                                                        Set_Work(mem_spot,the_code,the_str_code,the_alias,price);
                                                                                       end;
                                                    until GUI_Exit; }
                                                   //function Set_Work(the_mem,the_code:integer; the_str_code,the_alias:string; price:integer );
                                                 end;
                                           end;
                                          goto start_gui_prices;
                                         end;
 until GUI_Exit;

end;



begin
end.
