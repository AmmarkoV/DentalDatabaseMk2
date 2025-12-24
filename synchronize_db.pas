unit synchronize_db;

interface
 
function sync_up(theword:string):string;
function update_program:boolean;


implementation 
uses ammarunit,apsfiles,security,settings,userlogin,security_gra;

function update_program:boolean;
var fileused:text;
begin
clrscreen;
DrawJpegCentered(get_central_dir+'Art\progupdate');
if (not is_master_computer) then begin
                                  MakeMessageBox ('', 'Η λειτουργία αυτή εκτελείται μόνο από τον κεντρικό υπολογιστή..' ,'','','');
                                 end else
if (Get_User_Access(Get_Current_User)<500) then
                                 begin
                                  MakeMessageBox ('', 'Η λειτουργία αυτή χρειάζεται κωδικό μεγαλύτερης πρόσβασης (500)..' ,'','','');
                                 end else
 begin
  //MakeMessageBox('','Η υπηρεσία αυτή δεν είναι διαθέσιμη προς το παρόν..','','','');
  OutTextCenter('Please Wait..');
  RunEXEWait(get_external_browser+' "http://'+get_setting(1)+'/updates/index.php?cd='+get_update_cd_key+'&family=ddmk2&stat='+Convert2String(get_update_stat)+'"',false);
  MakeMessageBox ('', 'Πατήστε OK για επιστροφή..' ,'','','');

 
 end;
end;


function sync_up(theword:string):string;
begin
sync_up:=theword;
end;

begin
end.
