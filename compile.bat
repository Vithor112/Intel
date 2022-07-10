set arg1=%1
masm /zi %arg1%.asm
link /co %arg1%.obj;
rm %arg1%.obj
%arg1%.exe


