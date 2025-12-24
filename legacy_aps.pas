unit legacy_aps;

interface
procedure LoadAps_Internal (bufstr3:string);
function Save_RAW_File_Internal(theaps,fileout:string):boolean;
function Load_RAW_File_Internal(theaps,fileout:string):boolean;

implementation 
uses windows,apsfiles;
var fileused:text;
    memory:array[1..15] of string;
    memoryinteger:array[1..15] of integer;
    ctcolor,z:integer;


procedure seperate_words (bufstr4:string);
var buffers:array [1..5] of integer;
    zcount:integer;
    s3:string;
    buf:array[1..100]of char;
begin
   for zcount:=1 to 15 do begin
                     memory[zcount]:='';
                     memoryinteger[zcount]:=0;
                     end;
   zcount:=0;
   setlength (s3,1);
   buffers[2]:=Length(bufstr4);
   for zcount:=1 to Length(bufstr4) do
                              begin
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
  if buf[buffers[4]]='.' then buffers[3]:=buffers[3]+1
          else
  if buf[buffers[4]]=')' then buffers[3]:=buffers[3]+1;

  if buffers[5]=buffers[3] then
  begin
  if buffers[3]<16 then memory[buffers[3]]:=memory[buffers[3]]+buf[buffers[4]]
                                else
                               begin
                          {TOO COMPLICATED}
                           buffers[3]:=16
                                end;
  end;

  if buffers[4]=buffers[2] then buffers[3]:=16;
  
 until buffers[3]=16;
for zcount:=1 to 15 do begin
                  val (memory[zcount],buffers[1],buffers[5]);
                  if buffers[5]=0 then memoryinteger[zcount]:=buffers[1]
                                else
                            memoryinteger[zcount]:=0;
                  end;
end; 

procedure ApsDecode;
var done:boolean;
    bufc:char; 
    bufstr:string;
    x,y:integer;
begin
done:=false;
while done=false do     begin
                          bufstr:='';
                          repeat
                           read(fileused,bufc);
                           if bufc='[' then bufstr:='' else
                           if bufc=']' then begin end else
                           if bufc='}' then begin
                                             bufstr:='trialala';
                                             bufc:=']';
                                             done:=true;
                                            end else
                           bufstr:=bufstr+bufc;
                          until bufc=']';
                          seperate_words(bufstr);
                          if Upcase(memory[1])='BK' then aps_set_internal_options(3,RGB(memoryinteger[2],memoryinteger[3],memoryinteger[4])) 
                                      else
                          if Upcase(memory[1])='LENGTH' then aps_set_internal_options(1,memoryinteger[2])
                                      else
                          if Upcase(memory[1])='WIDTH' then begin
                                                              aps_set_internal_options(2,memoryinteger[2]);
                                                              for x:=GetLoadingX+1 to GetLoadingX+aps_get_internal_options(1) do
                                                              for y:=GetLoadingY+1 to GetLoadingY+aps_get_internal_options(2) do
                                                              SetApsPixelColor(x,y,aps_get_internal_options(3));
                                                            end
                                      else
                          if Upcase(memory[1])='C' then ctcolor:=RGB(memoryinteger[2],memoryinteger[3],memoryinteger[4])
                                      else
                          if Upcase(memory[1])='P' then SetApsPixelColor(GetLoadingX+memoryinteger[2],GetLoadingY+memoryinteger[3],ctcolor)
                                      else
                          if Upcase(memory[1])='}' then done:=true;

                          if eof(fileused)=true then done:=true;
                        end;
end;

procedure Aps1Decode;
var done,done2:boolean;
    bufc2,bufc3,next:char;
    numb:integer;
    stbuf:string;
    x,y,i:integer;
