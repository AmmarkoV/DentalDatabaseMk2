unit pic_select;
{$H+}
interface
 
procedure Convert_Picture_File(fromfile,tofile:string);
procedure Check_Aquired_Images(inpt:string);
procedure GUI_Person_Photo_Gallery(theperson:string);
procedure PrepareImagePrintout;

implementation 
uses windows,ammarunit,apsfiles,ammargui,settings,userlogin,people,teeth,tools,string_stuff,jpgfiles,security_gra;
const
 MAX_INFILES=60;
Type
  TFileName = Array[0..Max_Path] Of Char;
Type 
 picdata =
  Record
   filename:string; 
   doctor:string;
   patient:string;
   teeth:string;
   description:string;
   date:string;
  End;

var incoming_files:array[0..MAX_INFILES] of picdata;
    mem_file:picdata;
    images_loaded:integer;

Function SelectFile(Var FName:TFileName; Open:Boolean): Boolean;
Const
  Filter : PChar = 'JPEG Picture files (*.jpg)'#0'*.Jpg'#0+
                   'BMP Picture files (*.bmp)'#0'*.bmp'#0+
                   'APS Picture files (*.aps)'#0'*.aps'#0+
                   'All files (*.*)'#0'*.*'#0#0;
  Ext    : PChar = 'txt';
Var
  NameRec : OpenFileName;

Begin
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
      SelectFile := GetOpenFileName(@NameRec)
  Else
      SelectFile := GetSaveFileName(@NameRec);
End; 
 

procedure Convert_Picture_File(fromfile,tofile:string);
begin  //cmd /c 
RunEXE(get_external_image_convert+' "'+fromfile+'" /convert="'+tofile+'"','minimized');
end;

procedure Resize_Picture_File(fromfile:string; newx,newy:integer);
begin  //cmd /c 
RunEXEWait(get_external_image_convert+' "'+fromfile+'" /resize=('+Convert2String(newx)+','+Convert2String(newy)+') /aspectratio /convert="'+fromfile+'"',true);
end;

procedure Crop_Picture_File(fromfile:string; ax,ay,bx,by:integer);
begin  //cmd /c 
RunEXEWait(get_external_image_convert+' "'+fromfile+'" /crop=('+Convert2String(ax)+','+Convert2String(ay)+','+Convert2String(bx)+','+Convert2String(by)+')  /convert="'+fromfile+'"',true);
end;

procedure FlipX_Picture_File(fromfile:string);
begin  //cmd /c 
RunEXEWait(get_external_image_convert+' "'+fromfile+'" /hflip /convert="'+fromfile+'"',true);
end;

procedure FlipY_Picture_File(fromfile:string);
begin  //cmd /c 
RunEXEWait(get_external_image_convert+' "'+fromfile+'" /vflip /convert='+fromfile,true);
end;

procedure Open_Picture_File(fromfile:string);
begin  //cmd /c 
RunEXEWait(get_external_image_convert+' "'+fromfile+'" /one',true);
end;

procedure Flush_incoming_files;
var clr_inc:picdata;
    i:integer;
begin
if images_loaded>0 then
begin
clr_inc.filename:='';
clr_inc.doctor:='';
clr_inc.patient:='';
clr_inc.teeth:='';
clr_inc.description:='';
clr_inc.date:='';
for i:=1 to images_loaded do
  begin
   incoming_files[i]:=clr_inc;
  end;
images_loaded:=0;
end;
end;


function Ret_Cap_Filename_Str(num:integer):string;
var curfile,numfile:string;
    calc:integer;
begin
numfile:=Convert2String(num);
if Length(numfile)<3 then
 begin
  for calc:=1 to 4-Length(numfile) do numfile:='0'+numfile;
 end;
curfile:='StillCap'+numfile+'.bmp';
Ret_Cap_Filename_Str:=curfile;
end;


procedure add2picturemap(picname,patientfile,user,description,teeth:string);
var fileused:text;
    thefilename:string;
    datesnstuff:array[1..4]of word; 
begin
thefilename:=get_central_dir+'Image Database\'+AnalyseFilename(patientfile,'filename')+'.picdat';
assign(fileused,thefilename);
if (not (check_file_existance(thefilename)) ) then begin
                                                    {$i-}
                                                    rewrite(fileused);
                                                    {$i+}
                                                    if Ioresult<>0 then begin
                                                                         MessageBox (0, 'Σφάλμα κατά την πρώτη εγγραφή του αρχείου εικόνων για τον ασθενή..' , ' ', 0 + MB_ICONEXCLAMATION);
                                                                        end else
                                                                         close(fileused);
                                                  end;
{$i-}
append(fileused);
{$i+}
if Ioresult<>0 then begin
                     MessageBox (0, 'Δεν ήταν δυνατή  η προσθήκη της εικόνας στο αρχείο του ασθενή..' , 'DDMk2 - Picture Map error..', 0 + MB_ICONEXCLAMATION);
                    end else
                    begin 
                     GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
                     writeln(fileused,'pic(',picname,',',user,',',description,',',teeth,',',datesnstuff[1],'/',datesnstuff[3],'/',datesnstuff[4],')');
                     close(fileused);
                    end;
end;



procedure Add_Image(picname,patientfile,user,description,teeth:string; remove_safety:boolean);
var thedir,thenewfile,mappedfile:string;
    datesnstuff:array[1..8]of word;
begin
thedir:=AnalyseFilename(picname,'directory');
if thedir[Length(thedir)]<>'\' then thedir:=thedir+'\';
thenewfile:=AnalyseFilename(picname,'FILENAME')+'.jpg';

GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]);
GetLTime(datesnstuff[5],datesnstuff[6],datesnstuff[7],datesnstuff[8]);
mappedfile:=AnalyseFilename(patientfile,'FILENAME');
mappedfile:=mappedfile+Convert2String(datesnstuff[1])+Convert2String(datesnstuff[3])+Convert2String(datesnstuff[4])+'_';
mappedfile:=mappedfile+Convert2String(datesnstuff[5])+Convert2String(datesnstuff[6])+Convert2String(datesnstuff[7])+'.jpg';

SetBackgroundMode('OPAQUE');
GotoXY(0,GetMaxY div 2);
OutTextCenter('Compressing '+picname);
Convert_Picture_File(picname,thedir+thenewfile);
if (not (check_file_existance(thedir+thenewfile) ) ) then MessageBox (0, 'Δεν ήταν δυνατή η συμπίεση του αρχείου εικόνας' , ' ', 0 + MB_ICONEXCLAMATION) else
  begin
    add2picturemap(mappedfile,patientfile,user,description,teeth);
    GotoXY(0,GetMaxY div 2);
    OutTextCenter('Saving compressed file '+mappedfile);
    CopyFile(thedir+thenewfile,get_central_dir+'Image Database\'+mappedfile);

    if remove_safety then
     begin
      GotoXY(0,GetMaxY div 2);
      OutTextCenter('Removing initial files ..');
      delete_file(picname);
      delete_file(thedir+thenewfile);
     end;


    GotoXY(0,GetMaxY div 2);
    OutTextCenter('Image '+mappedfile+' compress/store success '); 
  end;
SetBackgroundMode('TRANSPARENT');

end;




procedure save_images_form(state:integer);
begin
incoming_files[state].filename:=Ret_Cap_Filename_Str(state);
incoming_files[state].doctor:=get_object_data('dentist');
incoming_files[state].patient:=get_object_data('name');
incoming_files[state].teeth:=get_object_data('teeth');
incoming_files[state].description:=get_object_data('description');
mem_file:=incoming_files[state];
end;

procedure load_images_form(state:integer);
begin
//set_object_data('','value',incoming_files[state].filename,0);
set_object_data('dentist','value',incoming_files[state].doctor,0);
set_object_data('name','value',incoming_files[state].patient,0);
set_object_data('teeth','value',incoming_files[state].teeth,0);
set_object_data('description','value',incoming_files[state].description,0); 
end;


function GUI_PicProperties(x,y:integer):integer;
const
  prepare_menu: array[1..5] of AnsiString = (
    '’νοιγμα καρτέλας εικόνας',
    'Αλλαγή στοιχείων εικόνας',
    'Ορισμός ως φωτογραφία ασθενούς',
    'Διαγραφή εικόνας',
    'Εκτύπωση εικόνας'
  );
var //prepare_menu:array [1..5] of string =('’νοιγμα καρτέλας εικόνας','Αλλαγή στοιχείων εικόνας','Ορισμός ως φωτογραφία ασθενούς','Διαγραφή εικόνας','Εκτύπωση εικόνας');
    selection:integer; 
begin
delay(120);
for selection:=1 to 10 do MouseButton(1);
selection:=0;
FlushMouseButtons;
selection:=text_handle_menu(x,y,5,prepare_menu);
GUI_PicProperties:=selection;
end;

procedure Check_Aquired_Images(inpt:string);
var fileused:text;
    stic1,curpic,stic2,tthnum,keepcol:integer;
    i,ax,ay,images_left:integer;
    pic_dim:array[1..4]of integer;
    scale_ratio:real;
    callfile,aperson,bufstr:string;
    made_sel:boolean;
    label end_check;
begin
Write_2_Log('Initiating image aquire');

i:=IDNO;
if check_file_existance(inpt+Ret_Cap_Filename_Str(0)) then  i:=MessageBox (0, 'Βρέθηκαν φωτογραφίες προς εισαγωγή στο πρόγραμμα , θέλετε να εισαχθούν στην βάση ?' , 'Βρέθηκαν εικόνες για εισαγωγή..', 0 + MB_YESNO + MB_ICONQUESTION+ MB_SYSTEMMODAL);
if i=IDNO then goto end_check;
i:=0;
chdir(inpt);
clrscreen;
flush_gui_memory(0);
set_gui_color(ConvertRGB(50,50,50),'COMMENT');

keepcol:=TakeTextColor;
TextColor(ConvertRGB(255,255,255));
stic1:=0;
stic2:=0;
i:=0;
while check_file_existance(inpt+Ret_Cap_Filename_Str(i)) do
  begin
   i:=i+1; 
   images_loaded:=images_loaded+1;
  end;
images_left:=i;
if images_left>MAX_INFILES then begin
                                 MessageBox (0, pchar('Το πρόγραμμα μπορεί να προβάλει έως και '+Convert2String(MAX_INFILES)+' φωτογραφίες..'+#10+'Επικοινωνήστε με την A-TECH για βελτιωμένη έκδοση..') , ' ', 0);
                                 images_left:=MAX_INFILES; //GIA NA APOFEYXTHOUN OVERFLOWS
                                end;
Write_2_Log('Found '+Convert2String(images_left)+' images for import');
stic2:=i-1;
curpic:=0;

Flush_incoming_files; 
if Equal(People_Data(8),'undefined.dat') then begin end else
if People_Data(8)<>'' then
 begin  //ADDED 14/04/07 ANAGRAFETAI AYTOMATA O XRISTIS (GIATI OXI :P)
  for i:=0 to images_left-1 do incoming_files[i].patient:=People_Data(8);
 end;

ax:=(GetMaxX - 720) div 2;
ay:=(GetMaxY - 520) div 2;
DrawRectangle2(5,ay,210,ay+510,ConvertRGB(220,220,220),ConvertRGB(160,160,160));
// ΥΠαρχει κ αλλού /\
include_object('back','buttonc','<-','no','','',10,ay+20,0,0);
include_object('curpic','textbox','0','no','','',X2(last_object)+10,Y1(last_object),X2(last_object)+80,0);
include_object('next','buttonc','->','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('namecomm','comment','Αρχείο Ασθενή:','no','','',7,Y2(last_object)+5,0,0);

include_object('name','textbox','','no','','',7,Y2(last_object)+5,193,0);
include_object('dentistcomm','comment','Όδοντίατρος:','no','','',7,Y2(last_object)+5,0,0);
include_object('dentist','textbox','','no','','',7,Y2(last_object)+5,193,0);
include_object('teethcomm','comment','Δόντια:','no','','',7,Y2(last_object)+5,0,0);
include_object('teeth','textbox','','no','','',7,Y2(last_object)+5,193,0);
include_object('descriptioncomm','comment','Περιγραφή:','no','','',7,Y2(last_object)+5,0,0);
include_object('description','textbox','','no','','',7,Y2(last_object)+5,193,0);

include_object('people','buttonc','’τομα','no','','',20,Y2(last_object)+10,0,0);
include_object('me','buttonc','Εγώ','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('tooth','buttonc','Δόντια','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('patient','buttonc','Ασθενείς','no','','',20,Y2(last_object)+10,0,0);

include_object('edit_photo','buttonc','’νοιγμα εικόνας','no','','',X2(last_object)+5,Y1(last_object),0,0);
include_object('memory','buttonc','Μνήμη (Πληροφορίες εικόνας)','no','','',20,Y2(last_object)+10,0,0);

include_object('crop','buttonc','Κόψιμο διαστάσεων','no','','',20,Y2(last_object)+10,0,0);
include_object('flipx','buttonc','Οριζόντιο Καθρέφτισμα','no','','',20,Y2(last_object)+10,0,0);
include_object('flipy','buttonc','Κάθετο Καθρέφτισμα','no','','',20,Y2(last_object)+10,0,0);

include_object('save','buttonc','Αποθήκευση','no','','',20,Y2(last_object)+10,0,0);
include_object('delete','buttonc','Διαγραφή','no','','',X2(last_object)+10,Y1(last_object),0,0);
include_object('exit','buttonc','Τέλος επεξεργασίας εικόνων','no','','',20,Y2(last_object)+10,0,0);
draw_all;

while ( (curpic>=stic1) and (curpic<=stic2)) do
  begin
   set_object_data('curpic','value',Convert2String(curpic),curpic);
   draw_object_by_name('curpic');
   load_images_form(curpic);
   draw_all;
   assign(fileused,inpt+Ret_Cap_Filename_Str(curpic));
    {$i-}
      reset(fileused);
    {$i+}
    if Ioresult=0 then
        begin  
         close(fileused);
         callfile:=AnalyseFilename(Ret_Cap_Filename_Str(curpic),'FILENAME');
         GotoXY(0,GetMaxY div 2);
         SetBackgroundMode('OPAQUE');
         OutTextCenter('..Φόρτωση εικόνας '+callfile+' ..');
         MouseButton(1);
         LoadPicture(Ret_Cap_Filename_Str(curpic));
         DrawRectangle2(250,0,GetMaxX,GetMaxY,ConvertRGB(0,0,0),ConvertRGB(0,0,0));
         if Retrieve_Aps_ID(callfile)=0 then
           begin
            if ((GetApsInfo('BMP_CORE','SIZEX')>2047) or (GetApsInfo('BMP_CORE','SIZEY')>768)) then
                begin
                 pic_dim[1]:=(GetMaxX - GetApsInfo('forbidden','sizex')) div 2;
                 pic_dim[2]:=(GetMaxY - GetApsInfo('forbidden','sizey')) div 2;
                 pic_dim[3]:=pic_dim[1]+GetApsInfo('forbidden','sizex');
                 pic_dim[4]:=pic_dim[2]+GetApsInfo('forbidden','sizey');
                 DrawApsCentered2('forbidden');
                 OutTextXY(pic_dim[1]+(GetApsInfo('forbidden','sizex')-TextWidth(Ret_Cap_Filename_Str(curpic))),pic_dim[4]+5,'Δεν είναι δυνατή η φόρτωση της εικόνας '+Ret_Cap_Filename_Str(curpic));
                 Write_2_Log('Could not load picture '+Ret_Cap_Filename_Str(curpic)+' because of its size '+Convert2String(GetApsInfo('BMP_CORE','SIZEX'))+'x'+Convert2String(GetApsInfo('BMP_CORE','SIZEY'))+'..');
                 i:=MessageBox (0, 'Θα θέλατε να γίνει σμίκρυνση της εικόνας έτσι ωστε να μπορεί να την χειριστεί το πρόγραμμα?' , 'Θα θέλατε να γίνει σμίκρυνση?', 0 + MB_YESNO + MB_ICONQUESTION+ MB_SYSTEMMODAL);
                 if i=IDYES then
                   begin
                     pic_dim[1]:=GetApsInfo('BMP_CORE','SIZEX');
                     pic_dim[2]:=GetApsInfo('BMP_CORE','SIZEY');
                     scale_ratio:=pic_dim[2]/768;
                     if (scale_ratio/pic_dim[1]<2047) then begin
                                                            pic_dim[1]:=round(pic_dim[1] / scale_ratio);
                                                            pic_dim[2]:=round(pic_dim[2] / scale_ratio);
                                                            Resize_Picture_File(Ret_Cap_Filename_Str(curpic),pic_dim[1],pic_dim[2]);
                                                            made_sel:=true;
                                                           end;
                   end;
                end;
           end else
           begin
            pic_dim[1]:=(GetMaxX - GetApsInfo(callfile,'sizex')) div 2;
            pic_dim[2]:=(GetMaxY - GetApsInfo(callfile,'sizey')) div 2;
            pic_dim[3]:=pic_dim[1]+GetApsInfo(callfile,'sizex');
            pic_dim[4]:=pic_dim[2]+GetApsInfo(callfile,'sizey');

            DrawAPSXY2(callfile,pic_dim[1],pic_dim[2]);
            OutTextXY(pic_dim[1]+(GetApsInfo(callfile,'sizex')-TextWidth(Ret_Cap_Filename_Str(curpic))),pic_dim[4]+5,Ret_Cap_Filename_Str(curpic));
            SetBackgroundMode('TRANSPARENT');
            DrawRectangle2(5,ay,210,ay+510,ConvertRGB(220,220,220),ConvertRGB(160,160,160));
            draw_all;
            SetBackgroundMode('OPAQUE');
            UnloadAPS(callfile);
           end;
         made_sel:=false;

         SetBackgroundMode('TRANSPARENT');
         repeat
          interact;
            if window_needs_redraw then made_sel:=true;
           if get_object_data('patient')='4' then
                  begin
                   set_button('patient',0);
                   save_graph_window; 
                   Deflash_AmmarGUI('wndtmp');
                   save_images_form(curpic);
                   aperson:=GUI_search_person;
                   load_graph_window; 
                   Flash_AmmarGUI('wndtmp'); 
                   set_gui_color(ConvertRGB(50,50,50),'COMMENT');
                   if aperson<>'' then begin
                                        set_object_data('name','value',aperson,0);
                                       end;
                   draw_all;
                  end else
           if get_object_data('me')='4' then
                  begin
                   set_button('me',0);
                   set_object_data('dentist','value',Get_Current_User,0);
                   draw_object_by_name('dentist');
                   draw_all;
                  end else
           if get_object_data('tooth')='4' then
                  begin
                   set_button('tooth',0);
                   save_graph_window; 
                   Deflash_AmmarGUI('wndtmp');
                   save_images_form(curpic);
                   aperson:=select_some_teeth(get_object_data('teeth'),tthnum);
                    
                   load_graph_window; 
                   Flash_AmmarGUI('wndtmp'); 
                   set_gui_color(ConvertRGB(50,50,50),'COMMENT');
                   if aperson<>get_object_data('teeth') then
                                       begin
                                        set_object_data('teeth','value',aperson,0);
                                       end;
                   draw_all;
                  end else
           if get_object_data('people')='4' then
                  begin
                   set_button('people',0); 
                   save_graph_window; 
                   Deflash_AmmarGUI('wndtmp');
                   save_images_form(curpic);
                   aperson:=GUI_Select_User;
                   load_graph_window; 
                   Flash_AmmarGUI('wndtmp');
                   set_gui_color(ConvertRGB(50,50,50),'COMMENT');
                   if aperson<>'' then begin
                                        set_object_data('dentist','value',aperson,0); 
                                       end;
                   draw_all;
                  end else
           if get_object_data('memory')='4' then
                  begin
                   set_button('memory',0);
                   incoming_files[curpic]:=mem_file;
                   load_images_form(curpic);
                   draw_all;
                  end else
           if get_object_data('back')='4' then
                  begin
                   set_button('back',0);
                   save_images_form(curpic);
                   curpic:=curpic-1;
                   if curpic<stic1 then curpic:=stic2;
                   made_sel:=true;
                  end else
           if get_object_data('next')='4' then
                  begin
                   set_button('next',0);
                   save_images_form(curpic);
                   curpic:=curpic+1;
                   if curpic>stic2 then curpic:=stic1;
                   made_sel:=true;
                  end
                   else
           if get_object_data('edit_photo')='4' then
                  begin
                   set_button('edit_photo',0);
                   save_images_form(curpic);
                   Open_Picture_File(Ret_Cap_Filename_Str(curpic));
                   made_sel:=true;
                  end
                   else 
           if get_object_data('crop')='4' then
                  begin
                   set_button('crop',0);
                   save_images_form(curpic);
                    GUI_ChangeCursorIcon(mouse_icon_resource('RING'));
                     i:=0; //clicks
                     WaitClearMouseButton(1);
                     repeat
                      if MouseButton(1)=2 then begin
                                                i:=i+1;
                                                if i=1 then begin
                                                             pic_dim[1]:=GetMouseX;
                                                             pic_dim[2]:=GetMouseY;
                                                             delay(100);
                                                             WaitClearMouseButton(1); 
                                                             DrawRectangle(pic_dim[1]-5,pic_dim[2]-5,pic_dim[1]+5,pic_dim[2]+5,ConvertRGB(255,0,0));
                                                            end else
                                                if i=2 then begin
                                                             pic_dim[3]:=GetMouseX; 
                                                             pic_dim[4]:=GetMouseY;
                                                             DrawRectangle(pic_dim[3]-5,pic_dim[4]-5,pic_dim[3]+5,pic_dim[4]+5,ConvertRGB(255,0,0));
                                                            end;
                                               end;
                     until ((i>=2) or Equal(readkeyfast,'escape')); 
                   DrawRectangle(pic_dim[1],pic_dim[2],pic_dim[3],pic_dim[4],ConvertRGB(255,0,0));
                   GUI_ChangeCursorIcon('arrow');
                   i:=MessageBox (0, 'Είστε σίγουροι οτι θέλετε να κόψετε την εικόνα σε αυτές τις διαστάσεις ?' , 'Αλλαγή στην εικόνα..', 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
                   if i=IDYES then
                      begin
                        Crop_Picture_File(Ret_Cap_Filename_Str(curpic),pic_dim[1],pic_dim[2],pic_dim[3],pic_dim[4]);
                      end;
                   made_sel:=true;
                  end
                   else  
           if get_object_data('flipx')='4' then
                  begin
                   set_button('flipx',0);
                   save_images_form(curpic);
                   FlipX_Picture_File(Ret_Cap_Filename_Str(curpic));
                   made_sel:=true;
                  end
                   else  
           if get_object_data('flipy')='4' then
                  begin
                   set_button('flipy',0);
                   save_images_form(curpic);
                   FlipY_Picture_File(Ret_Cap_Filename_Str(curpic));
                   made_sel:=true;
                  end
                   else  
           if get_object_data('delete')='4' then
                  begin
                   set_button('delete',0);
                   //i:=MessageBox (0, pchar('Είστε σίγουροι οτι θέλετε να διαγράψετε την εικόνα '+Ret_Cap_Filename_Str(curpic)+' ?') , 'Διαγραφή εικόνας ', 0 + MB_YESNO + MB_ICONQUESTION+ MB_SYSTEMMODAL);
                   i := MessageBoxA(
  0,
  PAnsiChar(AnsiString(
    'Είστε σίγουροι οτι θέλετε να διαγράψετε την εικόνα ' +
    Ret_Cap_Filename_Str(curpic) + ' ?'
  )),
  PAnsiChar(AnsiString('Διαγαφή εικόνας ')),
  MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL
);
                   if i=IDYES then
                 begin
                   Write_2_Log('Deleted image '+Ret_Cap_Filename_Str(curpic)+' ');
                   save_images_form(curpic); 
                   if curpic=stic1 then stic1:=stic1+1;
                   if curpic=stic2 then stic2:=stic2-1;
                   delete_file(inpt+Ret_Cap_Filename_Str(curpic));
                   curpic:=curpic+1;
                   if curpic>stic2 then curpic:=stic1;
                   made_sel:=true;
                   images_left:=images_left-1; 
                end;
                  end else
           if get_object_data('save')='4' then
                  begin
                   set_button('save',0);
                   save_images_form(curpic);
                   Write_2_Log('Added image '+Ret_Cap_Filename_Str(curpic)+' ');
                   Add_Image(inpt+Ret_Cap_Filename_Str(curpic),incoming_files[curpic].patient,incoming_files[curpic].doctor,incoming_files[curpic].description,incoming_files[curpic].teeth,true);
                   if curpic=stic1 then stic1:=stic1+1;
                   curpic:=curpic+1;
                   if curpic>stic2 then curpic:=stic1;
                   made_sel:=true;
                   images_left:=images_left-1; 
                  end  else
           if get_object_data('exit')='4' then
                  begin
                   set_button('exit',0);
                   i:=IDYES;
                   if images_left>0 then i:=MessageBox (0, pchar('Υπάρχουν ακόμα '+Convert2String(images_left)+' φωτογραφίες τις οποίες δεν έχετε αποθηκεύσει.'+#10+'Τελειώνοντας την επεξεργασία χωρίς να τις αποθηκεύσετε  μπορεί να χαθούν..'+#10+'Είστε σίγουροι οτι θέλετε να τελειώσει η επεξεργασία εικόνων ?') , 'Τέλος επεξεργασίας εικόνων?', 0 + MB_YESNO + MB_ICONQUESTION + MB_SYSTEMMODAL);
                   if i=IDYES then goto end_check;
                  end;
         until made_sel; 

        if images_left=0 then begin 
                                MessageBox (0, 'Όλες οι φωτογραφίες αποθηκεύτηκαν..' , 'Επιτυχής αποθήκευση', 0 + MB_ICONASTERISK+ MB_SYSTEMMODAL);
                                Write_2_Log('All pictures processed..');
                                goto end_check;
                              end;
        end else
        begin
         //MessageBox (0, pchar('Error Opening Picture file , could not open '+Ret_Cap_Filename_Str(curpic)) , 'Error Opening Picture file..', 0 + MB_ICONEXCLAMATION);
         curpic:=curpic+1;
         if curpic>stic2 then curpic:=stic1; 
        end;
  end;

end_check: 
TextColor(keepcol);
Write_2_Log('Image aquire done..');
chdir(get_central_dir);
end;


procedure LoadPersonGallery(theperson:string);
var bufstr:string;
    fileused:text;
    img_errors:integer;
begin 
assign(fileused,get_central_dir+'Image Database\'+theperson);
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                     images_loaded:=0; 
                     MessageBox (0, 'Δεν βρέθηκαν αρχεία εικόνας για αυτή την καταχώρηση' , ' ', 0 + MB_SYSTEMMODAL);
                    end else
                    begin
                     Flush_incoming_files;
                     images_loaded:=0;
                     img_errors:=0;
                     while (not (eof(fileused))) do
                       begin
                        readln(fileused,bufstr); 
                        seperate_words(bufstr);
                        if Equal(get_memory(1),'PIC') then
                           begin
                              if check_file_existance(get_central_dir+'Image Database\'+get_memory(2)) then
                              begin
                               images_loaded:=images_loaded+1;
                               incoming_files[images_loaded].filename:=get_memory(2);
                               incoming_files[images_loaded].doctor:=get_memory(3);
                               incoming_files[images_loaded].patient:=theperson;
                               incoming_files[images_loaded].teeth:=get_memory(5);
                               incoming_files[images_loaded].description:=get_memory(4);
                               incoming_files[images_loaded].date:=get_memory(6);
                              end else img_errors:=img_errors+1;
                           end;

                       end;
                      if img_errors>0 then MessageBox (0, Pchar(Convert2String(img_errors)+' αρχεία εικόνας λείπουν από το σύστημα.. ') , ' ', 0 + MB_ICONEXCLAMATION+ MB_SYSTEMMODAL);
                      close(fileused);
                    end;

end;


procedure GUI_Person_Photo_Gallery(theperson:string);
var fileused:text;
    bordery,i,curx,cury,img_errors,strtpic,endpic:integer;
    done_drawing,chk_flag:boolean;
    bufstr,photo,lastobj:string;
    filephoto:TFileName;
    label restart_draw,photo_gallery_start,end_gallery;
begin

if (take_char(1)+take_char(2)+take_char(3)+take_char(4)+take_char(8)+take_char(9)+take_char(18)+take_char(16)<>2604) then
   begin
    {ISODYNAMEI ME DRAW ADD KAI DELAY(8000); } view_screen(1);
    goto end_gallery;
   end;
 

strtpic:=0;
photo_gallery_start:
assign(fileused,get_central_dir+'Image Database\'+theperson);
{$i-}
reset(fileused);
{$i+}
if Ioresult<>0 then begin
                     images_loaded:=0; 
                     MessageBox (0, 'Δεν βρέθηκαν αρχεία εικόνας για αυτή την καταχώρηση' , ' ', 0 + MB_SYSTEMMODAL);
                    end else
                    begin
                     Flush_incoming_files;
                     images_loaded:=0;
                     img_errors:=0;
                     while (not (eof(fileused))) do
                       begin
                        readln(fileused,bufstr); 
                        seperate_words(bufstr);
                        if Equal(get_memory(1),'PIC') then
                           begin
                              if check_file_existance(get_central_dir+'Image Database\'+get_memory(2)) then
                              begin
                               images_loaded:=images_loaded+1;
                               incoming_files[images_loaded].filename:=get_memory(2);
                               incoming_files[images_loaded].doctor:=get_memory(3);
                               incoming_files[images_loaded].patient:=theperson;
                               incoming_files[images_loaded].teeth:=get_memory(5);
                               incoming_files[images_loaded].description:=get_memory(4);
                               incoming_files[images_loaded].date:=get_memory(6);
                              end else img_errors:=img_errors+1;
                           end;

                       end;
                      if img_errors>0 then MessageBox (0, Pchar(Convert2String(img_errors)+' αρχεία εικόνας λείπουν από το σύστημα.. ') , ' ', 0 + MB_ICONEXCLAMATION+ MB_SYSTEMMODAL);
                      close(fileused);
                    end;
restart_draw:

flush_gui_memory(0);
set_gui_color(ConvertRGB(0,0,0),'comment');
clrscreen;
draw_window;

include_object('window1','window','Dental Database','no','','',GridX(1,8),GridY(1,15),GridX(7,8),GridY(14,15)+20);
draw_all;
delete_object('window1','name');


bordery:=GridY(14,15)-50;
if (check_file_existance(get_external_video_input)) then
include_object('newimage_wdm','buttonc','Εισαγωγή από ψηφιακή κάμερα','no','','',GridX(1,8)+15,bordery,0,0);
include_object('newimage_scanner','buttonc','Εισαγωγή από συσκευή scanner','no','','',X2(last_object)+3,bordery,0,0);
include_object('newimage','buttonc','Εισαγωγή από αρχείο','no','','',X2(last_object)+3,bordery,0,0);
include_object('clearphoto','buttonc','Καθαρισμός φωτογραφίας καρτέλας','no','','',X2(last_object)+3,bordery,0,0);
draw_all;


if images_loaded>0 then
begin
curx:=GridX(1,8)+30;
cury:=GridY(1,15)+55;
done_drawing:=false;
chdir(get_central_dir+'Image Database\');
TextColor(ConvertRGB(0,0,0));
i:=strtpic;
while not (done_drawing) do
  begin
    i:=i+1;
    OutTextXY(curx+2,cury+2,'’νοιγμα εικόνας..');
    LoadPicture(incoming_files[i].filename);
    bufstr:=AnalyseFilename(incoming_files[i].filename,'filename');
    filter_resize(bufstr,320,240);
    DrawApsXY2(bufstr,curx,cury);
    include_object('image('+Convert2String(i)+')','layer','1','no','','select',curx,cury,curx+320,cury+240);
    UnloadAPS(bufstr);
    if curx+320*2+10>GridX(7,8)-40 then
                                   begin
                                    curx:=GridX(1,8)+30;
                                    if cury+2*240+10>GridY(14,15)-30 then done_drawing:=true else
                                                                     cury:=cury+250;
                                   end else
                                   curx:=curx+330;

   if i>=images_loaded then done_drawing:=true;
  end;
endpic:=i;
TextColor(ConvertRGB(255,255,255));
chdir(get_central_dir);
end;

if strtpic>0 then include_object('back','buttonc','<- Αρχή','no','','',GridX(1,8)+15,Y2('clearphoto')+5,0,0);
if endpic<images_loaded then begin
                              if (last_object='back') then i:=X2('back')+3 else
                                                           i:=GridX(1,8)+15;
                              include_object('next','buttonc','Επόμενο ->','no','','',i,Y2('clearphoto')+5,0,0);
                             end;
if ((strtpic<=0) and (endpic>=images_loaded)) then include_object('tmp','layer','1','no','','',GridX(1,8)+15,Y2('clearphoto')+5,GridX(1,8)+15,Y2('clearphoto')+5);
include_object('exit','buttonc','Έξοδος','no','','',X2(last_object)+3,Y1(last_object),0,0);

draw_all;

 
repeat
interact;
lastobj:=return_last_mouse_object;
if get_object_data('clearphoto')='4' then begin
                                            set_button('clearphoto',0);
                                            Set_People_Data(7,'');
                                          end    else
if get_object_data('back')='4' then begin
                                     set_button('back',0); 
                                     strtpic:=0;
                                     goto photo_gallery_start;
                                    end    else
if get_object_data('next')='4' then begin
                                     set_button('next',0);
                                     strtpic:=endpic;
                                     goto photo_gallery_start;
                                    end    else
if get_object_data('newimage_scanner')='4' then begin
                                             set_button('newimage_scanner',0);
                                             //MakeMessageBox (Pchar('Feature not included..') , ' ', '' ,'','');
                                             chk_flag:=false;
                                             if Equal(AnalyseFilename(get_external_image_convert,'FILENAME+EXTENTION'),'i_view32.exe') then
                                              begin 
                                              // if check_file_existance(get_external_image_convert) then   <- GIA KAPOION LOGO DEN DOYLEYEI
                                                 begin
                                                  chk_flag:=true;
                                                   if (not RunExeWait('"'+get_external_image_convert+'" /scan',true)) then
                                                   //MessageBox (0, pchar('Δεν ήταν δυνατή η εκκίνηση του '+get_external_image_convert+' ..') , 'Dental Database Mk2', 0 + MB_ICONASTERISK  + MB_SYSTEMMODAL) else
                                                   MessageBoxA(0, PAnsiChar(AnsiString( 'Δεν ήταν δυνατή η εκκίνηση του ' + get_external_image_convert + ' ..' )),PAnsiChar(AnsiString('Dental Database Mk2')), MB_ICONASTERISK or MB_SYSTEMMODAL) else
                                                   begin goto photo_gallery_start; end;
                                                 end;
                                              end;
                                              if not chk_flag then MessageBox (0, Pchar('Δεν ήταν δυνατή η εύρεση ενός TWAIN συμβατού προγράμματος , ένα τέτοιο πρόγραμμα είναι το IrfanView το οποίο παρέχεται στο CD εγκατάστασης.'+#10+'Σιγουρευτειτε οτι έχετε ρυθμίσει το μόνοπάτι της εφαρμογής στις Τεχνικές ρυθμίσεις..'+#10+'Το επιλεγμένο πρόγραμμα αυτή την στιγμή είναι "'+get_external_image_convert+'"') , 'Dental Database', 0 + MB_ICONASTERISK+ MB_SYSTEMMODAL);
                                            end    else
if get_object_data('newimage_wdm')='4' then begin 
                                             set_button('newimage_wdm',0);
                                             clrscreen;
                                             bufstr:=FixDir(AnalyseFilename(get_external_video_input,'directory'));
                                             chdir(bufstr);
                                             assign(fileused,bufstr+'options.ini');
                                              {$i-}
                                                reset(fileused);
                                              {$i+}
                                              if Ioresult<>0 then begin
                                                                   MessageBox (0, 'Αυτός ο υπολογιστής δεν φαίνεται να έχει εγκαταστημένο το πρόγραμμα εισαγωγής εικόνων..'+#10+'Διορθώστε την εγκατάσταση..' , ' ', 0 + MB_ICONEXCLAMATION + MB_SYSTEMMODAL);
                                                                  end else
                                              begin    
                                               GotoXY(0,GetMaxY div 2);
                                               OutTextCenter('Παρακαλώ περιμένετε..');
                                               OutTextCenter('Γίνεται εκκίνηση του προγράμματος εγγραφής εικόνας..');
                                               mousebutton(1);
                                               close(fileused);
                                               rewrite(fileused);
                                               write(fileused,'SeCURiTY');
                                               close(fileused);
                                               if (not RunExeWait(get_external_video_input,true)) then 
                                                   //MessageBox (0, pchar('Δεν ήταν δυνατή η εκκίνηση του '+get_external_video_input+' ..') , 'Dental Database Mk2', 0 + MB_ICONASTERISK  + MB_SYSTEMMODAL);
                                                   MessageBoxA(
  0,
  PAnsiChar(AnsiString(
    'Δεν ήταν δυνατή η εκκίνηση του ' + get_external_video_input + ' ..'
  )),
  PAnsiChar(AnsiString('Dental Database Mk2')),
  MB_ICONASTERISK or MB_SYSTEMMODAL
);
                                               rewrite(fileused);
                                               writeln(fileused,'C:\');
                                               close(fileused); 
                                               Check_Aquired_Images('C:\');
                                               chdir(get_central_dir); 

                                              end;
                                             goto photo_gallery_start;
                                            end    else
if get_object_data('newimage')='4' then begin
                                           set_object_data('newimage','value','1',1);
                                           if (SelectFile(filephoto,true)) then  begin
                                                                                  set_button('newimage',0); 
                                                                                  Convert_Picture_File(filephoto,'C:\'+Ret_Cap_Filename_Str(0));
                                                                                  Check_Aquired_Images('C:\');
                                                                                  goto photo_gallery_start;
                                                                                  //add2picturemap(picname,patientfile,user,description,teeth:string);
                                                                                 end else
                                           MessageBox (0, 'Δεν έγινε αλλαγή στην φωτογραφία..' , 'Dental Database Mk2', 0 + MB_ICONASTERISK  + MB_SYSTEMMODAL);
                                          end else 
if get_object_data(lastobj)='4' then begin
                                       if (lastobj<>'') then seperate_words(lastobj);
                                       i:=0;
                                       if (Equal(get_memory(1),'image')) then begin 
                                                                               i:=GUI_PicProperties(GetMouseX,GetMouseY);
                                                                               delay(50);
                                                                               set_object_data(lastobj,'VALUE','1',1);
                                                                              end;
                                       if i=-1 then begin end else
                                       if i=0 then begin end else
                                       if i=3 then  begin
                                                      Set_People_Data(7,incoming_files[get_memory_int(2)].filename);
                                                      MessageBox (0, 'Η φωτογραφία τέθηκε ως εικόνα του ασθενούς..' , 'Ορισμός φωτογραφίας', 0 + MB_ICONASTERISK+ MB_SYSTEMMODAL);
                                                    end else
                                       if i=1 then                            begin
                                                                                save_graph_window;
                                                                                i:=get_memory_int(2);
                                                                                DrawJpegCentered(get_central_dir+'Image Database\'+incoming_files[i].filename);
                                                                                curx:=(GetMaxX-GetJpgX) div 2;
                                                                                cury:=(GetMaxY-GetJpgY) div 2;
                                                                                TextColor(ConvertRGB(0,0,0));
                                                                                SetFont('arial','greek',20,0,0,0);
                                                                                DrawRectangle(curx,cury,curx+GetJpgX,cury+GetJpgY,Get_GUI_Color(6));
                                                                                DrawRectangle2(curx,cury+GetJpgY,curx+GetJpgX,cury+GetJpgY+TextHeight('A')*6,Get_GUI_Color(6),Get_GUI_Color(1));
                                                                                GotoXY(curx,cury+GetJpgY); 
                                                                                OutTextCenter('Οδοντίατρος : '+incoming_files[i].doctor);
                                                                                OutTextCenter('Δόντια : '+incoming_files[i].teeth);
                                                                                OutTextCenter('Ημ/νια : '+incoming_files[i].date);
                                                                                OutTextCenter('Περιγραφή : '+incoming_files[i].description);
                                                                                OutTextCenter('(Πιέστε κάποιο πλήκτρο για επιστροφή)'); 
                                                                                SetFont('arial','greek',15,0,0,0);
                                                                                TextColor(ConvertRGB(255,255,255));
                                                                                readkey;
                                                                                load_graph_window;
                                                                               end else
                                                  MessageBox (0, 'Η Επιλογή αυτή είναι υπο κατασκευή! Λυπούμαστε για την ταλαιπωρία..' , ' ', 0 + MB_ICONASTERISK+ MB_SYSTEMMODAL);



                                      end;
until GUI_Exit;

end_gallery:
end;









procedure PrepareImagePrintout;
var  thefile:string;
     fileused:text;
     i:integer;
     datesnstuff:array[1..4]of word;
begin
thefile:=get_central_dir+'Cache\'+People_Data(9)+'.html';
assign(fileused,thefile);
 {$i-}
 rewrite(fileused);
 {$i+}
 if Ioresult=0 then
    begin
     LoadPersonGallery(People_Data(9)+'.picdat');
     writeln(fileused,'<html><body>');
      writeln(fileused,'<table width=879 height=595>');
      writeln(fileused,'<tr><td width=227 height=250><center>');
      i:=1;
      if i<images_loaded then writeln(fileused,'<img src="..\Image Database\'+incoming_files[i].filename+'" height=250></center></td>');
      writeln(fileused,'<td width=227 height=250><center>');
      i:=i+1;
      if i<images_loaded then writeln(fileused,'<img src="..\Image Database\'+incoming_files[i].filename+'" height=250></center></td>');
      writeln(fileused,'<td width=227 height=250><center>');
      i:=i+1;
      if i<images_loaded then writeln(fileused,'<img src="..\Image Database\'+incoming_files[i].filename+'" height=250></center></td>');
      writeln(fileused,'</td></tr>');
      

      writeln(fileused,'<tr><td width=227 height=170><center>');
      i:=i+1;
      if i<images_loaded then writeln(fileused,'<img src="..\Image Database\'+incoming_files[i].filename+'" height=170></center></td>');
      writeln(fileused,'<td width=227 height=170><center>');
       //TEXT GOES HERE
       writeln(fileused,'<font face="Verdana" size=2>');

       writeln(fileused,People_Data(2)+' '+People_Data(3)+'<br>');
       GetLDate(datesnstuff[1],datesnstuff[2],datesnstuff[3],datesnstuff[4]); 
       writeln(fileused,Convert2String(datesnstuff[1])+'/'+Convert2String(datesnstuff[3])+'/'+Convert2String(datesnstuff[4])+'<br>');
       writeln(fileused,'</font><font face="Verdana" size=1>Generated by Dental Database Mk2</font>');
      writeln(fileused,'</center></td><td width=227 height=170><center>');
      i:=i+1;
      if i<images_loaded then writeln(fileused,'<img src="..\Image Database\'+incoming_files[i].filename+'" height=170></center></td>');
      writeln(fileused,'</td></tr>');
      

      writeln(fileused,'<tr><td width=227 height=128><center>');
      i:=i+1;
      if i<images_loaded then writeln(fileused,'<img src="..\Image Database\'+incoming_files[i].filename+'" height=128></center></td>');
      writeln(fileused,'<td width=227 height=128><center>');
      i:=i+1;
      if i<images_loaded then writeln(fileused,'<img src="..\Image Database\'+incoming_files[i].filename+'" height=128></center></td>');
      writeln(fileused,'<td width=227 height=128><center>');
      i:=i+1;
      if i<images_loaded then writeln(fileused,'<img src="..\Image Database\'+incoming_files[i].filename+'" height=128></center></td>');
      writeln(fileused,'</td></tr>');
      


      writeln(fileused,'</table>');
     writeln(fileused,'</body></html>');
     close(fileused);
     RunEXE(get_external_browser+' "'+thefile+'"','normal');
     MessageBox (0, 'Click Ok to Continue' , ' ', 0);
    end;


end;








begin
end.
