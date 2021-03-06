@echo off


set URL=svn://sphx.org/sphinx/trunk
set REL=0.9.9


set PATH=C:\Program Files\Microsoft Visual Studio 8\Common7\IDE;%PATH%;
set ICONVROOT=C:\Bin\Iconv
set EXPATROOT=C:\Bin\Expat
set MYSQLROOT=C:\Program Files\MySQL\MySQL Server 5.0
set PGSQLROOT=C:\Program Files\PostgreSQL\8.3


if "%1" EQU "" (
	echo *** FATAL: specify build tag as 1st argument (eg. build.cmd rc2^).
	exit
) else (
	set TAG=-%1
)


rmdir /s /q sphinxbuild 2>nul
mkdir sphinxbuild
cd sphinxbuild
if %ERRORLEVEL% NEQ 0 (
	echo *** FATAL: failed to create build directory.
	exit
)


svn co %URL% checkout
if %ERRORLEVEL% NEQ 0 (
	echo *** FATAL: checkout error.
	exit
)


call checkout\src\svnxrev.cmd checkout
echo #define SPHINX_TAG "%TAG%" >> checkout\src\sphinxversion.h
rmdir /s /q checkout\.svn


cd checkout
devenv sphinx05.sln /Rebuild Release
if %ERRORLEVEL% NEQ 0 (
	echo *** FATAL: build error.
	exit
)


cd ..
mkdir common
for %%i in (api doc contrib) do (
	svn export checkout\%%i common\%%i
)
for %%i in (COPYING INSTALL sphinx.conf.in sphinx-min.conf.in example.sql) do (
	copy checkout\%%i common\%%i
)


set BASE=sphinx-%REL%%TAG%-win32
mkdir %BASE%
mkdir %BASE%\bin
for %%i in (indexer.exe search.exe searchd.exe spelldump.exe) do (
	copy checkout\bin\release\%%i %BASE%\bin
)
copy "%ICONVROOT%\bin\iconv.dll" %BASE%\bin
copy "%EXPATROOT%\libs\libexpat.dll" %BASE%\bin
copy "%MYSQLROOT%\bin\libmysql.dll" %BASE%\bin
xcopy /q /s common\* %BASE%
pkzip25 -add %BASE%.zip -dir %BASE%\*
move %BASE%.zip ..


cd checkout
perl -i.bak -p -e "s/USE_PGSQL\s+\d/USE_PGSQL 1/g;" src\sphinx.h
devenv sphinx05.sln /Rebuild Release
if %ERRORLEVEL% NEQ 0 (
	echo *** FATAL: build error.
	exit
)


cd ..
set BASE=sphinx-%REL%%TAG%-win32-pgsql
mkdir %BASE%
mkdir %BASE%\bin
for %%i in (indexer.exe search.exe searchd.exe spelldump.exe) do (
	copy checkout\bin\release\%%i %BASE%\bin
)

for %%i in (comerr32.dll gssapi32.dll iconv.dll k5sprt32.dll krb5_32.dll libeay32.dll libexpat.dll libiconv2.dll libintl3.dll libpq.dll ssleay32.dll) do (
	copy "%PGSQLROOT%\bin\%%i" %BASE%\bin
)

copy "%MYSQLROOT%\bin\libmysql.dll" %BASE%\bin
xcopy /q /s common\* %BASE%
pkzip25 -add %BASE%.zip -dir %BASE%\*
move %BASE%.zip ..