begin
done:=false;
while done=false do     begin
                         read(fileused,bufc2);
                         if bufc2='[' then
                         begin
                          stbuf:='';
                          repeat
                           read(fileused,bufc2);
                           stbuf:=stbuf+bufc2;
                          until bufc2=']';
                          seperate_words(stbuf);
                          if Upcase(memory[1])='BK' then aps_set_internal_options(3,RGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]))
                           else
                          if Upcase(memory[1])='LENGTH' then aps_set_internal_options(1,memoryinteger[2])
                           else
                          if Upcase(memory[1])='WIDTH' then begin
                                                              aps_set_internal_options(2,memoryinteger[2]);
                                                              for x:=GetLoadingX+1 to GetLoadingX+aps_get_internal_options(1) do
                                                              for y:=GetLoadingY+1 to GetLoadingY+aps_get_internal_options(2) do
                                                              SetApsPixelColor(x,y,aps_get_internal_options(3));
                                                            end;
                          end else
                          if bufc2='&' then done:=true;
                         end;
done:=false;
repeat
if next=' ' then read(fileused,bufc2)
else bufc2:=next;
next:=' ';
if bufc2='c' then begin
                   stbuf:='';
                   done2:=false;
                   numb:=2;
                   memoryinteger[2]:=0;
                   memoryinteger[3]:=0;
                   memoryinteger[4]:=0;
                   repeat
                    read(fileused,bufc2);
                    if bufc2=',' then begin
                                      Val(stbuf,memoryinteger[numb],i);
                                      numb:=numb+1;
                                      stbuf:='';
                                     end
                                       else
                    if (bufc2='c') or (bufc2='p') then begin
                                                        done2:=true;
                                                        next:=bufc2;
                                                       end
                                       else
                    if bufc2='}' then begin
                                       done:=true;
                                       done2:=true;
                                      end
                                        else
                    if bufc2='1' then stbuf:=stbuf+'1' else
                    if bufc2='2' then stbuf:=stbuf+'2' else
                    if bufc2='3' then stbuf:=stbuf+'3' else
                    if bufc2='4' then stbuf:=stbuf+'4' else
                    if bufc2='5' then stbuf:=stbuf+'5' else
                    if bufc2='6' then stbuf:=stbuf+'6' else
                    if bufc2='7' then stbuf:=stbuf+'7' else
                    if bufc2='8' then stbuf:=stbuf+'8' else
                    if bufc2='9' then stbuf:=stbuf+'9' else
                    if bufc2='0' then stbuf:=stbuf+'0' else begin end;
                   until done2=true;
                   Val(stbuf,memoryinteger[numb],i);  
                   ctcolor:=RGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]);
                  end else
if bufc2='p' then begin
                   stbuf:='';
                   done2:=false;
                   numb:=2;
                   memoryinteger[2]:=0;
                   memoryinteger[3]:=0; 
                   repeat
                    read(fileused,bufc2);
                    if bufc2=',' then begin
                                      Val(stbuf,memoryinteger[numb],i); 
                                      numb:=numb+1;
                                      stbuf:='';
                                     end
                                       else
                    if (bufc2='c') or (bufc2='p') then begin
                                                        done2:=true;
                                                        next:=bufc2;
                                                       end
                                       else
                    if bufc2='}' then begin
                                       done:=true;
                                       done2:=true
                                      end
                                       else
                    if bufc2='1' then stbuf:=stbuf+'1' else
                    if bufc2='2' then stbuf:=stbuf+'2' else
                    if bufc2='3' then stbuf:=stbuf+'3' else
                    if bufc2='4' then stbuf:=stbuf+'4' else
                    if bufc2='5' then stbuf:=stbuf+'5' else
                    if bufc2='6' then stbuf:=stbuf+'6' else
                    if bufc2='7' then stbuf:=stbuf+'7' else
                    if bufc2='8' then stbuf:=stbuf+'8' else
                    if bufc2='9' then stbuf:=stbuf+'9' else
                    if bufc2='0' then stbuf:=stbuf+'0' else begin end; 
                   until done2=true;
                   Val(stbuf,memoryinteger[numb],i);  
                   SetApsPixelColor(GetLoadingX+memoryinteger[2],GetLoadingY+memoryinteger[3],ctcolor);
                  end else
