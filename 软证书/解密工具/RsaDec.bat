@echo off

IF "%~1" equ "/?" goto showhelp
IF "%~1" equ "--help" goto showhelp

@REM ##########################################################################
@REM
@REM Java������������
@REM �ַ����뼯����
@REM ȫ�ֱ�������
@REM
@REM ##########################################################################
setlocal
chcp 936 2>nul >nul
set java_exe=java.exe
setlocal EnableDelayedExpansion
set BASENAME=RsaDec-
set "t=%time%"
set /a total =0
set /a success =0
set /a fail =0
set /a skip =0
set /a forceFlag =1
set privateKeyFile="privatekey.txt"
set max=0

@REM ##########################################################################
@REM
@REM �Զ�ʶ��jar�����°汾��
@REM
@REM ##########################################################################
@REM Find the highest version .jar available in the same directory as the script

if exist RsaDec.jar (
    set BASENAME=RsaDec
    goto skipversioned
)

for /f "tokens=1* delims=-" %%A in ('dir /b /a-d %BASENAME%*.jar') do if %%~B gtr !max! set max=%%~nB
@echo found %BASENAME%%max%.jar, use it.
@echo RsaDec is running
@echo.
:skipversioned

@REM ##########################################################################
@REM
@REM  δ���� /y �������Ӵ˿�ʼִ��
@REM
@REM ##########################################################################
IF "%~1" equ "/y" goto force

@REM ��һ�����������ȡ����.lic�ļ����ƣ��� authorized.lic���������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\authorized.lic
@REM �ڶ������������ѹ��Ŀ���ļ������ƣ��� authorized.zip���������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\authorized.zip
@REM ����������������˽Կ���ļ������ƣ��� privatekey.txt���������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\privatekey.txt
IF "%~1" neq "" (
    set sourceFile="%~1"
    IF not exist !sourceFile! (
        @echo FAIL: Ŀ���ļ������ڣ�!sourceFile!
        goto over
    )

    IF "%~2" equ "" (
        @REM ���û������ָ��targetFile�����ƣ�Ĭ��ʹ��lic�ļ�ͬ�����Һ�׺����Ϊzip
        set targetFile="%~dpn1.zip"
        IF exist !targetFile! (
            @echo SKIP: Ŀ���ļ��Ѵ��ڣ�!targetFile!
            goto over
        )
    ) else (
        set  targetFile="%~2"
        IF exist !targetFile! (
            @echo SKIP: Ŀ���ļ��Ѵ��ڣ�!targetFile!
            goto over
        )
    )

    IF "%~3" equ "" (
        IF exist %~dp1privatekey.txt (
            @REM ���.lic �ļ�����Ŀ¼��˽Կ����ʹ�����˽Կ
            set privateKeyFile="%~dp1privatekey.txt"
        ) else (
            @REM ���.lic �ļ�����Ŀ¼û��˽Կ����ʹ�ø�Ŀ¼���privatekey.txt
            for %%d in (%~dp1..) do set ParentDirectory=%%~fd
            set privateKeyFile="!ParentDirectory!\privatekey.txt"
        )
    ) else (
        set  privateKeyFile="%~3"
    )

    goto load
)

goto run

@REM ##########################################################################
@REM
@REM  ������ /y �������Ӵ˿�ʼִ��
@REM  ����forceFlag=0,ǿ�Ƹ���ִ�У�����������ִ��
@REM
@REM ##########################################################################
:force
set /a forceFlag =0
@REM ��һ�����������ȡ����.lic�ļ����ƣ��� authorized.lic���������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\authorized.lic
@REM �ڶ������������ѹ��Ŀ���ļ������ƣ��� authorized.zip���������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\authorized.zip
@REM ����������������˽Կ���ļ������ƣ��� privatekey.txt���������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\privatekey.txt

IF "%~2" neq "" (

    set sourceFile="%~2"
    IF not exist !sourceFile! (
        @echo FAIL: Դ�ļ������ڣ�!sourceFile!
        goto over
    )

    IF "%~3" equ "" (
        @REM ���û������ָ��targetFile�����ƣ�Ĭ�Ϻ�lic�ļ�ͬ�����Һ�׺����Ϊzip
        set targetFile="%~dpn2.zip"
        IF exist !targetFile! (
            @echo ע�⣺Ŀ���ļ��Ѵ���:!targetFile!���Ḳ���ٴ����ɡ�
        )
    ) else (
        set targetFile="%~3"
        @echo  ע�⣺Ŀ���ļ��Ѵ���:!targetFile!���Ḳ���ٴ����ɡ�
    )

    IF "%~4" equ "" (
        IF exist %~dp2privatekey.txt (
            @REM ���.lic �ļ�����Ŀ¼��˽Կ����ʹ�����˽Կ
            set privateKeyFile="%~dp2privatekey.txt"
        ) else (
            @REM ���.lic �ļ�����Ŀ¼û��˽Կ����ʹ�ø�Ŀ¼���privatekey.txt
            for %%d in (%~dp2..) do set ParentDirectory=%%~fd
            set privateKeyFile="!ParentDirectory!\privatekey.txt"
        )
    ) else (
        set  privateKeyFile="%~4"
    )

    goto load
)

goto run

