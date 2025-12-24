unit people;
{$H+}
interface
function Get_Works(typ,the_works:integer):string;
procedure Check_Pass_2_Works(work_id,comments,comments2,user:string; price,discount,payed,dateday,datemonth,dateyear:integer);
function Get_Total_Works:integer;

procedure Init_People;
function Get_Display_Photos:boolean;
procedure Set_Display_Photos(theval:boolean);
procedure View_Person();
procedure Load_Form();
function GUI_search_person:string;
function  People_Data(datanum:integer):string;
procedure Set_People_Data(datanum:integer; thedata:string);
procedure New_Person(thefile,thecode,thename,thesurname:string);
procedure Save_Person(filename:string);
procedure Load_Person(filename:string; full_load:boolean);
function check_match(acode,aname,asurname,adateday,adatemonth,adateyear,aarea,atelephone,aprofession:string):boolean;
function check_match_pro(fd,fm,fy,td,tm,ty,xrwstaeifrom,xrwstaeito,ekptwsifrom,ekptwsito,plirwseifrom,plirwseito:string):boolean;


implementation
uses windows,ammarunit,apsfiles,ammargui,string_stuff,people_map,people_help,userlogin,the_works,teeth,settings,tools,pic_select,calender_help;
const seperate_words_strength=15;
      seperate_words_read_strength=1024;
      title='People Subsystem';

      MAX_WORKS=256; 
      MAX_XRAYS=15;
      MAX_CHECKS=31;

      DELETE_ACCESS=250;
Type
  TFileName = Array[0..Max_Path] Of Char;
  TDate = Array[0..2] of integer;

var memory:array[1..seperate_words_strength] of string;
    memoryinteger:array[1..seperate_words_strength] of integer;
    patientworks,patientxrays:integer;
    code,name,surname,load_file,area,telephone,profession,photo,cellphone,address,emoticon,other,areacode,email,vivlio_esodwn:string;
    birthdate,nextdate,recordcreated:TDate;
    works:array[1..9,1..MAX_WORKS]of string ; // 1 WorkID , 2 Price , 3 Discount , 4 Payed , 5 Comments , 6 user , 7 day , 8 month , 9year
    xrays:array[1..MAX_XRAYS]of string;
    curendir:string;
    patient_checks:array[1..MAX_CHECKS] of string;
    display_photos:boolean;


function Get_Total_Works:integer;
begin
Get_Total_Works:=patientworks;
end;

function Get_Works(typ,the_works:integer):string;
begin
Get_Works:=works[typ,the_works];
end;

procedure seperate_words (bufstr4:string);
var buffers:array [1..5] of integer;
    zcount:integer;
    s3:string;
    buf:array[1..seperate_words_read_strength]of char;
begin
for zcount:=1 to seperate_words_strength do begin
                                             memory[zcount]:='';
                                             memoryinteger[zcount]:=0;
                                            end;
zcount:=0;
setlength (s3,1);
buffers[2]:=Length(bufstr4);
for zcount:=1 to Length(bufstr4) do begin
                                     s3:=Copy(bufstr4,zcount,1);
                                     buf[zcount]:=s3[1];
                                    end;
buffers[3]:=1;
buffers[4]:=0;
repeat
  buffers[4]:=buffers[4]+1;
  buffers[5]:=buffers[3];
  if buf[buffers[4]]='(' then buffers[3]:=buffers[3]+1
          else 
  if buf[buffers[4]]=',' then buffers[3]:=buffers[3]+1
          else
  if buf[buffers[4]]=')' then buffers[3]:=buffers[3]+1;

if buffers[5]=buffers[3] then
  begin
if buffers[3]<=seperate_words_strength then memory[buffers[3]]:=memory[buffers[3]]+buf[buffers[4]] else
                               begin
                                buffers[3]:=seperate_words_strength+1
                               end;
  end;
  if buffers[4]=buffers[2] then buffers[3]:=seperate_words_strength+1;
until buffers[3]>=seperate_words_strength+1;
for zcount:=1 to seperate_words_strength do begin
                                             val(memory[zcount],buffers[1],buffers[5]);
                                             if buffers[5]=0 then memoryinteger[zcount]:=buffers[1] else
                                                                  memoryinteger[zcount]:=0;
                                            end;
end;

 
 



procedure Flush_People;
var x,y:integer;
begin
patientworks:=0; 
load_file:='undefined.dat';
name:='';
surname:='';
area:='';
telephone:='';
profession:='';
photo:='';
cellphone:='';
other:='';
areacode:='';
vivlio_esodwn:='';
emoticon:='smiley_neutral';
address:='';
email:='';
birthdate[0]:=0;
birthdate[1]:=0;
birthdate[2]:=0;
nextdate[0]:=0;
nextdate[1]:=0;
nextdate[2]:=0;
recordcreated[0]:=0;
recordcreated[1]:=0;
recordcreated[2]:=0;

for x:=1 to MAX_CHECKS do patient_checks[x]:='1';

for x:=1 to 9 do
 for y:=1 to MAX_WORKS do
     works[x,y]:='';
 
end;

function People_Data(datanum:integer):string;
var retres:string;
begin
if datanum=0 then retres:=curendir else
if datanum=1 then retres:=code else
if datanum=2 then retres:=name else
if datanum=3 then retres:=surname else
if datanum=4 then retres:=area else
if datanum=5 then retres:=telephone else
if datanum=6 then retres:=profession else
if datanum=7 then retres:=photo else
if datanum=8 then retres:=load_file else
if datanum=9 then retres:=AnalyseFilename(load_file,'FILENAME') else//Greeklish(name+'_'+surname+'_'+code) else
if datanum=10 then retres:=email;

People_Data:=retres;
end;

procedure Set_People_Data(datanum:integer; thedata:string);
var retres:string;
begin
if datanum=0 then curendir:=thedata else
if datanum=1 then code:=thedata else
if datanum=2 then name:=thedata else
if datanum=3 then surname:=thedata else
if datanum=4 then area:=thedata else
if datanum=5 then telephone:=thedata else
if datanum=6 then profession:=thedata else
if datanum=7 then photo:=thedata else
if datanum=8 then load_file:=thedata else
if datanum=9 then begin end else
if datanum=10 then email:=thedata;

end;


procedure Init_People;
begin
GetDir(0,curendir); 
if curendir[Length(curendir)]<>'\' then curendir:=curendir+'\';
Flush_People;
end;

 
procedure Set_Display_Photos(theval:boolean);
begin
display_photos:=theval;
end;

function Get_Display_Photos:boolean;
begin
Get_Display_Photos:=display_photos;
end;


function check_match(acode,aname,asurname,adateday,adatemonth,adateyear,aarea,atelephone,aprofession:string):boolean;
var points:integer;
    retres:boolean;
begin
retres:=false;
points:=0;

 if acode='' then points:=points+1 else
 if (GreekEqual(code,acode)) then points:=points+1;

 if aname='' then points:=points+1 else
 if (GreekEqual(name,aname)) then points:=points+1;

 if asurname='' then points:=points+1 else
 if (GreekEqual(surname,asurname)) then points:=points+1;

 if adateday='' then points:=points+1 else
 if (GreekEqual(Convert2String(nextdate[0]),adateday)) then points:=points+1;

 if adatemonth='' then points:=points+1 else
 if (GreekEqual(Convert2String(nextdate[1]),adatemonth)) then points:=points+1;

 if adateyear='' then points:=points+1 else
 if (GreekEqual(Convert2String(nextdate[2]),adateyear)) then points:=points+1;

 if aarea='' then points:=points+1 else
 if (GreekEqual(area,aarea)) then points:=points+1;

 if atelephone='' then points:=points+1 else
 if ((GreekEqual(telephone,atelephone)) or (GreekEqual(cellphone,atelephone))) then points:=points+1;

 if aprofession='' then points:=points+1 else
 if (GreekEqual(profession,aprofession)) then points:=points+1;

 if points=9 then retres:=true;
 
check_match:=retres;
end;


function check_match_pro(fd,fm,fy,td,tm,ty,xrwstaeifrom,xrwstaeito,ekptwsifrom,ekptwsito,plirwseifrom,plirwseito:string):boolean;
// fd = from day , fm = from month , fy = from year , td = to day , tm = to month , ty = to year
var points:integer;
    totalowing,totalpayed,totaldiscount,ergasies_in:integer;
    like:byte;
    i,z:integer;
    tmp:array[1..9]of integer;
    retres:boolean;
begin
retres:=false;
points:=0;
totalowing:=0;
totalpayed:=0;
totaldiscount:=0;
ergasies_in:=0; 
Val(fd,tmp[1],z);
Val(fm,tmp[2],z);
Val(fy,tmp[3],z);   // 1 ews 3 = from date
Val(td,tmp[4],z);
Val(tm,tmp[5],z);
Val(ty,tmp[6],z);   // 4 ews 6 = to date 
 if patientworks>0 then
 begin
  for i:=1 to patientworks do
    begin
      // CHECK TIMES..
      Val(works[2,i],tmp[7],z);  //KOSTOS
      Val(works[3,i],tmp[8],z);  //EKPTWSI
      Val(works[4,i],tmp[9],z);  //PLIRWSE
      tmp[8]:=tmp[7]*tmp[8] div 100;
      totalowing:=totalowing+tmp[7]-tmp[8]; //Synolika xrwstaei osa xrwstaei + ayta - tin ekptwsi..
      totalpayed:=totalpayed+tmp[9];
      totaldiscount:=totaldiscount+tmp[8];
      // CHECK HMEROMINIES..
      Val(works[7,i],tmp[7],z);  // DAY
      Val(works[8,i],tmp[8],z);  // MONTH
      Val(works[9,i],tmp[9],z);  // YEAR
      like:=0;
      if ((tmp[1]=0)and(tmp[2]=0)and(tmp[3]=0)) then like:=like+1 else
      if ((tmp[1]<=tmp[7])and(tmp[2]<=tmp[8])and(tmp[3]<=tmp[9])) then like:=like+1;

      if ((tmp[4]=0)and(tmp[5]=0)and(tmp[6]=0)) then like:=like+1 else
      if ((tmp[4]>=tmp[7])and(tmp[5]>=tmp[8])and(tmp[6]>=tmp[9])) then like:=like+1;

      if like=2 then ergasies_in:=ergasies_in+1;
    end;
 end;

 if ((fd='')and(fm='')and(fy='')and(td='')and(tm='')and(ty='')) then points:=points+1 else
 if ergasies_in>0 then points:=points+1;

 Val(xrwstaeifrom,tmp[1],z); // OWING MONEY
 Val(xrwstaeito,tmp[2],z);
 if ((xrwstaeifrom='') and (xrwstaeito='')) then points:=points+1 else
 if (((tmp[1]=0)or(tmp[1]<=totalowing-totalpayed)) and ((tmp[2]=0)or(tmp[2]>=totalowing-totalpayed))) then points:=points+1;

 Val(ekptwsifrom,tmp[1],z); // TOTAL DISCOUNT
 Val(ekptwsito,tmp[2],z);
 if ((ekptwsifrom='') and (ekptwsito='')) then points:=points+1 else
 if ((tmp[1]<=totaldiscount) and (tmp[2]>=totaldiscount)) then points:=points+1;

 Val(plirwseifrom,tmp[1],z); // TOTAL DISCOUNT
 Val(plirwseito,tmp[2],z);
 if ((plirwseifrom='') and (plirwseito='')) then points:=points+1 else
 if ((tmp[1]<=totalpayed) and (tmp[2]>=totalpayed)) then points:=points+1;

 if points=4 then retres:=true;