if bufc2='}' then begin
                  done:=true;
                  end;
if eof(fileused)=true then done:=true;
until done=true;
end;

procedure Aps2Decode;
var done,done2:boolean;
    bufc2,bufc3,next:char;
    numb{,ers,colrs,iis,ps}:integer;
    stbuf:string;
    x,y,i:integer;
begin
done:=false;
{ers:=0;
colrs:=0;
iis:=0;
ps:=0;    }
while done=false do     begin
                         read(fileused,bufc2);
                         if bufc2='[' then
                         begin
                          stbuf:='';
                          repeat
                           read(fileused,bufc2);
                           stbuf:=stbuf+bufc2;
                          until bufc2=']';
                          seperate_words(stbuf);
                          if Upcase(memory[1])='BK' then aps_set_internal_options(3,RGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]))
                           else
                          if Upcase(memory[1])='LENGTH' then aps_set_internal_options(1,memoryinteger[2])
                           else
                          if Upcase(memory[1])='WIDTH' then begin
                                                              aps_set_internal_options(2,memoryinteger[2]);
                                                              for x:=GetLoadingX+1 to GetLoadingX+aps_get_internal_options(1) do
                                                              for y:=GetLoadingY+1 to GetLoadingY+aps_get_internal_options(2) do
                                                              SetApsPixelColor(x,y,aps_get_internal_options(3));
                                                            end;
                          end else
                          if bufc2='&' then done:=true;
                         end;
done:=false;  
next:=' ';
repeat
if next=' ' then read(fileused,bufc2)
else bufc2:=next;
next:=' ';
if bufc2='c' then begin
                   stbuf:='';
                   done2:=false;
                   numb:=2;
                   memoryinteger[2]:=0;
                   memoryinteger[3]:=0;
                   memoryinteger[4]:=0;
                   repeat
                    read(fileused,bufc2);
                    if bufc2=',' then begin
                                      Val(stbuf,memoryinteger[numb],i);
                                      numb:=numb+1;
                                      stbuf:='';
                                     end
                                      else
                    if (bufc2='c') or (bufc2='p') or (bufc2='i') then begin
                                                                      done2:=true;
                                                                      next:=bufc2;
                                                                      end 
                                       else
                    if bufc2='}' then begin
                                       done:=true;
                                       done2:=true;
                                      end
                                        else
                    if bufc2='1' then stbuf:=stbuf+'1' else
                    if bufc2='2' then stbuf:=stbuf+'2' else
                    if bufc2='3' then stbuf:=stbuf+'3' else
                    if bufc2='4' then stbuf:=stbuf+'4' else
                    if bufc2='5' then stbuf:=stbuf+'5' else
                    if bufc2='6' then stbuf:=stbuf+'6' else
                    if bufc2='7' then stbuf:=stbuf+'7' else
                    if bufc2='8' then stbuf:=stbuf+'8' else
                    if bufc2='9' then stbuf:=stbuf+'9' else
                    if bufc2='0' then stbuf:=stbuf+'0' else begin 
                                                            end; 
                   until done2=true;
                   Val(stbuf,memoryinteger[numb],i);   
                   ctcolor:=RGB(memoryinteger[2],memoryinteger[3],memoryinteger[4]);
                   //colrs:=colrs+1;
                  end else
