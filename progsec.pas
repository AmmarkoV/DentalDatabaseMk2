program psec;
uses windows,ammarunit,apsfiles,ammargui,random_generators,acd_database;
const wnd_x=640; wnd_y=490;
      version='0.3';
var i:integer;
    cdkey:array[1..24] of char;
    characteristics:array[0..30] of integer;
    characteristics_comp:array[0..30] of integer;
    user_id,created_key:string;

procedure protect_string(thestring:string; where:integer);
var inputcount:integer;
begin
inputcount:=0;    {
repeat
 inputcount:=inputcount+1;
 z:=z+1;
 read(inputtxt,bufc);
 triadaint:=ord(bufc);
 bufci:=ord(key[z]);
 i:=bufci xor triadaint;
 write(outtxt,Chr(i));
 if z>=keylength then z:=0;
until inputcount=Length(thestring);   }
end;

function compare2correct(showres:boolean):boolean;
var i:integer;
    bufstr:string;
    retres:boolean;
begin
retres:=true;
bufstr:='';
for i:=0 to 19 do
  begin
   if characteristics[i]<>characteristics_comp[i] then
         begin
           bufstr:=bufstr+'Difference stamp('+Convert2String(i)+') -> '+Convert2String(characteristics[i])+' -> '+Convert2String(characteristics_comp[i])+#10;
           retres:=false;
         end;
  end;
 if bufstr<>'' then
   begin
    retres:=false;
    if showres then MessageBox (0, pchar(bufstr) , 'Results', 0 + MB_ICONASTERISK); 
   end;
compare2correct:=retres;
end;


procedure revive_correct;
var i:integer;
begin
for i:=0 to 19 do  characteristics[i]:=characteristics_comp[i];
end;

procedure saveascorrect;
var i:integer; 
begin
for i:=0 to 19 do characteristics_comp[i]:=characteristics[i];
end;




function save_cd_key(theval:string):boolean;
var retres:boolean;
    i:integer;
begin
retres:=true; 
 if Length(theval)<>24 then retres:=false;

 if retres then
   begin 
    for i:=1 to 24 do cdkey[i]:=theval[i];
   end;

save_cd_key:=retres;
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


procedure print_characteristics;
var i:integer;
    bufstr:string;
begin
bufstr:='';
for i:=0 to 19 do bufstr:=bufstr+'characteristics['+Convert2String(i)+'] = '+Convert2String(characteristics[i])+','+Convert2String(characteristics_comp[i])+#10;
MessageBox (0, pchar(bufstr) , ' ', 0);
end;

function create_a_cd_key:boolean;
var tmp_pass,bufstr:string;
    i:integer;
    byt1,byt2:byte;
begin
tmp_pass:='';
clear_errors_generating;
revive_correct;

//Reconstruct Nibble #1
random_2_diffrence(characteristics[1]+characteristics[2]+characteristics[4],byt1,byt2);
cdkey[1]:=chr(byt1); cdkey[6]:=chr(byt2);
cdkey[2]:=chr(ord(cdkey[1])-characteristics[1]);
cdkey[5]:=chr(characteristics[4]+ord(cdkey[6]));
//cdkey[2]:=chr(ord(cdkey[5])+characteristics[2]);
cdkey[3]:=chr(characteristics[0]-ord(cdkey[1])-ord(cdkey[2])-ord(cdkey[5])-ord(cdkey[6])); 
cdkey[4]:=chr(ord(cdkey[3]) xor characteristics[3]);
 

//Reconstruct Nibble #2
random_2_addup(characteristics[6],byt1,byt2);
cdkey[7]:=chr(byt1); cdkey[8]:=chr(byt2);
cdkey[9]:=chr(characteristics[7]-characteristics[6]);
cdkey[10]:=chr(characteristics[7]-characteristics[6]-characteristics[8]);
random_2_addup(characteristics[5]+characteristics[6]-2*characteristics[7]+characteristics[8],byt1,byt2);
cdkey[11]:=chr(byt1); cdkey[12]:=chr(byt2);
 

//Reconstruct Nibble #3 
random_2_diffrence(characteristics[13],byt1,byt2);
cdkey[18]:=chr(byt1); cdkey[17]:=chr(byt2);
cdkey[15]:=chr(byt2+characteristics[12]);
cdkey[13]:=chr(characteristics[11]-ord(cdkey[15]));
random_2_addup(characteristics[10]-ord(cdkey[18])-ord(cdkey[17])-ord(cdkey[15])-ord(cdkey[13]),byt1,byt2);
cdkey[14]:=chr(byt1); cdkey[16]:=chr(byt2);
 


