@echo off
REM Directory variables
setlocal EnableDelayedExpansion

set folder=%JOB_NAME%
ECHO  ===  === %JOB_NAME%
cd /d ..\%folder%
for /F "delims=" %%i in ('dir /b') do (rmdir "%%i" /s/q || del "%%i" /s/q)
XCOPY "..\Deployment\*" "..\%JOB_NAME%" /s /i
REM XCOPY C:\utils\* D:\Backup\utils /s /i

ECHO  ===  === 
ECHO  === End ===
pause
endlocal