if bufc2='p' then begin
                   stbuf:='';
                   done2:=false;
                   numb:=2;
                   memoryinteger[2]:=0;
                   memoryinteger[3]:=0; 
                   repeat
                    read(fileused,bufc2);
                    if bufc2=',' then begin
                                      Val(stbuf,memoryinteger[numb],i); 
                                      numb:=numb+1;
                                      stbuf:='';
                                     end
                                      else
                    if (bufc2='c') or (bufc2='p') or (bufc2='i') then begin
                                                                      done2:=true;
                                                                      next:=bufc2;
                                                                      end 
                                       else
                    if bufc2='}' then begin
                                       done:=true;
                                       done2:=true
                                      end
                                       else
                    if bufc2='1' then stbuf:=stbuf+'1' else
                    if bufc2='2' then stbuf:=stbuf+'2' else
                    if bufc2='3' then stbuf:=stbuf+'3' else
                    if bufc2='4' then stbuf:=stbuf+'4' else
                    if bufc2='5' then stbuf:=stbuf+'5' else
                    if bufc2='6' then stbuf:=stbuf+'6' else
                    if bufc2='7' then stbuf:=stbuf+'7' else
                    if bufc2='8' then stbuf:=stbuf+'8' else
                    if bufc2='9' then stbuf:=stbuf+'9' else
                    if bufc2='0' then stbuf:=stbuf+'0' else begin end; 
                   until done2=true;
                   Val(stbuf,memoryinteger[numb],i);  
                   //ps:=ps+1;
                   SetApsPixelColor(GetLoadingX+memoryinteger[2],GetLoadingY+memoryinteger[3],ctcolor);
                  end else
if bufc2='i' then begin 
                   done2:=false;
                   numb:=2;
                   memoryinteger[2]:=0;
                   memoryinteger[3]:=0; 
                   repeat
                    read(fileused,bufc2);
                    if bufc2=',' then numb:=numb+1  else
                    if (bufc2='c') or (bufc2='p') or (bufc2='i') then begin
                                                                       done2:=true;
                                                                       next:=bufc2; 
                                                                      end 
                                       else
                    if bufc2='}' then begin
                                       done:=true;
                                       done2:=true; 
                                      end;
                    if (done2=false) and (bufc2<>',') then
                    memoryinteger[numb]:=memoryinteger[numb]+ord(bufc2);
                   until done2=true;   
                   SetApsPixelColor(GetLoadingX+memoryinteger[2],GetLoadingY+memoryinteger[3],ctcolor);
                   //iis:=iis+1;
                  end else
if bufc2='}' then begin
                   done:=true;
                  end;{ else
                  begin
                   ers:=ers+1; 
                  end;  }
if eof(fileused)=true then done:=true;
until done=true;  
end;


procedure LoadAps_Internal (bufstr3:string);
const fopen=1;
      fclose=2;
      fid=3;
      sopen=4;
      sclose=5;
      smain=6;
var charcollect:array[1..40]of char;
    bufc:char;
    job,i,x,y:integer;
    bufstr,result,foldertmp:string;
begin
GetDir(0,foldertmp);
if foldertmp[Length(foldertmp)]<>'\' then foldertmp:=foldertmp+'\'; 
assign (fileused,foldertmp+bufstr3+'.aps');
{$i-}
reset(fileused);
{$i+}
if Ioresult <> 0 then begin
                       MessageBox (0, Pchar('Could not open '+bufstr3+'.aps') , 'APSFiles Error', 0);
                      //   MakeMessageBox('Error',Pchar('This error might be caused by the patch to apsfiles! ('+foldertmp+bufstr3+'.aps)'),'OK','!','application');
                      end
                     else
