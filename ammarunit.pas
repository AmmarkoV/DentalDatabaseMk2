{Id:Unit Constructed by Ammar Qammaz (ammar@otenet.gr) 2003-2004-2005-2006-2007 

             Copyright (c) 2003-2004-2005-2006-2007 - Ammar Qammaz

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

Do not Alter the unit in any way before mailing to --> ammar@otenet.gr
version
}  
{INFO Uses Ammarunit 0.916- made by Ammar Qammaz}
unit ammarunit;
interface
uses windows,strings;

procedure Vista_Compatibility(exename:string);
function FixDir(dirin:string):string;
procedure WindowsExecute(thefile,thedirectory:String);
procedure Refresh_DC;
function Declare_Paint_Start:hdc;
procedure Declare_Paint_End;
function window_needs_redraw_at(what:integer):integer;
procedure set_window_needs_redraw;
procedure set_window_drawn;
procedure set_window_clipping(x1,y1,x2,y2:integer);
function window_needs_redraw:boolean;
procedure AlwaysOnTop(on_off:boolean);
procedure UnitId;
function  AmmarUnitVersion:string;
function PasteFromClipboard: string;
function CopyToClipboard(const S: string): Boolean;
function Equal(bufstr1,bufstr2:string):boolean;
procedure ShakeSort(var inp:array of String);
function  MakeMessageBox(title,textw,buttons,icon,system:string):string;
function  StripString(thestring:string;thechar:char):string;
function  AnalyseFilename(filenam,mode:string):string;
function RunExeWait (AProgram : STRING; ishidden:boolean) : BOOLEAN;
procedure RunEXE(exename,window:string);
function  RunExeProcess(const ExeName, Params: String; const ShowWin: Word; const Wait: Boolean): Handle;
procedure OpenFolder(folderpath:string);
function  SlowComputer:integer;
function  Boottype:integer;
procedure ShutDownComputer;
procedure RestartComputer;
function  Uptime:integer;
procedure Delay(delaytime:integer);
procedure NoConsole;
procedure GetLDate(var theday,thedaywk,themonth,theyear:word);
procedure GetLTime(var thehour,theminute,thesecond,themillisec:word);
function  ConvertRGB2HTML(r,g,b:integer):string;
function  ConvertRGB(r,g,b:integer):integer;
function  ConvertR(rgb:integer):integer;
function  ConvertG(rgb:integer):integer;
function  ConvertB(rgb:integer):integer;
procedure SetLineSettings(LineStyle,Pattern,Width:integer);
function  TakeTextColor:colorref;
procedure TextColor(currentcolor:colorref);
function  TextWidth(textu:string):integer;
function  TextHeight(textu:string):integer;
procedure Beep_Sound(frequency,duration:integer);
procedure GotoXY(x111,y111:integer);
function  GetX:integer;
function  GetY:integer;
procedure ChangeWindowTitle(textus:string);
procedure Clrscreen;
procedure OutTextXY (xcoord,ycoord:integer; text:string);
procedure OutText(text:string);
procedure OutTextCenter(text:string);
function  GetMaxX:integer;
function  GetMaxY:integer;
procedure SetColor(rgbcolorstated:colorref);
function  GetColor:colorref;
function  GetTextFontColor:integer;
function  GetBackgroundColor:colorref;
procedure SetBackgroundColor(backcolor:colorref);
function  GetBackgroundMode:integer;
procedure SetBackgroundMode(mode:string);
procedure DrawDesktop;
procedure GetBorders;
procedure Refresh;
procedure PutPixel(xcoord,ycoord:integer; currentcolor:colorref);
procedure PutPixelFast(xcoord,ycoord:integer; currentcolor:colorref); 
function  GetPixelColor(xcoord,ycoord:integer):colorref;
procedure DrawLine(xcoord,ycoord,xcoord2,ycoord2:integer; currentcolor:colorref);
procedure DrawLine2(xcoord,ycoord,xcoord2,ycoord2:integer);
procedure DrawRectangle(xcoord,ycoord,xcoord2,ycoord2:integer; currentcolor2:colorref);
procedure DrawRectangle2(x1,y1,x2,y2:integer; currentcolor2,currentcolor3:COLORREF);
procedure DrawRectangle3(xcoord,ycoord,xcoord2,ycoord2,currentcolor2,currentcolor3:integer);
procedure DrawCircle(xcoord,ycoord,radious:integer; currentcolor:colorref);
procedure DrawCircle2(xcoord,ycoord,radious:integer);
procedure DrawBackground(backcolor:colorref);
procedure flushwindowproc(timses:integer);
procedure ChangeCursorIcon(pathtocur:string);
procedure FlushMouseButtons;
function  MouseButton(buttonid:integer):integer;
function MouseScroll:integer;
procedure WaitClearMouseButton(buttonid:integer);
function  GetMouseX:integer;
function  GetMouseY:integer;
procedure SetMouseXY(xcoord,ycoord:integer);
procedure save_graph_window;
procedure load_graph_window_xy(x1,y1,x2,y2:integer);
procedure load_graph_window;
procedure delete_graph_window;
function  Convert2String(thenumber:integer):string;
function  KeyboardLanguage:string;
procedure SetInternalKeyboardLanguage(lang:string);
function  GetInternalKeyboardLanguage:string;
function  Greek_Tone(str1:string):string;
function  Upcase2(str1:string):string;
function  key_database(ckey:integer):string;
procedure  SetLastReadKey_Code(newval:integer);
function  GetLastReadKey_Code:integer;
function  ReadKey:string;
function  ReadKeyFast:string;
function  KeyPressed:integer;
function  CheckKeyFast(keyid:integer):integer;
procedure  WaitForKey(keyids:string);
procedure WriteText(xcoord1,ycoord1:integer; text:string);
function  ReadText:string;
function  ChangeFont:string;
procedure SetFont(fontname,charset:string; sizef,bold,italic,rotation:integer);
function  GetFileName:string;
function RunWindow:boolean;
procedure WindowMove(x21,y21:integer);
function GetWindowStartX:integer;
function GetWindowStartY:integer; 
function  GraphDcUsed:integer;
function  Windowhandle:integer;
function  InitGraph(text:string; windowx,windowy,border:integer):integer;
procedure CloseGraph;

implementation


const version='0.923';
var
   AMessage: Msg;
   WindowHandles:HWnd;
   dc,dc2:hdc;
   ammar,keybtonos:byte;
   Appname,keyblanguage:string;
   last_keypress:integer;
   r:rect;
   activecolorused,backgroundcolor,curtextcolor:colorref;
   pencil,oldpencil:hpen;
   windowxu,windowyu,borderu,borderu2,curxcoord,curycoord,vkpressed,savedc:integer;
   window_start_x,window_start_y:integer;
   mousebtns:array[1..5] of integer; //4= Rotation
   LineSettings:array[1..3] of integer; //LineStyle,Pattern,Width
   currentcursor:HCURSOR;
   bufbol:boolean;
   hdcCompatible:hdc;
   hbmScreen:HBITMAP;
   update_rect:rect;
   bmretainobj:hgdiobj;
   windowregion:hrgn; //NEW,, TEST
   retainobj:hgdiobj;
   logfon:TLogFont;
     ps: paintstruct;
   need_redraw:boolean;

procedure Vista_Compatibility(exename:string);
var fileused:text;
    info:OSVERSIONINFO;
begin
With Info Do Begin
              dwOSVersionInfoSize:=SizeOf(info);
             End;
GetVersionEx(@info);
//MessageBox (0, pchar('Windows Version.. '+#10+Convert2String(info.dwMajorVersion)) , 'Windows Vista!', 0 + MB_ICONASTERISK);
  