//Reconstruct Nibble #4
random_2_addup(characteristics[16],byt1,byt2);
cdkey[21]:=chr(byt1); cdkey[22]:=chr(byt2);
cdkey[23]:=chr(characteristics[17] xor byt2);

cdkey[20]:=chr(characteristics[15]-ord(cdkey[21]));
cdkey[19]:=chr(characteristics[14]-ord(cdkey[23])-ord(cdkey[22])-ord(cdkey[21])-ord(cdkey[20]));


 

 
created_key:='';
for i:=1 to 24 do created_key:=created_key+cdkey[i];
        
end;

function check_cd_key:boolean;
var retres:boolean;
    printres:string;
    i:integer;
begin
printres:='';
process_cd_key;

for i:=0 to 19 do
  printres:=printres+'stamp('+Convert2String(i)+') = '+Convert2String(characteristics[i])+#10;

//MessageBox (0, pchar(printres) , 'Results', 0 + MB_ICONASTERISK);
end;




procedure create_many_cd_keys(theprog:string);
var  i,lastrand,z,count,wrongcreation,already_used:integer;
     serial_ok:boolean;
     chk_key:string;
     label start_over;
begin
start_over:
flush_gui_memory(0); 
set_gui_color(ConvertRGB(0,0,0),'comment');

include_object('backwindow','window','ACD-Key protection System '+version,'','','',1,1,640,480);
draw_all;
delete_object('backwindow','NAME'); 