if Ioresult=0 then    begin
i:=0;
repeat
 read (fileused,bufc);
  if bufc='{' then job:=fopen
              else
  if bufc='}' then job:=fclose
              else
  if bufc='*' then job:=fid
              else
  if bufc='&' then job:=smain
              else
  if bufc='[' then job:=sopen
              else
  if bufc=']' then job:=sclose
              else
             job:=0;
                              if job<>0 then begin
                                                if job=fopen then begin end
                                                           else
                                                if job=fclose then i:=10000 {Simatodotei to telos tou LoadAps}
                                                           else
                                                if job=fid then begin
                                                                       bufc:='*';
                                                                       while bufc<>'=' do read (fileused,bufc); {Eftasa sto id=}
                                                                       for x:=1 to 40 do charcollect[x]:='*';
                                                                       x:=0;
                                                                       repeat  {Mazevei oti diavazei sto charcollect}
                                                                        x:=x+1;
                                                                        read(fileused,bufc);
                                                                        if bufc<>'*' then charcollect[x]:=bufc else x:=100;
                                                                       until x=100;
                                                                       x:=0;
                                                                       bufstr:='';
                                                                       repeat {Metaferei tis plirofories tou charcollect sto bufstr}
                                                                        x:=x+1;
                                                                        if charcollect[x]<>'*' then bufstr:=bufstr+charcollect[x] else x:=100;
                                                                       until x=100; 
                                                                       if bufstr='aps' then begin
                                                                                             ApsDecode;
                                                                                             job:=fclose; 
                                                                                             i:=10000;
                                                                                            end
                                                                                   else
                                                                       if bufstr='aps1' then begin 
                                                                                              Aps1Decode; 
                                                                                              job:=fclose; 
                                                                                              i:=10000;
                                                                                             end
                                                                                   else
                                                                       if bufstr='aps2' then begin
                                                                                              Aps2Decode;
                                                                                              job:=fclose; 
                                                                                              i:=10000;
                                                                                             end
                                                                                   else
                                                                                begin 
                                                                                  MessageBox (0, Pchar('Could not open file '+bufstr3+'.aps,it contains an invalid id') , 'APSFiles Error', 0);
                                                                                 close (fileused);
                                                                                 i:=10000;
                                                                                end; 
                                                                   end
                                                                  else
                                                  if job=sopen then begin 
                                                                    end;
                                                     end;
                    until i=10000;
                   close(fileused);
                  end;

 

end;







function Save_RAW_File_Internal(theaps,fileout:string):boolean;
var x,y,ax,ay,bx,by:integer;
    a:byte;
    fileused:text;
    retres:boolean;
begin
 retres:=false;
 ax:=GetApsInfo(theaps,'X1');
 ay:=GetApsInfo(theaps,'Y1');
 bx:=GetApsInfo(theaps,'X2');
 by:=GetApsInfo(theaps,'Y2');
 assign(fileused,fileout);
  {$i-}
    rewrite(fileused);
  {$i+}
  if Ioresult=0 then
    begin
     writeln(fileused,bx-ax);
     writeln(fileused,by-ay);
     writeln(fileused,3);
     for y:=ay to by do
      for x:=ax to bx do
       begin
         a:=GetRValue(GetApsPixelColor(x,y));
         write(fileused,a);
         a:=GetGValue(GetApsPixelColor(x,y));
         write(fileused,a);
         a:=GetBValue(GetApsPixelColor(x,y));
         write(fileused,a);
       end;
     close(fileused);
     retres:=true;
    end else
    begin end;
Save_RAW_File_Internal:=retres;
end;


function Load_RAW_File_Internal(theaps,fileout:string):boolean;
var x,y,ax,ay,bx,by:integer;
    r,g,b:byte;
    fileused:text;
    retres:boolean;
begin
 retres:=false;
 assign(fileused,fileout);
  {$i-}
    reset(fileused);
  {$i+}
  if Ioresult=0 then
    begin
     
      readln(fileused,bx);
      bx:=bx+GetLoadingX;
      readln(fileused,by);
      by:=by+GetLoadingy;
      ax:=GetLoadingX;
      ay:=GetLoadingY;

      readln(fileused,r);
     for y:=ay to by do
      for x:=ax to bx do
       begin 
         read(fileused,r);
         read(fileused,g);
         read(fileused,b);
         SetApsPixelColor(x,y,RGB(r,g,b));
       end;
     DefineAps(theaps,ax,ay,bx,by);
     close(fileused);
     retres:=true;
    end else
    begin end;
Load_RAW_File_Internal:=retres;
end;

begin
end.
