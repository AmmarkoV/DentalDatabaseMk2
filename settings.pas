unit settings;
{$H+}
interface
 

function alert_level:boolean; 
procedure signal_alert;

function get_update_stat:integer;
procedure set_update_stat(thestat:integer);

function get_need_restart:boolean;
procedure set_need_restart(theval:boolean);

procedure settings_menu;
function get_backup_device:string;
function get_external_shortcut_tool1:string;
function get_external_scheduler:string;
function get_external_editor:string;
function get_external_browser:string;
function get_external_synctool:string;
function get_external_packer:string;
function get_external_encrypt:string;
function get_external_image_convert:string;
function get_external_video_input:string;
function get_central_dir:string;
function is_master_computer:boolean;
function get_setting(count:integer):string;
procedure Init_Settings;

implementation 
uses windows,ammarunit,apsfiles,ammargui,string_stuff,backups,userlogin,tools,pumacrypt,security_gra,sms_send;

Type
  TFileName = Array[0..Max_Path] Of Char;
const MAX_SETTINGS=15;
var  thesettings:array[1..MAX_SETTINGS]of string;// 1=Update Server , 2=Browser , 3=Editor 15=shortcut tool
     authentication:array[1..2]of string;
     curendir:string;

     restart_issued,is_master:boolean;
     update_stat:integer;
     alert:boolean;


function alert_level:boolean;
begin
alert_level:=alert;
end;

procedure signal_alert;
begin
alert:=true;
end;

function is_master_computer:boolean;
begin
is_master_computer:=is_master;
end;

procedure set_update_stat(thestat:integer);
begin
update_stat:=thestat;
end;

function get_update_stat:integer;
begin
get_update_stat:=update_stat;
end;

procedure set_need_restart(theval:boolean);
begin
restart_issued:=theval;
end;

function get_need_restart:boolean;
begin
get_need_restart:=restart_issued;
end;


Function SelectFileGeneral(Var FName:TFileName; Extention:String; Open:Boolean): Boolean;
Const 
  Ext    : PChar = 'txt';
Var
  NameRec : OpenFileName;
  Foldertmp,Filtertmp:String;
  Filter : PChar;
  loci:integer;
  i:integer;
Begin
GetDir(0,Foldertmp);
  seperate_words(Extention);
  i:=1;
  Filtertmp:='';
  while get_memory(i)<>'' do begin
                          Filtertmp:=Filtertmp+get_memory(i)+#0+'*.'+get_memory(i+1)+#0;
                          i:=i+2;
                         end;
  Filtertmp:=Filtertmp+'All files (*.*)'#0'*.*'#0#0;
  Filter:=Pchar(Filtertmp);
  FillChar(NameRec,SizeOf(NameRec),0);
  FName[0] := #0;
  With NameRec Do
    Begin
      LStructSize := SizeOf(NameRec);
      HWndOwner   := WindowHandle;
      LpStrFilter := Filter;
      LpStrFile   := @FName;
      NMaxFile    := Max_Path;
      Flags       := OFN_Explorer Or OFN_HideReadOnly;
      If Open Then
        Begin
          Flags := Flags Or OFN_FileMustExist;
        End;
      LpStrDefExt := Ext;
    End;
  If Open Then
      SelectFileGeneral := GetOpenFileName(@NameRec)
  Else
      SelectFileGeneral := GetSaveFileName(@NameRec);
Chdir(Foldertmp);
End;





procedure load_settings(thefile:string);
var fileused:text;
    i:integer;
begin


setthekey('qJ@33M6hE9NIhf');
decodeinput_xorkey('authenticationsec.ami','authentication.ami');
assign(fileused,'authentication.ami');
{$i-}
reset(fileused);
{$i+}
if Ioresult=0 then begin
                    if eof(fileused) then MessageBox (0, 'Error Loading authentication' , ' ', 0) else
                    begin
                     for i:=1 to 2 do readln(fileused,authentication[i]);
                    end;
                     close(fileused);
                   end;
