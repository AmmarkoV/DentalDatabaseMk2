unit security_gra;

interface
function get_original_cd_key:string;
function get_update_cd_key:string;

function save_cd_key(theval:string):boolean; 
function process_cd_key:boolean;
procedure read_cd_key;

procedure pass_sec_to_seperate;
function take_char(thenum:byte):integer;
function take_hash:string;
//SECURITY FUNCTION DELAY
procedure view_screen(mode:integer);

procedure disclaimer_menu; 

implementation 
uses windows,ammarunit,ammargui,apsfiles,string_stuff,random_generators,tools,settings,userlogin;
var characteristics:array[0..30] of integer;
    cdkey:array[1..24] of char;
    thebloatedkey:string;
    user_id,user_name,user_surname,user_add,user_tel,user_email:string;


function get_update_cd_key:string;
var retres:string;
begin
retres:='';
read_cd_key;
retres:=make_serial_string_like(thebloatedkey);
get_update_cd_key:=retres;
end;

function get_original_cd_key:string; 
begin 
read_cd_key; 
get_original_cd_key:=thebloatedkey;
end;

function save_cd_key(theval:string):boolean;
var retres:boolean;
    i:integer;
begin
retres:=true; 
 thebloatedkey:=theval;
 if Length(theval)<>37 then begin retres:=false; {MessageBox (0, '37' , ' ', 0);} end;
 if retres then theval:=make_serial_string_like(theval);
 if Length(theval)<>32 then begin retres:=false; {MessageBox (0, '32' , ' ', 0);} end;
 if retres then theval:=deflate_code_charset(theval);
 if Length(theval)<>24 then begin retres:=false; {MessageBox (0, '24' , ' ', 0);} end;
 if retres then
   begin 
    //make_serial_string_like
    for i:=1 to 24 do cdkey[i]:=theval[i];
   end;

save_cd_key:=retres;
end;

function looks_like_genuine:boolean;
var retres:boolean;
begin
retres:=false;
retres:=(take_char(1)+take_char(2)+take_char(3)+take_char(4)+take_char(8)+take_char(9)+take_char(18)+take_char(16)=2604);
retres:=retres or (take_char(0)+take_char(5)+take_char(6)+take_char(11)+take_char(14)=1836+512);
retres:=retres or (take_char(2)+take_char(4)+take_char(7)+take_char(15)+take_char(16)+take_char(19)=384+439);
//retres:=(take_char(18)=2504);
looks_like_genuine:=retres;
end;



function process_cd_key:boolean;
var retres:boolean;
    i:integer;
begin
// NIBBLE #1
characteristics[0]:=(ord(cdkey[1])+ord(cdkey[2])+ord(cdkey[3])+ord(cdkey[5])+ord(cdkey[6]));
characteristics[1]:=(ord(cdkey[1])-ord(cdkey[2]));
characteristics[2]:=(ord(cdkey[2])-ord(cdkey[5]));
characteristics[4]:=(ord(cdkey[5])-ord(cdkey[6]));
characteristics[3]:=(ord(cdkey[3]) xor ord(cdkey[4]));

// NIBBLE #2
characteristics[5]:=(ord(cdkey[7])+ord(cdkey[8])+ord(cdkey[9])+ord(cdkey[10])+ord(cdkey[11])+ord(cdkey[12]));
characteristics[6]:=(ord(cdkey[7])+ord(cdkey[8]));
characteristics[7]:=(ord(cdkey[7])+ord(cdkey[8])+ord(cdkey[9]));
characteristics[8]:=(ord(cdkey[9])-ord(cdkey[10]));
characteristics[9]:=characteristics[8];//abs(ord(cdkey[11])+ord(cdkey[12])+ord(cdkey[10]));

// NIBBLE #3
characteristics[10]:=(ord(cdkey[13])+ord(cdkey[14])+ord(cdkey[15])+ord(cdkey[16])+ord(cdkey[17])+ord(cdkey[18]));
characteristics[11]:=(ord(cdkey[13])+ord(cdkey[15]){-ord(cdkey[14])});
characteristics[12]:=(ord(cdkey[15])-ord(cdkey[17]));
characteristics[13]:=(ord(cdkey[18])-ord(cdkey[17]));


// NIBBLE #4
characteristics[14]:=(ord(cdkey[19])+ord(cdkey[20])+ord(cdkey[21])+ord(cdkey[22])+ord(cdkey[23]));
characteristics[15]:=(ord(cdkey[20])+ord(cdkey[21]));
characteristics[16]:=(ord(cdkey[21])+ord(cdkey[22]));
characteristics[17]:=(ord(cdkey[22]) xor ord(cdkey[23]));

