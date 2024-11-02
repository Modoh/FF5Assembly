@echo off
rem this takes a .sym file in nocash format from asar (ff5_c2.sym)
rem and merges it with a static data symbols file that handles strucures better in mesen (ff5_data.mlb)
rem to create a new merged symbols file ff5_c2.mlb

pushd %~dp0
del temp.mlb 2>nul


for /f "tokens=1,2" %%G IN (ff5_c2.sym) do call :address %%G %%H
goto :merge

:address
rem test for comment, skip line
set in1=%1
set test=%in1:~0,1%
if [%test%]==[;] exit /b

rem test for labels that contain : or ., replace with _
rem also replace spaces with nothing
set label=%2
set label=%label::=_%
set label=%label:.=_%
set "label=%label: =%"

rem replace cpu based addresses with rom based ones
set address=%in1:~4%
set bank1=%in1:~2,1%
set bank2=%in1:~3,1%
rem if %bank1%==C set bank1=0
rem if %bank1%==D set bank1=1
rem if %bank1%==E set bank1=2
rem if %bank1%==F set bank1=3
set bank1=%bank1:C=0%
set bank1=%bank1:D=1%
set bank1=%bank1:E=2%
set bank1=%bank1:F=3%
set bank=%bank1%%bank2%

rem choose appropriate format for ram/rom address
rem also get rid of discarded addresses
if %bank%==00 goto :ram
if %bank%==7E goto :ram
:rom
echo SnesPrgRom:%bank%%address%:%label%| findstr /v "__discarded" >>temp.mlb
exit /b

:ram 
echo SnesWorkRam:%address%:%label%| findstr /v "__discarded" >>temp.mlb
exit /b

:merge
rem prepare static data because they work better than the asar generated ones
rem strip out comments first because mesen doesn't like them
findstr /b /v ";" ff5_data.mlb >temp2.mlb

rem merge our temp files
rem duplicate symbols are fine but last one wins so data should be second
copy temp.mlb+temp2.mlb ff5_c2.mlb

del temp.mlb
del temp2.mlb
del ff5_c2.sym
popd


