unit people_map;

interface

procedure Init_People_Map; 
function retrieve_map_serial(num:integer):string;
procedure add2map(id,person_name,person_surname,thefilename:string);
procedure delete4map(id,person_name,person_surname,thefilename:string);
function retrieve_map(id,person_name,person_surname:string):string;
function query_database(code,name,surname,dateday,datemonth,dateyear,area,telephone,proffesion:string):string;
procedure Clean_Up_Map;

implementation 
uses windows,ammarunit,apsfiles,ammargui,people,string_stuff,backups,userlogin,tools;
const title='Database People Map Subsystem';
var curendir:string;



procedure Add_Fast_Type_Names; 
var fileused:text; 
    read_str:string; 
    i:integer;
begin  
outtextcenter('Adding names for fast typing');

assign(fileused,curendir+'Database\map.map');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                       MessageBox (0, 'Δεν βρέθηκε το αρχείο χάρτης για τους φακέλους ασθενών - Δεν μπορεί να δημιουργηθεί ο χάρτης γρήγορης πληκτρολόγισης..' , ' ', 0 + MB_ICONEXCLAMATION);
                    end else
                    begin 
                     i:=0;
                     while not(eof(fileused)) do
                                        begin
                                         readln(fileused,read_str);
                                         seperate_words(read_str);
                                         if Equal(get_memory(1),'PERSON') then
                                            begin 
                                               i:=i+1;
                                               Text_Memory('ADD',get_memory(3)); //ADD NAME :)
                                               Text_Memory('ADD',get_memory(4)); //ADD SURNAME :) 
                                            end;

                                        end;
                      //Text_Memory('VIEW','');
                      outtextcenter('Added '+Convert2String(i)+' names/surnames ');
                      close(fileused);
                    end;
end;



 


procedure Init_People_Map;
begin
GetDir(0,curendir); 
if curendir[Length(curendir)]<>'\' then curendir:=curendir+'\';

Add_Fast_Type_Names;
end;

procedure add2map(id,person_name,person_surname,thefilename:string);
var fileused:text; 
    i:integer;
begin 
assign(fileused,curendir+'Database\map.map');
append(fileused);
writeln(fileused,'person('+id+','+person_name+','+person_surname+','+thefilename+')');
close(fileused);
end;

procedure delete4map(id,person_name,person_surname,thefilename:string);
var fileused,tmpfile:text;
    i:integer;
    retres:boolean;
    check_str,read_str:string;
begin 
retres:=false;
check_str:='person('+id+','+person_name+','+person_surname+','+thefilename+')';

assign(fileused,curendir+'Database\map.map');
assign(tmpfile,curendir+'Database\tmpfile.map');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                       MessageBox (0, 'Δεν βρέθηκε το αρχείο χάρτης για τους φακέλους ασθενών - Η Διαγραφή δεν μπορεί (και δεν έχει νόημα να πραγματοποιηθεί)' , ' ', 0 + MB_ICONEXCLAMATION);
                    end else
                    begin 
rewrite(tmpfile);
while not(eof(fileused)) do
           begin
             readln(fileused,read_str);
             seperate_words(read_str);
             retres:=false;
             if Equal(get_memory(1),'PERSON') then
                  begin
                    if Equal(get_memory(5),thefilename) then
                    begin
                     retres:=true;
                    end;
                  end;
             if (not retres) then
                                begin
                                  writeln(tmpfile,read_str);
                                end;
           end;
                     close(tmpfile);
                     close(fileused);
                     Make_BackUp('Database','tmpfile.map');
                     CopyFile(curendir+'Database\tmpfile.map',curendir+'Database\map.map');
                    end; //Opened fileused
end;

function retrieve_map_serial(num:integer):string;
var fileused:text; 
    i:integer;
    read_str,retres:string;
begin
retres:='';
assign(fileused,curendir+'Database\map.map');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                       MessageBox (0, 'Δεν βρέθηκε το αρχείο χάρτης για τους φακέλους ασθενών - Δεν μπορεί να γίνει αναζήτηση..' , ' ', 0 + MB_ICONEXCLAMATION);
                    end else
                    begin 
                      i:=0;
                      while not(eof(fileused)) do
                             begin 
                               i:=i+1;
                               readln(fileused,read_str);
                               if i=num then begin
                                              seperate_words(read_str);
                                              retres:=get_memory(5);
                                             end;
                             end;
                       close(fileused);
                       if i<num then retres:='eof'; // <- To num pou epileksame einai poly megalo..
                    end;
retrieve_map_serial:=retres;
end;


function retrieve_map(id,person_name,person_surname:string):string;
var fileused:text; 
    read_str,retres:string;
    i:integer;
begin 
retres:='';
assign(fileused,curendir+'Database\map.map');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                       MessageBox (0, 'Δεν βρέθηκε το αρχείο χάρτης για τους φακέλους ασθενών - Δεν μπορεί να γίνει αναζήτηση..' , ' ', 0 + MB_ICONEXCLAMATION);
                    end else
                    begin 
                      while not(eof(fileused)) do
                                        begin
                                          readln(fileused,read_str);
                                          seperate_words(read_str);
                                          i:=0;
                                          if Upcase(get_memory(1))='PERSON' then
                                            begin
                                               if Upcase(get_memory(2))=Upcase(id) then i:=i+1 else
                                               if id='' then i:=i+1;

                                               if Upcase(get_memory(3))=Upcase(person_name) then i:=i+1 else
                                               if person_name='' then i:=i+1;

                                               if Upcase(get_memory(4))=Upcase(person_surname) then i:=i+1 else
                                               if person_surname='' then i:=i+1;

                                               if i=3 then begin
                                                            retres:=get_memory(5);
                                                            break;
                                                           end;
                                            end;
                                        end;  
                      close(fileused);
                    end;
