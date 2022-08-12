del *.obj
wsl nasm boot.asm
util\lppp kernel\lll\main.lll
ren out.obj main.obj
util\lppp kernel\lll\strings.lll
ren out.obj strings.obj
util\lppp kernel\lll\menu.lll
ren out.obj menu.obj
util\lppp kernel\lll\crash.lll
ren out.obj crash.obj
util\lppp kernel\lll\globals.lll
ren out.obj globals.obj
wsl nasm -fas86 kernel/asm/disk.asm -o disk.obj
wsl nasm -fas86 kernel/asm/str.asm -o str.obj
wsl nasm -fas86 kernel/asm/io.asm -o io.obj
wsl nasm -fas86 kernel/asm/mouse.asm -o mouse.obj
wsl ld86 -d -T0 -o rmnkrnl.sys main.obj strings.obj disk.obj str.obj menu.obj crash.obj globals.obj mouse.obj io.obj
copy boot floppy.img
imdisk -a -f floppy.img -s 1440K -m B:
copy rmnkrnl.sys B:
copy rmnkrnl.sys B:\RAMENE.COA
imdisk -D -m B:
