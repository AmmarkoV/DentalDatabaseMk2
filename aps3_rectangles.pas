unit aps3_rectangles;
interface
Type

 TRGB=
 Record
   RC,GC,BC:byte;
 End;
 

 
function PackRectangle_Old(x1,y1,x2,y2:word; linesize:byte; filled:boolean):string;
function UnPackRectangle_Old(inptstr:string; var x1,y1,x2,y2:word; linesize:byte; filled:boolean);
function PackRectangle(x1,y1,x2,y2:word; linesize:byte; filled:boolean):string;


implementation 
uses ammarunit,apsfiles,aps3,aps3_lowlevel;
const
      SAME_X_PIXEL=128;
      SAME_Y_PIXEL=129;
      SAME_X_PIXEL_NEIGHBOR=130;
      SAME_Y_PIXEL_NEIGHBOR=131;
      NEIGHBOR_PIXEL=132;
      REPEAT_PIXEL_X=133;
      REPEAT_PIXEL_Y=134;
      RECTANGLE_FILLED_SMALL=135;
      RECTANGLE_FILLED_BIG=136;
      RECTANGLE_NOFILL_SMALL=137;
      RECTANGLE_NOFILL_BIG=138;
      REAL_RECTANGLE_SMALL=139;
      REAL_RECTANGLE_BIG=140;
      FILL=141;
      SINGLE_FILL=142;
      REPEAT_PIXEL_X_SMALL=143;
      REPEAT_PIXEL_Y_SMALL=144; 
      RECTANGLE_FILLED_SMALL_GUESSED=145;

      RGB_CODE=150;
 
      FRAME=204;
      DUPLICATE_REGION=205;


      LINE_CODE=128;
      RECTANGLE_CODE=129;
      SIZE_RECTANGLE_CODE=6;
      TRIANGLE_CODE=130;
      POLYLINE_CODE=131;
      RECTANGLE_SIZEFILLED_CODE=132;
      RECTANGLE_NOSIZEFILLED_CODE=133;
      REAL_RECTANGLE_NOSIZEFILLED_CODE=134; 
      FILL_CODE=135;
      // COLORS START


      var i:integer;

function PackRectangle_Old(x1,y1,x2,y2:word; linesize:byte; filled:boolean):string;
var retres:string;
    override_pixels:boolean; // Oxi default pixel setup dld 2 bytes x1 , 2 bytes y1 , 2 bytes x2 , 2 bytes y2
    byt1,byt2:byte;
begin
retres:='';
override_pixels:=false;
if ((linesize=0)and(filled=false)) then begin
                                             writeln('Unsupported (Rectangle with no size and no fills'); 
                                        end else
if ((linesize>0)and(filled=false)) then begin 
                                         retres:=retres+chr(RECTANGLE_CODE)+chr(linesize); 
                                        end else
if ((linesize>0)and(filled=true)) then begin
                                         retres:=retres+chr(RECTANGLE_SIZEFILLED_CODE)+chr(linesize);
                                        end else
if ((linesize=0)and(filled=true)and( (x2-x1)=(y2-y1) )) then //REAL RECTANGLE THETOUME X,Y KAI AKMH MONO.. GLYTWNOUME 2 BYTES..
                                            begin
                                              retres:=retres+chr(REAL_RECTANGLE_NOSIZEFILLED_CODE);
                                              word_2_bytes(x1,byt1,byt2);
                                              retres:=retres+chr(byt1)+chr(byt2); //X
                                              word_2_bytes(y1,byt1,byt2);
                                              retres:=retres+chr(byt1)+chr(byt2); //Y
                                              word_2_bytes(x2-x1,byt1,byt2);
                                              retres:=retres+chr(byt1)+chr(byt2); //AKMHv
                                              override_pixels:=true; // Thesame monoi mas ta pixels..
                                            end else
if ((linesize=0)and(filled=true)) then begin
                                         retres:=retres+chr(RECTANGLE_NOSIZEFILLED_CODE);
                                       end;
if (not override_pixels)
 then begin
       word_2_bytes(x1,byt1,byt2);
       retres:=retres+chr(byt1)+chr(byt2);
       word_2_bytes(y1,byt1,byt2);
       retres:=retres+chr(byt1)+chr(byt2);
       word_2_bytes(x2,byt1,byt2);
       retres:=retres+chr(byt1)+chr(byt2);
       word_2_bytes(y2,byt1,byt2);
       retres:=retres+chr(byt1)+chr(byt2); 
      end;

PackRectangle_Old:=retres;
end;