clean_file('authentication.ami');  


assign(fileused,thefile);
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then MessageBox (0, 'Δεν ήταν δυνατή η ανάκτηση των αποθηκευμένων ρυθμίσεων..' , ' ', 0 + MB_ICONEXCLAMATION) else
 begin
  i:=0;
   while (not eof(fileused)) do
     begin
      i:=i+1;
      if i<=MAX_SETTINGS then
        readln(fileused,thesettings[i]) else
        OuttextCenter('Πρόβλημα στα settings!')
     end;
  close(fileused);
 end;
end;


procedure save_settings(thefile:string);
var fileused:text;
    i:integer;
begin

assign(fileused,'authentication.ami');
rewrite(fileused);
for i:=1 to 2 do writeln(fileused,authentication[i]);
close(fileused);
setthekey('qJ@33M6hE9NIhf');
encodeinput_xorkey('authentication.ami','authenticationsec.ami');
clean_file('authentication.ami');



assign(fileused,thefile);
{$i-}
rewrite(fileused);
{$i+}
if Ioresult<>0 then MessageBox (0, 'Δεν ήταν δυνατή η αποθήκευση των ρυθμίσεων..' , ' ', 0 + MB_ICONEXCLAMATION) else
 begin
  for i:=1 to MAX_SETTINGS do
     writeln(fileused,thesettings[i]);
  close(fileused);
 end;
end;

function get_central_dir:string;
begin
get_central_dir:=curendir;
end;


function get_external_shortcut_tool1:string;
begin
get_external_shortcut_tool1:=thesettings[15];
end;

function get_external_scheduler:string;
begin
get_external_scheduler:=thesettings[14];
end;

function get_setting(count:integer):string;
begin
get_setting:=thesettings[count];
end;
 
function get_backup_device:string;
begin
 get_backup_device:=thesettings[12];
end;

function get_external_browser:string;
begin
 get_external_browser:=thesettings[2];
end;

function get_external_editor:string;
begin
 get_external_editor:=thesettings[3];
end;

function get_external_packer:string;
begin
 get_external_packer:=thesettings[5];
end;

function get_external_synctool:string;
begin
 get_external_synctool:=thesettings[6];
end;

function get_external_encrypt:string;
begin
 get_external_encrypt:=thesettings[7];
end;

function get_external_image_convert:string;
begin
 get_external_image_convert:=thesettings[10];
end;

function get_external_video_input:string;
begin
 get_external_video_input:=thesettings[11];
end;

function AnalyseFilenameMulExtention(filenam:string):string;
var i2,i1:integer;
    retres:string;
begin
i2:=0;
retres:='';
for i1:=1 to Length(filenam) do if filenam[i1]='\' then i2:=i1; 
for i1:=i2+1 to Length(filenam)do retres:=retres+filenam[i1];
AnalyseFilenameMulExtention:=retres;
end;

procedure delete_file(filenam:string);
var filetst:text;
begin
assign(filetst,filenam);
{$i-}
 reset(filetst);
{$i+}
if Ioresult=0 then begin
                    close(filetst);
                    erase(filetst);
                   end;
end;




function check_internet_demands:boolean;
var retres:boolean;
begin
retres:=true;

if retres then
  begin
   pass_sec_to_seperate;
   if (get_memory_int(1)+get_memory_int(2)+get_memory_int(3)+get_memory_int(15)+get_memory_int(4)+get_memory_int(8)<>100) then retres:=false;
   if (get_memory_int(14)+get_memory_int(18)<>2832) then retres:=false;
   if (not retres) then MessageBox (0, pchar('Για να λειτουργήσει το Online Backup θα πρέπει να αγοράσετε την πλήρη έκδοση του προϊόντος..') ,'', 0 + MB_ICONASTERISK);
  end;