check_match_pro:=retres;
end;


procedure test_aps;
var x,y:integer;
begin
for x:=1 to GetMaxX do
 for y:=1 to GetMaxY do
  putpixel(x,y,GetApsPixelColor(x,y));
readkey;
end;

procedure Load_Photo(what2load:string; full_load:boolean);
begin

if photo<>'' then
                if (full_load) then UnloadAps(AnalyseFilename(photo,'filename'));

                                        if (not display_photos) then
                                          begin
                                           photo:=what2load;
                                           DefineAPS(AnalyseFilename(photo,'filename'),GetLoadingX+1,GetLoadingY+1,GetLoadingX+2,GetLoadingY+2);
                                           //Koroideyoume to prama Gia na min xathei i pliroforia sxetika me tin eikona :) !
                                          end;
                                        if ((full_load) and (display_photos)) then //Enhance performance apeira! :)
                                        begin
                                         photo:=what2load;
                                         chdir(curendir+'Image Database');
                                         if check_file_existance(photo) then begin
                                                                              set_user_state(Get_Current_User,'loading_picture');
                                                                              LoadPicture(photo);
                                                                              //photo:=AnalyseFilename(photo,'filename');
                                                                              if ((GetApsInfo(AnalyseFilename(photo,'filename'),'sizex')>200) or (GetApsInfo(AnalyseFilename(photo,'filename'),'sizey')>300) ) then
                                                                              begin
                                                                                if GetApsInfo(AnalyseFilename(photo,'filename'),'sizex')>GetApsInfo(AnalyseFilename(photo,'filename'),'sizey') then
                                                                                  begin
                                                                                    filter_resize(AnalyseFilename(photo,'filename'),200,0);
                                                                                  end else
                                                                                    filter_resize(AnalyseFilename(photo,'filename'),0,300);
                                                                              end; 
                                                                              set_user_state(Get_Current_User,'running'); 
                                                                             end  else
                                         MessageBox (0,Pchar('Δεν μπορώ να βρώ την εικόνα '+photo), title, 0 + MB_ICONEXCLAMATION);
                                         chdir(curendir);
                                        end;
end;


procedure Load_Person(filename:string; full_load:boolean);
var fileused:text;
    bufstr:string;
begin
if filename='' then begin
                      {filename:=name+'_'+surname+'.dat';
                      filename:=Greeklish(filename);  }
                      filename:=load_file;
                    end;