retrieve_map:=retres;
end;


function query_database(code,name,surname,dateday,datemonth,dateyear,area,telephone,proffesion:string):string;
var fileused:text;
    filled_up:boolean;
    line,retres,last_box:string;
    i,query_result,results,blocky,startfrom,where2goback:integer;
    label start_query,end_query;
begin 
retres:='';
where2goback:=0;
startfrom:=1;
blocky:=35;

start_query:
assign(fileused,curendir+'Database\'+'map.map');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then MessageBox (0, 'Could not open map.map for allocation of person records,,' , title , 0 + MB_ICONEXCLAMATION) else
               begin
                 flush_gui_memory(0);
                 include_object('backwindow','window','Αναζήτηση ασθενών','','','',GridX(1,5),10,GridX(4,5),GetMaxY-10);
                 draw_all;
                 delete_object('backwindow','NAME');
                 //query_result:=30;
                 results:=0;
                 if startfrom>1 then begin
                                      i:=1;
                                      while ((not (eof(fileused))) and (i<startfrom)) do
                                       begin
                                        i:=i+1;
                                        readln(fileused,line);
                                       end;
                                     end;
                 results:=startfrom-1;
                 filled_up:=false;
                 include_object('alignment','buttonc','Align','','','',-1,50,-1,0);
                 last_box:=last_object;
                 while ( (not filled_up) and  (not eof(fileused)) ) do
                   begin
                    readln(fileused,line);
                    seperate_words(line);  
                    Load_Person(get_memory(5),false);
                    if (check_match(code,name,surname,dateday,datemonth,dateyear,area,telephone,proffesion)) then
                       begin 
                        results:=results+1;   
                        include_object('data'+Convert2String(results),'data',get_memory(5),'','','',0,0,0,0);
                        line:=People_Data(1)+' - '+People_Data(2)+' '+People_Data(3)+' - '+People_Data(6)+' - '+People_Data(5);
                        include_object('btn'+Convert2String(results),'buttonc',line,'','','',-1,Y2(last_box)+5,-1,0);
                        last_box:=last_object;
                        if Y2(last_object)+100>=GetMaxY then filled_up:=true;
                       end;
                   end;

                 close(fileused);
                 //results:=results+1;
                 delete_object('alignment','NAME'); 
                 include_object('exit','buttonc','Έξοδος','','','',-1,Y2(last_object)+10,-1,0);
                 if filled_up then include_object('next','buttonc','Επόμενο ->','','','',X2(last_object)+5,Y1(last_object),0,0);
                 if ((startfrom>1) and (where2goback>0) ) then include_object('previous','buttonc','<- Προηγούμενο','','','',X1('exit')-112,Y1(last_object),0,0);
                 
               if results>0 then
           begin
                 draw_all;
                 repeat
                  interact; 
                  if get_object_data('previous')='4' then begin
                                                           set_button('previous',0);
                                                          if where2goback=0 then MessageBox (0, 'Πρόβλημα με τον μηχανισμό προβολής.. Ανακαλύψατε ένα BUG!' , ' ', 0 + MB_ICONEXCLAMATION) else
                                                           begin
                                                            startfrom:=startfrom-where2goback;
                                                            if startfrom<1 then startfrom:=1;
                                                            goto start_query;
                                                           end;
                                                      end else 
                  if get_object_data('next')='4' then begin
                                                       set_button('next',0);
                                                        where2goback:=results+1-startfrom; 
                                                        startfrom:=results+1;
                                                       goto start_query;
                                                      end else
                                                      begin
                  for i:=startfrom to results do begin
                                          if get_object_data('btn'+Convert2String(i))='4' then begin
                                                                                                 retres:=get_object_data('data'+Convert2String(i));
                                                                                                 goto end_query;
                                                                                                 break;
                                                                                                 break;

                                                                                               end;
                                         end;
                                                     end;
                 until get_object_data('exit')='4';
               end else
                  MessageBox (0, 'Δεν υπάρχουν αποτελέσματα για τα κριτήρια αναζήτησης σας' , title, 0 + MB_ICONASTERISK);
             
               end;
end_query:
query_database:=retres;
end;

procedure Clean_Up_Map;
var fileused:text;
    line:string;
    found_errors:boolean;
begin
found_errors:=false;
assign(fileused,curendir+'Database\map.map');
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then MessageBox (0, 'Could not open map.map for allocation of person records ' , title , 0 + MB_ICONEXCLAMATION) else
               begin
                 while (not eof(fileused)) do
                   begin
                    readln(fileused,line);
                    seperate_words(line);
                    if ( not check_file_existance(curendir+'Database\'+get_memory(5))) then
                                 begin
                                  Outtextcenter('Map Reference does not exist.. - '+curendir+'Database\'+get_memory(5));
                                  Write_2_Log('Map Reference does not exist.. - Suspected Data Loss.. - '+curendir+'Database\'+get_memory(5));
                                  found_errors:=true;
                                 end;
                   end;
                  close(fileused);
                 if found_errors then begin
                                       OuttextCenter('Press any key to continue !');
                                       OuttextCenter('bypass !');
                                      //readkey;
                                      end;
               end;

end;


begin
end.
