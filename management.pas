unit management;


interface
 
procedure database_menu;
procedure Init_Management;

implementation 
uses windows,ammarunit,ammargui,apsfiles,user_tutorials,string_stuff,userlogin,payments,people,people_map,the_works,settings,backups,synchronize_db,tools;
const pososto=40;
var curendir:string;


procedure Init_Management;
begin
GetDir(0,curendir); 
if curendir[Length(curendir)]<>'\' then curendir:=curendir+'\'; 
end;





procedure append_file(thefile,thetxt:string);
var fileused:text;
begin
assign(fileused,thefile);
{$i-}
append(fileused);
{$i+}
//if Ioresult<>0 then MessageBox (0, Pchar('Could not write to '+thefile) , ' ', 0) else
if IOResult <> 0 then
  MessageBoxA(
    0,
    PAnsiChar(AnsiString('Could not write to ' + thefile)),
    PAnsiChar(AnsiString(' ')),
    0
  )
else
               begin
                writeln(fileused,thetxt);
                close(fileused);
               end;
end;

procedure intermediate_search(acode,aname,asurname,aarea,atelephone,aprofession,fd,fm,fy,td,tm,ty,xrwstaeifrom,xrwstaeito,ekptwsifrom,ekptwsito,plirwseifrom,plirwseito:string);
var x:integer;
    basic_search,pro_search:boolean;
    examine_file:string;
    fileused:text;
begin
 chdir(curendir+'Cache');
 assign(fileused,'Patient_Report.html');
 rewrite(fileused);
 writeln(fileused,'<html><head>'); 
 writeln(fileused,'<title> Προχωρημένη αναζήτηση χρηστών </title>');
 writeln(fileused,'<meta http-equiv="Content-Type" content="text/html; charset=windows-1253"></head>');
 writeln(fileused,'<body bgcolor=#FFFFFF text=#000000>'); 
 writeln(fileused,'<center>');
 writeln(fileused,'<img src="../logo.jpg" width=500> <font bgcolor=#CCCCCC size=1>Powered by A-TECH</font><br><br>');
 writeln(fileused,'<h1> Αποτελέσματα προχωρημένης αναζήτησης χρηστών</h1><br><br>');
 writeln(fileused,'</center>');
 writeln(fileused,'Κριτήρια αναζήτησης :<br>');
 if (acode<>'') then writeln(fileused,'Κωδικός = ',acode,'<br>');
 if (aname<>'') then writeln(fileused,'Όνομα = ',aname,'<br>');
 if (asurname<>'') then writeln(fileused,'Επώνυμο = ',asurname,'<br>');
 if (aarea<>'') then writeln(fileused,'Περιοχή = ',aarea,'<br>');
 if (atelephone<>'') then writeln(fileused,'Τηλέφωνο = ',atelephone,'<br>');
 if (aprofession<>'') then writeln(fileused,'Επάγγελμα = ',aprofession,'<br>');
 if ((fd<>'') or (fm<>'') or (fy<>'')) then writeln(fileused,'Από ημερομηνία εργασίας ',fd,'/',fm,'/',fy,'<br>');
 if ((td<>'') or (tm<>'') or (ty<>'')) then writeln(fileused,'Έως ημερομηνία εργασίας ',td,'/',tm,'/',ty,'<br>'); 
 if (xrwstaeifrom<>'') then writeln(fileused,'Χρωστάει από = ',xrwstaeifrom,'<br>');
 if (xrwstaeito<>'') then writeln(fileused,'Χρωστάει έως = ',xrwstaeito,'<br>');
 if (ekptwsifrom<>'') then writeln(fileused,'Έχει λάβει έκπτωση από = ',ekptwsifrom,'<br>');
 if (ekptwsito<>'') then writeln(fileused,'Έχει λάβει έκπτωση έως = ',ekptwsito,'<br>');
 if (plirwseifrom<>'') then writeln(fileused,'Έχει πληρώσει από = ',plirwseifrom,'<br>');
 if (plirwseito<>'') then writeln(fileused,'Έχει πληρώσει έως = ',plirwseito,'<br>');