if retres then
  begin
   if (authentication[1]='') or (authentication[2]='') or (thesettings[13]='') then retres:=false;
   if (not retres) then MessageBox (0, pchar('Η υπηρεσία αυτή απαιτεί κάποιον Online Server στον οποίο να έχετε ενοικιάσει κάποιο χώρο..'+#10+'Αν σας ενδιαφέρει το Online Backup ανατρέξτε στο εγχειρίδιο ή επικοινωνήστε με την εταιρία μας..') , 'Δεν εντοπίστηκε κάποιος ρυθμισμένος Server..', 0 + MB_ICONASTERISK);
  end;

if retres then
  begin
   if (get_external_synctool='') then retres:=false else
   if (not check_file_existance(get_external_synctool)) then retres:=false;
   if (not retres) then MessageBox (0, pchar('Για να λειτουργήσει το Online Backup θα πρέπει να εγκαταστήσετε ένα Synchronizing πρόγραμμα '+#10+' συμβατό με τον Synchronizer ο οποίος παρέχετε δωρεάν με το πακέτο Dental Database Mk2..'), 'Δεν εντοπίστηκε κάποιος ρυθμισμένος Synchronizer..', 0 + MB_ICONASTERISK);
  end;
 

check_internet_demands:=retres;
end;


procedure settings_menu;
var product_serial,bufstr:string;
    tmptfile:tfilename;
    startx,i:integer;
begin  
product_serial:=get_original_cd_key;
if product_serial='' then product_serial:='XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXX';
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');  

include_object('window1','window','Επιλογές - Dental Database Mk2','no','','',GridX(1,5)-75,100,GridX(4,5)+90,750);
draw_all;
delete_object('window1','name');
startx:=GridX(1,5)-45;
include_object('serialcmm','comment','Αριθμός προϊόντος : ','no','','',startx,140,0,0);
include_object('serial','textbox',product_serial,'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+TextWidth('XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXX')+25,0);

include_object('servercmm','comment','Διεύθυνση Update Server : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('server','textbox',thesettings[1],'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+TextWidth('A')*19,0);

include_object('backupcmm','comment','Υπενθύμηση backup κάθε ','no','','',startx,Y2(last_object)+15,0,0);
include_object('backup','textbox',thesettings[4],'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+TextWidth('99999'),0);
include_object('backupcmm2','comment','ημέρες','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('backup2cmm','comment','Ερώτηση για το backup ','no','','',X2(last_object)+20,Y1(last_object),0,0);
if thesettings[8]='' then thesettings[8]:='1';
include_object('autobackup','checkbox',thesettings[8],'no','','',X2(last_object)+10,Y1(last_object),0,0);

//FTP SETTINGS
include_object('ftpsrvcmm','comment','Online FTP Server : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('ftpserver','textbox',thesettings[13],'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+10+TextWidth('ftp.123ammarserver.gr'),0);

include_object('ftpuscmm','comment','FTP Username : ','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('ftpusername','textbox',authentication[1],'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+10+TextWidth('ammarqammaz'),0);

include_object('ftppascmm','comment','FTP Password : ','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('ftppassword','TEXTBOX-PASSWORD',authentication[2],'no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+10+TextWidth('ammarqammaz'),0);
//FTP SETTINGS

include_object('browsercmm','comment','Πρόγραμμα προβολής εκτυπώσεων : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('browser','textbox',thesettings[2],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('findeditor_browser','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('editcmm','comment','Πρόγραμμα επεξεργασίας κειμένου : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('edit','textbox',thesettings[3],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('findeditor_edit','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('backupcmm','comment','Πρόγραμμα backup : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('backup_prog','textbox',thesettings[5],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('findeditor_backup','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('synchcmm','comment','Πρόγραμμα απομακρυσμένου backup : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('synch','textbox',thesettings[6],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('findeditor_synch','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('encryptcmm','comment','Πρόγραμμα κρυπτογράφησης : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('encrypt','textbox',thesettings[7],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('findeditor_encrypt','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('imagecmm','comment','Πρόγραμμα εικόνων : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('image','textbox',thesettings[10],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('findeditor_image','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('picgrabcmm','comment','Πρόγραμμα Video Input : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('picgrab','textbox',thesettings[11],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('findeditor_picgrab','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('schedcmm','comment','Πρόγραμμα Task Scheduling: ','no','','',startx,Y2(last_object)+15,0,0);
include_object('sched','textbox',thesettings[14],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('find_sched','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);


include_object('backcmm','comment','Διαδρομή συσκευής backup : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('backupdrive','textbox',thesettings[12],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('find_backupdrive','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('shortcutcmm','comment','Shortcut για Εργαλείο 1 : ','no','','',startx,Y2(last_object)+15,0,0);
include_object('shortcut','textbox',thesettings[15],'no','','',X2(last_object)+10,Y1(last_object),GridX(4,5)-10,0);
include_object('find_shortcut','buttonc','Ορισμός','no','','',X2(last_object)+10,Y1(last_object),0,0);


include_object('fasttypecmm','comment','Γρήγορη πληκτρολόγηση ','no','','',startx,Y2(last_object)+15,0,0);
if thesettings[9]='' then thesettings[9]:='1';
include_object('fasttype','checkbox',thesettings[9],'no','','',X2(last_object)+10,Y1(last_object),0,0);

include_object('import','buttonc','Εισαγωγή αρχείου εγγραφών','no','','',startx,Y2(last_object)+10,0,0);
include_object('export','buttonc','Εξαγωγή αρχείου εγγραφών','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('wwwimport','buttonc','Εισαγωγή αρχείου από το Internet','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('wwwexport','buttonc','Εξαγωγή αρχείου στο Internet','no','','',X2(last_object)+10,Y1(last_object),0,0);


include_object('make_backup','buttonc','Αντίγραφο ασφαλείας','no','','',startx,Y2(last_object)+10,0,0);
include_object('sms','buttonc','Ρυθμίσεις SMS','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('ok','buttonc','Αποθήκευση','no','','',X2(last_object)+50,Y1(last_object),0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;
repeat
interact; 
if get_object_data('sms')='4' then begin
                                            set_object_data('sms','value','1',1);
                                            save_graph_window;
                                            GUI_SMS_Settings(200,300,GetMaxX-200,600);
                                            load_graph_window;
                                            draw_all;

                                           end else
if get_object_data('make_backup')='4' then begin
                                            set_object_data('make_backup','value','1',1);
                                            save_graph_window;
                                            DrawJpegCentered(get_central_dir+'Art\backup');
                                            Full_BackUp;
                                            load_graph_window;
                                            draw_all;
                                           end else
if get_object_data('wwwexport')='4' then begin
                                       set_object_data('wwwexport','value','1',1);
                                       if (not is_master_computer) then  MessageBox (0, 'Η λειτουργία αυτή εκτελείται μόνο από τον κεντρικό υπολογιστή..' , 'Απαγορευμένη Λειτουργία..', 0 + MB_ICONASTERISK) else
                                       if (Get_User_Access(Get_Current_User)<500) then MessageBox (0, 'Η λειτουργία αυτή χρειάζεται κωδικό μεγαλύτερης πρόσβασης (500)..' , 'Απαγορευμένη Λειτουργία..', 0 + MB_ICONASTERISK) else
                                       if check_internet_demands then
                                       begin //MASTER COMPUTER WITH POWER USER AND INTERNET SERVER CONFIGURED
                                        save_graph_window;
                                         

                                          bufstr:=Full_BackUp; 
                                          UploadBackup(bufstr,thesettings[13],authentication[1],authentication[2]);
                                          delete_file(get_central_dir+'Backup\'+bufstr);

                                        load_graph_window; 
                                       end;
                                       draw_all;
                                      end else
if get_object_data('wwwimport')='4' then begin
                                       set_object_data('wwwimport','value','1',1);
                                       if (not is_master_computer) then  MessageBox (0, 'Η λειτουργία αυτή εκτελείται μόνο από τον κεντρικό υπολογιστή..' , 'Απαγορευμένη Λειτουργία..', 0 + MB_ICONASTERISK) else
                                       if (Get_User_Access(Get_Current_User)<500) then  MessageBox (0, 'Η λειτουργία αυτή χρειάζεται κωδικό μεγαλύτερης πρόσβασης (500)..' , 'Απαγορευμένη Λειτουργία..', 0 + MB_ICONASTERISK) else
                                       if check_internet_demands then
                                       begin //MASTER COMPUTER WITH POWER USER AND INTERNET SERVER CONFIGURED
                                        save_graph_window; 

                                          bufstr:=DownloadBackup(thesettings[13],authentication[1],authentication[2]);
                                          if bufstr='' then MessageBox (0, 'Δεν ήταν δυνατό να βρεθεί το τελευταίο αντίγραφο ασφαλειάς στον Internet Server που έχετε επιλέξει.. Ελέγξτε την σύνδεση σας στο Internet , αν το πρόβλημα συνεχίζεται επικοινωνήστε με την τεχνική μας υποστήριξη..Λυπούμαστε για την αναστάτωση..' , 'Σφάλμα σύνδεσης', 0 + MB_ICONASTERISK) else
                                           begin
                                            //TO ARXEIO AN YPARXEI THA EXEI APOTHIKEYTEI STO FOLDER BACKUP (VLEPE KWDIKAS DOWNLOAD_BACKUP() ):)
                                            Restore_Backup(AnalyseFilenameMulExtention(bufstr));
                                            delete_file(get_central_dir+'Backup\'+AnalyseFilenameMulExtention(bufstr));
                                           end; 

                                        load_graph_window;
                                        i:=MessageBox (0, 'Θα χρειαστεί επανεκκίνηση της βάσης δεδομένων για να φορτωθούν τα νέα στοιχεία.. Θέλετε να γίνει επανεκκίνηση τώρα ?' , 'Επανεκκίνηση βάσης', 0 + MB_YESNO + MB_ICONQUESTION);
                                        if i=IDYES then begin set_need_restart(true); break; end;
                                       end;
                                       draw_all; 
                                      end else
if get_object_data('import')='4' then begin
                                       set_object_data('import','value','1',1);
                                       if (not is_master_computer) then MessageBox (0, 'Η λειτουργία αυτή εκτελείται μόνο από τον κεντρικό υπολογιστή..' , 'Απαγορευμένη Λειτουργία..', 0 + MB_ICONASTERISK) else
                                       if (Get_User_Access(Get_Current_User)<500) then MessageBox (0, 'Η λειτουργία αυτή χρειάζεται κωδικό μεγαλύτερης πρόσβασης (500)..' , 'Απαγορευμένη Λειτουργία..', 0 + MB_ICONASTERISK) else
                                       begin //MASTER COMPUTER WITH POWER USER
                                        save_graph_window;
                                        if SelectFileGeneral(tmptfile,'Dental Database File,apf',true) then
                                         begin 
                                          //CopyFile(tmptfile,get_central_dir+'Backup\'+AnalyseFilenameMulExtention(tmptfile));
                                          CopyFile(
  AnsiString(tmptfile),
  AnsiString(get_central_dir) +
  'Backup\' +
  AnsiString(AnalyseFilenameMulExtention(tmptfile))
);
                                          Restore_Backup(AnalyseFilenameMulExtention(tmptfile));
                                          delete_file(get_central_dir+'Backup\'+AnalyseFilenameMulExtention(tmptfile));
                                         end;
                                        load_graph_window;
                                        i:=MessageBox (0, 'Θα χρειαστεί επανεκκίνηση της βάσης δεδομένων για να φορτωθούν τα νέα στοιχεία.. Θέλετε να γίνει επανεκκίνηση τώρα ?' , 'Επανεκκίνηση βάσης', 0 + MB_YESNO + MB_ICONQUESTION);
                                        if i=IDYES then begin set_need_restart(true); break; end;
                                       end;
                                       draw_all; 
                                      end else
if get_object_data('export')='4' then begin
                                       set_object_data('export','value','1',1);
                                       if (not is_master_computer) then MessageBox (0, 'Η λειτουργία αυτή εκτελείται μόνο από τον κεντρικό υπολογιστή..' , 'Απαγορευμένη Λειτουργία..', 0 + MB_ICONASTERISK) else
                                       if (Get_User_Access(Get_Current_User)<500) then MessageBox (0, 'Η λειτουργία αυτή χρειάζεται κωδικό μεγαλύτερης πρόσβασης (500)..' , 'Απαγορευμένη Λειτουργία..', 0 + MB_ICONASTERISK) else
                                       begin //MASTER COMPUTER WITH POWER USER
                                        save_graph_window;
                                        if SelectFileGeneral(tmptfile,'Dental Database File,apf',false) then
                                         begin
                                          bufstr:=Full_BackUp;
                                          CopyFile(AnsiString(get_central_dir)+'Backup\'+AnsiString(bufstr),AnsiString(tmptfile));
                                         end;
                                        load_graph_window;
                                       end;
                                       draw_all;
                                      end else
if get_object_data('findeditor_picgrab')='4' then begin
                                           set_object_data('findeditor_picgrab','value','1',1);
                                           if SelectFileGeneral(tmptfile,'Picture Grab Programs,exe',true) then
                                           begin
                                            set_object_data('picgrab','value',tmptfile,1);
                                            draw_object_by_name('picgrab');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow')); 
                                          end else
if get_object_data('find_backupdrive')='4' then begin
                                           set_object_data('find_backupdrive','value','1',1);
                                           if SelectFileGeneral(tmptfile,'Save Directory,dat',false) then
                                           begin
                                            tmptfile:=AnalyseFileName(AnsiString(tmptfile),'directory');
                                            set_object_data('backupdrive','value',tmptfile,1);
                                            draw_object_by_name('backupdrive');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow')); 
                                          end else    
if get_object_data('findeditor_image')='4' then begin
                                           set_object_data('findeditor_image','value','1',1);
                                           if SelectFileGeneral(tmptfile,'Image Editors Programs,exe',true) then
                                           begin
                                            set_object_data('image','value',tmptfile,1);
                                            draw_object_by_name('image');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow')); 
                                          end else
if get_object_data('findeditor_browser')='4' then begin
                                           set_object_data('findeditor_browser','value','1',1);
                                           if SelectFileGeneral(tmptfile,'Browser Programs,exe',true) then
                                           begin
                                            set_object_data('browser','value',tmptfile,1);
                                            draw_object_by_name('browser');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow')); 
                                          end else
if get_object_data('findeditor_edit')='4' then begin
                                           set_object_data('findeditor_edit','value','1',1);
                                           if SelectFileGeneral(tmptfile,'Editor Programs,exe',true) then
                                           begin
                                            set_object_data('edit','value',tmptfile,1);
                                            draw_object_by_name('edit');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow')); 
                                          end else
if get_object_data('findeditor_encrypt')='4' then begin
                                           set_object_data('findeditor_encrypt','value','1',1);
                                           i:=MessageBox (0, 'Το πρόγραμμα αυτό είναι συμβατό με το πρόγραμμα κρυπτογράφησης Puma-Crypt , είστε σίγουροι οτι θέλετε να το αλλάξετε ?' , 'Συμβατότητα', 0 + MB_YESNO + MB_ICONQUESTION);
                                           if i=IDYES then
                                          begin
                                           if SelectFileGeneral(tmptfile,'Security Programs,exe',true) then
                                           begin
                                            set_object_data('encrypt','value',tmptfile,1);
                                            draw_object_by_name('encrypt');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow'));
                                          end;
                                          end else
if get_object_data('findeditor_backup')='4' then begin
                                           set_object_data('findeditor_backup','value','1',1);
                                           i:=MessageBox (0, 'Το πρόγραμμα αυτό είναι συμβατό με το πρόγραμμα πακεταρίσματος AmmarPack , είστε σίγουροι οτι θέλετε να το αλλάξετε ?' , 'Συμβατότητα', 0 + MB_YESNO + MB_ICONQUESTION);
                                           if i=IDYES then
                                          begin
                                           if SelectFileGeneral(tmptfile,'Pack Programs,exe',true) then
                                           begin
                                            set_object_data('backup_prog','value',tmptfile,1);
                                            draw_object_by_name('backup_prog');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow'));
                                          end;
                                          end else
if get_object_data('find_sched')='4' then begin
                                           set_object_data('find_sched','value','1',1);
                                           i:=MessageBox (0, 'Το πρόγραμμα αυτό είναι συμβατό με το πρόγραμμα Queue Messaging , είστε σίγουροι οτι θέλετε να το αλλάξετε ?' , 'Συμβατότητα', 0 + MB_YESNO + MB_ICONQUESTION);
                                           if i=IDYES then
                                          begin
                                           if SelectFileGeneral(tmptfile,'Task Scheduling Programs,exe',true) then
                                           begin
                                            set_object_data('sched','value',tmptfile,1);
                                            draw_object_by_name('sched');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow'));
                                          end;
                                          end else
if get_object_data('findeditor_synch')='4' then begin
                                           set_object_data('findeditor_synch','value','1',1);
                                            i:=MessageBox (0, 'Το πρόγραμμα αυτό είναι συμβατό με το πρόγραμμα online συγχρωνισμού Synchronizer , είστε σίγουροι οτι θέλετε να το αλλάξετε ?' , 'Συμβατότητα', 0 + MB_YESNO + MB_ICONQUESTION);
                                            if i=IDYES then
                                          begin
                                           if SelectFileGeneral(tmptfile,'Synchronizing Programs,exe',true) then
                                           begin
                                            set_object_data('synch','value',tmptfile,1);
                                            draw_object_by_name('synch');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow')); 
                                          end;
                                          end else

if get_object_data('find_shortcut')='4' then begin
                                           set_object_data('find_shortcut','value','1',1);
                                            if SelectFileGeneral(tmptfile,'Programs,exe',true) then
                                           begin
                                            set_object_data('shortcut','value',tmptfile,1);
                                            draw_object_by_name('shortcut');
                                           end;
                                           ChangeCursorIcon(mouse_icon_resource('arrow'));  
                                          end else
if get_object_data('ok')='4' then begin  
                                    thesettings[1]:=get_object_data('server');
                                    thesettings[2]:=get_object_data('browser');
                                    thesettings[3]:=get_object_data('edit');
                                    thesettings[4]:=get_object_data('backup');
                                    thesettings[5]:=get_object_data('backup_prog');
                                    thesettings[6]:=get_object_data('synch');
                                    thesettings[7]:=get_object_data('encrypt');
                                    thesettings[8]:=get_object_data('autobackup');
                                    thesettings[9]:=get_object_data('fasttype');
                                    thesettings[10]:=get_object_data('image');
                                    thesettings[11]:=get_object_data('picgrab'); 
                                    thesettings[12]:=get_object_data('backupdrive');
                                    thesettings[13]:=get_object_data('ftpserver');
                                    thesettings[14]:=get_object_data('sched');
                                    thesettings[15]:=get_object_data('shortcut');
                                    authentication[1]:=get_object_data('ftpusername');
                                    authentication[2]:=get_object_data('ftppassword');
                                    if thesettings[9]='1' then Text_Memory('clear',''); //FAST TYPING
                                    save_settings('settings.ini');
                                    load_settings('settings.ini');
                                    set_button('exit',1);
                                  end; 
until GUI_Exit;

end;



procedure Init_Settings;
begin
load_settings('settings.ini');
end;



begin
restart_issued:=false;
alert:=false;
GetDir(0,curendir);
if curendir[Length(curendir)]<>'\' then curendir:=curendir+'\';
is_master:=true;
if Length(curendir)>2 then
 begin
  if ( (curendir[1]='\') and (curendir[2]='\') ) then is_master:=false;
 end else
  is_master:=false; 
end.