function UnPackRectangle_Old(inptstr:string; var x1,y1,x2,y2:word; linesize:byte; filled:boolean);
var retres:string;
    override_pixels:boolean; // Oxi default pixel setup dld 2 bytes x1 , 2 bytes y1 , 2 bytes x2 , 2 bytes y2
    guidebyte,read_place,byt1,byt2:byte;
begin
retres:='';
override_pixels:=false;
read_place:=1;
guidebyte:=ord(inptstr[read_place]);

if (guidebyte=RECTANGLE_CODE) then begin
                                     filled:=false;
                                     read_place:=read_place+1;
                                     linesize:=ord(inptstr[read_place]); 
                                   end else
if (guidebyte=RECTANGLE_SIZEFILLED_CODE) then
                                   begin
                                     filled:=true;
                                     read_place:=read_place+1;
                                     linesize:=ord(inptstr[read_place]); 
                                   end else
if (guidebyte=REAL_RECTANGLE_NOSIZEFILLED_CODE) then
                                   begin
                                     override_pixels:=true;
                                     linesize:=0;
                                     filled:=true;
                                     read_place:=read_place+1; byt1:=ord(inptstr[read_place]);
                                     read_place:=read_place+1; byt2:=ord(inptstr[read_place]); // X
                                     bytes_2_word(byt1,byt2,x1);
                                     read_place:=read_place+1; byt1:=ord(inptstr[read_place]);
                                     read_place:=read_place+1; byt2:=ord(inptstr[read_place]); // Y
                                     bytes_2_word(byt1,byt2,y1);
                                     read_place:=read_place+1; byt1:=ord(inptstr[read_place]);
                                     read_place:=read_place+1; byt2:=ord(inptstr[read_place]); // AKMH
                                     bytes_2_word(byt1,byt2,y2);
                                     x2:=x1+y2; //x2 = x1 + AKMH
                                     y2:=y1+y2; //y2 = y1 + AKMH
                                   end else
if (guidebyte=RECTANGLE_NOSIZEFILLED_CODE) then
                                   begin
                                     filled:=true;
                                   //  read_place:=read_place+1;
                                     linesize:=0;
                                   end else
                                   begin
                                    writeln('Unsupported (Rectangle with no size and no fills');
                                   end;

 
if (not override_pixels)
 then begin
       read_place:=read_place+1; byt1:=ord(inptstr[read_place]);
       read_place:=read_place+1; byt2:=ord(inptstr[read_place]); // X1
       bytes_2_word(byt1,byt2,x1);

       read_place:=read_place+1; byt1:=ord(inptstr[read_place]);
       read_place:=read_place+1; byt2:=ord(inptstr[read_place]); // Y1
       bytes_2_word(byt1,byt2,y1); 

       read_place:=read_place+1; byt1:=ord(inptstr[read_place]);
       read_place:=read_place+1; byt2:=ord(inptstr[read_place]); // X2
       bytes_2_word(byt1,byt2,x2); 

       read_place:=read_place+1; byt1:=ord(inptstr[read_place]);
       read_place:=read_place+1; byt2:=ord(inptstr[read_place]); // X2
       bytes_2_word(byt1,byt2,y2);
      end;
 
end;
 

function PackRectangle(x1,y1,x2,y2:word; linesize:byte; filled:boolean):string;
var retres:string;
begin
retres:=''; 
if ((get_guess(1)=x1) and (get_guess(2)=y1) and (x2-x1<255) and (y2-y1<255) and (filled)) then
   begin //RECTANGLE_FILLED_SMALL_GUESSED
     retres:=retres+chr(RECTANGLE_FILLED_SMALL_GUESSED);
     retres:=retres+chr(x2-x1)+chr(y2-y1);
   end else
if ((x2-x1<255) and (y2-y1<255)) then
   begin //RECTANGLE SMALL
     if filled then
         begin //RECTANGLE SMALL FILLED
          retres:=retres+chr(RECTANGLE_FILLED_SMALL); 
         end else
         begin //RECTANGLE SMALL NOT FILLED
          retres:=retres+chr(RECTANGLE_NOFILL_SMALL);
         end;
         retres:=retres+word_2_string(x1)+word_2_string(y1);
         retres:=retres+chr(x2-x1)+chr(y2-y1);
   end else
   begin
      if filled then
         begin //RECTANGLE SMALL FILLED
          retres:=retres+chr(RECTANGLE_FILLED_BIG);
         end else
         begin //RECTANGLE SMALL NOT FILLED
          retres:=retres+chr(RECTANGLE_NOFILL_BIG);
         end;
         retres:=retres+word_2_string(x1)+word_2_string(y1);
         retres:=retres+word_2_string(x2)+word_2_string(y2);
   end;
set_guess(1,x2+1);
set_guess(2,y1);
PackRectangle:=retres;
end;


begin
end.