//NIBBLE #ALL :)
characteristics[18]:=(characteristics[14]+characteristics[10]+characteristics[5]+characteristics[0]);
characteristics[19]:=StringAddUp1(user_id);
for i:=0 to 18 do characteristics[19]:=characteristics[19]+ord(characteristics[i]);
characteristics[19]:=characteristics[19] mod 255;
 
end;


procedure pass_sec_to_seperate;
var i:integer;
begin
for i:=1 to 19 do set_memory_int(i,characteristics[i]);
end;

function take_char(thenum:byte):integer;
begin
take_char:=characteristics[thenum];
end;

function take_hash:string;
var bufstr:string;
    i:integer;
begin
bufstr:='';
for i:=0 to 19 do bufstr:=bufstr+chr(characteristics[i]); 
take_hash:=bufstr;
end;


procedure write_nfo(cdkey,name,surname,username,addr,tel,email:string);
var fileused:text;
    destinationdir:pchar;
begin
destinationdir:='';
GetWindowsDirectory(destinationdir,MAX_PATH); 
assign(fileused,destinationdir+'\ddmk2.ini');
{$i-}
  rewrite(fileused);
{$i+}
 //if Ioresult<>0 then MessageBox (0, pchar('Δεν ήταν δυνατή η αποθήκευση της εγγραφής '+destinationdir) , 'Ammar CD-Key Protection', 0 + MB_ICONEXCLAMATION);
 if IOResult <> 0 then
  MessageBoxA(
    0,
    PAnsiChar(AnsiString(
      'Δεν ήταν δυνατή η αποθήκευση της εγγραφής ' + destinationdir
    )),
    PAnsiChar(AnsiString('Ammar CD-Key Protection')),
    MB_ICONEXCLAMATION
  );
 if Ioresult=0 then
   begin
    writeln(fileused,'[DDMk2]');
    writeln(fileused,'cdkey('+cdkey+')');
    writeln(fileused,'username('+username+')');
    writeln(fileused,'name('+name+')');
    writeln(fileused,'surname('+surname+')');
    writeln(fileused,'address('+addr+')');
    writeln(fileused,'telephone('+tel+')'); 
    writeln(fileused,'email('+email+')');
    close(fileused);
   end;
end;


procedure create_cd_key; 
var i:integer;
    border:array[1..4] of integer;
    label start_over;
begin
border[1]:=(GetMaxX - 640) div 2;
border[2]:=(GetMaxY - 280) div 2;
border[3]:=border[1]+640;
border[4]:=border[2]+280;


start_over:
flush_gui_memory(0); 

include_object('backwindow','window','ACD-Key protection System','','','',border[1],border[2],border[3],border[4]);
draw_all;
delete_object('backwindow','NAME'); 