if info.dwMajorVersion>5 then
begin
assign(fileused,exename+'.manifest');
{$i-}
 reset(fileused);
{$i+}
if Ioresult<>0 then
 begin 
  {$i-}
    rewrite(fileused);
  {$i+}
 if Ioresult=0 then
 begin
  MessageBox (0, 'Windows Vista or newer OS Detected.. '+#10+' Trying to run as Administrator' , 'Windows Vista!', 0 + MB_ICONASTERISK);
  writeln(fileused,'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
  writeln(fileused,'<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">');
  writeln(fileused,'  <assemblyIdentity version="1.0.0.0"');
  writeln(fileused,'processorArchitecture="X86"');
  writeln(fileused,'name="'+exename+'"');
  writeln(fileused,'type="win32"/>');
  writeln(fileused,'<description>elevate execution level</description>');
  writeln(fileused,'   <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">');
  writeln(fileused,'      <security>');
  writeln(fileused,'         <requestedPrivileges>');
  writeln(fileused,'            <requestedExecutionLevel level="requireAdministrator" uiAccess="false"/>');
  writeln(fileused,'         </requestedPrivileges>');
  writeln(fileused,'      </security>');
  writeln(fileused,'   </trustInfo>');
  writeln(fileused,'</assembly>');
  close(fileused);
 end; 
 end else
 close(fileused);
end;
end;

function FixDir(dirin:string):string;
begin
if dirin[Length(dirin)]<>'\' then dirin:=dirin+'\';
FixDir:=dirin;
end;

procedure Refresh_DC;
begin
 ReleaseDC(WindowHandles,dc2);
 dc2:=GetDC(WindowHandles);
end;

function Declare_Paint_Start:hdc;
begin
BeginPaint(WindowHandles,@ps);
end;

procedure Declare_Paint_End;
begin
EndPaint(WindowHandles,@ps);
end;


procedure WindowsExecute(thefile,thedirectory:String);
var thefile_p,thedir_p:pchar;
begin
thefile_p:=Pchar(thefile);
thedir_p:=Pchar(thedirectory);
if thedirectory='' then ShellExecute(WindowHandle,'open',thefile_p,nil,nil,SW_SHOWNORMAL) else
                        ShellExecute(WindowHandle,'open',thefile_p,nil,thedir_p,SW_SHOWNORMAL);
end;


function window_needs_redraw_at(what:integer):integer;
begin
 case what of
  1: begin window_needs_redraw_at:=update_rect.left; end;
  2: begin window_needs_redraw_at:=update_rect.top; end;
  3: begin window_needs_redraw_at:=update_rect.right; end;
  4: begin window_needs_redraw_at:=update_rect.bottom; end;
  end;
end;

procedure set_window_needs_redraw;
begin
need_redraw:=true;
update_rect.left:=0;
update_rect.top:=0;
update_rect.right:=0;
update_rect.bottom:=0;
end;

procedure set_window_clipping(x1,y1,x2,y2:integer);
var i:integer;
	cliprgn:HRGN; 	// handle of region to be selected
   
begin
 if ( (x1=0) and (y1=0) and (x2=0) and (y2=0)) then  SelectClipRgn(dc2,0) else
       begin
        cliprgn:=CreateRectRgn(x1,y1,x2,y2);
        i:=SelectClipRgn(dc2,cliprgn);
        if i=ERROR then MessageBox (0, 'Error Clipping..' , ' ', 0);
        DeleteObject(cliprgn);
       end;

end;

procedure set_window_drawn;
begin
need_redraw:=false;
ValidateRect(WindowHandle,0);
end;

function window_needs_redraw:boolean;
var retres:boolean;
begin
retres:=need_redraw;
{if need_redraw then begin
                     //need_redraw:=false;   KAKI IDEA!!!! APO EDW K EMPROS APAGOREYETAI TO AFINW GIA ISTORIKOUS LOGOUS!
                    end; }
window_needs_redraw:=retres;
end;


procedure AlwaysOnTop(on_off:boolean);
begin
     if (on_off) then  SetWindowPos (WindowHandles,HWND_TOPMOST,0,0,0,0,SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE)  else
                       SetWindowPos (WindowHandles,HWND_NOTOPMOST,0,0,0,0,SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE );

end;


function CopyToClipboard(const S: string): Boolean;

var
  hGlobalMem: HGlobal;
  lpGlobalMem: LPVoid;
begin
  Result := False;
  { Allocation de l'espace me'moire }
  hGlobalMem := GlobalAlloc(GHND, Length(S) + 1);
  if hGlobalMem <> 0 then
  begin
    { Fixation en me'moire et obtention d'un pointeur }
    lpGlobalMem := GlobalLock(hGlobalMem);
    if lpGlobalMem <> nil then
    begin
      { Copie de la chai^ne }
      StrPCopy(PChar(lpGlobalMem), S);
      if Integer(GlobalUnlock(hGlobalMem)) = 0 then
      begin
        { Ouverture du presse-papier }
        if OpenClipboard(0) then
        begin
          { On vide le presse-papier avant de le remplir }
          EmptyClipboard;
          { On place la chai^ne dedans }
          Result := (SetClipboardData(CF_TEXT, hGlobalMem) <> 0);
          { On referme le presse-papier }
          CloseClipboard;
        end;
      end;
    end;
  end;
  { ATTENTION ! Il ne faut pas libe'rer la me'moire alloue'e
    pour le presse-papier : le syste`me en devient le proprie'taire }
end;

function PasteFromClipboard: string;
var hglb:HGLOBAL;
    tst:LPTSTR;
    retres:string;
begin
retres:='';
if OpenClipboard(0) then
  begin
   hglb:=GetClipboardData(CF_TEXT);
   if hglb<>0 then
     begin
      tst:=GlobalLock(hglb);
      if (tst<>nil) then
        begin
         GlobalUnlock(hglb);
        end;
     end;
   CloseClipboard;
   retres:=tst;
  end;
PasteFromClipboard:=retres;
end;

function Pchar2(inp:string):pchar;
var i:integer;
    res:pchar;
begin
res:='';
{for i:=1 to Length(inp) do res:=res+'-';
for i:=1 to Length(inp) do res[i]:=inp[i];
}res:=Pchar(inp);
Pchar2:=res;
end;

function Equal(bufstr1,bufstr2:string):boolean;
var retres:boolean;
    i:integer;
begin
retres:=true;
if (Length(bufstr1)<>Length(bufstr2)) then retres:=false else
              begin
               for i:=1 to Length(bufstr1) do
                  if (Upcase(bufstr1[i])<>Upcase(bufstr2[i])) then begin
                                                                    retres:=false;
                                                                    break;
                                                                   end;
              end;
Equal:=retres;
end;

procedure ShakeSort(var inp:array of String);   // DEN DOULEVEI KALA!
var tmp:String;
    left,right,pont,i:integer;
begin
   left:=Low(inp)+1;
   right:=High(inp)+1;
   pont:=0;
   writeln('LEFT=',left,' RIGHT=',right);
   while (left<right) do begin
                          for i:=right downto left do begin
                                                       if inp[i-1]>inp[i] then begin
                                                                                tmp:=inp[i];
                                                                                inp[i]:=inp[i-1];
                                                                                inp[i-1]:=tmp;
                                                                                pont:=i;
                                                                               end;
                                                      end;
                          left:=pont;
                          for i:=left to right do    begin
                                                       if inp[i]>inp[i+1] then begin
                                                                                tmp:=inp[i];
                                                                                inp[i]:=inp[i+1];
                                                                                inp[i+1]:=tmp;
                                                                                pont:=i;
                                                                               end;
                                                      end;
                          right:=pont; 
                        end;   
end;
 
procedure CleanUpDC;
begin
{RestoreDc(dc2,savedc);
GdiFlush;
ValidateRect(WindowHandles,r);
GetMessage(@AMessage,0,0,0);
TranslateMessage(AMessage);
dispatchMessage(AMessage);
UpdateWindow(WindowHandles);
RedrawWindow(WindowHandles,r,0,RDW_ERASE+RDW_INVALIDATE);    }
end;

function  AmmarUnitVersion:string;
begin
AmmarUnitVersion:=version;
end;

procedure UnitId;
begin
MessageBox (0, 'Using ammarunit version '+version+' made by Ammar Qammaz (ammar@otenet.gr)' , 'Ammar`s Unit', 0 + MB_SYSTEMMODAL);
end;


function MakeMessageBox(title,textw,buttons,icon,system:string):string;
var bufint,bufint2:integer;
begin
bufint:=0;
if Upcase(buttons)='OK' then bufint:=bufint+MB_OK
               else
if Upcase(buttons)='OK/CANCEL' then bufint:=bufint+MB_OKCANCEL
               else
if Upcase(buttons)='YES/NO' then bufint:=bufint+MB_YESNO
               else
if Upcase(buttons)='YES/NO/CANCEL' then bufint:=bufint+MB_YESNOCANCEL
               else
if Upcase(buttons)='ABORT/RETRY/IGNORE' then bufint:=bufint+MB_ABORTRETRYIGNORE
               else
if Upcase(buttons)='RETRY/CANCEL' then bufint:=bufint+MB_RETRYCANCEL
               else
           bufint:=bufint;
if Upcase(icon)='!' then bufint:=bufint+MB_ICONEXCLAMATION
               else
if Upcase(icon)='?' then bufint:=bufint+MB_ICONQUESTION
               else
if Upcase(icon)='X' then bufint:=bufint+MB_ICONSTOP
               else
if Upcase(icon)='I' then bufint:=bufint+MB_ICONINFORMATION
               else
           bufint:=bufint;

if Upcase(system)='SYSTEM' then bufint:=bufint+MB_SYSTEMMODAL
               else
if Upcase(system)='APPLICATION' then bufint:=bufint+MB_TASKMODAL
               else
            bufint:=bufint;
bufint2:=MessageBox (0,Pchar2(textw),Pchar2(title),bufint);
if bufint2=IDYES then MakeMessageBox:='yes' else
if bufint2=IDNO then MakeMessageBox:='no' else
if bufint2=IDOK then MakeMessageBox:='ok' else
if bufint2=IDRETRY then MakeMessageBox:='retry' else
if bufint2=IDCANCEL then MakeMessageBox:='cancel' else
if bufint2=IDABORT then MakeMessageBox:='abort' else
if bufint2=IDIGNORE then MakeMessageBox:='ignore' else
MakeMessageBox:='';
end;


function StripString(thestring:string;thechar:char):string;
var buffres:string;
    i:integer;
begin
buffres:='';
i:=1;
while (i<=Length(thestring)) do
  begin
   if (thestring[i]<>thechar) then buffres:=buffres+thestring[i];
   inc(i);
  end;
StripString:=buffres;
end;

function AnalyseFilename(filenam,mode:string):string;
var i1,i2,i3:integer;
    directory1,filenam1,fileextention1,extention1:string;
begin
i2:=0;
i3:=0;
for i1:=1 to Length(filenam) do if filenam[i1]='\' then i2:=i1;
for i1:=i2 to Length(filenam) do if filenam[i1]='.' then i3:=i1;
directory1:=Copy(filenam,1,i2);
filenam1:=Copy(filenam,i2+1,i3-i2-1);
fileextention1:=Copy(filenam,i2+1,Length(filenam)-i2);
extention1:=Copy(filenam,i3+1,Length(filenam)-i3);
if Upcase(mode)='DIRECTORY' then AnalyseFilename:=directory1 else
if Upcase(mode)='FILENAME' then  AnalyseFilename:=filenam1 else
if Upcase(mode)='EXTENTION' then  AnalyseFilename:=extention1 else
if Upcase(mode)='FILENAME+EXTENTION' then AnalyseFilename:=fileextention1; 
end;

function RunExeProcess(const ExeName, Params: String; const ShowWin: Word; const Wait: Boolean): Handle;
var StartUpInfo : TStartupInfo;
    ProcessInfo : TProcessInformation;
    Cmd         : String;
    managed:boolean;
begin
  if Params = '' then
    Cmd := ExeName else
    Cmd := ExeName + ' ' + Params;
  FillChar(StartUpInfo, SizeOf(StartUpInfo), #0);
  StartUpInfo.cb := SizeOf(StartUpInfo);
  StartUpInfo.dwFlags := STARTF_USESHOWWINDOW; // STARTF_USESTDHANDLES
  StartUpInfo.wShowWindow := ShowWin;
  managed:= CreateProcess( nil, PChar(Cmd), nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PChar(AnalyseFilename(ExeName,'directory')), StartUpInfo, ProcessInfo);
  if not managed then MessageBox (0, 'Could not create process ' , 'Error Creating Process', 0 + MB_ICONEXCLAMATION);
  Result:=ProcessInfo.hProcess;
  if Wait then
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
end;


function RunExeWait (AProgram : STRING; ishidden:boolean) : BOOLEAN;
var
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
begin
  FillChar (StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
 if (ishidden) then
  begin
   StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
   StartupInfo.wShowWindow := SW_HIDE;
  end;
  Result := CreateProcess (
    nil,
    PChar(AProgram),
    nil,
    nil,
    FALSE,
    0,
    nil,
    nil,
    StartupInfo,
    ProcessInfo);
  if Result then
    begin
     WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
     CloseHandle(ProcessInfo.hProcess);
     CloseHandle(ProcessInfo.hThread);
    end;
end;

 
procedure RunEXE(exename,window:string);
var bufint:integer;
    converted:pchar;
begin
if Upcase(window)='HIDDEN' then bufint:=SW_HIDE
               else
if Upcase(window)='MINIMIZED' then bufint:=SW_MINIMIZE
               else
if Upcase(window)='MAXIMIZED' then bufint:=SW_MAXIMIZE
               else
if Upcase(window)='NORMAL' then bufint:=SW_SHOW;
converted:=Pchar2(exename);
winexec(converted,bufint);
end;

procedure OpenFolder(folderpath:string);
begin                                                   //null      //NULL
ShellExecute(WindowHandles, 'open', pchar2(folderpath) , '','', SW_SHOWNORMAL);
end;

function SlowComputer:integer;
begin
SlowComputer:=GetSystemMetrics(SM_SLOWMACHINE);
end;

function Boottype:integer;
begin
boottype:=GetSystemMetrics(SM_CLEANBOOT);
end;

function SetPrivilege(privilegeName: string; enable: boolean): boolean;
var
  tpPrev,
  tp         : PTokenPrivileges;
  token      : THandle;
  dwRetLen   : PDWORD;
begin
  result := False;
  {       //Broken
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, @token);

  tp.PrivilegeCount := 1;  // BROKEN
  if LookupPrivilegeValue(nil, pchar(privilegeName), @tp.Privileges[0].LUID) then
  begin
    if enable then
      tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else
      tp.Privileges[0].Attributes := 0;

    dwRetLen := 0;
    result := AdjustTokenPrivileges(token, False, @tp, SizeOf(tpPrev), tpPrev, dwRetLen);
  end;
  CloseHandle(token);  }
end;
 



procedure ShutDownComputer; 
var shutreserv:dword;
    newwin:text;
begin 
shutreserv:=0; 
assign(newwin,'C:\Windows\System32\shutdown.exe');
{$i-}
reset(newwin);
{$i+}
if Ioresult<>0 then begin
                     SetPrivilege('SeShutdownPrivilege', True);
                     sleep(10000);
                     ExitWindowsEx(EWX_SHUTDOWN+EWX_FORCE{ Or EWX_FORCE},shutreserv);
                     SetPrivilege('SeShutdownPrivilege', False);
                    end else
                    begin
                     close(newwin);
                     RunEXE('"C:\Windows\System32\shutdown.exe" -s','normal');
                    end;
end;

procedure LogOffComputer;
var shutreserv:dword;
begin 
shutreserv:=0; 
//SetPrivilege('SeShutdownPrivilege', True);
ExitWindowsEx(EWX_LOGOFF+EWX_FORCE{ Or EWX_FORCE},shutreserv);
//SetPrivilege('SeShutdownPrivilege', False);
end;

procedure RestartComputer;
var shutreserv:dword;
    newwin:text;
begin
shutreserv:=0;
assign(newwin,'C:\Windows\System32\shutdown.exe');
{$i-}
reset(newwin);
{$i+}
if Ioresult<>0 then begin
                    SetPrivilege('SeShutdownPrivilege', True);
                     sleep(10000);
                     ExitWindowsEx(EWX_REBOOT+EWX_FORCE{ Or EWX_FORCE},shutreserv);
                    SetPrivilege('SeShutdownPrivilege', False);
                    end else
                    begin
                     close(newwin);
                     RunEXE('"C:\Windows\System32\shutdown.exe" -r','normal'); 
                    end;
end;

function Uptime:integer;
begin
Uptime:=GetTickCount;
end;


procedure Delay(delaytime:integer);
//var Ttim,Ktim:integer;
begin
{Ktim:=GetTickCount;
Ktim:=Ktim-1;
repeat
Ttim:=GetTickCount;
if Ktim+delaytime<=Ttim then Ktim:=Ttim;
until ktim=ttim;}
Sleep(delaytime);
end;

procedure NoConsole;
var bufbool:boolean;
begin
bufbool:=FreeConsole;
if bufbool=false then MessageBox (0, 'Could not free console !' , 'Ammar`s Graphic System Error', 0 + MB_ICONEXCLAMATION);
end;

procedure  GetLDate(var theday,thedaywk,themonth,theyear:word);
var timdat:SYSTEMTIME;
begin
GetLocalTime(@timdat);
theday:=timdat.wday;
thedaywk:=timdat.wdayOfWeek;
themonth:=timdat.wmonth;
theyear:=timdat.wyear; 
end;

procedure  GetLTime(var thehour,theminute,thesecond,themillisec:word);
var timdat:SYSTEMTIME;
begin
GetLocalTime(@timdat);
thehour:=timdat.whour;
theminute:=timdat.wminute;
thesecond:=timdat.wsecond;
themillisec:=timdat.wMilliseconds;
end;

function Check_Coordinates(xcoord11,ycoord11,xcoord22,ycoord22:integer):integer;
begin
if xcoord11>=0   then  Check_Coordinates:=0
        else
if ycoord11>=0    then  Check_Coordinates:=0
        else
if xcoord22<=r.right  then  Check_Coordinates:=0
        else
if ycoord22<=r.bottom then  Check_Coordinates:=0
        else
 Check_Coordinates:=1;
end;

function ConvertRGB2HTML(r,g,b:integer):string;
var theresult:string;
begin
theresult:=('#'+HexStr(r,2)+HexStr(g,2)+HexStr(b,2));
ConvertRGB2HTML:=theresult;
end;

function ConvertRGB(r,g,b:integer):integer;
begin
ConvertRGB:=RGB(r,g,b);
end;

function ConvertR(rgb:integer):integer;
begin
ConvertR:=GetRValue(rgb);
end;

function ConvertG(rgb:integer):integer;
begin
ConvertG:=GetGValue(rgb);
end;

function ConvertB(rgb:integer):integer;
begin
ConvertB:=GetBValue(rgb);
end;

procedure SetLineSettings(LineStyle,Pattern,Width:integer);
begin
LineSettings[1]:=LineStyle;
LineSettings[2]:=Pattern;
LineSettings[3]:=Width;
end;

function GetMaxX:integer;
begin
GetMaxX:=r.right;
end;

function GetMaxY:integer;
begin
GetMaxY:=r.bottom;
end;

function TakeTextColor:colorref;
begin
TakeTextColor:=curtextcolor;
end;

procedure TextColor(currentcolor:colorref);
begin
SetTextColor(dc2,currentcolor);
curtextcolor:=currentcolor;
end;

function TextWidth(textu:string):integer;
var sz:size;
begin
GetTextExtentPoint32(dc2,Pchar2(textu),Length(textu), @sz);
TextWidth:=sz.cx;
end;

function TextHeight(textu:string):integer;
var sz:size;
begin
GetTextExtentPoint32(dc2,Pchar2(textu),Length(textu), @sz);
TextHeight:=sz.cy;
end;

procedure GotoXY(x111,y111:integer);
begin
if Check_Coordinates(x111,y111,x111,y111)=0 then  begin
                                                   curycoord:=y111;
                                                   curxcoord:=x111;
                                                  end;
end;

function GetX:integer;
begin
getx:=curxcoord;
end;

function GetY:integer;
begin
gety:=curycoord;
end;

procedure Beep_Sound(frequency,duration:integer);
begin
Beep(frequency,duration);
end;
 



procedure ChangeWindowTitle(textus:string);
begin
SetWindowText(dc2,Pchar2(textus));
end;

procedure Clrscreen;
var x22integer:integer;
begin
refresh;
x22integer:=LineSettings[3];
SetLineSettings(1,1,GetmaxY*2);
DrawLine(0,GetMaxY div 2,GetMaxX,GetMaxY div 2,backgroundcolor);
LineSettings[3]:=x22integer;
curycoord:=0;
curxcoord:=0;
end;

procedure OutTextXY (xcoord,ycoord:integer; text:string);
begin
if Check_Coordinates(xcoord,ycoord,xcoord,ycoord)=0 then begin
TextOut(dc2,xcoord,ycoord,Pchar2(text),Length(text));
                                                         end;
end;

procedure OutText (text:string);
begin
if Check_Coordinates(curxcoord,curycoord,curxcoord,curycoord)=0 then begin
TextOut(dc2,curxcoord,curycoord,Pchar2(text),Length(text));
curycoord:=curycoord+TextHeight(text)+1;
                                                                     end
                                                                     else
                                                                     begin
                                                                     if curycoord>GetMaxY then curycoord:=0
                                                                                else
                                                                     if 0>curycoord then curycoord:=0;

                                                                     if curxcoord>GetMaxX then curxcoord:=0
                                                                                else
                                                                     if 0>curxcoord then curxcoord:=0;

                                                                     end;
end;

procedure OutTextCenter(text:string);
var x11:integer;
begin
x11:=GetMaxX Div 2-TextWidth(text) Div 2;
outtextXY (x11,curycoord,text);
curycoord:=curycoord+TextHeight(text)+1;
end;

procedure SetColor(rgbcolorstated:colorref);
begin
activecolorused:=rgbcolorstated;
end;

function GetColor:colorref;
begin
GetColor:=activecolorused;
end;

function  GetTextFontColor:integer;
begin
GetTextFontColor:=curtextcolor;
end;

function GetBackgroundColor:colorref;
begin
backgroundcolor:=GetBkColor(dc2);
Getbackgroundcolor:=backgroundcolor;
end;

procedure SetBackgroundColor(backcolor:colorref);
begin
SetBkColor(dc2,backcolor);
backgroundcolor:=backcolor;
end;

function GetBackgroundMode:integer;
begin
GetBackgroundMode:=GetBkMode(dc2);
end;

procedure SetBackgroundMode(mode:string);
var integer1:integer;
begin
if Upcase(mode)='OPAQUE' then integer1:=opaque
                  else
if Upcase(mode)='TRANSPARENT' then integer1:=transparent;
SetBkMode(dc2,integer1);
end;

procedure DrawDesktop;
begin
PaintDesktop(dc2);
end;

procedure GetBorders;
begin
GetWindowRect(WindowHandles,@r);
end;

procedure Refresh;
begin{
RedrawWindow(WindowHandles,r,0,RDW_ERASE+RDW_INVALIDATE);
UpdateWindow(WindowHandles);
GetClientRect(WindowHandles,@r);
GdiFlush;      }
end;

procedure PutPixel(xcoord,ycoord:integer; currentcolor:colorref);
//var tmpdc:HDC;
begin
//if Check_Coordinates(xcoord,ycoord,xcoord,ycoord)=0 then
begin
//tmpdc:=BeginPaint(WindowHandles,@ps);
SetPixelV(dc2,xcoord,ycoord,currentcolor);
//EndPaint(WindowHandles,ps);
end;
end;

procedure PutPixelFast(xcoord,ycoord:integer; currentcolor:colorref);
{var lbmi:BITMAPINFO;   }
begin
//if Check_Coordinates(xcoord,ycoord,xcoord,ycoord)=0 then
begin
SetPixelV(dc2,xcoord,ycoord,currentcolor);
{SetDIBitsToDevice(dc2,xcoord,ycoord,1,1,xcoord,ycoord,1,100,0,lbmi,DIB_RGB_COLORS);  }
end;
end;

function GetPixelColor(xcoord,ycoord:integer):colorref;
begin
GetPixelColor:=GetPixel(dc2,xcoord,ycoord);
end;

procedure DrawLine(xcoord,ycoord,xcoord2,ycoord2:integer; currentcolor:colorref);
begin
if Check_Coordinates(xcoord,ycoord,xcoord2,ycoord2)=0 then begin
                                                            pencil:=CreatePen(PS_SOLID,LineSettings[3],currentcolor);
                                                            oldpencil:=SelectObject(dc2,pencil);
                                                            MoveToEx(dc2,xcoord,ycoord,0);
                                                            LineTo(dc2,xcoord2,ycoord2);
                                                            SelectObject(dc2,oldpencil);
                                                            DeleteObject(Pencil);
                                                        end;
end;

procedure DrawLine2(xcoord,ycoord,xcoord2,ycoord2:integer);
begin
DrawLine(xcoord,ycoord,xcoord2,ycoord2,activecolorused);
end;

procedure DrawRectangle(xcoord,ycoord,xcoord2,ycoord2:integer; currentcolor2:colorref);
begin
if Check_Coordinates(xcoord,ycoord,xcoord2,ycoord2)=0 then begin
DrawLine(xcoord,ycoord,xcoord2,ycoord,currentcolor2);
DrawLine(xcoord2,ycoord,xcoord2,ycoord2,currentcolor2);
DrawLine(xcoord2,ycoord2,xcoord,ycoord2,currentcolor2);
DrawLine(xcoord,ycoord2,xcoord,ycoord,currentcolor2);
                                                         end;
end;


procedure DrawRectangle3(xcoord,ycoord,xcoord2,ycoord2,currentcolor2,currentcolor3:integer);
var i:integer;
begin
if Check_Coordinates(xcoord,ycoord,xcoord2,ycoord2)=0 then begin

for i:=xcoord to xcoord2 do DrawLine(i,ycoord,i,ycoord2,currentcolor3);
DrawRectangle(xcoord,ycoord,xcoord2,ycoord2,currentcolor2); 
                                                           end;
end;


{procedure DrawRectangle2(xcoord,ycoord,xcoord2,ycoord2,currentcolor2,currentcolor3:integer);
var bufi:integer;  
begin
if Check_Coordinates(xcoord,ycoord,xcoord2,ycoord2)=0 then begin

for bufi:=xcoord to xcoord2 do DrawLine(bufi,ycoord,bufi,ycoord2,currentcolor3);
DrawRectangle(xcoord,ycoord,xcoord2,ycoord2,currentcolor2); 
                                                           end;
end;}
 
procedure DrawRectangle2(x1,y1,x2,y2:integer; currentcolor2,currentcolor3:COLORREF);
var bufi:integer;
    rct:RECT;
    thebrush,oldbrush:hbrush;
begin
if Check_Coordinates(x1,y1,x2,y2)=0 then begin
                                                            rct.left:=x1;
                                                            rct.right:=x2;
                                                            rct.top:=y1;
                                                            rct.bottom:=y2;


                                                            thebrush:=CreateSolidBrush(currentcolor3);
                                                            oldbrush:=SelectObject(dc2,thebrush);
                                                            FillRect(dc2,rct, thebrush);
                                                            DeleteObject(thebrush);
                                                            SelectObject(dc2,oldbrush);


                                                            DrawRectangle(x1,y1,x2,y2,currentcolor2);
                                                         end;
end;

procedure DrawCircle(xcoord,ycoord,radious:integer; currentcolor:colorref);
begin
if Check_Coordinates(xcoord,ycoord,xcoord,ycoord)=0 then begin
pencil:=CreatePen(PS_SOLID,LineSettings[3],currentcolor);
oldpencil:=SelectObject(dc2,pencil);
arc(dc2,xcoord-radious,ycoord-radious,xcoord+radious,ycoord+radious,xcoord+radious,ycoord+radious,xcoord+radious,ycoord+radious);
SelectObject(dc2,oldpencil);
DeleteObject(Pencil);
                                                         end;
end;

procedure DrawCircle2(xcoord,ycoord,radious:integer);
begin
DrawCircle(xcoord,ycoord,radious,activecolorused);
end;

procedure DrawBackground(backcolor:colorref);
var x222:integer;
begin
x222:=LineSettings[3];
SetLineSettings(1,1,GetmaxY);
backgroundcolor:=backcolor;
SetColor(backcolor);
DrawLine(0,GetMaxY div 2,GetMaxX,GetMaxY div 2,backcolor);
LineSettings[3]:=x222;
end;

procedure save_graph_window;
begin
if hbmScreen<>0 then begin
                      //SelectObject(hdcCompatible,bmretainobj);
                      DeleteObject(hbmScreen); 
                     end;
if hdcCompatible<>0 then DeleteDC(hdcCompatible);

hdcCompatible:=CreateCompatibleDC(dc2);
hbmScreen:=CreateCompatibleBitmap(dc2,GetDeviceCaps(dc2,HORZRES),GetDeviceCaps(dc2,VERTRES));
bmretainobj:=SelectObject(hdcCompatible,hbmScreen);
                                  //GetMAXX,GetMAXY
BitBlt(hdcCompatible,0,0,GetDeviceCaps(dc2,HORZRES),GetDeviceCaps(dc2,VERTRES),dc2,0,0,SRCCOPY);
end;

procedure load_graph_window_xy(x1,y1,x2,y2:integer);
begin                                                              //0,0
if hdcCompatible<>0 then BitBlt(dc2,x1,y1,x2-x1,y2-y1,hdcCompatible,x1,y1,SRCCOPY);
end;

procedure load_graph_window;
begin                                           //GetMAXX,GetMAXY
if hdcCompatible<>0 then BitBlt(dc2,0,0,GetDeviceCaps(dc2,HORZRES),GetDeviceCaps(dc2,VERTRES),hdcCompatible,0,0,SRCCOPY);
end;

procedure delete_graph_window;
begin
if hbmScreen<>0 then
  begin
   //SelectObject(hdcCompatible,retainobj);
   DeleteObject(hbmScreen);
  end;
if hdcCompatible<>0 then DeleteDC(hdcCompatible);
hdcCompatible:=0;
hbmScreen:=0;
end;

function RunWindow:boolean;
var retres:boolean;
begin
retres:=GetMessage(@AMessage,0,0,0);
if retres then
  begin
   TranslateMessage(@AMessage);
   DispatchMessage (@AMessage);
  end;
end;

function WindowProc(Window: HWnd; AMessage2, WParam,LParam: Longint): Longint; stdcall; export;
var paint_dc:hdc;
begin
  WindowProc:=0;
  case AMessage2 of
    wm_keydown : begin vkpressed:=wparam; end;
    wm_activate: begin
                  {if (WParam=0) then begin
                                      save_graph_window; 
                                      InvalidateRgn(Window,windowregion,FALSE); 
                                     end else
                                     begin
                                      load_graph_window;
                                      need_redraw:=true; 
                                      ValidateRgn(Window,windowregion); 
                                     end;     }
                 end;
    WM_SHOWWINDOW:begin         //WA_INACTIVE
                  {  if (WParam=0) then begin
                                        save_graph_window;
                                        InvalidateRgn(Window,windowregion,FALSE); 
                                       end else
                                       begin
                                        load_graph_window;
                                        need_redraw:=true;
                                        ValidateRgn(Window,windowregion);
                                       end;    }
                  end;
    wm_create:  begin
                end; 
    {wm_compacting: begin
                   //The WM_COMPACTING message is sent to all top-level windows when Windows detects more than 12.5 percent of system time over a 30- to 60-second interval is being spent compacting memory. This indicates that system memory is low. }
                  // end; }
  {  wm_erasebkgnd: begin
                      paint_dc:=BeginPaint(Window,@ps);
                      BitBlt(paint_dc,0,0,GetMAXX,GetMAXY,hdcCompatible,0,0,SRCCOPY);
                      EndPaint(Window,ps);
                      need_redraw:=false; 
                   end;        }
     WM_PAINT : begin


                 //InvalidateRect(WindowHandle,NULL,TRUE);
                //_> paint_dc:=BeginPaint(WindowHandle,@ps);
                 //BitBlt(paint_dc,0,0,GetMAXX,GetMAXY,hdcCompatible,0,0,SRCCOPY);
                 //DrawLine(1,1,GetMaxX,GetMaxY,ConvertRGB(round(random(255)),round(random(255)),round(random(255))));
                 //DrawLine(1,5,GetMaxX,GetMaxY-5,ConvertRGB(round(random(255)),round(random(255)),round(random(255))));
                //_> EndPaint(WindowHandle,@ps);

                { NEW DELETE *  }
                 if GetUpdateRect(WindowHandle,@update_rect,false) then need_redraw:=true;
                 if ((update_rect.top-update_rect.bottom<>0) or (update_rect.right-update_rect.left<>0)) then need_redraw:=true;
                                           //NULL
                 ValidateRect(WindowHandle,0);
                 //DrawLine(0,0,GetMaxX,GetMaxY,RGB(random(255),random(255),random(255)));

                 //need_redraw:=true;
                 //set_window_needs_redraw;

                // WindowProc:=0;

               end;


               //end;
   { wm_power : begin end;
    wm_size: begin 
             end;        }
    wm_close: begin
              {DeleteObject(pencil); }
              DestroyWindow(WindowHandles);
              {Exit; }
              end;
    wm_destroy : begin
                   if bufbol=false then begin
                                         DeleteObject(pencil);
                                         PostQuitMessage(0);
                                         Halt;
                                        end;
                 end;
              {Keyboard/Mouse input}
    WM_SETCURSOR :begin
                   mousebtns[1]:=123;
                   mousebtns[2]:=123;
                   mousebtns[3]:=123; 
                  end;
    WM_MOUSEMOVE:begin mousebtns[4]:=123; mousebtns[5]:=0; end;
    WM_LBUTTONUP:begin
                  mousebtns[1]:=2; 
                 end;
    WM_LBUTTONDOWN:begin
                    mousebtns[1]:=1; 
                   end;
    WM_MBUTTONUP:begin
                  mousebtns[2]:=2; 
                 end;
    WM_MBUTTONDOWN:begin
                    mousebtns[2]:=1; 
                   end;
    WM_RBUTTONUP:begin
                  mousebtns[3]:=2; 
                 end;
    WM_RBUTTONDOWN:begin
                    mousebtns[3]:=1; 
                   end;
     522:         begin //0x020A WM_MOUSEWHEEL
                    //MessageBox (0, 'WHEEL' , ' ', 0);
                    if mousebtns[5]<>WParam then
                     begin
                      mousebtns[5]:=WParam;
                      if mousebtns[4]=123 then mousebtns[4]:=0;
                      mousebtns[4]:=mousebtns[4]+WParam;
                     end;
                  end;
    else   begin
            //MessageBox (0, Pchar(Convert2String(AMessage2)) , ' ', 0);
               WindowProc:=DefWindowProc(Window, AMessage2, WParam, LParam);
           end;

  end; 
  //delay(1); // xD  Kanei tin apokrisi tis efarmogis.. Provlimatiki!
 //   WindowProc:=DefWindowProc(Window, AMessage2, WParam, LParam);
end;

procedure flushwindowproc(timses:integer);
var i1:integer;
begin
 for i1:=1 to timses do begin
                        GetMessage(@AMessage,0,0,0{,PM_NOREMOVE});
                        TranslateMessage(AMessage);
                        dispatchMessage(AMessage);
                       end;
end;

procedure ChangeCursorIcon(pathtocur:string);
var cursorhandle:HCURSOR;
begin
{cursorhandle:=LoadImage(0,Pchar(pathtocur),IMAGE_CURSOR,0,0,LR_LOADREALSIZE+LR_LOADFROMFILE);}
if Equal(pathtocur,'ARROW') then cursorhandle:=LoadCursor(0, idc_Arrow) else
if Equal(pathtocur,'APP_STARTING') then cursorhandle:=LoadCursor(0,IDC_APPSTARTING) else
if Equal(pathtocur,'WAIT') then cursorhandle:=LoadCursor(0,IDC_WAIT) else
if Equal(pathtocur,'EMPTY') then cursorhandle:=LoadCursor(0,IDC_ICON) else
if Equal(pathtocur,'MOVE') then cursorhandle:=LoadCursor(0,IDC_SIZE) else
if Equal(pathtocur,'SIZE_NESW') then cursorhandle:=LoadCursor(0,IDC_SIZENESW) else
if Equal(pathtocur,'SIZE_NS') then cursorhandle:=LoadCursor(0,IDC_SIZENS) else
if Equal(pathtocur,'SIZE_NWSE') then cursorhandle:=LoadCursor(0,IDC_SIZENWSE) else
if Equal(pathtocur,'SIZE_WE') then cursorhandle:=LoadCursor(0,IDC_SIZEWE) else
                                  cursorhandle:=LoadCursorFromFile(Pchar2(pathtocur));
currentcursor:=cursorhandle;
SetCursor(cursorhandle); 
end;

procedure FlushMouseButtons;
begin
 mousebtns[1]:=123;
 mousebtns[2]:=123;
 mousebtns[3]:=123;
end;

function MouseButton(buttonid:integer):integer;
begin
if buttonid<=0 then buttonid:=1;
if buttonid>=4 then buttonid:=1;
if mousebtns[buttonid]<>123 then MouseButton:=mousebtns[buttonid] else
begin
 PeekMessage(@AMessage,windowhandles,0,0,PM_REMOVE);
//{Peek}GetMessage(@AMessage,0,0,0{,PM_NOREMOVE});
TranslateMessage(@AMessage);
DispatchMessage(@AMessage);
if mousebtns[buttonid]<>123 then MouseButton:=mousebtns[buttonid] else
                                 MouseButton:=0;
end;
mousebtns[buttonid]:=123;
end;

function MouseScroll:integer;
var i:integer;
begin
if mousebtns[4]<>123 then MouseScroll:=mousebtns[4] else
begin
 PeekMessage(@AMessage,windowhandles,0,0,PM_REMOVE);
//{Peek}GetMessage(@AMessage,0,0,0{,PM_NOREMOVE});
 TranslateMessage(AMessage);
 dispatchMessage(AMessage);
 if mousebtns[4]<>123 then MouseScroll:=mousebtns[4] else
                           MouseScroll:=0;
 //SendMessage(windowhandles,WM_SETCURSOR,0,0);  
end;
mousebtns[4]:=123;
end;

procedure WaitClearMouseButton(buttonid:integer);
begin
 while MouseButton(buttonid)<>0 do begin delay(1); end;
end;

function GetMouseX:integer;
var pt:point;
begin
GetCursorPos(pt);
pt.x:=pt.x-window_start_x;
GetMouseX:=pt.x;
end;

function GetMouseY:integer;
var pt:point;
begin
GetCursorPos(pt);
pt.y:=pt.y-window_start_y;
GetMouseY:=pt.y;
end;

procedure SetMouseXY(xcoord,ycoord:integer);
begin
xcoord:=xcoord+window_start_x;
ycoord:=ycoord+window_start_y;
SetCursorPos(xcoord,ycoord);
end;

function Convert2String(thenumber:integer):string;
var thestring:string;
begin
Str(thenumber,thestring);
Convert2String:=thestring;
end;

function KeyboardLanguage:string;
var bufpc:pchar;
    bufs1,bufs2:string;
begin
bufpc:='        ';
GetKeyboardLayoutName(bufpc); 
bufs1:=String(bufpc);
bufs2:=Copy(bufs1,6,3);
if bufs2='409' then bufs1:='english' else
if bufs2='408' then bufs1:='greek';
KeyboardLanguage:=bufs1;
end;

function GetInternalKeyboardLanguage:string;
begin
GetInternalKeyboardLanguage:=keyblanguage;
end;

procedure SetInternalKeyboardLanguage(lang:string);
begin
if Upcase(lang)='GREEK' then keyblanguage:='greek' else
                             keyblanguage:='english';
end;


function Greek_Tone(str1:string):string;
var bufc1:char;
begin
if Length(str1)>0 then
   begin
    bufc1:=str1[1];
    case bufc1 of
    'á': begin
          bufc1:='Ü';
         end;
    'å': begin
         bufc1:='Ý';
         end;
    'ç': begin
         bufc1:='Þ';
         end;
    'é': begin
         bufc1:='ß';
         end;
    'ï': begin
         bufc1:='ü';
         end;
    'õ': begin
         bufc1:='ý';
         end;
    'ù': begin
         bufc1:='þ';
         end;
    'Á': begin
         bufc1:='¢';
         end;
    'Å': begin
         bufc1:='¸';
         end;
    'Ç': begin
         bufc1:='¹';
         end;
    'É': begin
         bufc1:='º';
         end;
    'Ï': begin
         bufc1:='¼';
         end;
    'Õ': begin
         bufc1:='¾';
         end;
    'Ù': begin
         bufc1:='¿';
         end;
         end;
     str1[1]:=bufc1;

   end;
Greek_Tone:=str1;
end;

function Upcase2(str1:string):string;
var  str2:string;
     bufc1:char;
     i:integer;
begin
str2:='';
for i:=1 to Length(str1) do begin 
                              bufc1:=str1[i];
                              if bufc1='á' then bufc1:='Á' else
                              if bufc1='â' then bufc1:='Â' else
                              if bufc1='ã' then bufc1:='Ã' else
                              if bufc1='ä' then bufc1:='Ä' else
                              if bufc1='å' then bufc1:='Å' else
                              if bufc1='æ' then bufc1:='Æ' else
                              if bufc1='ç' then bufc1:='Ç' else
                              if bufc1='è' then bufc1:='È' else
                              if bufc1='é' then bufc1:='É' else
                              if bufc1='ê' then bufc1:='Ê' else
                              if bufc1='ë' then bufc1:='Ë' else
                              if bufc1='ì' then bufc1:='Ì' else
                              if bufc1='í' then bufc1:='Í' else
                              if bufc1='î' then bufc1:='Î' else
                              if bufc1='ï' then bufc1:='Ï' else
                              if bufc1='ð' then bufc1:='Ð' else
                              if bufc1='ñ' then bufc1:='Ñ' else
                              if bufc1='ó' then bufc1:='Ó' else
                              if bufc1='ô' then bufc1:='Ô' else
                              if bufc1='õ' then bufc1:='Õ' else
                              if bufc1='ö' then bufc1:='Ö' else
                              if bufc1='÷' then bufc1:='×' else
                              if bufc1='ø' then bufc1:='Ø' else
                              if bufc1='ù' then bufc1:='Ù' else
                              if bufc1='ò' then bufc1:='Ó' else
                              if bufc1='ß' then bufc1:='º' else
                              if bufc1='Þ' then bufc1:='¹' else
                              if bufc1='ü' then bufc1:='¼' else
                              if bufc1='þ' then bufc1:='¿' else
                              if bufc1='Ü' then bufc1:='¢' else
                              if bufc1='Ý' then bufc1:='¸' else
                              if bufc1='ý' then bufc1:='¾' else
                                                bufc1:=Upcase(bufc1);
                              str2:=str2+bufc1;
                   end;
Upcase2:=str2;
end;

function key_database(ckey:integer) :string;
var
buffercaps:integer;
database:string;
bufc:char;
begin
buffercaps:=0;
database:='';
// if ckey=vk_capital then database:='CAPS LOCK'  else       //GIA NA ALLAZOUN MIKRA KEFALAIA!

case ckey of
vk_lbutton: database:='LEFT MOUSE';
vk_rbutton : database:='RIGHT MOUSE' ;
vk_mbutton : database:='MIDDLE MOUSE' ;
vk_back : database:='BACKSPACE' ;
vk_tab : database:='TAB' ;
vk_return : database:='ENTER' ;
vk_control : database:='CONTROL' ;
vk_pause : database:='PAUSE' ;
vk_shift : database:='SHIFT' ;
vk_menu : database:='ALT' ;
vk_escape : database:='ESCAPE' ;
vk_space : database:=' ' ;
vk_prior : database:='PAGE UP' ;
vk_next : database:='PAGE DOWN' ;
vk_end : database:='END' ;
vk_home : database:='HOME' ;
vk_left : database:='LEFT ARROW' ;
vk_right : database:='RIGHT ARROW' ;
vk_up : database:='UP ARROW' ;
vk_down : database:='DOWN ARROW' ;
vk_snapshot : database:='PRINTSCREEN' ;
vk_insert : database:='INSERT' ;
vk_delete : database:='DELETE' ;
vk_0 : database:='0' ;
vk_1 : database:='1' ;
vk_2 : database:='2' ;
vk_3 : database:='3' ;
vk_4 : database:='4' ;
vk_5 : database:='5' ;
vk_6 : database:='6' ;
vk_7 : database:='7' ;
vk_8 : database:='8' ;
vk_9 : database:='9' ;
vk_A : database:='A' ;
vk_B : database:='B' ;
vk_C : database:='C' ;
vk_D : database:='D' ;
vk_E : database:='E' ;
vk_F : database:='F' ;
vk_G : database:='G' ;
vk_H : database:='H' ;
vk_I : database:='I' ;
vk_J : database:='J' ;
vk_K : database:='K' ;
vk_L : database:='L' ;
vk_M : database:='M' ;
vk_N : database:='N' ;
vk_O : database:='O' ;
vk_P : database:='P' ;
vk_Q : database:='Q' ;
vk_R : database:='R' ;
vk_S : database:='S' ;
vk_T : database:='T' ;
vk_U : database:='U' ;
vk_V : database:='V' ;
vk_W : database:='W' ;
vk_X : database:='X' ;
vk_Y : database:='Y' ;
vk_Z : database:='Z' ;
vk_NUMPAD0 : database:='0' ;
vk_NUMPAD1 : database:='1' ;
vk_NUMPAD2 : database:='2' ;
vk_NUMPAD3 : database:='3' ;
vk_NUMPAD4 : database:='4' ;
vk_NUMPAD5 : database:='5' ;
vk_NUMPAD6 : database:='6' ;
vk_NUMPAD7 : database:='7' ;
vk_NUMPAD8 : database:='8' ;
vk_NUMPAD9 : database:='9' ;
vk_separator : database:='\' ;
vk_MULTIPLY : database:='*' ;
vk_ADD : database:='+' ;
vk_SUBTRACT : database:='-' ;
vk_DECIMAL : database:='.' ;
vk_DIVIDE : database:='/' ;
vk_F1 : database:='F1' ;
vk_F2 : database:='F2' ;
vk_F3 : database:='F3' ;
vk_F4 : database:='F4' ;
vk_F5 : database:='F5' ;
vk_F6 : database:='F6' ;
vk_F7 : database:='F7' ;
vk_F8 : database:='F8' ;
vk_F9 : database:='F9' ;
vk_F10 : database:='F10' ;
vk_F11 : database:='F11' ;
vk_F12 : database:='F12' ;
vk_scroll : database:='SCROLL LOCK' ;
91 :   database:='WINDOWS' ;
93 :   database:='MENU' ;
187 :   database:='=' ;
189 :   database:='-' ;
186 :  database:=';' ;
188 :  database:=',' ;
190 :  database:='.' ;
191 :  database:='/' ;
192 :  database:='`' ;
219 :  database:='[' ;
220 :  database:='\' ;
221 :  database:=']' ;
222 :  database:=chr(39) ;
vk_numlock : database:='NUM LOCK';
end;


{ else
                        database:=Convert2String(ckey); // GUESSING OPTION :)     }
{buffercaps:=GetKeyState(VK_CAPITAL);}
if (GetKeyState(VK_CAPITAL)=1) {or (GetKeyState(VK_SHIFT)=1) }then buffercaps:=1 else
if (GetKeyState(VK_CAPITAL)=0) {and (GetKeyState(VK_SHIFT)=0)}then buffercaps:=0;
if buffercaps=1 then database:=Upcase(database) else
if buffercaps=0 then database:=lowercase(database);
if Upcase(keyblanguage)='GREEK' then begin
                                       if length(database)=1 then
                                    begin //NEEDS TRANSLATION
                                       bufc:=database[1];
                                       case bufc of  
                                       'A' : database:='Á' ; {kefalaia}
                                       'B' : database:='Â' ;
                                       'C' : database:='Ø' ;
                                       'D' : database:='Ä' ;
                                       'E' : database:='Å' ;
                                       'F' : database:='Ö' ;
                                       'G' : database:='Ã' ;
                                       'H' : database:='Ç' ;
                                       'I' : database:='É' ;
                                       'J' : database:='Î' ;
                                       'K' : database:='Ê' ;
                                       'L' : database:='Ë' ;
                                       'M' : database:='Ì' ;
                                       'N' : database:='Í' ;
                                       'O' : database:='Ï' ;
                                       'P' : database:='Ð' ;
                                       'Q' : database:=':' ;
                                       'R' : database:='Ñ' ;
                                       'S' : database:='Ó' ;
                                       'T' : database:='Ô' ;
                                       'U' : database:='È' ;
                                       'V' : database:='Ù' ;
                                       'W' : database:='Ó' ;
                                       'X' : database:='×' ;
                                       'Y' : database:='Õ' ;
                                       'Z' : database:='Æ'; {mikra}
                                       'a' : database:='á' ;
                                       'b' : database:='â' ;
                                       'c' : database:='ø' ;
                                       'd' : database:='ä' ;
                                       'e' : database:='å' ;
                                       'f' : database:='ö' ;
                                       'g' : database:='ã' ;
                                       'h' : database:='ç' ;
                                       'i' : database:='é' ;
                                       'j' : database:='î' ;
                                       'k' : database:='ê' ;
                                       'l' : database:='ë' ;
                                       'm' : database:='ì' ;
                                       'n' : database:='í' ;
                                       'o' : database:='ï' ;
                                       'p' : database:='ð' ;
                                       'q' : database:=';' ;
                                       'r' : database:='ñ' ;
                                       's' : database:='ó' ;
                                       't' : database:='ô' ;
                                       'u' : database:='è' ;
                                       'v' : database:='ù' ;
                                       'w' : database:='ò' ;
                                       'x' : database:='÷' ;
                                       'y' : database:='õ';
                                       'z' : database:='æ';
                                       end;
                                    end; //NEEDS TRANSLATION

                                     end;
key_database:=database;  
end;

procedure SetLastReadKey_Code(newval:integer);
begin
last_keypress:=newval;
end;

function GetLastReadKey_Code:integer;
begin
GetLastReadKey_Code:=last_keypress;
end;


function ReadKey:string;
var keybuffer:string;
begin
 vkpressed:=608265;
 repeat
 GetMessage(@AMessage,0,0,0);
 TranslateMessage(@AMessage);
 dispatchMessage(@AMessage);
 if vkpressed<>608265 then keybuffer:=key_database(vkpressed);
 until vkpressed<>608265;
 last_keypress:=vkpressed;
 readkey:=keybuffer;
 vkpressed:=608265;
end;

function ReadKeyFast:string;
var keybuffer:string;
begin
 keybuffer:='nokey';
 vkpressed:=608265;
 PeekMessage(@AMessage,windowhandles,0,0,PM_REMOVE);
 TranslateMessage(@AMessage); {+}
 dispatchMessage(@AMessage);
 if vkpressed<>608265 then keybuffer:=key_database(vkpressed); 
if keybuffer<>'nokey' then begin
                            readkeyfast:=keybuffer;
                            last_keypress:=vkpressed;
                           end  else
                           begin
                            readkeyfast:='';
                            last_keypress:=0;
                           end;

 vkpressed:=608265;
end;

function KeyPressed:integer;
begin
vkpressed:=608265;
GetMessage(@AMessage,0,0,0);
TranslateMessage(AMessage);
dispatchMessage(AMessage);
if vkpressed<>608265 then keypressed:=1
         else
      keypressed:=0;
end;

function CheckKeyFast(keyid:integer):integer;
var keypressed:boolean;
    keybuffer:integer;
    BMessage:Msg;
begin
CheckKeyFast:=0;
keypressed:=false;
if PeekMessage(@Bmessage,0,0,0,0) = TRUE then begin // if message waiting then get it
                                              GetMessage(@Bmessage,0,0,0);
                                              TranslateMessage(Bmessage);
                                              DispatchMessage(Bmessage);
                                              end;
keybuffer:=GetAsyncKeyState(keyid);
if keybuffer<>0 then keypressed:=true;
if keypressed=true then CheckKeyFast:=1;
end;

procedure WaitForKey(keyids:string);
var keybuffer2:integer;

begin
keybuffer2:=0;
repeat
if Upcase(ReadKey)=Upcase(keyids) then keybuffer2:=1;
until keybuffer2=1;
end;


procedure WriteText(xcoord1,ycoord1:integer; text:string);
begin
OutTextXY(xcoord1,ycoord1,text);
end;

function ReadText:string;
var bufferstring,bufferstring2,bufs3,laststr:string;
    progress,x,y,i,y2:integer;
    bufferchar:char;
begin
TextColor(curtextcolor);
x:=curxcoord;
y:=curycoord;
bufferstring:='';
bufs3:='';
laststr:='';
progress:=0; 
repeat
repeat
bufs3:=readkeyfast;
sleep(10); 
until bufs3<>''; 
{bufs3:=readkey; }
if Upcase(bufs3)<>'ENTER' then
                begin
 if Upcase(bufs3)='F1' then begin
                             if Upcase(keyblanguage)='ENGLISH' then keyblanguage:='GREEK' else
                                                                    keyblanguage:='ENGLISH';
                            end else
if Upcase(bufs3)='F2' then keybtonos:=1 else
 if Upcase(bufs3)='BACKSPACE' then begin 
                                    bufferstring2:='';
                                    if progress>0 then begin
                                    for i:=1 to Length(bufferstring)-1  do begin
                                                                           bufferchar:=bufferstring[i];
                                                                           bufferstring2:=bufferstring2+bufferchar;
                                                                           end;
                                                       bufferstring:=bufferstring2;
                                                       end;
                                    if progress-1>=0 then progress:=progress-1;
                                    if progress>=0 then begin
                                                        y2:=y+TextHeight(laststr);
                                                        for i:=x to x+TextWidth(laststr) do drawline(i,y,i,y2,backgroundcolor);
                                                        if Length(bufferstring)>0 then laststr:=bufferstring[Length(bufferstring)]
                                                                                else   laststr:='';
                                                        x:=x-TextWidth(laststr);
                                                        end;
                                    end
                                     else
                                    begin 
                                     x:=x+TextWidth(laststr);
                                     outtextXY(x,y,bufs3);
                                     bufferstring:=bufferstring+bufs3;
                                     progress:=progress+1;
                                     laststr:=bufs3;
                                     end;
                end;
until Upcase(bufs3)='ENTER';
ReadText:=bufferstring;
curycoord:=curycoord+TextHeight(bufferstring)+1;
end;

function  ChangeFont:string;
var fon:TChooseFont;{lpchoosefont;}
    lastfont:hfont;
begin
MessageBox(0,'Den doulevei..','',0);
{
fon.lStructSize := sizeof(TChooseFont);
fon.hwndOwner := WindowHandles;
fon.hDC := 0;
fon.lpLogFont := @logfon;
fon.iPointSize := 0;
fon.Flags := cf_ScreenFonts;
fon.rgbColors := 0;
fon.lCustData := 0;
fon.lpfnHook := nil;
fon.lpTemplateName := nil;
fon.hInstance := 0;
fon.lpszStyle := nil;
fon.nFontType := Regular_FontType;
fon.nSizeMin := 0;
fon.nSizeMax := 0;
 ChooseFont (@fon); // then MessageBox (0, 'ChooseFont done', 'Message', 0);
lastfont:=SelectObject(dc2,CreateFontIndirect(@logfon));
DeleteObject(lastfont);
outtextcenter(logfon.lfFaceName);     }
end;

procedure SetFont(fontname,charset:string; sizef,bold,italic,rotation:integer);
var lastfont:hfont;
begin
if Upcase(fontname)='ARIAL' then logfon.lfFaceName:='ARIAL' else
                                 logfon.lfFaceName:=fontname;
if Upcase(charset)='GREEK' then logfon.lfCharSet:=GREEK_CHARSET else
if Upcase(charset)='ARABIC' then logfon.lfCharSet:=ARABIC_CHARSET else
if Upcase(charset)='RUSSIAN' then logfon.lfCharSet:=RUSSIAN_CHARSET else
if Upcase(charset)='ANSI' then logfon.lfCharSet:=ANSI_CHARSET else
if Upcase(charset)='SYMBOL' then logfon.lfCharSet:=SYMBOL_CHARSET else
logfon.lfCharSet:=DEFAULT_CHARSET;
logfon.lfHeight:=sizef;
logfon.lfWeight:=bold;
logfon.lfEscapement:=rotation;
logfon.lfOrientation:=rotation;
if italic=1 then  logfon.lfItalic:=1 else
                  logfon.lfItalic:=0;
lastfont:=SelectObject(dc2,CreateFontIndirect(@logfon));
DeleteObject(lastfont);
end;

function  GetFileName:string;
var filename1:Lpopenfilename;
    ero:dword;
    FileTitle2:PChar;
    ret:boolean;
begin
MessageBox (0, 'Function not implemented fully yet !' , 'Ammarunit ', 0);
{filename1.hInstance:=system.MainInstance;
filename1.hwndowner:=WindowHandles; 
filename1.lpstrFilter:=0;//null; .aps ktl
filename1.lpstrCustomFilter:=0;//null; .aps ktl
filename1.nMaxCustFilter:=100;
filename1.lpstrFile:=FileTitle2;
filename1.nMaxFile:=256;
filename1.lpstrInitialDir:=0 //null;
filename1.lpstrTitle:='Open File';
filename1.lStructSize:=sizeof(Lpopenfilename);

GetMem(FileTitle2,150);
ret:=GetOpenFileName(@filename1);
if ret=true then begin
                  MessageBox (0, 'Success!' , 'Ammarunit ', 0);
                 end;
outtextcenter(filename1.lpstrFile);
FreeMem(FileTitle2,150);

//if ret=false then MessageBox (0, 'Ooops !' , 'Ammarunit ', 0);
CommDlgExtendedError;
ero:=CommDlgExtendedError;
if ero=FNERR_BUFFERTOOSMALL then outtextcenter('BUFFFFFFFER') else
if ero=CDERR_MEMALLOCFAILURE then outtextcenter('MEMALOC') else
if ero=CDERR_MEMLOCKFAILURE	 then outtextcenter('MEMLOCK') else
if ero=CDERR_STRUCTSIZE then outtextcenter('STRUCTSIZE') else
if ero=CDERR_INITIALIZATION	 then outtextcenter('INIT') else
outtextcenter('????????');                                      }
end;



{ Register the Window Class }
{function WinRegister: Boolean;  //OLD WIN REGISTER
var WindowClass: WndClass;
begin
  WindowClass.Style := CS_OWNDC or cs_hRedraw or cs_vRedraw ;
  WindowClass.lpfnWndProc := WndProc(@WindowProc);
  WindowClass.cbClsExtra := 0;
  WindowClass.cbWndExtra := 0;
  WindowClass.hInstance := system.MainInstance;
  WindowClass.hIcon := LoadIcon(0,idi_Application);
  WindowClass.hCursor:=0
  WindowClass.hbrBackground := GetStockObject(BLACK_BRUSH);
  WindowClass.lpszMenuName := nil;
  WindowClass.lpszClassName := Pchar2(AppName);
  Result := RegisterClass(WindowClass) <> 0;
end;     }

function WinRegister: boolean;
var WindowClass: WndClassEx;
begin
  WindowClass.cbSize := sizeof(WndClassEx);
  WindowClass.Style :=  CS_OWNDC or cs_hRedraw or cs_vRedraw {or CS_SAVEBITS	};
  WindowClass.lpfnWndProc := WndProc(@WindowProc);
  WindowClass.cbClsExtra := 0;
  WindowClass.cbWndExtra := 0;
  WindowClass.hInstance := system.MainInstance;
  WindowClass.hIcon := LoadIcon(0,idi_Application);
  WindowClass.hCursor:=0;
  if borderu=10 then WindowClass.hbrBackground := 0 else //TANSPARENCY MODE
                     WindowClass.hbrBackground := GetStockObject(BLACK_BRUSH);

  WindowClass.lpszMenuName := nil;
  WindowClass.lpszClassName := Pchar2(AppName);
  WindowClass.hIconSm:= LoadIcon(0, IDI_APPLICATION);
  Result := RegisterClassEx(WindowClass) <> 0;
 
end;  

{ Create the Window Class }
function WinCreate: HWnd;                    {ws_OverlappedWindow+sima_a-tech    cw_UseDefault}
var hWindow: HWnd;
begin

//if ((windowxu=0) and (windowyu=0)) then begin end;
if windowxu=0 then windowxu:=GetSystemMetrics(SM_CXSCREEN)+GetSystemMetrics(SM_CXBORDER);
if windowyu=0 then windowyu:=GetSystemMetrics(SM_CYSCREEN)+GetSystemMetrics(SM_CYBORDER);
borderu2:=0;
if borderu=10 then borderu:=WS_POPUP+WS_EX_TRANSPARENT else
if borderu=0 then borderu:=WS_POPUP else
if borderu=1 then borderu:=WS_BORDER else
if borderu=3 then borderu:=WS_THICKFRAME else
if borderu=4 then begin
                    borderu2:=WS_EX_TRANSPARENT;
                    borderu:=WS_POPUP;
                  end else
if borderu=5 then begin
                   borderu2:=WS_EX_TOOLWINDOW;
                   borderu:=WS_POPUP;
                  end else
if borderu=6 then begin
                   borderu:=WS_BORDER+ws_maximize;
                  end else
if borderu=7 then begin
                   borderu2:=WS_EX_TRANSPARENT;
                   borderu:=WS_POPUP+ws_maximize;
                  end;
borderu:=borderu+WS_VISIBLE;
hWindow:=CreateWindowEx(borderu2,Pchar2(AppName),Pchar2(Appname),borderu,0,0,windowxu,windowyu, 0, 0, system.MainInstance,nil);
WindowHandles:=hWindow;
if WindowHandles <> 0 then begin
                            SetActiveWindow(hWindow);
                            SetForegroundWindow(hWindow);
                            ShowWindow(WindowHandles,SW_SHOW);
                            UpdateWindow(WindowHandles); 
                          end;
Result:=hWindow;
end;

procedure WindowMove(x21,y21:integer);
begin
window_start_x:=x21;
window_start_y:=y21;
MoveWindow(WindowHandles,x21,y21,GetMaxX,GetMaxY,true);
end;

function GetWindowStartX:integer;
begin
GetWindowStartX:=window_start_x;
end;

function GetWindowStartY:integer;
begin
GetWindowStartY:=window_start_y;
end;

function InitGraph(text:string; windowx,windowy,border:integer):integer;
begin
appname:=text;
windowxu:=windowx;
windowyu:=windowy;
borderu:=border;
SetLineSettings(1,1,1);
if not WinRegister then begin
                           MessageBox (0, 'Could not register new window' , 'Ammar`s Graphic System Error', 0 + MB_ICONEXCLAMATION);
                           Halt;
                        end;
WindowHandles:=WinCreate;
if longint(WindowHandles)=0 then begin
                               MessageBox (0, 'Could not register new window' , 'Window Creation failed', 0 + MB_ICONEXCLAMATION);
                               Halt;
                             end;
//Activate Window
//dc2:=GetDc(WindowHandles);
GetWindowRgn(WindowHandles,windowregion);
dc2:=GetDC(WindowHandles); //GetDcEx(WindowHandles,windowregion,DCX_WINDOW or DCX_VALIDATE);

ShowWindow(WindowHandles,SW_SHOW);       //Show The Window
//SetActiveWindow(WindowHandles);
//SetForegroundWindow(WindowHandles);      //Slightly Higher Priority
//SetFOcus(WindowHandles);                 //Set Keyboard Focus To The Window
UpdateWindow(WindowHandles);
SetBackgroundColor(RGB(0,0,0));
//Initialize Graph
SetLineSettings(1,1,1);
GetWindowRect(WindowHandles,@r);
SetBackgroundMode('TRANSPARENT');
TextColor(RGB(255,255,255));
savedc:=SaveDC; 
// NEW SVISIMO* SetROP2(dc2,R2_COPYPEN);

 //SelectClipRgn(dc2,windowregion); axristo..

hbmScreen:=0;
hdcCompatible:=0;

//Mouse
mousebtns[1]:=123;
mousebtns[2]:=123;
mousebtns[3]:=123;
currentcursor:=LoadCursor(0,idc_Arrow); {Proetoimasia tou Mouse}
SetCursor(currentcursor); 
//Return Success
initgraph:=1;
end;

function  GraphDcUsed:integer;
begin
GraphDcUsed:=dc2;
end;

function  Windowhandle:integer;
begin
Windowhandle:=WindowHandles;
end;

procedure CloseGraph;
begin
CleanUpDC;
ReleaseDc(WindowHandles,dc2);
ReleaseDc(WindowHandles,dc);
DestroyWindow(WindowHandles);
dc:=0;
dc2:=0;
windowxu:=0;
windowyu:=0;
borderu:=0;
borderu2:=0;
savedc:=0;
curxcoord:=0;
curycoord:=0;
vkpressed:=0;
pencil:=0;
bufbol:=true; 
mousebtns[1]:=0;
mousebtns[2]:=0;
mousebtns[3]:=0;
windowhandles:=0; 
window_start_x:=0;
window_start_y:=0;
end;


end.