@REM
@REM ##########################################################################
@REM
@REM δָ�� sourceFile targetFile privateKeyFile
@REM ѭ����������ǰĿ¼�Լ���Ŀ¼�����е�.lic,������һ����
@REM
@REM ˵����
@REM        ����ʹ��.lic �ļ�����Ŀ¼��˽Կ��
@REM        ���.lic �ļ�����Ŀ¼û��˽Կ����ʹ�ø�Ŀ¼���˽Կ
@REM
@REM ##########################################################################
:run
for /r %%i in (*.lic) do (
    set sourceFile="%%i"
    @REM ��ȡ.lic ����Ŀ¼�� privateKey.txt
    @REM echo %%i
    @REM echo %%~dpiprivatekey.txt
    IF exist %%~dpiprivatekey.txt (
        @REM ���.lic �ļ�����Ŀ¼��˽Կ����ʹ�����˽Կ
        set privateKeyFile="%%~dpiprivatekey.txt"
    ) else (
        @REM ���.lic �ļ�����Ŀ¼û��˽Կ����ʹ�ø�Ŀ¼���privatekey.txt
        for %%d in (%%~dpi..) do set ParentDirectory=%%~fd
        set privateKeyFile="!ParentDirectory!\privatekey.txt"
    )

    set targetFile="%%~dpni.zip"

    IF "!forceFlag!" == "0" (
        IF exist %%~dpni.zip (
            @echo  ע�⣺Ŀ���ļ��Ѵ��ڣ��Ḳ���ٴ����ɣ�"%%~dpni.zip"
            call:load
        ) else (
            call:load
        )
    ) else (
        IF exist %%~dpni.zip (
            set /a skip + =1
            set /a total + =1
            @echo SKIP: Ŀ���ļ��Ѵ��ڣ�"%%~dpni.zip"
        ) else (
            call:load
        )
    )
)

@REM ##########################################################################
@REM
@REM done.
@REM �������н���
@REM ͳ������ʱ�䣬�����������ɹ�����ʧ��������������
@REM
@REM ##########################################################################
:done
@echo.
@echo Completed
@echo Total:%total%, Success:%success%, Fail:%fail%, Skip:%skip%

set "t1=%time%"
if "%t1:~,2%" lss "%t:~,2%" set "add=+24"
set /a "times=(%t1:~,2%-%t:~,2%%add%)*360000+(1%t1:~3,2%%%100-1%t:~3,2%%%100)*6000+(1%t1:~6,2%%%100-1%t:~6,2%%%100)*100+(1%t1:~-2%%%100-1%t:~-2%%%100)" ,"ss=(times/100)%%60","mm=(times/6000)%%60","hh=times/360000","ms=times%%100""
echo cost:%mm%m:%ss%s:%ms%ms
@echo.

setlocal DisableDelayedExpansion

cmd.exe /K
goto over

@REM ##########################################################################
@REM
@REM load.
@REM ִ�� jar�� -Duser.language=ch -Dfile.encoding=UTF8
@REM
@REM ##########################################################################
:load
set /a total + =1
%java_exe%  -jar %~dp0%BASENAME%%max%.jar %sourceFile% %targetFile% %privateKeyFile%

if "%ERRORLEVEL%" == "0" (
    set /a success + =1
    @echo SUCCESS: Decrypted to %targetFile%.
) else if "%ERRORLEVEL%" == "1" (
    set /a fail + =1
    @echo FAIL: ��Կ�ļ���ƥ��: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else if "%ERRORLEVEL%" == "2" (
    set /a fail + =1
    @echo FAIL: ��Կ�ļ���ʽ����: %sourceFile% Decryption failed,by privateKeyFile:%privateKeyFile%
) else if "%ERRORLEVEL%" == "3" (
    set /a fail + =1
    @echo FAIL: ��Կ�ļ�������: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else if "%ERRORLEVEL%" == "4" (
    set /a fail + =1
    @echo FAIL: Դ�ļ�������: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else if "%ERRORLEVEL%" == "5" (
    set /a fail + =1
    @echo FAIL: �����ļ���������ʧ��: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else if "%ERRORLEVEL%" == "99" (
    set /a fail + =1
    @echo FAIL: �����쳣: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else (
    set /a fail + =1
    @echo FAIL: �����쳣: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
)
goto over

:showhelp
@echo 1. ˫���ɿ���ִ�С���Ŀ���ļ��Ѵ������������ɡ�
@echo 2. ������ִ�У�
@echo     %0 [/y] [sourceFile] [targetFile] [privateKeyFile]
@echo       /y��            ��Ŀ���ļ�����ʱ��ǿ�Ƹ��ǡ�
@echo       sourceFile��    ��ȡ����.lic�ļ����������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\authorized.lic
@echo       targetFile��    ��ѹ���Ŀ���ļ����������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\authorized.zip
@echo       privateKeyFile�����ڽ��ܵ�˽Կ�ļ����������bat�ļ���ͬһĿ¼��������ȫ·�����磺D:\license\privatekey.txt
@echo.
@echo     example:
@echo       %0 /y authorized.lic authorized.zip privatekey.txt

@REM ##########################################################################
@REM
@REM �������н���
@REM
@REM ##########################################################################
:over