include_object('comment1','comment','Username :','','','',border[1]+20,border[2]+50,0,0);
include_object('username','textbox','','','','',border[1]+108,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment5','comment','E-mail :','','','',border[1]+300,Y1(last_object)+3,0,0);
include_object('email','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment2','comment','Όνομα Χρήστη :','','','',border[1]+20,Y2(last_object)+13,0,0);
include_object('user','textbox','','','','',border[1]+108,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment3','comment','Επώνυμο Χρήστη :','','','',border[1]+300,Y1(last_object)+3,0,0);
include_object('surname','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment4','comment','Διεύθυνση :','','','',border[1]+20,Y2(last_object)+13,0,0);
include_object('address','textbox','','','','',border[1]+108,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS-ADDRESS'),0);
include_object('comment7','comment','Τηλέφωνο :','','','',border[1]+300,Y1(last_object)+3,0,0);
include_object('telephone','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);

DrawLine(border[1]+20,Y2(last_object)+13,border[3]-20,Y2(last_object)+13,ConvertRGB(0,0,0));


include_object('comment8','comment','Αλλαγή γλώσσας γίνεται πατώντας F1 , τα κεφαλαία/μικρά παίζουν ρόλο , προσοχή σε ομοιότητες','','','',border[1]+20,Y2(last_object)+26,0,0);
include_object('comment9','comment','στα ψηφία του κλειδιού όπως 1(ένα) και l(το αγγλικό λ) ή 0(μηδέν) και o(αγγλικό όμικρον)','','','',border[1]+20,Y2(last_object)+3,0,0);
include_object('comment6','comment','CD-Key :','','','',border[1]+20,Y2(last_object)+10,0,0);
include_object('cdkey','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,border[3]-20,0);

include_object('ok','buttonc','OK','','','',border[1]+20,Y2(last_object)+23,0,0);
include_object('howto','buttonc','Πως να αποκτήσω CD-Key?','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('exit','buttonc','Έξοδος','','','',X2(last_object)+5,Y1(last_object),0,0);

Flash_AmmarGUI('personregistraton');
delete_file('personregistraton');
set_gui_color(ConvertRGB(0,0,0),'comment');
draw_all;
repeat
 interact;

  if window_needs_redraw then begin 
                               DeFlash_AmmarGUI('personregistraton');
                               goto start_over;
                              end;

  if get_object_data('ok')='4' then
      begin
       set_button('ok',0); 
       if save_cd_key(get_object_data('cdkey')) then
         begin
          process_cd_key;
          if looks_like_genuine then begin
                                       write_nfo(get_object_data('cdkey'),get_object_data('username'),get_object_data('user'),get_object_data('surname'),get_object_data('address'),get_object_data('email'),get_object_data('telephone'));
                                       set_button('exit',1);
                                     end else
                                     MessageBox (0, 'Ο κωδικός που εισήχθει είναι σωστού format αλλά περιέχει κάποιο/α λάθη..'+#10+'Βεβαιωθείτε οτι έχετε πληκτρολογήσει σωστά όλα τα ψηφία με την σωστή σειρά , οτι τα κεφαλαία/μικρά είναι γραμμένα κατα τον ίδιο τρόπο καθώς παίζει ρόλο '+#10+'ενώ τέλος πως έχετε συμπεριλάβει στην πληκτρολόγηση και τους χαρακτήρες @ (shift+2) , $ (shift+4) , * (shift+8) και ? (shift + /) που τυχόν περιέχονται στο CD-Key σας ' , 'AmmarCD-Key Protection', 0 + MB_ICONASTERISK);
         end else MessageBox (0, 'Παρακαλώ εισάγετε τον κωδικό ο οποίος αναγράφεται στην συσκευασία του προϊόντος στο πεδίο cd-key..' , 'Ammar', 0 + MB_ICONASTERISK + MB_SYSTEMMODAL);
      end else
  if get_object_data('howto')='4' then
      begin
       set_button('howto',0); 
       RunExe('cmd /c "'+get_central_dir+'buy.htm"','minimized');
       MessageBox (0, 'Ένα νέο παράθυρο του internet browser σας άνοιξε για να σας συνδέσει με την ιστοσελίδα μας'+#10+'Πατήστε OK για να επιστρέψετε στο πρόγραμμα..' , 'Σύνδεση με την ιστοσελίδα μας', 0);
       DeFlash_AmmarGUI('personregistraton');
       goto start_over;
      end else
  if get_object_data('exit')='4' then
      begin
        i:=MessageBox (0, 'Είστε σίγουροι οτι θέλετε να συνεχίσετε ?'+#10+'Το πρόγραμμα θα λειτουργήσει σαν δοκιμαστική έκδοση..' , 'Ammar CD-Key Protection', 0 + MB_YESNO + MB_ICONQUESTION);
        if i=IDNO then begin
                         set_button('exit',0); 
                         DeFlash_AmmarGUI('personregistraton');
                         goto start_over;
                       end;
      end;

until GUI_Exit;

end;

procedure read_cd_key;
var fileused:text;
    destinationdir:pchar;
    bufstr:string;
    label end_read;
begin
destinationdir:='';
GetWindowsDirectory(destinationdir,MAX_PATH);
assign(fileused,destinationdir+'\ddmk2.ini');
{$i-}
  reset(fileused);
{$i+}
if Ioresult<>0 then create_cd_key else
  begin
   while not (eof(fileused)) do
    begin
     readln(fileused,bufstr);
     seperate_words(bufstr);
     if Equal(get_memory(1),'cdkey') then
           begin
            if not save_cd_key(get_memory(2)) then begin
                                                    close(fileused);
                                                    create_cd_key;
                                                    goto end_read;
                                                   end else
              begin
               process_cd_key;
               if not looks_like_genuine then begin
                                                close(fileused);
                                                create_cd_key;
                                                goto end_read;
                                               end
              end;
           end else
     if Equal(get_memory(1),'username') then user_id:=get_memory(2) else
     if Equal(get_memory(1),'name') then  user_name:=get_memory(2) else
     if Equal(get_memory(1),'surname') then user_surname:=get_memory(2) else
     if Equal(get_memory(1),'address') then user_add:=get_memory(2) else
     if Equal(get_memory(1),'email') then user_email:=get_memory(2) else
     if Equal(get_memory(1),'telephone') then user_tel:=get_memory(2); 
     

    end;  
   close(fileused);
  end;
end_read:
end;


procedure view_screen(mode:integer);
label pass_on;
begin
if mode=1 then DrawJpegCentered(get_central_dir+'Art\feat_1'); 
delay(250);

seperate_words('Initialization');
if get_memory(1)='off' then goto pass_on;
if mode<=32 then view_screen(mode+1);
pass_on:
end;





function write_disclaimer_page(theline:integer; var thenewline:integer):boolean;
var eulatxt:text;     
    eulastring:string;
    curline,keepcolor:integer;
    retres:boolean;
begin
retres:=false;
curline:=0;
set_gui_color(ConvertRGB(224,224,224),'COMMENT');
assign(eulatxt,'eula.txt');
{$i-}
 reset(eulatxt);
{$i+}
if Ioresult<>0 then begin
                     MessageBox (0, 'Δεν ήταν δυνατός ο εντοπισμός του eula.txt που περιέχει πληροφορίες σχετικά με την ’δεια Χρήσης του προϊόντος.. Επαναλάβετε την εγκατάσταση ή επικοινωνήστε με την εταιρία μας.' , 'Αδεια Χρήσης', 0 + MB_ICONASTERISK); 
                     thenewline:=-1;
                    end else
                    begin
                     eulastring:='';

                     while not eof(eulatxt) do
                       begin
                        readln(eulatxt,eulastring);
                        curline:=curline+1;
                        if curline>=theline then break;
                       end;

                     curline:=theline;
                     draw_text_area(eulastring,GridX(1,6),50,GridX(5,6),GridY(3,4));
                     while not eof(eulatxt) do
                       begin
                        readln(eulatxt,eulastring); 
                        draw_text_area(eulastring,GetX,GetY+15,GridX(5,6),GridY(3,4));
                        curline:=curline+1;
                        if GetY+150>GetMAxY then break;
                       end;
                       thenewline:=curline;

                       include_object('temp','layer','1','no','','',-1,GetY+15,-1,0);
                       if theline>0 then  include_object('back','buttonc','<- First Page','no','','',(GetMaxX div 2)-130,GetY+19,0,0);
                       if GetY+150>GetMAxY then  include_object('next','buttonc','Next Page ->','no','','',X2(last_object)+10,GetY+19,0,0) else
                                                 retres:=true;
                     close(eulatxt); 
                    end;
set_gui_color(ConvertRGB(0,0,0),'COMMENT');

write_disclaimer_page:=retres;
end;

procedure disclaimer_menu; 
var filechk:text;
    ok:boolean;
    curpage,nextpage:integer;
    all_read:boolean;
label bypass_disclaimer,start_screen;
begin 
ok:=false;
assign (filechk,'agreement');
{$i-}
reset(filechk);
{$i-}
if Ioresult=0 then begin
                    ok:=true;
                    close(filechk);
                    goto bypass_disclaimer;
                   end;

curpage:=0;
nextpage:=0;

start_screen:
clrscreen;
flush_gui_memory(0);
//include_object('backwindow','window','Welcome to Dental Database Mk2..','','','',Gridx(1,3),GridY(1,3),Gridx(2,3),GridY(2,3));
//draw_all;
//delete_object('backwindow','NAME');
SetFont('arial','greek',15,0,0,0);

all_read:=write_disclaimer_page(curpage,nextpage);
if nextpage=-1 then goto bypass_disclaimer;

if all_read then
  begin
   include_object('ok','buttonc','I read the license and I agree','no','','',(GetMaxX div 2)-80,GetY+45,0,0);
   include_object('exit','buttonc','I do not agree','no','','',X2(last_object)+5,Y1(last_object),0,0);
  end;
draw_all;
repeat
if window_needs_redraw then begin
                             goto start_screen;
                            end;
interact;
if get_object_data('back')='4' then begin
                                     set_button('back',0);
                                     curpage:=0;
                                     goto start_screen;
                                    end else
if get_object_data('next')='4' then begin
                                     set_button('next',0);
                                     curpage:=nextpage+1;
                                     goto start_screen;
                                    end else
if get_object_data('ok')='4' then begin
                                   assign (filechk,'agreement');
                                   {$i-}
                                    rewrite(filechk);
                                   {$i-}
                                   if Ioresult=0 then begin
                                                       Write_2_Log('User Agrees to disclaimer!');
                                                       writeln(filechk,'User agrees to disclaimer!');
                                                       ok:=true;
                                                       close(filechk);
                                                      end;
                                   break;
                                  end;
until GUI_Exit; 
bypass_disclaimer:
clrscreen;
if ok=false then halt; 
end;










begin
end.
