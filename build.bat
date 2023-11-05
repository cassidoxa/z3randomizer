del ..\working.sfc
copy ..\alttp.sfc ..\working.sfc
%~dp0bin\windows\asar.exe --symbols=wla --fix-checksum=off LTTP_RND_GeneralBugfixes.asm ..\working.sfc
cmd /k