writeln(fileused,'<center>');
writeln(fileused,'<table width=400><!-- ΑΠΟΤΕΛΕΣΜΑΤΑ -->');
writeln(fileused,'<tr height=30 bgcolor=#CCCCCC><td>');
writeln(fileused,'</td></tr>');
x:=0; 
while examine_file<>'eof' do
       begin
        x:=x+1;
        examine_file:=retrieve_map_serial(x);
        if examine_file<>'eof' then
          begin 
           Load_Person(examine_file,false); 
           basic_search:=check_match(acode,aname,asurname,'','','',aarea,atelephone,aprofession);
           pro_search:=check_match_pro(fd,fm,fy,td,tm,ty,xrwstaeifrom,xrwstaeito,ekptwsifrom,ekptwsito,plirwseifrom,plirwseito);
           if ((basic_search) and (pro_search)) then
             begin 
              writeln(fileused,'<tr><td>');
              writeln(fileused,People_Data(2),' ',People_Data(3),' (κωδικός ',People_Data(1),') <br>');
              writeln(fileused,'περιοχή: ',People_Data(4),' τηλ: ',People_Data(5),'<br>');
              writeln(fileused,'επάγγελμα: ',People_Data(6),'<br>');
              writeln(fileused,'</td></tr>');
              writeln(fileused,'<tr height=30 bgcolor=#CCCCCC><td>');
              writeln(fileused,'</td></tr>');
              
              
             end;
          end;
       end;
writeln(fileused,'</table><!--ΤΕΛΟΣ ΑΠΟΤΕΛΕΣΜΑΤΑ -->');
writeln(fileused,'</center>');
 writeln(fileused,'</body></html>');
 close(fileused);

 chdir(curendir);  
 drawbackground(3);
 OutTextCenter('Please Wait..');
 RunEXE(get_external_browser+' "'+curendir+'Cache\Patient_Report.html"','normal');
 MessageBox (0, 'Περιμένετε να εμφανιστεί το παράθυρο των στατιστικών και στην συνέχεια'+#10+'πατήστε OK για επιστροφή..' , ' ', 0);
end;

procedure GUI_intermediate_search;
var textboxx,textboxx2:integer;
    commentx:integer;
    acode,aname,asurname,adateday,adatemonth,adateyear,aarea,atelephone,aprofession,fd,fm,fy,td,tm,ty,xrwstaeifrom,xrwstaeito,ekptwsifrom,ekptwsito,plirwseifrom,plirwseito:string;
    return_query:string;
label   start_intermediate_search;
begin
start_intermediate_search:
flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
include_object('backwindow','window','Dental Database Mk2 , Αναζήτηση ασθενών',' ','','',GetMaxX div 3,200,GetMaxX-(GetMaxX div 3)+20,GetMaxY-100);
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

// ERGASIA
include_object('datecomment','comment','Εργασία','no','','',commentx,Y2(last_object)+15,0,0);
// APO
include_object('work_dateday','textbox','','no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXX'),0);
include_object('/','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('work_datemonth','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXX'),0);
include_object('//','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('work_dateyear','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXXXX'),0);
// EWS
include_object('ewscomment','comment','έως','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('work_todateday','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXX'),0);
include_object('///','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('work_todatemonth','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXX'),0);
include_object('////','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('work_todateyear','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXXXX'),0);

// XRWSTOUMENA XRHMATA
include_object('datecomment2','comment','Ωφείλει','no','','',commentx,Y2(last_object)+15,0,0);
// APO
include_object('price_xrwstaei1','textbox','','no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXXXXX'),0);
include_object('EURO1','comment','','no','','',X2(last_object)+5,Y1(last_object),0,0);
// EWS
include_object('ewscomment','comment','έως','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('price_xrwstaei2','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXXXXX'),0);
include_object('EURO2','comment','','no','','',X2(last_object)+5,Y1(last_object),0,0);

// XRHMATA POU EXEI DWSEI
include_object('datecomment3','comment','Πλήρωσε','no','','',commentx,Y2(last_object)+15,0,0);
// APO
include_object('price_plirwsei1','textbox','','no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXXXXX'),0);
include_object('EURO3','comment','','no','','',X2(last_object)+5,Y1(last_object),0,0);
// EWS
include_object('ewscomment','comment','έως','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('price_plirwsei2','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXXXXX'),0);
include_object('EURO4','comment','','no','','',X2(last_object)+5,Y1(last_object),0,0);

// SYNOLIKI EKTPWSI POU EXEI LAVEI
include_object('datecomment4','comment','Έκπτωση','no','','',commentx,Y2(last_object)+15,0,0);
// APO
include_object('price_ekptwsi1','textbox','','no','','',textboxx,Y1(last_object),textboxx+TextWidth('XXXXXX'),0);
include_object('EURO5','comment','','no','','',X2(last_object)+5,Y1(last_object),0,0);
// EWS
include_object('ewscomment','comment','έως','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('price_ekptwsi2','textbox','','no','','',X2(last_object)+5,Y1(last_object),X2(last_object)+5+TextWidth('XXXXXX'),0);
include_object('EURO6','comment','','no','','',X2(last_object)+5,Y1(last_object),0,0);

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
                                       //set_button('search',0);
                                       fd:=get_object_data('work_dateday');
                                       fm:=get_object_data('work_datemonth');
                                       fy:=get_object_data('work_dateyear');
                                       td:=get_object_data('work_todateday');
                                       tm:=get_object_data('work_todatemonth');
                                       ty:=get_object_data('work_todateyear');
                                       xrwstaeifrom:=get_object_data('price_xrwstaei1');
                                       xrwstaeito:=get_object_data('price_xrwstaei2');
                                       ekptwsifrom:=get_object_data('price_ekptwsi1');
                                       ekptwsito:=get_object_data('price_ekptwsi2');
                                       plirwseifrom:=get_object_data('price_plirwsei1');
                                       plirwseito:=get_object_data('price_plirwsei2');
                                       /////////
                                       acode:=get_object_data('code');
                                       aname:=get_object_data('name');
                                       asurname:=get_object_data('surname'); 
                                       aarea:=get_object_data('area');
                                       atelephone:=get_object_data('telephone');
                                       aprofession:=get_object_data('profession');
                                       intermediate_search(acode,aname,asurname,aarea,atelephone,aprofession,fd,fm,fy,td,tm,ty,xrwstaeifrom,xrwstaeito,ekptwsifrom,ekptwsito,plirwseifrom,plirwseito);
                                       break;
                                      end;
until GUI_Exit;
if get_object_data('search')='4' then goto start_intermediate_search; //KEEP INSIDE..
end;











procedure doctors_statistics(person,from_day,from_month,from_year,to_day,to_month,to_year:integer);
const MAX_USERS=15;
var x,y,z,i,i2,total_users,total_works:integer;
    examine_file,bufstr:string;
    examine_cur:boolean;
    curyear,curmonth,curday,tmpmoney,total_money_made,total_money_payed:integer;
    userlist:array[1..3,1..15] of string;
    userlist_Stats:array[1..7,1..15] of integer;
    fileused,fileused2:text;
    // Astheneis pou symmeteixe o xristis stis ergasies..
    // Ergasies pou exei kanei..
    // Xrimata pou kostisan oi ergasies pou exei kanei..
    // Xrimata pou lifthikan apo tis ergasies pou exei kanei..
begin
chdir(curendir+'Cache');
total_money_made:=0;
total_users:=Get_Total_User_Number;
if MAX_USERS<total_users then begin
                                total_users:=MAX_USERS;
                                MessageBox (0, 'Το πλήθος των χρηστών είναι μεγαλύτερο από αυτό που υποστηρίζεται.. Επικοινωνήστε με την A-TECH για αναβάθμιση..' , ' ', 0 + MB_ICONASTERISK);
                              end;
for x:=1 to 7 do
for y:=1 to total_users do  userlist_Stats[x,y]:=0; 
for x:=1 to 3 do
for y:=1 to total_users do  begin 
                             userlist[x,y]:=Get_User_Data(x,y); //Load Users Localy..  
                            end; 
for y:=1 to total_users do begin 
                            clear_file(userlist[1,y]+'.tmp');
                           end; 

draw_background(3);
OutTextCenter('Υπολογισμός αποτελεσμάτων..');
examine_file:='';
x:=0;  
while examine_file<>'eof' do
       begin
        x:=x+1;
        examine_file:=retrieve_map_serial(x);
        if examine_file<>'eof' then
          begin 
           Load_Person(examine_file,false); //TRUE ?? GIA POION LOGO ??
           total_works:=Get_Total_Works; // Fortwnoume ton arithmo ergasiwn pou exoun ginei sto sygkekrimeno atomo.. 
           if total_works>0 then
           begin
            for y:=1 to total_works do begin
                                         Val(Get_Works(7,y),curday,i);
                                         Val(Get_Works(8,y),curmonth,i);
                                         Val(Get_Works(9,y),curyear,i);

                                         if ((to_year=0) or ((curmonth>=from_month) and (curmonth<=to_month)) ) then 
                                              begin
                                               if ((to_month=0) or ((curyear>=from_year) and (curyear<=to_year)) ) then
                                                   begin
                                                   if ((to_day=0) or ((curday>=from_day) and (curday<=to_day)) ) then
                                                        begin

                                                     z:=0;
                                                     while z<total_users do begin //Check an i ergasia afora ton xristi..
                                                        z:=z+1;
                                                         if Equal(Get_Works(6,y),userlist[1,z]) then
                                                            begin 
                                                             Val(Get_Works(2,y),tmpmoney,i);
                                                             Val(Get_Works(3,y),i2,i);
                                                             tmpmoney:=tmpmoney-(tmpmoney*i2 div 100);
                                                             total_money_made:=total_money_made+tmpmoney;
                                                             userlist_Stats[2,z]:=userlist_Stats[2,z]+1; // Ergasies pou exei pragmatopoiisei o xristis..
                                                             userlist_Stats[3,z]:=userlist_Stats[3,z]+tmpmoney; // Xrimata pou tha apodosei i Ergasia pou exei pragmatopoiisei o xristis..
                                                             Val(Get_Works(4,y),i2,i);
                                                             userlist_Stats[4,z]:=userlist_Stats[4,z]+i2; // Xrimata pou lavame gia tin Ergasia pou exei pragmatopoiisei o xristis..

                                                             bufstr:=Convert2String(userlist_Stats[2,z])+' - '+Get_Works(1,y)+' στον '+People_Data(2)+' '+People_Data(3)+' '+Convert2String(tmpmoney)+' '+Convert2String(i2);
                                                             chdir(curendir+'Cache');
                                                             append_file(userlist[1,z]+'.tmp',bufstr);
                                                             break; 
                                                            end; 
                                                                            end;
                                                        end; //EIMASTE MESA STIN IMERA
                                                   end;   //EIMASTE MESA STON MINA
                                              end;  //EIMASTE MESA STON XRONO
                                       end;
           end;
          end;
       end;

 chdir(curendir+'Cache');
 assign(fileused,'Money_Report.html');
 rewrite(fileused);
 writeln(fileused,'<html><head>');
 if ((to_year=0) and (to_month=0) and (to_day=0)) then begin
                                                         bufstr:='καθ`όλη την διάρκεια χρήσης του πρoγράμματος';
                                                       end else
                                                       begin
                                                         bufstr:=' από '+Convert2String(from_day)+'/'+Convert2String(from_month)+'/'+Convert2String(from_year);
                                                         bufstr:=bufstr+' έως '+Convert2String(to_day)+'/'+Convert2String(to_month)+'/'+Convert2String(to_year); 
                                                       end;
 writeln(fileused,'<title> Στατιστικά χρηστών '+bufstr+'</title>');
 writeln(fileused,'<meta http-equiv="Content-Type" content="text/html; charset=windows-1253"></head>');
 writeln(fileused,'<body bgcolor=#FFFFFF text=#000000>');
 writeln(fileused,'<center>');
 writeln(fileused,'<img src="../logo.jpg" width=500> <font bgcolor=#CCCCCC size=1>Powered by A-TECH</font><br><br>');
 writeln(fileused,'<h1> Αποτελέσματα ανάλυσης στατιστικών</h1>');
 writeln(fileused,'<h1>'+bufstr+'</h1>');
 tmpmoney:=0;
 for x:=1 to total_users do
   begin 
  if ((x=person) or (person=0)) then
   begin //PERSON FILTER
     writeln(fileused,'<table border=1 width=700 bgcolor=#FFFFFF>');
      writeln(fileused,'<tr bgcolor=#CCCCCC><td>Όνομα Χρήστη</td><td>Εργασίες</td><td>Χρήματα που έβγαλε</td><td>Χρήματα που πλήρωσαν οι ασθενείς</td><td>Πληρωμή '+Convert2String(pososto)+'%</td></tr>');
      writeln(fileused,'');
      writeln(fileused,'<tr><td>'+userlist[3,x]+'</td><td>'+Convert2String(userlist_Stats[2,x])+'</td><td>'+Convert2String(userlist_Stats[3,x])+'</td><td>'+Convert2String(userlist_Stats[4,x])+'</td>');
      writeln(fileused,'<td>'+Convert2String((pososto*userlist_Stats[4,x]) div 100)+'</td></tr>');
      tmpmoney:=tmpmoney+userlist_Stats[3,x]; //Epalitheysi..

      total_money_payed:=Calculate_Income(Get_User_Data(1,x),from_day,from_month,from_year,to_day,to_month,to_year);

      writeln(fileused,'<tr><td colspan=5>Αναλυτικά .. </td></tr>');
      writeln(fileused,'<tr><td colspan=5>');
      assign(fileused2,userlist[1,x]+'.tmp');
      {$i-}
      reset(fileused2);
      {$i+}
      if Ioresult<>0 then writeln(fileused,'<center><strong><font color=#FF0000> Πρόβλημα κατα το άνοιγμα του αρχείου '+userlist[1,x]+'.tmp'+'<br> Επικοινωνήστε με την A-TECH </font></strong></center>') else
            begin
             while (not eof(fileused2) ) do
              begin
               readln(fileused2,bufstr);
               writeln(fileused,bufstr+' <br> ');
              end;
             close(fileused2);
            end;
      writeln(fileused,'</td></tr>');

      writeln(fileused,'<tr><td colspan=5>Πληρωμές .. </td></tr>');   //PLIRWMES
      writeln(fileused,'<tr><td colspan=5>');
      assign(fileused2,Greeklish(userlist[1,x])+'_payments.tmp');
      {$i-}
      reset(fileused2);
      {$i+}
      if Ioresult<>0 then writeln(fileused,'<center><strong><font color=#FF0000> Πρόβλημα κατα το άνοιγμα του αρχείου πληρωμών '+userlist[1,x]+'_payments.tmp'+'<br> Επικοινωνήστε με την A-TECH </font></strong></center>') else
            begin
             while (not eof(fileused2) ) do
              begin
               readln(fileused2,bufstr);
               writeln(fileused,bufstr+'<br>');
              end;
             close(fileused2);
            end; 
      writeln(fileused,'</td></tr>');
 
      writeln(fileused,'<tr><td colspan=5>');    //PLIRWMES 
      i:=((pososto*userlist_Stats[4,x]) div 100)-total_money_payed;
      if i<0 then writeln(fileused,'<center><h3>Η επιχείρηση έχει πληρώσει στον '+userlist[3,x]+' '+Convert2String(-i)+' &euro; παραπάνω</h3></center>') else
      if i=0 then writeln(fileused,'<center><h3>Ο/Η '+userlist[3,x]+' δεν έχει πληρωμές που να εκρεμμούν</h3></center>') else 
      if i>0 then writeln(fileused,'<center><h3>Η επιχείρηση ωφείλει στον '+userlist[3,x]+' '+Convert2String(i)+' &euro;</h3></center>');
      writeln(fileused,'</td></tr>'); 
      writeln(fileused,'</table><br><br>');
    end; //PERSON FILTER
   end;

   if ((tmpmoney<>total_money_made) and (person=0)) then
                                      begin
                                        writeln(fileused,'<font color=#FF0000><strong>');
                                        writeln(fileused,'Πρόβλημα στην επαλήθευση των αποτελεσμάτων !!!<br>');
                                        writeln(fileused,Convert2String(total_money_made-tmpmoney)+'<br>');
                                        writeln(fileused,'Επικοινωνήστε με την A-TECH !!!<br>');
                                        writeln(fileused,'</strong></font>');
                                      end;
 writeln(fileused,'</center>');
 writeln(fileused,'</body> </html>');
 close(fileused);
 
 chdir(curendir);  
 drawbackground(3);
 OutTextCenter('Please Wait..');
 RunEXE(get_external_browser+' "'+curendir+'Cache\Money_Report.html"','normal');
 MessageBox (0, 'Περιμένετε να εμφανιστεί το παράθυρο των στατιστικών και στην συνέχεια'+#10+'πατήστε OK για επιστροφή..' , ' ', 0);
 
end;


procedure GUI_doctors_statistics;
var startx,starty,blocky,textboxx,i,z:integer;
    from_day,from_month,from_year,to_day,to_month,to_year:integer;
    datesnstuff:array[1..4]of word; 
label end_gui_stats;
begin

 GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);

 flush_gui_memory(0);
 set_gui_color(ConvertRGB(0,0,0),'comment');
 draw_background(3);

 startx:=GridX(1,3)-70;
 starty:=200;
 textboxx:=TextWidth('XXXXX');
 include_object('window1','window','Στατιστικά Χρηστών','no','','',startx,starty,GetMaxX-startx,starty+170);
 draw_all;
 delete_object('window1','name');

 startx:=startx+150;
 starty:=starty+40;
 include_object('from','comment','Από','no','','',startx,starty,0,0);
 include_object('from_day','textbox','','no','','',X2(last_object)+15,Y1(last_object),X2(last_object)+15+textboxx,0);
 include_object('/','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
 include_object('from_month','textbox','','no','','',X2(last_object)+15,Y1(last_object),X2(last_object)+15+textboxx,0);
 include_object('//','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
 include_object('from_year','textbox','','no','','',X2(last_object)+15,Y1(last_object),X2(last_object)+15+textboxx,0);
 include_object('from_sync','buttonc','Σήμερα','no','','',X2(last_object)+15,Y1(last_object),0,0);
 //include_object('from_calend','buttonc','Ημερολόγιο','no','','',X2(last_object)+15,Y1(last_object),0,0);

 starty:=starty+35;
 include_object('to','comment','Έως','no','','',startx,starty,0,0);
 include_object('to_day','textbox','','no','','',X2(last_object)+15,Y1(last_object),X2(last_object)+15+textboxx,0);
 include_object('///','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
 include_object('to_month','textbox','','no','','',X2(last_object)+15,Y1(last_object),X2(last_object)+15+textboxx,0);
 include_object('////','comment','/','no','','',X2(last_object)+5,Y1(last_object),0,0);
 include_object('to_year','textbox','','no','','',X2(last_object)+15,Y1(last_object),X2(last_object)+15+textboxx,0);
 include_object('to_sync','buttonc','Σήμερα','no','','',X2(last_object)+15,Y1(last_object),0,0);
 //include_object('to_calend','buttonc','Ημερολόγιο','no','','',X2(last_object)+15,Y1(last_object),0,0);
 include_object('all_stats_cmm','comment','Προβολή στατιστικών όλων των χρηστών','no','','',startx,Y2(last_object)+5,0,0);
 include_object('all_stats','checkbox','3','no','','',X2(last_object)+10,Y1(last_object),0,0);

 startx:=startx+60;
 starty:=Y2(last_object)+5;
 include_object('start','buttonc','Εκκίνηση','no','','',startx,starty,0,0);
 include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+5,starty,0,0);
 draw_all;
 fasttextboxchange(1);
 repeat
  interact;
  if get_object_data('from_sync')='4' then begin
                                            set_button('from_sync',0);
                                            set_object_data('from_day','value',Convert2String(datesnstuff[1]),0);
                                            set_object_data('from_month','value',Convert2String(datesnstuff[3]),0);
                                            set_object_data('from_year','value',Convert2String(datesnstuff[4]),0);
                                            draw_object_by_name('from_day');
                                            draw_object_by_name('from_month');
                                            draw_object_by_name('from_year'); 
                                           end else
  if get_object_data('to_sync')='4' then begin
                                            set_button('to_sync',0);
                                            set_object_data('to_day','value',Convert2String(datesnstuff[1]),0);
                                            set_object_data('to_month','value',Convert2String(datesnstuff[3]),0);
                                            set_object_data('to_year','value',Convert2String(datesnstuff[4]),0);
                                            draw_object_by_name('to_day');
                                            draw_object_by_name('to_month');
                                            draw_object_by_name('to_year'); 
                                           end else
  if get_object_data('start')='4' then begin
                                         Val(get_object_data('to_day'),to_day,i);
                                         Val(get_object_data('to_month'),to_month,i);
                                         Val(get_object_data('to_year'),to_year,i);
                                         Val(get_object_data('from_day'),from_day,i);
                                         Val(get_object_data('from_month'),from_month,i);
                                         Val(get_object_data('from_year'),from_year,i);
                                         Val(get_object_data('all_stats'),z,i);
                                         if z=3 then begin
                                                      if Get_User_Access(Get_Current_User)>500 then z:=0 else
                                                        begin
                                                         MessageBox (0, 'Δεν έχετε αρκετά μεγάλο βαθμό πρόσβασης για να δείτε στατιστικά άλλων χρηστών!' , 'Security', 0 + MB_ICONASTERISK);
                                                         z:=Get_User_Number(Get_Current_User);
                                                        end;
                                                     end else
                                                     z:=Get_User_Number(Get_Current_User);
                                         doctors_statistics(z,from_day,from_month,from_year,to_day,to_month,to_year);
                                         break;
                                       end;
 until GUI_Exit;
 end_gui_stats:
end; 

procedure statistics;
var startx,starty:integer;
begin
startx:=20;
starty:=20;
include_object('window1','window','Statistics','no','','',startx,starty,GetMaxX-startx,GetMaxY-starty);
draw_all;
delete_object('window1','name');
startx:=startx+20;
starty:=starty+40;
DrawRectangle2(startx,starty,GetMaxX-startx,GetMaxY-starty,ConvertRGB(0,0,0),ConvertRGB(0,0,0));
SetLineSettings(5,5,5);
DrawLine(startx,starty,startx,GetMaxY-starty,ConvertRGB(255,0,0));
DrawLine(startx,GetMaxY-starty,GetMaxX-startx,GetMaxY-starty,ConvertRGB(255,0,0));
SetLineSettings(1,1,1); 
flush_gui_memory(0);
include_object('exit','buttonc','Έξοδος','no','','',-1,GetMaxY-starty+7,-1,GetMaxY-starty+37);
draw_all;
repeat
interact;
until GUI_Exit;
end;




procedure database_menu;
var startx,starty,blocky,i:integer;
label start_database;
begin
start_database:

flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment'); 
draw_background(3);
blocky:=30;
startx:=200;
starty:=190;
include_object('window1','window','Dental Database','no','','',((GetMaxX) div 2)-startx,150,((GetMaxX) div 2)+startx,starty+150+blocky*6+GetApsInfo('statgraph','sizey')+40);
draw_all;
delete_object('window1','name');

DrawApsXY('statgraph',(GetMaxX-GetApsInfo('statgraph','sizex')) div 2,190);

starty:=190+GetApsInfo('statgraph','sizey')+20;
include_object('backup','buttonc','Αντίγραφο ασφαλείας','no','','',-1,starty+blocky*0,-1,0);
include_object('statistics','buttonc','Στατιστικά επιχείρησης','no','','',-1,starty+blocky*1,-1,0);
include_object('intermediate_search','buttonc','Αναζήτηση λιστών ασθενών','no','','',-1,starty+blocky*2,-1,0);
include_object('users_stats','buttonc','Στατιστικά Χρηστών','no','','',-1,starty+blocky*3,-1,0);
include_object('pay_stats','buttonc','Πληρωμές Χρηστών','no','','',-1,starty+blocky*4,-1,0);
include_object('prices','buttonc','Ρύθμιση Εργασιών/Τιμών','no','','',-1,starty+blocky*5,-1,0);
include_object('users','buttonc','Ρύθμιση Χρηστών','no','','',-1,starty+blocky*6,-1,0);
include_object('tips','buttonc','Tips & Tricks','no','','',-1,starty+blocky*7,-1,0);
include_object('update','buttonc','Update Dental Database Mk2','no','','',-1,starty+blocky*8,-1,0);
include_object('exit','buttonc','Έξοδος','no','','',-1,starty+blocky*9,-1,0);
draw_all; 
repeat
interact;
if get_object_data('update')='4' then begin
                                       Write_2_Log('User updating..');
                                       set_button('update',0);
                                       update_program;
                                       goto start_database;
                                      end else
if get_object_data('backup')='4' then begin
                                       Write_2_Log('User making full backup');
                                       set_button('backup',0);
                                       Full_BackUp;
                                       goto start_database;
                                      end else
if get_object_data('statistics')='4' then begin
                                       Write_2_Log('User accessed Statistics');
                                       set_button('statistics',0);
                                       statistics;
                                       goto start_database;
                                      end else
if get_object_data('users')='4' then begin
                                       Write_2_Log('User accessed User Settings');
                                       set_button('users',0); 
                                       GUI_User_Command;
                                       goto start_database;
                                      end else
if get_object_data('intermediate_search')='4' then begin
                                       Write_2_Log('User accessed Intermidate Search');
                                       set_button('intermediate_search',0);
                                       GUI_intermediate_search;
                                       goto start_database;
                                      end else
if get_object_data('pay_stats')='4' then begin
                                       Write_2_Log('User accessed Payments');
                                       set_button('pay_stats',0);
                                       GUI_Issue_Payment;
                                       goto start_database;
                                      end else  
if get_object_data('prices')='4' then begin
                                       Write_2_Log('User accessed Prices ');
                                       set_button('prices',0);
                                       GUI_prices;
                                       goto start_database;
                                      end else
if get_object_data('tips')='4' then begin
                                       Write_2_Log('User accessing Tips and Tricks ');
                                       set_button('tips',0);  
                                       gui_open_tutorial;
                                       goto start_database;
                                      end else
if get_object_data('users_stats')='4' then begin
                                            Write_2_Log('User accessed User Statistics');
                                            set_button('users_stats',0);
                                            GUI_doctors_statistics;
                                            goto start_database;
                                           end;
until GUI_Exit;

end;

begin
end.