include_object('comment1','comment','Κωδικοί που έχουν παραχτεί :','','','',20,50,0,0);
include_object('codenum','textbox','0','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('99999999'),0);
include_object('comment2','comment','Σύνολο Λάθος :','','','',20,Y2(last_object)+13,0,0);
include_object('wrongnum','textbox','0','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('99999999'),0);
include_object('comment3','comment','Σύνολο Χρησιμοποιημένων :','','','',20,Y2(last_object)+13,0,0);
include_object('usednum','textbox','0','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('99999999'),0);
include_object('comment4','comment','Σύνολο προσπαθειών :','','','',20,Y2(last_object)+13,0,0);
include_object('totalnum','textbox','0','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('99999999'),0);

include_object('generate','buttonc','Παραγωγή','','','',20,Y2(last_object)+33,0,0);
include_object('exit','buttonc','Έξοδος','','','',X2(last_object)+5,Y1(last_object),0,0);
draw_all;
repeat
 interact;

  if window_needs_redraw then begin 
                               goto start_over;
                              end;

  if get_object_data('generate')='4' then
      begin
        set_button('generate',0);  
         i:=0; 
         count:=0;
         wrongcreation:=0;
         already_used:=0;
         lastrand:=0;
        repeat
        i:=i+1;
        create_a_cd_key;
        if not error_generating then
          begin
           process_cd_key;
           serial_ok:=compare2correct(false); 

           if serial_ok then
              begin  
               chk_key:=created_key;
               created_key:=make_string_serial_like(inflate_code_charset(created_key));
               if chk_key<>deflate_code_charset(make_serial_string_like(created_key)) then  MessageBox (0, 'Wrong Deflation' , ' ', 0) else
               if  ( not (User_Exists(theprog,created_key)) )  then
                  begin
                    count:=count+1;
                    Associate_User(theprog,created_key,'ausername','aname','asurname','aadd','0','',Convert2String(count));
                    set_object_data('codenum','value',Convert2String(count),0);
                    draw_object_by_name('codenum');
                  end else

                  begin  //KEY ALREADY USED
                   already_used:=already_used+1;
                   set_object_data('usednum','value',Convert2String(already_used),0);
                   draw_object_by_name('usednum');
                  end;

             end;

            set_object_data('totalnum','value',Convert2String(i),0);
            draw_object_by_name('totalnum');
 
          end else
          begin //ERROR CREATING KEY
           wrongcreation:=wrongcreation+1;
           set_object_data('wrongnum','value',Convert2String(wrongcreation),0);
           draw_object_by_name('wrongnum');
          end;

          if i>lastrand+30 then begin
                                  delay(100);
                                  randomize;
                                  delay(100);
                                  lastrand:=i;
                                 end;
          for z:=1 to 10 do interact;
        until (GUI_Exit);
      end;

until GUI_Exit;

end;




procedure main_menu; 
var  thegenkey,cod2,cod3:string;
     i,z:integer;
     serial_ok:boolean;
     label start_over;
begin
thegenkey:='';
start_over:
flush_gui_memory(0); 
set_gui_color(ConvertRGB(0,0,0),'comment');

include_object('backwindow','window','ACD-Key protection System '+version,'','','',1,1,640,480);
draw_all;
delete_object('backwindow','NAME'); 

include_object('comment1','comment','Όνομα Εφαρμογής :','','','',20,50,0,0);
include_object('application','textbox','atech','','','',X2(last_object)+5,Y1(last_object)-3,wnd_x-20,0);

include_object('comment2','comment','Αριθμός Πακεταρίσματος :','','','',20,Y2(last_object)+9,0,0);
include_object('packagenum','textbox','000000-000000-000000-000000','','','',X2(last_object)+5,Y1(last_object)-3,wnd_x-20,0);

include_object('comment3','comment','Όνομα Χρήστη :','','','',20,Y2(last_object)+9,0,0);
include_object('username','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,wnd_x-20,0);

include_object('comment4','comment','Σφραγίδα Συστήματος :','','','',20,Y2(last_object)+9,0,0);
include_object('seal','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,wnd_x-20,0);

DrawLine(20,Y2(last_object)+8,wnd_x-20,Y2(last_object)+8,ConvertRGB(0,0,0));

include_object('comment5','comment','Kωδικός :','','','',20,Y2(last_object)+19,0,0);
include_object('serial','textbox',thegenkey,'','','',X2(last_object)+5,Y1(last_object)-3,wnd_x-20,0);
include_object('comment6','comment','Kωδικός Inflated :','','','',20,Y2(last_object)+19,0,0);
include_object('inflated','textbox',cod2,'','','',X2(last_object)+5,Y1(last_object)-3,wnd_x-20,0);
include_object('comment7','comment','Kωδικός Ready :','','','',20,Y2(last_object)+19,0,0);
include_object('ready','textbox',cod3,'','','',X2(last_object)+5,Y1(last_object)-3,wnd_x-20,0);

DrawLine(20,Y2(last_object)+8,wnd_x-20,Y2(last_object)+8,ConvertRGB(0,0,0));

include_object('comment8','comment','Στοιχεία ιδιοκτήτη :','','','',20,Y2(last_object)+19,0,0);
include_object('comment9','comment','Όνομα :','','','',20,Y2(last_object)+19,0,0);
include_object('name','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment10','comment','Επώνυμο :','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('surname','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment11','comment','Τηλέφωνο :','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('phone','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment12','comment','E-Mail :','','','',20,Y2(last_object)+19,0,0);
include_object('email','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment13','comment','Address :','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('address','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);
include_object('comment14','comment','Άλλα :','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('others','textbox','','','','',X2(last_object)+5,Y1(last_object)-3,X2(last_object)+TextWidth('NABOUXODONOSORAS'),0);


include_object('generate','buttonc','Παραγωγή','','','',20,Y2(last_object)+23,0,0);
include_object('generate_random','buttonc','Παραγωγή τυχαίου','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('setup','buttonc','Setup','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('check','buttonc','Ορισμός ως Setup','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('see_setup','buttonc','Επισκόπηση Setup','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('exit','buttonc','Έξοδος','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('save','buttonc','Αποθήκευση στην βάση','','','',20,Y2(last_object)+3,0,0);
include_object('load','buttonc','Φόρτωση από βάση','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('save_setup','buttonc','Αποθήκευση Setup','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('load_setup','buttonc','Φόρτωση Setup','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('randomize','buttonc','Random','','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('mass_generate','buttonc','Μαζική Παραγωγή','','','',20,Y2(last_object)+3,0,0);

draw_all;
repeat
 interact;

  if window_needs_redraw then begin
                               thegenkey:=get_object_data('serial');
                               cod2:=get_object_data('inflated');
                               cod3:=get_object_data('ready');
                               goto start_over;
                              end;

  if get_object_data('mass_generate')='4' then
      begin
        set_button('mass_generate',0); 
        create_many_cd_keys(get_object_data('application'));
        goto start_over;
      end else
  if get_object_data('randomize')='4' then
      begin
        set_button('randomize',0);
        randomize;
        delay(400);
      end else
  if get_object_data('generate')='4' then
      begin
        set_button('generate',0);
        serial_ok:=false;
        if characteristics[18]=0 then begin
                                         MessageBox (0, 'Φορτώστε κάποιο setup' , ' ', 0 + MB_ICONASTERISK);
                                         serial_ok:=true;
                                      end;
        i:=0;
        repeat
        i:=i+1;
        create_a_cd_key;
        if not error_generating then
          begin
           process_cd_key;
           serial_ok:=compare2correct(false);

           if serial_ok then
              begin 
               set_object_data('serial','value',created_key,0);
               set_object_data('inflated','value',inflate_code_charset(get_object_data('serial')),0);
               set_object_data('ready','value',make_string_serial_like(get_object_data('inflated')),0);
               if get_object_data('serial')<>deflate_code_charset(make_serial_string_like(get_object_data('ready'))) then
                  begin
                   cod3:='';
                   if make_serial_string_like(get_object_data('ready'))<>get_object_data('inflated') then MessageBox (0, 'Error Simple Deflation' , ' ', 0);
                   if Length(get_object_data('serial'))<>Length(deflate_code_charset(make_serial_string_like(get_object_data('ready')))) then
                   cod3:='Wrong size '+Convert2String(Length(get_object_data('serial')))+' , '+Convert2String(Length(deflate_code_charset(make_serial_string_like(get_object_data('ready')))));
                   cod2:=deflate_code_charset(make_serial_string_like(get_object_data('ready')));
                   thegenkey:=get_object_data('serial');
                   for z:=1 to Length(thegenkey) do
                      begin
                       if thegenkey[z]<>cod2[z] then cod3:=cod3+' '+Convert2String(z)+'('+Convert2String(abs(ord(thegenkey[z])-ord(cod2[z])))+') '+Convert2String(ord(thegenkey[z]))+','+Convert2String(ord(cod2[z]));
                      end;
                   MessageBox (0, pchar('Wrong Deflation '+cod3) , ' ', 0);
                  end;
               
               draw_object_by_name('serial');
               draw_object_by_name('inflated');
               draw_object_by_name('ready');
               break;
             end;
          end;
        until ((serial_ok) or (i>45));
 
      end else
  if get_object_data('generate_random')='4' then
      begin
        set_button('generate_random',0);
        set_object_data('serial','value',create_password(6)+create_password(6)+create_password(6)+create_password(6),0);
        set_object_data('inflated','value',inflate_code_charset(get_object_data('serial')),0);
        set_object_data('ready','value',make_string_serial_like(get_object_data('inflated')),0);

        draw_object_by_name('serial');
        draw_object_by_name('inflated');
        draw_object_by_name('ready'); 
      end
       else
  if get_object_data('setup')='4' then
      begin
        set_button('setup',0);
        thegenkey:='';
        for i:=1 to 24 do begin
                           if i<=19 then thegenkey:=thegenkey+chr(128) else
                                         thegenkey:=thegenkey+chr(50);
                          end;
        set_object_data('serial','value',thegenkey,0);
        set_object_data('inflated','value',inflate_code_charset(get_object_data('serial')),0);
        set_object_data('ready','value',make_string_serial_like(get_object_data('inflated')),0);
        draw_object_by_name('serial');
        draw_object_by_name('inflated');
        draw_object_by_name('ready'); 

        if save_cd_key(get_object_data('serial')) then process_cd_key else
                                                       MessageBox (0, 'Could not pass cd-key to memory!' , ' ', 0);
        saveascorrect;
      end else
  if get_object_data('see_setup')='4' then
      begin
        set_button('see_setup',0);
        if save_cd_key(get_object_data('serial')) then
          begin
           process_cd_key;
           print_characteristics;
          end else  MessageBox (0, 'Could not pass cd-key to memory!' , ' ', 0);
      end else 
  if get_object_data('save')='4' then
      begin
        set_button('save',0);
        if save_cd_key(get_object_data('serial')) then
           begin
             process_cd_key;
             i:=IDYES;
             if not compare2correct(false) then i:=MessageBox (0, 'Attempting to store wrong key.. Continue ?' , ' ', 0 + MB_YESNO + MB_ICONQUESTION);
             if i=IDYES then
               begin
                 if User_Exists(get_object_data('application'),get_object_data('ready')) then MessageBox (0, 'Ο Κωδικός αυτός είναι καταχωρημένος' , ' ', 0) else
                 Associate_User(get_object_data('application'),get_object_data('ready'),get_object_data('username'),get_object_data('name'),get_object_data('surname'),get_object_data('address'),get_object_data('phone'),get_object_data('email'),get_object_data('others'));
               end;
           end;
       delay(200);
      end;
  if get_object_data('check')='4' then
      begin
        set_button('check',0);
        if save_cd_key(get_object_data('serial')) then check_cd_key else
                                                       MessageBox (0, 'Could not pass cd-key to memory!' , ' ', 0);
        saveascorrect;
      end;
until GUI_Exit;


end;





begin
randomize;
load_skin('');
Initgraph('Ammar`s SerialNum Generator',640,480,0);
SetFont('arial','greek',15,0,0,0);
 SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
 TEst_Converter;
 main_menu;

 SetPriorityClass(GetCurrentProcess,NORMAL_PRIORITY_CLASS);
CloseGraph;
Halt;
end.