Flush_People;
load_file:=filename;
assign(fileused,curendir+'Database\'+filename);
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then MessageBox (0, 'Κενό αρχείο επαφής..' , ' ', 0) else
begin
 patientworks:=0;
 //OutTextCenter('Loading..'); 
repeat 
   readln(fileused,bufstr); 
   seperate_words(bufstr); 
   if (Equal(memory[1],'CODE')) then code:=memory[2] else
   if (Equal(memory[1],'NAME')) then name:=memory[2] else
   if (Equal(memory[1],'SURNAME')) then surname:=memory[2] else
   if (Equal(memory[1],'AREA')) then area:=memory[2] else
   if (Equal(memory[1],'AREACODE')) then areacode:=memory[2] else
   if (Equal(memory[1],'TELEPHONE')) then telephone:=memory[2] else
   if (Equal(memory[1],'PROFESSION')) then profession:=memory[2] else
   if (Equal(memory[1],'CELLPHONE')) then cellphone:=memory[2] else
   if (Equal(memory[1],'ADDRESS')) then  address:=memory[2] else
   if (Equal(memory[1],'EMOTICON')) then  emoticon:=memory[2] else
   if (Equal(memory[1],'VIVLIO_ESODWN_EKSODWN')) then  vivlio_esodwn:=memory[2] else 
   if (Equal(memory[1],'OTHER')) then  other:=memory[2] else
   if (Equal(memory[1],'EMAIL')) then  email:=memory[2] else
   if (Equal(memory[1],'BIRTH')) then begin
                                                 birthdate[0]:=memoryinteger[2];
                                                 birthdate[1]:=memoryinteger[3];
                                                 birthdate[2]:=memoryinteger[4];
                                                end else
   if (Equal(memory[1],'RECORD_CREATION')) then begin
                                                 recordcreated[0]:=memoryinteger[2];
                                                 recordcreated[1]:=memoryinteger[3];
                                                 recordcreated[2]:=memoryinteger[4];
                                                end else
   if (Equal(memory[1],'NEXT_APPOINTMENT')) then begin
                                                  nextdate[0]:=memoryinteger[2];
                                                  nextdate[1]:=memoryinteger[3];
                                                  nextdate[2]:=memoryinteger[4];
                                                 end   else
   if (Equal(memory[1],'PHOTO')) then begin 
                                       Load_Photo(memory[2],full_load);
                                       { if photo<>'' then UnloadAps(photo);
                                        if (not display_photos) then
                                          begin
                                           photo:=memory[2];
                                           DefineAPS(AnalyseFilename(photo,'filename'),GetLoadingX+1,GetLoadingY+1,GetLoadingX+2,GetLoadingY+2);
                                           //Koroideyoume to prama Gia na min xathei i pliroforia sxetika me tin eikona :) !
                                          end;
                                        if ((full_load) and (display_photos)) then //Enhance performance apeira! :)
                                        begin
                                         photo:=memory[2];
                                         chdir(curendir+'Image Database');
                                         if check_file_existance(photo) then begin
                                                                              set_user_state(Get_Current_User,'loading_picture');
                                                                              LoadPicture(photo);
                                                                              //photo:=AnalyseFilename(photo,'filename');
                                                                              if ((GetApsInfo(AnalyseFilename(photo,'filename'),'sizex')>200) or (GetApsInfo(AnalyseFilename(photo,'filename'),'sizey')>300) ) then
                                                                              begin
                                                                                if GetApsInfo(AnalyseFilename(photo,'filename'),'sizex')>GetApsInfo(AnalyseFilename(photo,'filename'),'sizey') then
                                                                                  begin
                                                                                    filter_resize(AnalyseFilename(photo,'filename'),200,0);
                                                                                  end else
                                                                                    filter_resize(AnalyseFilename(photo,'filename'),0,300);
                                                                              end; 
                                                                              set_user_state(Get_Current_User,'running'); 
                                                                             end  else
                                         MessageBox (0,Pchar('Δεν μπορώ να βρώ την εικόνα '+photo), title, 0 + MB_ICONEXCLAMATION);
                                         chdir(curendir);
                                        end;              }
                                      end   else
   if (Equal(memory[1],'WORK')) then begin
                                       patientworks:=patientworks+1;
                                       works[1,patientworks]:=memory[2];
                                       works[2,patientworks]:=memory[3];
                                       works[3,patientworks]:=memory[4];
                                       works[4,patientworks]:=memory[5];
                                       works[5,patientworks]:=memory[6];
                                       works[6,patientworks]:=memory[7];
                                       works[7,patientworks]:=memory[8];
                                       works[8,patientworks]:=memory[9];
                                       works[9,patientworks]:=memory[10];
                                     end else
   //CHECKBOXES LOAD
   if (Equal(memory[1],'patient_checks')) then begin
                                                if ( (memoryinteger[2]>0) and (memoryinteger[2]<=MAX_CHECKS) ) then patient_checks[memoryinteger[2]]:=memory[3];
                                              end else
   if (Equal(memory[1],'asthma')) then patient_checks[1]:=memory[2] else
   if (Equal(memory[1],'ipatitida')) then patient_checks[2]:=memory[2] else
   if (Equal(memory[1],'pyreto')) then patient_checks[3]:=memory[2] else
   if (Equal(memory[1],'lypothimies')) then patient_checks[4]:=memory[2] else
   if (Equal(memory[1],'aimoragies')) then patient_checks[5]:=memory[2] else
   if (Equal(memory[1],'diaviti')) then patient_checks[6]:=memory[2] else
   if (Equal(memory[1],'anaimia')) then patient_checks[7]:=memory[2] else
   if (Equal(memory[1],'kardiaggeiaki')) then patient_checks[8]:=memory[2] else
   if (Equal(memory[1],'nefra')) then patient_checks[9]:=memory[2] else
   if (Equal(memory[1],'epilipsia')) then patient_checks[10]:=memory[2] else
   if (Equal(memory[1],'neyropsyxika')) then patient_checks[11]:=memory[2] else
   if (Equal(memory[1],'ALLERGIA')) then patient_checks[12]:=memory[2] else
   if (Equal(memory[1],'kapnisma')) then patient_checks[13]:=memory[2] else
   if (Equal(memory[1],'farmaka')) then patient_checks[14]:=memory[2] else

until eof(fileused); 
close(fileused); 

end;
end;

procedure Save_Person(filename:string);
var fileused:text;
    bufstr:string;
    i:integer;
begin
if filename='' then begin
                      {filename:=name+'_'+surname+'.dat';
                      filename:=Greeklish(filename);  }
                      filename:=load_file;
                    end;
load_file:=filename;
assign(fileused,curendir+'Database\'+filename);
rewrite(fileused); 
if code<>'' then writeln(fileused,'CODE('+code+')');
if name<>'' then writeln(fileused,'NAME('+name+')');
if surname<>'' then writeln(fileused,'SURNAME('+surname+')');
if area<>'' then writeln(fileused,'AREA('+area+')');
if vivlio_esodwn<>'' then writeln(fileused,'VIVLIO_ESODWN_EKSODWN('+vivlio_esodwn+')'); 
if areacode<>'' then writeln(fileused,'AREACODE('+areacode+')'); 
if telephone<>'' then writeln(fileused,'TELEPHONE('+telephone+')');
if profession<>'' then writeln(fileused,'PROFESSION('+profession+')');
if photo<>'' then writeln(fileused,'PHOTO('+photo+')');
if cellphone<>'' then  writeln(fileused,'CELLPHONE('+cellphone+')');
if address<>'' then writeln(fileused,'ADDRESS('+address+')');
if emoticon<>'' then writeln(fileused,'EMOTICON('+emoticon+')'); 
if other<>'' then  writeln(fileused,'OTHER('+other+')');
if email<>'' then  writeln(fileused,'EMAIL('+email+')');

//CHECKBOXES LOAD
for i:=1 to MAX_CHECKS do begin
                   if patient_checks[i]='3' then
                     begin
                      if i=1 then bufstr:='asthma' else
                      if i=2 then bufstr:='ipatitida' else
                      if i=3 then bufstr:='pyreto' else
                      if i=4 then bufstr:='lypothimies' else
                      if i=5 then bufstr:='aimoragies' else
                      if i=6 then bufstr:='diaviti' else
                      if i=7 then bufstr:='anaimia' else
                      if i=8 then bufstr:='kardiaggeiaki' else
                      if i=9 then bufstr:='nefra' else
                      if i=10 then bufstr:='epilipsia' else
                      if i=11 then bufstr:='neyropsyxika' else
                      if i=12 then bufstr:='allergia' else
                      if i=13 then bufstr:='kapnisma' else
                      if i=14 then bufstr:='farmaka' else
                                   bufstr:='patient_checks('+Convert2String(i);
                      writeln(fileused,bufstr+'(3)');
                     end;
                  end;


if birthdate[0]<>0 then writeln(fileused,'BIRTH(',birthdate[0],',',birthdate[1],',',birthdate[2],')');
if nextdate[0]<>0 then writeln(fileused,'NEXT_APPOINTMENT(',nextdate[0],',',nextdate[1],',',nextdate[2],')');
if recordcreated[0]<>0 then writeln(fileused,'RECORD_CREATION(',recordcreated[0],',',recordcreated[1],',',recordcreated[2],')');

if patientworks>0 then begin
for i:=1 to patientworks do begin 
                             writeln(fileused,'WORK(',works[1,i],',',works[2,i],',',works[3,i],',',works[4,i],',',works[5,i],',',works[6,i],',',works[7,i],',',works[8,i],',',works[9,i],')');
                            end;
                       end;

close(fileused);
end;

procedure New_Person(thefile,thecode,thename,thesurname:string);
//Creates Record and loads primary data..
var  datesnstuff:array[1..4]of word;
begin
Flush_People;
load_file:=thefile;
code:=thecode;
name:=thename;
surname:=thesurname;
GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
recordcreated[0]:=datesnstuff[1];
recordcreated[1]:=datesnstuff[3];
recordcreated[2]:=datesnstuff[4]; 
Save_Person(thefile);
end;


procedure View_Print_Person;
var fileused:text;
begin
assign(fileused,'Cache\person_printout.html');
rewrite(fileused);
writeln(fileused,'<html><head><title>'+name+' '+surname+'</title><meta http-equiv="Content-Type" content="text/html; charset=windows-1253"></head>');
writeln(fileused,'<body bgcolor=#FFFFFF text=#000000><BASEFONT face="Verdana">');

writeln(fileused,'<center><table><tr><td width=600><center><h2>'+People_Data(2)+' '+People_Data(3)+'</h2><br>κωδικός : '+code+'</center></td>');
writeln(fileused,'<td><center><img src="../logo.jpg" height=50><br><font bgcolor=#CCCCCC size=1>Powered by A-TECH</font></center></td></tr></table></center>');
writeln(fileused,'<br>');

writeln(fileused,'<hr><br>');
writeln(fileused,'<center><table border=1><tr><td>');
writeln(fileused,'Δημιουργία αρχείου '+Convert2String(recordcreated[0])+'/'+Convert2String(recordcreated[1])+'/'+Convert2String(recordcreated[2])+'<br>');
writeln(fileused,'<br><br>');
//code,name,surname,load_file,area,telephone,profession,photo,cellphone,address,emoticon,other,areacode
writeln(fileused,'Όνομα : '+name+' <br>');
writeln(fileused,'Επίθετο : '+surname+' <br>');
writeln(fileused,'Περιοχή : '+area+' <br>');
writeln(fileused,'ΤΚ : '+areacode+'<br>');
writeln(fileused,'Διευθυνση : '+address+'<br>');
writeln(fileused,'Τηλέφωνο : '+telephone+' <br>');
writeln(fileused,'Κινητό : '+cellphone+'<br>');
writeln(fileused,'Επάγγελμα : '+profession+'<br>');
writeln(fileused,'’λλα : '+other+'<br>');
if email<>'' then writeln(fileused,'E-Mail : <a href="mailto:'+email+'">'+email+'</a><br>');
writeln(fileused,'</td>');
if photo<>'' then writeln(fileused,'<td><img src="../Image Database/'+photo+'"><br></td>');
writeln(fileused,'</tr></table></center><hr>');
writeln(fileused,'</body>');
writeln(fileused,'</html>');
close(fileused);
RunEXE(get_external_browser+' "'+People_Data(0)+'Cache\person_printout.html"','normal');
end;


procedure Load_Form();
var i:integer;
begin
set_object_data('code','VALUE',code,0);
set_object_data('name','VALUE',name,0);
set_object_data('surname','VALUE',surname,0);
set_object_data('area','VALUE',area,0);
set_object_data('areacode','VALUE',areacode,0); 
set_object_data('telephone','VALUE',telephone,0);
set_object_data('profession','VALUE',profession,0); 
set_object_data('cellphone','VALUE',cellphone,0);
set_object_data('address','VALUE',address,0);
set_object_data('other','VALUE',other,0); 
set_object_data('email','VALUE',email,0);
set_object_data('vivlio_esodwn_eksodwn','VALUE',vivlio_esodwn,0);


set_object_data('asthma','VALUE',patient_checks[1],0);
set_object_data('ipatitida','VALUE',patient_checks[2],0);
set_object_data('pyreto','VALUE',patient_checks[3],0);
set_object_data('lypothimies','VALUE',patient_checks[4],0);
set_object_data('aimoragies','VALUE',patient_checks[5],0);
set_object_data('diaviti','VALUE',patient_checks[6],0);
set_object_data('anaimia','VALUE',patient_checks[7],0);
set_object_data('kardiaggeiaki','VALUE',patient_checks[8],0);
set_object_data('nefra','VALUE',patient_checks[9],0);
set_object_data('epilipsia','VALUE',patient_checks[10],0);
set_object_data('neyropsyxika','VALUE',patient_checks[11],0);
set_object_data('allergia','VALUE',patient_checks[12],0);
set_object_data('kapnisma','VALUE',patient_checks[13],0);
set_object_data('farmaka','VALUE',patient_checks[14],0); 
for i:=15 to MAX_CHECKS do
   begin
    set_object_data('patient_checks('+Convert2String(i),'VALUE',patient_checks[i],0); 
   end;

set_object_data('1birth1','VALUE',Convert2String(birthdate[0]),0);
set_object_data('1birth2','VALUE',Convert2String(birthdate[1]),0);
set_object_data('1birth3','VALUE',Convert2String(birthdate[2]),0);

set_object_data('2birth1','VALUE',Convert2String(nextdate[0]),0);
set_object_data('2birth2','VALUE',Convert2String(nextdate[1]),0);
set_object_data('2birth3','VALUE',Convert2String(nextdate[2]),0);
end;

procedure Save_Form();
var i:integer;
begin
code:=get_object_data('code');
name:=First_Capital(Sigma_Teliko(get_object_data('name') ) );
surname:=First_Capital(Sigma_Teliko(get_object_data('surname') ) );
area:=get_object_data('area');
areacode:=get_object_data('areacode'); 
telephone:=get_object_data('telephone');
profession:=First_Capital(Sigma_Teliko(get_object_data('profession') ) );
cellphone:=get_object_data('cellphone');
address:=get_object_data('address');
other:=get_object_data('other');
email:=get_object_data('email');
vivlio_esodwn:=get_object_data('vivlio_esodwn_eksodwn');

patient_checks[1]:=get_object_data('asthma');
patient_checks[2]:=get_object_data('ipatitida');
patient_checks[3]:=get_object_data('pyreto');
patient_checks[4]:=get_object_data('lypothimies');
patient_checks[5]:=get_object_data('aimoragies');
patient_checks[6]:=get_object_data('diaviti');
patient_checks[7]:=get_object_data('anaimia');
patient_checks[8]:=get_object_data('kardiaggeiaki');
patient_checks[9]:=get_object_data('nefra');
patient_checks[10]:=get_object_data('epilipsia');
patient_checks[11]:=get_object_data('neyropsyxika');
patient_checks[12]:=get_object_data('allergia');
patient_checks[13]:=get_object_data('kapnisma');
patient_checks[14]:=get_object_data('farmaka');
for i:=15 to MAX_CHECKS do
   begin
    patient_checks[i]:=get_object_data('patient_checks('+Convert2String(i));
   end;


Val(get_object_data('1birth1'),birthdate[0],i);
Val(get_object_data('1birth2'),birthdate[1],i);
Val(get_object_data('1birth3'),birthdate[2],i); 

Val(get_object_data('2birth1'),nextdate[0],i);
Val(get_object_data('2birth2'),nextdate[1],i);
Val(get_object_data('2birth3'),nextdate[2],i); 

end;


procedure Mark_Person_Last_Vist_Now;
var datesnstuff:array[1..4]of word;
begin
GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
nextdate[0]:=datesnstuff[1];
nextdate[1]:=datesnstuff[3];
nextdate[2]:=datesnstuff[4];
end;

procedure Show_Photos_Xrays();
var bordery:integer;
    filephoto:TFileName; 
    fileinit:LPOPENFILENAME;
    test_file:string;
label start_Show_Photos_Xrays;
begin
start_Show_Photos_Xrays:
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
clrscreen;
draw_window;

include_object('window1','window','Dental Database','no','','',GridX(1,8),GridY(1,15),GridX(7,8),GridY(14,15));
draw_all;
delete_object('window1','name');

bordery:=GridY(2,13)+30;
include_object('newxray','buttonc','Νέα ακτινογραφία','no','','',GridX(3,5),bordery,0,0);
include_object('photograph','buttonc','Φωτογραφία','no','','',X2(last_object)+3,bordery,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+3,bordery,0,0);
draw_all; 
DrawJpeg(curendir+'Image Database\dental-x-ray.jpg',GridX(1,8)+30,GridY(1,15)+50);
DrawJpeg(curendir+'Image Database\x-ray2.jpg',GridX(1,8)+30,GridY(1,15)+300);
repeat
interact;
if get_object_data('photograph')='4' then begin
                                           set_object_data('photograph','value','1',1);
                                           MessageBox (0, 'OLD CODE !!!' , ' ', 0 + MB_ICONHAND);
                                          { if (SelectFile(filephoto,true)) then}  begin
                                                                                  set_button('photograph',0);
                                                                                  photo:=AnalyseFilename(filephoto,'FILENAME+EXTENTION');
                                                                                  CopyFile(AnsiString(filephoto),AnsiString(curendir+'Image Database\'+photo));
                                                                                  test_file:=load_file;
                                                                                  Save_Person('');
                                                                                  {$i-}
                                                                                   Load_Person('',true);
                                                                                  {$i+}
                                                                                  if Ioresult<>0 then begin
                                                                                                        MessageBox (0, 'Υπάρχει κάποιο πρόβλημα με την φωτογραφία αυτή!' , ' ', 0 + MB_ICONHAND);
                                                                                                        photo:='';
                                                                                                        Save_Person('');
                                                                                                      end;
                                                                                 end;{ else }
                                           MessageBox (0, 'Δεν έγινε αλλαγή στην φωτογραφία..' , 'Dental Database Mk2', 0 + MB_ICONASTERISK);
                                          end;
until GUI_Exit;
end;


procedure Check_Pass_2_Works(work_id,comments,comments2,user:string; price,discount,payed,dateday,datemonth,dateyear:integer);
// PSAXNEI AN KATI YPARXEI STA WORKS KAI AN OXI SE RWTAEI KAI TO PROSTHETEI..
var matches,i,z:integer;
    swaped:boolean;
    differences,datedays,datemonths,dateyears,bufstr:string;
begin 
//works:array[1..9,1..MAX_WORKS]of string ; // 1 WorkID , 2 Price , 3 Discount , 4 Payed , 5 Comments , 6 user , 7 day , 8 month , 9year 
      matches:=0;
      swaped:=false;
      differences:='';
      datedays:=Convert2String(dateday);
      datemonths:=Convert2String(datemonth);
      dateyears:=Convert2String(dateyear);
   if patientworks>0 then
 begin
      for i:=1 to patientworks do
       begin
        if Equal(works[1,i],work_id) then
          begin
           matches:=matches+1;
           if ((Equal(works[7,i],datedays)) and (Equal(works[8,i],datemonths)) and (Equal(works[9,i],dateyears)) ) then
             begin 
              bufstr:='Η Εργασία αυτή είναι ήδη περασμένη για την ίδια ημερομηνία ('+datedays+'/'+datemonths+'/'+dateyears+'), θέλετε να την αντικαταστήσετε?'+#10;
              z:=MessageBox (0, pchar(bufstr) , ' ', 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
              if z=IDYES then
                 begin
                  swaped:=true;
                  works[1,i]:=work_id;
                  works[2,i]:=Convert2String(price);
                  works[3,i]:=Convert2String(discount);
                  works[4,i]:=Convert2String(payed);
                  works[5,i]:=comments;
                  if Length(comments2)>0 then works[5,i]:=works[5,i]+' '+comments2;
                  works[6,i]:=user;
                  works[7,i]:=datedays;
                  works[8,i]:=datemonths;
                  works[9,i]:=dateyears;
                  Save_Person('');
                 end; //SWAPED
             end; //SAME DATE.. 
          end; // A MATCH
       end; // SEARCH
  end;//THE PATIENT HAS WORKS (BUGFIX 26-05-06)
       if not swaped then
        begin
           if matches>0 then begin
                               bufstr:='Η Εργασία αυτή εντοπίστηκε περασμένη '+Convert2String(matches)+' φορές'+#10;
                               bufstr:=bufstr+'Θέλετε να την προσθέσετε και άλλη μια φορά?'+#10+#10;
                               bufstr:=bufstr+'(καλό θα ήταν να ανοίξετε το menu εργασιών και να  δείτε τα περιεχόμενα του)'+#10;
                             end else
                               bufstr:='Θέλετε να προσθέσετε την εργασία '+work_id+' ?' +#10;
           z:=MessageBox (0, pchar(bufstr) , ' ', 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
           if z=IDYES then
                 begin
                  patientworks:=patientworks+1;
                  works[1,patientworks]:=work_id;
                  works[2,patientworks]:=Convert2String(price);
                  works[3,patientworks]:=Convert2String(discount);
                  works[4,patientworks]:=Convert2String(payed);
                  works[5,patientworks]:=comments;
                  if Length(comments2)>0 then works[5,patientworks]:=works[5,patientworks]+' '+comments2;
                  works[6,patientworks]:=user;
                  works[7,patientworks]:=datedays;
                  works[8,patientworks]:=datemonths;
                  works[9,patientworks]:=dateyears;
                  Save_Person('');
                 end;
        end;
 
end;

procedure Delete_Works(fromrec,torec:integer);
var i,z,fromwhere:integer;
begin
//TODO BUG ?
if fromrec<=torec then
  begin
    for i:=fromrec to patientworks do
      begin 
         fromwhere:=torec+i-fromrec+1;
         for z:=1 to 9 do works[z,i]:=works[z,fromwhere]; 
      end;
    patientworks:=patientworks-(torec-fromrec+1);
  end;
end;

procedure Compact_Works;
var i:integer;
begin
if patientworks>0 then
begin
Write_2_Log('Compact_Works not ready yet..'); 
end;//WORKS EXIST (ALLIWS TI NOIMA EXEI TO COMPACTING..?)
end;


procedure GUI_Delete_Works;
var from_where,to_where,i:integer;
    formx:integer;
    label end_delete;
begin 
if patientworks=0 then begin
                        MessageBox (0, 'Δεν υπάρχουν εργασίες για διαγραφή! ' , ' ', 0 + MB_ICONASTERISK);
                        goto end_delete;
                       end;

formx:=TextWidth('XXXXΧΧΧΧXX');
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
//clrscreen;
//draw_window;

include_object('window1','window','Διαγραφή εργασιών , '+Convert2String(patientworks)+' συνολικά ','no','','',GridX(1,3),300,GridX(2,3),450);
draw_all;
delete_object('window1','name');
include_object('wherecomment','comment','Από : ','no','','',GridX(1,3)+30,360,0,0);
include_object('where','textbox','','no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+formx,0);
include_object('tocomment','comment','Έως : ','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('to','textbox','','no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+formx,0);
include_object('ok','buttonc','Διαγραφή','no','','',GridX(1,3)+30,Y2(last_object)+10,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+10,Y1(last_object),0,0);
draw_all;
repeat
interact;
if get_object_data('ok')='4' then begin
                                    Val(get_object_data('where'),from_where,i);
                                    Val(get_object_data('to'),to_where,i); 
                                    //EXEI SIMASIA I SEIRA TWN ERROR CHECKS! :)
                                    if (from_where>patientworks) then from_where:=patientworks;
                                    if (to_where>patientworks) then to_where:=patientworks;
                                    if from_where<=0 then MessageBox (0, pchar('Λάθος επιλογή από '+Convert2String(from_where)) , ' ', 0 + MB_ICONEXCLAMATION) else
                                    if to_where<=0 then MessageBox (0, pchar('Λάθος επιλογή έως '+Convert2String(to_where)) , ' ', 0 + MB_ICONEXCLAMATION) else
                                    if from_where>to_where then begin
                                                                 i:=MessageBox (0, pchar('Έχετε τοποθετήσει ανάποδα τα νούμερα των εγγραφών που θέλετε να διαγραφούν..'+#10+' Μήπως εννοείτε '+Convert2String(to_where)+' έως '+Convert2String(from_where)+' ?'+#10+'Αν όχι διορθώστε την εντολή σας για να εκτελεστεί..') , ' ', 0 + MB_YESNO + MB_ICONQUESTION);
                                                                 if i=IDYES then
                                                                   begin
                                                                    i:=from_where;
                                                                    from_where:=to_where;
                                                                    to_where:=i;
                                                                   end;
                                                                end;
                                    Delete_Works(from_where,to_where);
                                    set_button('exit',1);
                                  end; 
until GUI_Exit;
end_delete:
end;


procedure Pass_Works(startrecord,endrecord:integer);
var i,y,z:integer;
    s,bufstr:string;
begin
y:=startrecord-1;
for i:=startrecord to endrecord do
begin
s:=Convert2String(i);
if i<10 then s:='0'+s;
bufstr:='episkepsi'+s;
works[1,i]:=get_object_data('ergasia'+s);
works[2,i]:=get_object_data('kostos'+s);
works[3,i]:=get_object_data('ekptwsi'+s);
works[4,i]:=get_object_data('payed'+s);
works[5,i]:=get_object_data('comments'+s);
works[6,i]:=get_object_data('user'+s);
works[7,i]:=get_object_data('day'+s);
works[8,i]:=get_object_data('month'+s);
works[9,i]:=get_object_data('year'+s); 
//if ((works[1,i]<>'')or(works[2,i]<>'')or(works[6,i]<>'')) then y:=y+1;
for z:=1 to 9 do begin //GIA NA PAIZEI KATEYTHEIAN ME ALLAGI MONO SE HMEROMINIES KTL ADDED 20/4/07
                  if (z<>6) then
                   begin  //DILADI ELEGXOUME GIA ALLAGES SE OPOIODIPOTE KOUTAKI KAI AN YPARXOUN TO SWZOUME
                    if (works[z,i]<>'') then begin
                                              y:=y+1;
                                              break;
                                             end;
                   end;
                 end;
end;
if ((y>patientworks) and (endrecord>patientworks)) then patientworks:=y;
Compact_Works;
end;

procedure Draw_Works_Form(startrecord,endrecord:integer);
var i:integer;
    s:string;
begin
for i:=startrecord to endrecord do
begin
s:=Convert2String(i);
if i<10 then s:='0'+s; 
set_object_data('ergasia'+s,'value',works[1,i],0);
draw_object_by_name('ergasia'+s);

set_object_data('kostos'+s,'value',works[2,i],0);
draw_object_by_name('kostos'+s);

set_object_data('ekptwsi'+s,'value',works[3,i],0);
draw_object_by_name('ekptwsi'+s);

set_object_data('payed'+s,'value',works[4,i],0);
draw_object_by_name('payed'+s);

set_object_data('comments'+s,'value',works[5,i],0);
draw_object_by_name('comments'+s);

set_object_data('user'+s,'value',works[6,i],0);
draw_object_by_name('user'+s);

set_object_data('day'+s,'value',works[7,i],0);
draw_object_by_name('day'+s);

set_object_data('month'+s,'value',works[8,i],0);
draw_object_by_name('month'+s);

set_object_data('year'+s,'value',works[9,i],0); 
draw_object_by_name('year'+s); 
end;
end;

procedure Show_Data();
var startrecord,endrecord,pagerecords,page,i,y,xb,xs,formx,formmoneyx,where2add:integer;
    bufstr,s:string;
    show_disc,filled_up:boolean;
    activation,theuser,lastobj:string;
    tot_cost,tot_disc,tot_pay:integer;
    datesnstuff:array[1..4]of word;
    label start_show_data,start_show_data_noclear;
begin
theuser:=Get_Current_User; //Oi allages tha apothikeytoun ston..
GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
activation:='';

page:=1;
pagerecords:=14;
startrecord:=1;
//endrecord:=patientworks;
endrecord:=pagerecords;
//if endrecord-startrecord>15 then endrecord:=15;

start_show_data:
clrscreen;
draw_window;

start_show_data_noclear:

flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');

include_object('window1','window','Εργασίες , '+Convert2String(startrecord)+'-'+Convert2String(endrecord)+'/ '+Convert2String(patientworks),'no','','',GridX(1,8),GridY(1,15),GridX(7,8),GridY(14,15)+30);
draw_all;
delete_object('window1','name');

xs:=20; //X border from start of window
xb:=4; // X Border for everything
formx:=TextWidth('X')*15;  // X size for each form
formmoneyx:=TextWidth('X')*8;

 
for i:=startrecord to endrecord do
begin
s:=Convert2String(i);
if i<10 then s:='0'+s;
//bufstr:='episkepsi'+s;                //Επίσκεψη 
include_object('episkepsi'+s,'comment','#'+s,'no','','',GridX(1,8)+xs,GridY(i-startrecord+3,19)+3,0,0);
//DrawApsXY('delbtn',X1(last_object)+(X2(last_object)-X1(last_object)) div 2,Y2(last_object)+5);
include_object('ergasia'+s,'textbox',works[1,i],'no','','',X2(last_object)+2*xb,GridY(i-startrecord+3,19),X2(last_object)+formx-TextWidth('X')*8,0);
include_object('day'+s,'textbox',works[7,i],'no','','',X2(last_object)+3*xb,GridY(i-startrecord+3,19),X2(last_object)+3*xb+25,0);
include_object('/'+s,'comment','/','no','','',X2(last_object)+xb,GridY(i-startrecord+3,19)+3,0,0);
include_object('month'+s,'textbox',works[8,i],'no','','',X2(last_object)+xb,GridY(i-startrecord+3,19),X2(last_object)+xb+25,0);
include_object('//'+s,'comment','/','no','','',X2(last_object)+xb,GridY(i-startrecord+3,19)+3,0,0);
include_object('year'+s,'textbox',works[9,i],'no','','',X2(last_object)+xb,GridY(i-startrecord+3,19),X2(last_object)+xb+40,0);
{
include_object('date'+s,'textbox',works[7,i]+'/'+works[8,i]+'/'+works[9,i],'no','','',X2(last_object)+3*xb,GridY(i-startrecord+3,19),X2(last_object)+3*xb+formx,0);
}
include_object('kostos'+s,'textbox',works[2,i],'no','','',X2(last_object)+2*xb,GridY(i-startrecord+3,19),X2(last_object)+formmoneyx,0);
include_object('ekptwsi'+s,'textbox',works[3,i],'no','','',X2(last_object)+2*xb,GridY(i-startrecord+3,19),X2(last_object)+formmoneyx,0);
include_object('payed'+s,'textbox',works[4,i],'no','','',X2(last_object)+2*xb,GridY(i-startrecord+3,19),X2(last_object)+formmoneyx,0);
include_object('comments'+s,'textbox',works[5,i],'no','','',X2(last_object)+2*xb,GridY(i-startrecord+3,19),X2(last_object)+formx*3,0);
include_object('user'+s,'comment',works[6,i],'no','','',X2(last_object)+2*xb,GridY(i-startrecord+3,19),X2(last_object)+formx*2,0);

//include_object('del'+s,'comment',works[6,i],'no','','',X2(last_object)+2*xb,GridY(i-startrecord+3,19),X2(last_object)+formx*2,0);
//include_object('episkepsi'+bufstr,'comment',works[4,i],'no','','',GridX(i,10),GridY(i,19),0,0);
end; 

bufstr:=s;
s:=Convert2String(startrecord);
if startrecord<10 then s:='0'+s;
include_object('comment_Ergasia','comment','Εργασία','no','','',X1('ergasia'+s),Y1('ergasia'+s)-22,0,0);
include_object('comment_Date','comment','Ημερομηνία','no','','',X1('/'+s),Y1('/'+s)-22,0,0);
include_object('comment_Cost','comment','Κόστος','no','','',X1('kostos'+s),Y1('kostos'+s)-22,0,0);
include_object('comment_Cost','comment','Έκπτωση','no','','',X1('ekptwsi'+s),Y1('ekptwsi'+s)-22,0,0);
include_object('comment_Cost','comment','Πληρωμή','no','','',X1('payed'+s),Y1('payed'+s)-22,0,0);
include_object('comment_Date','comment','Περιγραφή','no','','',X1('comments'+s),Y1('comments'+s)-22,0,0);
s:=bufstr;

include_object('add_smth','buttonc','Προσθήκη εργασίας','no','','',X1('ergasia'+s)+30,Y2('ergasia'+s)+45,0,0);
include_object('delete_smth','buttonc','Διαγραφή','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('antistoixisi','buttonc','Αντιστοίχηση ('+theuser+')','no','','',X2('delete_smth')+5,Y1('delete_smth'),0,0);
include_object('notes','buttonc','Κοινές Σημειώσεις','no','','',X2('antistoixisi')+5,Y1('antistoixisi'),0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2('notes')+5,Y1('notes'),0,0);
if startrecord>1 then include_object('back','buttonc','<-','no','','',X2(last_object)+5,Y1(last_object),0,0);
if endrecord<patientworks then include_object('next','buttonc','->','no','','',X2(last_object)+5,Y1(last_object),0,0);
draw_all;

DrawApsXY('ffinder',X1('episkepsi'+s)+5,Y1('exit'));
include_object('hide','layer','1','no','','',X1('episkepsi'+s)+5,Y1('exit'),X1('episkepsi'+s)+5+GetApsInfo('ffinder','sizex'),Y1('exit')+GetApsInfo('ffinder','sizey'));
show_disc:=false;
if activation<>'' then begin //ONLOAD ACTIVATION..
                        activate_object(activation);
                        activation:='';
                       end; 
repeat
interact;
lastobj:=last_object_activated; 
if (get_object_data('delete_smth')='4') then begin
                                        set_object_data('delete_smth','value','1',1);
                                        Pass_Works(startrecord,endrecord); //TEST CODE
                                        GUI_Delete_Works;
                                        goto start_show_data;
                                       end else 
if (get_object_data('notes')='4') then begin
                                        set_object_data('notes','value','1',1);
                                        Pass_Works(startrecord,endrecord);  
                                        save_graph_window;
                                        clrscreen;
                                        RunEXE(get_external_editor+' "'+curendir+'Database\'+People_Data(9)+'.nfo"','normal');
                                        MessageBox (0, 'Πατήστε ΟΚ όταν τελείωσετε με την επεξεργασία του κειμένου..' , ' ', 0);
                                        load_graph_window;
                                        goto start_show_data;
                                       end else
if (get_object_data('antistoixisi')='4') then begin
                                               set_object_data('antistoixisi','value','1',1);
                                               Pass_Works(startrecord,endrecord);
                                               if (Get_User_Access(Get_Current_User)>=500) then begin
                                                                                                 bufstr:=GUI_Select_User;
                                                                                                 if bufstr<>'' then theuser:=bufstr;
                                                                                                 goto start_show_data;
                                                                                                end else
                                                                        MessageBox (0, 'Χρειάζεται κωδικός μεγαλύτερης πρόσβασης (500+)' , ' ', 0);
                                              end else
if (get_object_data('back')='4') then begin
                                       set_object_data('back','value','1',1); 
                                       Pass_Works(startrecord,endrecord);
                                       if startrecord-pagerecords<1 then startrecord:=1 else
                                                                         startrecord:=startrecord-pagerecords;
                                       endrecord:=pagerecords+startrecord-1; 
                                       goto start_show_data;
                                      end else
if (get_object_data('next')='4') then begin
                                       set_object_data('next','value','1',1); 
                                       Pass_Works(startrecord,endrecord);
                                       if endrecord+pagerecords>MAX_WORKS then endrecord:=MAX_WORKS else
                                                                               endrecord:=endrecord+pagerecords-1;
                                       startrecord:=endrecord-pagerecords+2;
                                       goto start_show_data;
                                      end else
if (get_object_data('add_smth')='4') then begin
                                           set_object_data('add_smth','value','1',1);
                                           Pass_Works(startrecord,endrecord);
                                           where2add:=0;
                                           filled_up:=true;
                                           for i:=startrecord to endrecord do
                                             begin
                                              s:=Convert2String(i);
                                              if i<10 then s:='0'+s;
                                              if ((get_object_data('ergasia'+s)='')and(get_object_data('kostos'+s)='')) then
                                                      begin
                                                       filled_up:=false;
                                                       where2add:=i;
                                                       break;
                                                      end;
                                             end;
                                             if filled_up then where2add:=patientworks+1; 
                                                            
                                             if ((where2add>0) and (where2add<=MAX_WORKS) ) then
                                             begin
                                              s:=Convert2String(where2add);
                                              if where2add<10 then s:='0'+s;
                                           bufstr:=Select_Works(false);
                                           if bufstr<>'' then
                                           begin
                                              y:=Get_Work_Mem_From_Code(bufstr); 
                                              if y=-1 then begin
                                                            MessageBox (0, 'Δεν υπάρχει τιμή για την συγκεκριμένη καταχώρηση - Error' , ' ', 0 + MB_ICONEXCLAMATION);
                                                            works[2,where2add]:='0';
                                                            works[5,where2add]:='';
                                                           end else
                                                           begin
                                                            works[2,where2add]:=Convert2String(Get_Int_From_Mem(2,y));
                                                            works[5,where2add]:=Get_Str_From_Mem(2,y);
                                                           end;
                                              works[1,where2add]:=bufstr;
                                              works[3,where2add]:='0';
                                              works[4,where2add]:='0';
                                              works[6,where2add]:=theuser;
                                              works[7,where2add]:=Convert2String(datesnstuff[1]);
                                              works[8,where2add]:=Convert2String(datesnstuff[3]);
                                              works[9,where2add]:=Convert2String(datesnstuff[4]);
                                              s:=Convert2String(where2add);
                                              if where2add<10 then s:='0'+s;
                                              if ((where2add>0) and (where2add<=endrecord)) then activation:='payed'+s else
                                                                                                 activation:='';
                                              if filled_up then patientworks:=patientworks+1;
                                            end;
                                              Draw_Works_Form(where2add,where2add);
                                              //goto start_show_data_noclear;
                                             end;
                                           {filled_up:=true;
                                           for i:=startrecord to endrecord do
                                             begin
                                              s:=Convert2String(i);
                                              if i<10 then s:='0'+s;
                                              if ((get_object_data('ergasia'+s)='')and(get_object_data('kostos'+s)='')) then
                                                   begin
                                                    filled_up:=false;
                                                    bufstr:=Select_Works;
                                                    if bufstr<>'' then
                                                  begin
                                                     y:=Get_Work_Mem_From_Code(bufstr);
                                                     if y=-1 then begin
                                                                   MessageBox (0, 'Δεν υπάρχει τιμή για την συγκεκριμένη καταχώρηση - Error' , ' ', 0 + MB_ICONEXCLAMATION);
                                                                   works[2,i]:='0';
                                                                   works[5,i]:='';
                                                                 end else
                                                                  begin
                                                                   works[2,i]:=Convert2String(Get_Int_From_Mem(2,y));
                                                                   works[5,i]:=Get_Str_From_Mem(2,y);
                                                                  end;
                                                     works[1,i]:=bufstr; 
                                                     works[3,i]:='0';
                                                     works[4,i]:='0';
                                                     works[6,i]:=theuser;
                                                     works[7,i]:=Convert2String(datesnstuff[1]);
                                                     works[8,i]:=Convert2String(datesnstuff[3]);
                                                     works[9,i]:=Convert2String(datesnstuff[4]);
                                                     activation:='payed'+s;
                                                     patientworks:=patientworks+1;

                                                 end; // EXIT
                                                   goto start_show_data;

                                                   end; 
                                             end;
                                             if filled_up then begin
                                                                goto start_show_data;
                                                               end; }
                                          end else
if (get_object_data('emoticons')='4') then begin
                                             set_object_data('emoticons','value','1',1);
                                             Pass_Works(startrecord,endrecord); //Prin katastrafei to parathiro..
                                             emoticon:=Select_GUI_Smiley(emoticon); 
                                             goto start_show_data;
                                           end else
if (get_object_data('hide')='4') then begin
                                        set_object_data('hide','value','1',1); 
                                        if (show_disc) then show_disc:=false else  show_disc:=true;
                                        s:=Convert2String(endrecord);
                                        if endrecord<10 then s:='0'+s;                                                      
                                        if (show_disc) then  DrawRectangle2(X1('ergasia'+s),Y2('ergasia'+s)+20,X2('comments'+s),Y2('ergasia'+s)+40,ConvertRGB(123,123,123),ConvertRGB(123,123,123)) else
                                                             DrawRectangle2(X1('ergasia'+s),Y2('ergasia'+s)+20,X2('comments'+s),Y2('ergasia'+s)+40,ConvertRGB(208,219,241),ConvertRGB(208,219,241));

                                        if (show_disc) then  begin
                                                              include_object('emoticons','layer','1','no','','',X2('hide')+5,Y1('hide'),X2('hide')+5+GetApsInfo('smiley_neutral','sizex'),Y1('hide')+GetApsInfo('smiley_neutral','sizey'));
                                                              if (emoticon='') then emoticon:='smiley_neutral';
                                                              DrawApsXY(emoticon,X1('emoticons'),Y1('emoticons'));
                                                             end else
                                                             begin
                                                              DrawRectangle2(X1('emoticons')-1,Y1('emoticons')-1,X2('emoticons')+1,Y2('emoticons')+1,ConvertRGB(208,219,241),ConvertRGB(208,219,241));
                                                              delete_object('emoticons','NAME');
                                                             end;


                                        //draw_object_by_name('add_smth');
                                        //draw_object_by_name('exit');
                                        if (show_disc) then begin
                                                               tot_cost:=0;
                                                               tot_disc:=0;
                                                               tot_pay:=0;
                                                               if startrecord>1 then
                                                                //Athroisma kai proigoumenwn selidwn..
                                                                begin
                                                                 for i:=1 to startrecord-1 do
                                                                  begin               // 1 WorkID , works2 Price , 3 Discount , 4 Payed 
                                                                   Val(works[2,i],xb,xs);
                                                                   tot_cost:=tot_cost+xb;
                                                                   Val(works[3,i],y,xs);
                                                                   xs:=(xb * (y) ) div 100;
                                                                   tot_disc:=tot_disc+xs;
                                                                   Val(works[4,i],xb,xs);
                                                                   tot_pay:=tot_pay+xb;
                                                                  end;
                                                                end; //TELOS athroisma proigoumenwn selidwn..
                                                               for i:=startrecord to endrecord do
                                                                 begin
                                                                   s:=Convert2String(i);
                                                                   if i<10 then s:='0'+s;
                                                                   Val(get_object_data('kostos'+s),xb,xs);
                                                                   tot_cost:=tot_cost+xb;
                                                                   Val(get_object_data('ekptwsi'+s),y,xs);
                                                                   xs:=(xb * (y) ) div 100;
                                                                   tot_disc:=tot_disc+xs;
                                                                   Val(get_object_data('payed'+s),xb,xs);
                                                                   tot_pay:=tot_pay+xb;
                                                                 end; 
                                                              if endrecord<patientworks then
                                                                //Athroisma kai meta selidwn..
                                                                begin
                                                                 for i:=endrecord+1 to patientworks do
                                                                  begin               // 1 WorkID , works2 Price , 3 Discount , 4 Payed  
                                                                   Val(works[2,i],xb,xs);
                                                                   tot_cost:=tot_cost+xb;
                                                                   Val(works[3,i],y,xs);
                                                                   xs:=(xb * (y) ) div 100;
                                                                   tot_disc:=tot_disc+xs;
                                                                   Val(works[4,i],xb,xs);
                                                                   tot_pay:=tot_pay+xb;
                                                                  end;
                                                                end; //TELOS athroisma kai metaselidwn..
                                                                s:=Convert2String(endrecord);
                                                                if endrecord<10 then s:='0'+s;
                                                                OutTextXY(X1('kostos'+s),Y2('kostos'+s)+22,Convert2String(tot_cost)+'');
                                                                OutTextXY(X1('ekptwsi'+s),Y2('ekptwsi'+s)+22,Convert2String(tot_disc)+'');
                                                                OutTextXY(X1('payed'+s),Y2('payed'+s)+22,Convert2String(tot_pay)+'');
                                                                i:=tot_pay-tot_cost+tot_disc; // balance
                                                                if i<0 then TextColor(ConvertRGB(255,0,0)) else
                                                                if i>0 then TextColor(ConvertRGB(0,255,0)) else
                                                                            TextColor(ConvertRGB(0,0,255));
                                                                OutTextXY(X1('comments'+s),Y2('comments'+s)+22,' balance = '+Convert2String(i)+'');
                                                                TextColor(ConvertRGB(255,255,255));
                                                            end;
                                          delay(200);
                                          for i:=1 to 10 do MouseButton(1);
                                          FlushMouseButtons;
                                      end else

                                      begin
                                       flush_last_object_activated; 
                                       i:=SerialEqual('ergasia',lastobj);
                                       if i<>0 then
                                         begin
                                          bufstr:='';
                                          for y:=i+1 to Length(lastobj) do bufstr:=bufstr+lastobj[y];
                                          Val(bufstr,where2add,y); // i =row changed
                                          if ( (works[1,where2add]='') and (get_object_data(lastobj)<>'') ) then
                                              begin //Changed from empty field
                                              set_object_data('ekptwsi'+bufstr,'value','0',1);

                                              works[1,where2add]:=get_object_data(lastobj);
                                              works[7,where2add]:=Convert2String(datesnstuff[1]);
                                              works[8,where2add]:=Convert2String(datesnstuff[3]);
                                              works[9,where2add]:=Convert2String(datesnstuff[4]); 
                                              works[3,where2add]:='0'; 
                                              works[6,where2add]:=theuser;

                                               y:=Get_Work_Mem_From_Code(get_object_data(lastobj));
                                               if y=-1 then begin
                                                             //ASXETI PLIKTROLOGISI STIN ERGASIA!
                                                             activation:='kostos'+bufstr;
                                                            end else
                                                            begin
                                                             works[2,where2add]:=Convert2String(Get_Work_Int(y,2));
                                                             works[5,where2add]:=Get_Work_Str(y,2);
                                                             activation:='payed'+bufstr; 
                                                            end;

                                               Draw_Works_Form(where2add,where2add);
                                               //goto start_show_data_noclear;
                                              end;
                                         end;
                                      end;


until GUI_Exit;

Pass_Works(startrecord,endrecord);




end;
 



procedure View_Person();
var borderx,bordery,i,blocky,st_x:integer;
    bufstr,bufstr2:string;
    wndx1,wndx2,btny:integer;
label start_view_person,abandon_person;
begin
start_view_person:

flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
clrscreen;
draw_window;
                                                                                 //GridY(1,15)     GridY(14,15)
wndx1:=(GridX(1,8) div 2);
wndx2:=GetMaxX-(GridX(1,8) div 2);
include_object('window1','window','Dental Database','no','','',wndx1,10,wndx2,GetMaxY-10);
draw_all;
delete_object('window1','name');

include_object('layer1','layer','photo place','no','','',GridX(3,5),GridY(2,13),GridX(4,5)-10,GridY(6,13));


st_x:=wndx1+30;

include_object('comment9','comment','Κωδικός: ','no','','',st_x,GridY(1,13),GridX(2,5),GridY(2,13));
include_object('code','textbox',code,'no','','',X2('comment9')+10,GridY(1,13),GridX(3,5),GridY(2,13));
blocky:=Y2(last_object)-Y1(last_object)-7;


include_object('comment1','comment','Όνομα: ','no','','',st_x,Y2(last_object)+blocky,GridX(2,5),0);
include_object('name','textbox',name,'no','','',X2('comment1')+10,Y1(last_object),GridX(3,5),GridY(3,13));

include_object('comment2','comment','Επίθετο: ','no','','',st_x,Y2(last_object)+blocky,GridX(2,5),GridY(4,13));
include_object('surname','textbox',surname,'no','','',X2('comment2')+10,Y1(last_object),GridX(3,5),GridY(4,13));

include_object('comment3','comment','Πόλη: ','no','','',st_x,Y2(last_object)+blocky,0,GridY(5,13));
include_object('area','textbox',area,'no','','',X2('comment3')+10,Y1(last_object),X2(last_object)+230,GridY(5,13));

include_object('commentTK','comment','Τ.Κ. : ','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('areacode','textbox',areacode,'no','','',X2(last_object)+10,Y1(last_object),GridX(3,5),0);

include_object('comment6','comment','Διεύθυνση: ','no','','',st_x,Y2(last_object)+blocky,GridX(2,5),GridY(5,13));
include_object('address','textbox',address,'no','','',X2('comment6')+10,Y1(last_object),GridX(3,5),GridY(5,13));

include_object('comment4','comment','Τηλέφωνο: ','no','','',st_x,Y2(last_object)+blocky,GridX(2,5),GridY(6,13));
include_object('telephone','textbox',telephone,'no','','',X2('comment4')+10,Y1(last_object),X2('comment4')+10+12*TextWidth('X'),GridY(6,13));
include_object('cellphone','textbox',cellphone,'no','','',X2('telephone')+10,Y1(last_object),X2('telephone')+10+12*TextWidth('X'),GridY(6,13));

include_object('comment10','comment','E-Mail: ','no','','',X2(last_object)+10,Y1(last_object)+3,GridX(2,5),GridY(6,13));
include_object('email','textbox',email,'no','','',X2(last_object)+10,Y1(last_object)-3,GridX(3,5),GridY(6,13));




include_object('comment5','comment','Επάγγελμα: ','no','','',st_x,Y2(last_object)+blocky,GridX(2,5),GridY(7,13));
include_object('profession','textbox',profession,'no','','',X2('comment5')+10,Y1(last_object),GridX(3,5),GridY(7,13));





include_object('1comment6','comment','Γέννηση: ','no','','',st_x,Y2(last_object)+blocky,GridX(2,5),GridY(8,13));
bufstr:=Convert2String(birthdate[0]);
if bufstr='0' then bufstr:='';
include_object('1birth1','textbox',bufstr,'no','','',X2('1comment6')+10,Y1(last_object),X2('1comment6')+40,GridY(8,13));
include_object('1comment7','comment','/','no','','',X2('1birth1')+10,Y1(last_object),GridX(2,5),GridY(8,13));
bufstr:=Convert2String(birthdate[1]);
if bufstr='0' then bufstr:='';
include_object('1birth2','textbox',bufstr,'no','','',X2('1comment7')+10,Y1(last_object),X2('1comment7')+40,GridY(8,13));
include_object('1comment8','comment','/','no','','',X2('1birth2')+10,Y1(last_object),GridX(2,5),GridY(8,13));
bufstr:=Convert2String(birthdate[2]);
if bufstr='0' then bufstr:='';
include_object('1birth3','textbox',bufstr,'no','','',X2('1comment8')+10,Y1(last_object),X2('1comment8')+60,GridY(8,13));

                                                           // GridX(1,5),Y2(last_object)+blocky
include_object('2comment6','comment','Τελ. Επίσκεψη: ','no','','',X2(last_object)+10,Y1(last_object),GridX(2,5),GridY(8,13));
bufstr:=Convert2String(nextdate[0]);
if bufstr='0' then bufstr:='';
include_object('2birth1','textbox',bufstr,'no','','',X2('2comment6')+10,Y1(last_object),X2('2comment6')+40,GridY(8,13));
include_object('2comment7','comment','/','no','','',X2('2birth1')+10,Y1(last_object),GridX(2,5),GridY(8,13));
bufstr:=Convert2String(nextdate[1]);
if bufstr='0' then bufstr:='';
include_object('2birth2','textbox',bufstr,'no','','',X2('2comment7')+10,Y1(last_object),X2('2comment7')+40,GridY(8,13));
include_object('2comment8','comment','/','no','','',X2('2birth2')+10,Y1(last_object),GridX(2,5),GridY(8,13));
bufstr:=Convert2String(nextdate[2]);
if bufstr='0' then bufstr:='';
include_object('2birth3','textbox',bufstr,'no','','',X2('2comment8')+10,Y1(last_object),X2('2comment8')+60,GridY(8,13));
include_object('now_arrived','buttonc','Τώρα','no','','',X2(last_object)+5,Y1(last_object),0,0);



if ((recordcreated[0]>0)and (recordcreated[1]>0) and (recordcreated[2]>0)) then
          bufstr:=Convert2String(recordcreated[0])+'/'+Convert2String(recordcreated[1])+'/'+Convert2String(recordcreated[2])
           else
          bufstr:='’γνωστη';

if (not alert_level) then  begin
                            include_object('vivlio_com','comment','Βιβλίο ασθενών: ','no','','',st_x,Y2(last_object)+blocky,GridX(2,5),GridY(8,13));
                            include_object('vivlio_esodwn_eksodwn','textbox',vivlio_esodwn,'no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+150,0); //GridX(4,5)
                           end else
                            include_object('vivlio_esodwn_eksodwn','data',vivlio_esodwn,'no','','',st_x,Y2(last_object),st_x,Y2(last_object));
                           

include_object('othercmm','comment','’λλα : ','no','','',st_x,Y2(last_object)+blocky,GridX(3,5)-10,0);
include_object('other','textbox',other,'no','','',X2(last_object)+5,Y1(last_object),GridX(4,5),0);

include_object('recordcreation','comment','Δημιουργία Αρχείου : '+bufstr,'no','','',st_x,Y2(last_object)+blocky,GridX(2,5),GridY(8,13));




//PHOTO START

borderx:=GridX(1,5) div 3;
//DrawRectangle(GridX(3,5)+borderx,GridY(2,13),GridX(4,5),GridY(6,13),ConvertRGB(255,0,0));
{DrawLine(GridX(3,5)+borderx,GridY(2,13),GridX(4,5),GridY(6,13),ConvertRGB(255,0,0));
DrawLine(GridX(3,5)+borderx,GridY(6,13),GridX(4,5),GridY(2,13),ConvertRGB(255,0,0));    }
//PHOTO END



bordery:=Y2(last_object)+30;
btny:=bordery; // BUTTONS Y
if patient_checks[23]='3' then //O ASTHENIS EXEI AIDS
  begin
    SetLineSettings(5,5,5);
     DrawLine(st_x-10,bordery,st_x,GetMaxY-80,ConvertRGB(255,0,0));
    SetLineSettings(1,1,1);
  end; 
include_object('comment119','comment','Φύλο     Α : ','no','','',st_x,bordery,GridX(2,5),0);
include_object('patient_checks(30','checkbox',patient_checks[30],'no','','',X2(last_object),bordery,X2(last_object),0);

include_object('comment1199','comment','Θ : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(31','checkbox',patient_checks[31],'no','','',X2(last_object),bordery,X2(last_object)+5,0);


bordery:=bordery+20;

include_object('comment9','comment','’σθμα - Αναπνευστικό πρόβλημα : ','no','','',st_x,bordery,GridX(2,5),0);
include_object('asthma','checkbox',patient_checks[1],'no','','',X2(last_object),bordery,X2(last_object),0);

include_object('comment10','comment','Ηπατίτιδα : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('ipatitida','checkbox',patient_checks[2],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment11','comment','Ρευματικό πυρετό : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('pyreto','checkbox',patient_checks[3],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

bordery:=bordery+20;
 
include_object('comment12','comment','Λιποθυμίες : ','no','','',st_x,bordery,0,0);
include_object('lypothimies','checkbox',patient_checks[4],'no','','',X2(last_object),bordery,X2(last_object),0);

include_object('comment13','comment','Ακατάσχετες αιμοραγίες : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('aimoragies','checkbox',patient_checks[5],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment15','comment','Αναιμία - Πρόβλημα με το αίμα : ','no','','',X2(last_object)+15,bordery,0,0);
include_object('anaimia','checkbox',patient_checks[7],'no','','',X2(last_object),bordery,X2(last_object),0);

bordery:=bordery+20;

include_object('comment14','comment','Διαβήτης : ','no','','',st_x,bordery,X2(last_object),0);
include_object('diaviti','checkbox',patient_checks[6],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment20','comment','Αλλεργία : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('allergia','checkbox',patient_checks[12],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment181','comment','HIV : ','no','','',X2(last_object)+15,bordery,GridX(2,5),0);
include_object('patient_checks(23','checkbox',patient_checks[23],'no','','',X2(last_object),bordery,X2(last_object),0);

include_object('comment18','comment','Επιληψία : ','no','','',X2(last_object)+15,bordery,GridX(2,5),0);
include_object('epilipsia','checkbox',patient_checks[10],'no','','',X2(last_object),bordery,X2(last_object),0);

include_object('comment22','comment','Φάρμακα : ','no','','',X2(last_object)+15,bordery,0,0);
include_object('farmaka','checkbox',patient_checks[14],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment173','comment','Αδενοπάθειες : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(19','checkbox',patient_checks[19],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

bordery:=bordery+20;

include_object('comment16','comment','Καρδιαγγειακή νόσος : ','no','','',st_x,bordery,X2(last_object),0);
include_object('kardiaggeiaki','checkbox',patient_checks[8],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment171','comment','Υπέρταση/Υπόταση : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(16','checkbox',patient_checks[16],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment17','comment','Νόσος των νεφρών : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('nefra','checkbox',patient_checks[9],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment172','comment','Έλκος : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(20','checkbox',patient_checks[20],'no','','',X2(last_object),bordery,X2(last_object)+5,0);


bordery:=bordery+20;

include_object('comment19','comment','Νευροψυχικές διαταραχές : ','no','','',st_x,bordery,X2(last_object),0);
include_object('neyropsyxika','checkbox',patient_checks[11],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment174','comment','Εξαρτησιογόνα : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(26','checkbox',patient_checks[26],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment175','comment','Οινοπνευματώδη : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(25','checkbox',patient_checks[25],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment21','comment','Κάπνισμα : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('kapnisma','checkbox',patient_checks[13],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

bordery:=bordery+20;

include_object('comment23','comment','Κατάγματα/Ατυχήματα : ','no','','',st_x,bordery,X2(last_object),0);
include_object('patient_checks(15','checkbox',patient_checks[15],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment24','comment','Ιγμορίτιδα : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(17','checkbox',patient_checks[17],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment25','comment','Θυροειδής/Ενδοκρ. : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(22','checkbox',patient_checks[22],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment26','comment','Όγκοι/Ακτινοβολίες : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(24','checkbox',patient_checks[24],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

bordery:=bordery+20;

include_object('comment27','comment','Συχνοί πονοκέφαλοι/κρυολογήματα/πονόλαιμοι : ','no','','',st_x,bordery,X2(last_object),0);
include_object('patient_checks(18','checkbox',patient_checks[18],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

include_object('comment28','comment','Πολυομυελίτιδα/φυματίωση/πνευμονία : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
include_object('patient_checks(21','checkbox',patient_checks[21],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

if patient_checks[31]='3' then // ASTHNIS THYLIKOS
   begin
    bordery:=bordery+20;

    include_object('comment29','comment','Έγκυος : ','no','','',st_x,bordery,X2(last_object),0);
    include_object('patient_checks(27','checkbox',patient_checks[27],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

    
    include_object('comment30','comment','Χρήση Αντισυλληπτικών : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
    include_object('patient_checks(28','checkbox',patient_checks[28],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

    include_object('comment31','comment','Κανονική Περίοδος : ','no','','',X2(last_object)+15,bordery,X2(last_object),0);
    include_object('patient_checks(25','checkbox',patient_checks[25],'no','','',X2(last_object),bordery,X2(last_object)+5,0);

   end;

//BUTTONS
bordery:=btny;
st_x:=GridX(3,5)+25;
include_object('aktinografia','buttonc','Ακτινογραφίες / Φωτογραφίες','no','','',st_x,bordery,0,0);
include_object('teeth','buttonc','Οδοντοστοιχία','no','','',X2('aktinografia')+5,bordery,0,0);
bordery:=bordery+30;
include_object('shortcut','buttonc','Εργαλείο 1','no','','',st_x,bordery,0,0);
bordery:=bordery+30;

include_object('notes','buttonc','Κοινές Σημειώσεις','no','','',st_x,bordery,0,0);
include_object('info','buttonc','’λλες πληροφορίες','no','','',X2(last_object)+5,Y1(last_object),0,0);
if (not alert_level) then  begin
                            bordery:=bordery+30;
                            include_object('ergasies','buttonc','Εργασίες','no','','',st_x,bordery,0,0);
                            include_object('sxediaergasiwn','buttonc','Σχέδια Εργασιών','no','','',X2('ergasies')+5,bordery,0,0);
                            include_object('rendezervous','buttonc','Νέο ραντεβού','no','','',X2(last_object)+5,Y1(last_object),0,0);
                           end;
//include_object('clear','buttonc','Απαλοιφή','no','','',X2('sxediaergasiwn')+5,bordery,0,0);
bordery:=bordery+30;
include_object('delete','buttonc','Διαγραφή','no','','',st_x,bordery,0,0);
include_object('print','buttonc','Εκτύπωση','no','','',X2(last_object)+5,bordery,0,0);
include_object('print_image','buttonc','Εκτύπωση Εικόνων','no','','',X2(last_object)+5,bordery,0,0);
bordery:=bordery+30;
include_object('save','buttonc','Αποθήκευση','no','','',st_x,bordery,0,0);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+5,bordery,0,0);
 
 
if photo<>'' then DrawApsXY2(AnalyseFilename(photo,'FILENAME'),GridX(3,5)+borderx,GridY(2,13)) else
                  DrawApsXY2('dental_defaultuser',GridX(3,5)+borderx,GridY(2,13));
draw_all;
fasttextboxchange(1);
repeat
interact;                     

if (get_object_data('print_image')='4') then begin
                                        set_button('print_image',0);
                                        Save_Form();
                                        PrepareImagePrintout;
                                        goto start_view_person;
                                       end else 
if (get_object_data('now_arrived')='4') then begin
                                        set_button('now_arrived',0);
                                        Save_Form();
                                        Mark_Person_Last_Vist_Now;
                                        goto start_view_person;
                                       end else
if (get_object_data('rendezervous')='4') then begin
                                        set_button('rendezervous',0);
                                        Save_Form();
                                        //clrscreen;
                                        gui_pick_next_free_day(People_Data(8));
                                        goto start_view_person;
                                       end else
if (get_object_data('print')='4') then begin
                                        set_button('print',0);
                                        Save_Form();
                                        clrscreen;
                                        View_Print_Person;
                                        MessageBox (0, 'Πατήστε ΟΚ όταν τελείωσετε με την επεξεργασία του κειμένου..' , ' ', 0);
                                        goto start_view_person;
                                       end else 
if (get_object_data('shortcut')='4') then begin
                                        set_button('shortcut',0);
                                        Save_Form();
                                        clrscreen;
                                        RunEXEWait(get_external_shortcut_tool1,false);
                                        MessageBox (0, 'Πατήστε ΟΚ όταν τελείωσετε με την εργασία σας..' , ' ', 0);
                                        goto start_view_person;
                                       end else 
if (get_object_data('notes')='4') then begin
                                        set_button('notes',0);
                                        Save_Form();
                                        clrscreen;
                                        RunEXE(get_external_editor+' "'+curendir+'Database\'+People_Data(9)+'.nfo"','normal');
                                        MessageBox (0, 'Πατήστε ΟΚ όταν τελείωσετε με την επεξεργασία του κειμένου..' , ' ', 0); 
                                        goto start_view_person;
                                       end else
if (get_object_data('aktinografia')='4') then begin
                                            set_button('aktinografia',0);
                                            //MessageBox (0, 'TEST VERSION!' , ' ', 0);
                                            Save_Form();
                                            if photo<>'' then begin
                                                               UnloadAPS(AnalyseFilename(photo,'FILENAME'));
                                                              end;
                                            bufstr:=People_Data(8); //KRATAME TIN PLIROFORIA TIS EGGRAFIS GIATI MPOREI NA XATHEI BUGFIX 22-11-06
                                            GUI_Person_Photo_Gallery(People_Data(9)+'.picdat'); 
                                            //if photo<>'' then Load_Photo(photo,true);
                                            //Show_Photos_Xrays();
                                            bufstr2:=photo; //GIATI MPOREI NA EXOUME ALLAKSEI TIN FWTOGRAFIA MESA STIS EIKONES ;) BUGFIX 3-12-06
                                            Load_Person(bufstr,true);
                                            photo:=bufstr2;
                                            if photo<>'' then Load_Photo(photo,true);
                                            goto start_view_person;
                                           end else

if (get_object_data('teeth')='4') then begin
                                            set_button('teeth',0); 
                                            Save_Form();
                                            GUI_check_teeth;
                                            goto start_view_person;
                                           end else
if (get_object_data('ergasies')='4') then begin
                                            set_button('ergasies',0); 
                                            Save_Form();
                                            Show_Data();
                                            goto start_view_person; 
                                           end else
if (get_object_data('sxediaergasiwn')='4') then begin
                                            set_button('sxediaergasiwn',0); 
                                            Save_Form();
                                            Show_Plans(People_Data(9)); 
                                            goto start_view_person;
                                           end else
if (get_object_data('clear')='4') then begin
                                            set_button('clear',0);
                                            i:=MessageBox (0,pchar('Είστε σίγουρος οτι θέλετε να απολοιφούν οι πληροφορίες της καταχώρησης '+name+' '+surname+' ?'), 'Dental Database Mk2', 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
                                            if i=IDYES then
                                            begin
                                             name:=''; surname:=''; area:=''; telephone:='';
                                             profession:=''; photo:=''; other:='';
                                             Save_Form();
                                            end;
                                            draw_all;
                                           end else
if (get_object_data('delete')='4') then begin
                                            set_button('delete',0);
                                           if Get_User_Access(Get_Current_User)<DELETE_ACCESS then begin
                                                                                                    Write_2_Log('SECURITY - User without sufficient privilleges tried to delete '+load_file);
                                                                                                    MessageBox (0, 'Δεν έχετε αρκετά μεγάλο βαθμό πρόσβασης για να διαγράψετε αυτό το αρχείο..' ,'Dental Database Mk2', 0 + MB_ICONQUESTION);
                                                                                                   end else
                                                                                                   begin
                                                                                                     i:=MessageBox (0, 'Είστε σίγουρος/η οτι θέλετε να διαγράψετε την συγκεκριμένη καταχώρηση?' , ' ', 0 +MB_YESNO+ MB_ICONASTERISK + MB_SYSTEMMODAL);
                                                                                                     if i=IDYES then
                                                                                                     begin
                                                                                                      Write_2_Log('User chose to delete '+load_file);
                                                                                                      delete4map(code,name,surname,load_file);
                                                                                                      goto abandon_person;
                                                                                                     end;
                                                                                                   end; 
                                           end else
if (get_object_data('save')='4') then begin
                                       set_button('save',0);
                                       DrawApsXY('greenbtn',X1('save')-GetApsInfo('greenbtn','sizex')-5,Y1('save')+3);
                                       Save_Form();
                                       Save_Person(''); // <- Ara ennoeitai current person..  
                                      end;              
until GUI_Exit;
set_button('exit',0);
Save_Form(); //AUTOSAVE
Save_Person(''); // <- Ara ennoeitai current person..
abandon_person:
if photo<>'' then UnloadAps(AnalyseFilename(photo,'FILENAME'));
end;

function GUI_search_person:string;
var textboxx,textboxx2:integer;
    commentx:integer;
    retres:string;
begin
retres:='';
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
include_object('backwindow','window','Dental Database Mk2 , Αναζήτηση Ασθενών','','','',GetMaxX div 3,200,GetMaxX-(GetMaxX div 3),GetMaxY-200);
draw_all;
commentx:=X1(last_object)+30;
include_object('codecomment','comment','Κώδικός','no','','',commentx,Y1(last_object)+50,0,0);
textboxx:=X2(last_object)+30;
textboxx2:=GetMaxX-(GetMaxX div 3)-30;
include_object('code','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);
include_object('namecomment','comment','Όνομα','no','','',commentx,Y2(last_object)+15,0,0);
include_object('name','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('surnamecomment','comment','Επίθετο','no','','',commentx,Y2(last_object)+15,0,0);
include_object('surname','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('datecomment','comment','Επανεξέταση','no','','',commentx,Y2(last_object)+15,0,0);
include_object('dateday','textbox','','no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXX'),0);
include_object('/','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('datemonth','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXX'),0);
include_object('//','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('dateyear','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXXXX'),0);

include_object('telcomment','comment','Τηλέφωνο','no','','',commentx,Y2(last_object)+15,0,0);
include_object('telephone','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('profcomment','comment','Επάγγελμα','no','','',commentx,Y2(last_object)+15,0,0);
include_object('proffesion','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

include_object('areacomment','comment','Περιοχή','no','','',commentx,Y2(last_object)+15,0,0);
include_object('area','textbox','','no','','',textboxx,Y1(last_object),textboxx2,0);

delete_object('backwindow','NAME');
include_object('search','buttonc','Αναζήτηση','no','','',(GetMaxX div 2)-40,Y2(last_object)+40,0,0);
include_object('exit','buttonc','’κυρο','no','','',X2(last_object)+15,Y1(last_object),0,0);
fasttextboxchange(1);
draw_all;
repeat
interact;
if get_object_data('search')='4' then begin
                                       set_button('search',0);
                                       Write_2_Log('Searching for '+get_object_data('code')+get_object_data('name')+get_object_data('surname')+get_object_data('dateday')+get_object_data('datemonth')+get_object_data('dateyear')+get_object_data('area')+get_object_data('telephone')+get_object_data('profession'));
                                       retres:=query_database(get_object_data('code'),get_object_data('name'),get_object_data('surname'),get_object_data('dateday'),get_object_data('datemonth'),get_object_data('dateyear'),get_object_data('area'),get_object_data('telephone'),get_object_data('profession'));
                                       set_button('exit',1);
                                       break;
                                      end;
until GUI_Exit;
GUI_search_person:=retres;
end;       


begin
display_photos:=true;
end.
