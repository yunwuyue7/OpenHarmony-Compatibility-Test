@echo off

IF "%~1" equ "/?" goto showhelp
IF "%~1" equ "--help" goto showhelp

@REM ##########################################################################
@REM
@REM Java环境变量配置
@REM 字符编码集配置
@REM 全局变量配置
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
@REM 自动识别jar的最新版本号
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
@REM  未调用 /y 参数，从此开始执行
@REM
@REM ##########################################################################
IF "%~1" equ "/y" goto force

@REM 第一步：请输入获取到的.lic文件名称，如 authorized.lic，如果不和bat文件在同一目录，请输入全路径，如：D:\license\authorized.lic
@REM 第二步：请输入解压后目标文件的名称，如 authorized.zip，如果不和bat文件在同一目录，请输入全路径，如：D:\license\authorized.zip
@REM 第三步：请输入存放私钥的文件的名称，如 privatekey.txt，如果不和bat文件在同一目录，请输入全路径，如：D:\license\privatekey.txt
IF "%~1" neq "" (
    set sourceFile="%~1"
    IF not exist !sourceFile! (
        @echo FAIL: 目标文件不存在：!sourceFile!
        goto over
    )

    IF "%~2" equ "" (
        @REM 如果没有输入指定targetFile的名称，默认使用lic文件同名，且后缀更改为zip
        set targetFile="%~dpn1.zip"
        IF exist !targetFile! (
            @echo SKIP: 目标文件已存在：!targetFile!
            goto over
        )
    ) else (
        set  targetFile="%~2"
        IF exist !targetFile! (
            @echo SKIP: 目标文件已存在：!targetFile!
            goto over
        )
    )

    IF "%~3" equ "" (
        IF exist %~dp1privatekey.txt (
            @REM 如果.lic 文件所在目录有私钥，则使用这个私钥
            set privateKeyFile="%~dp1privatekey.txt"
        ) else (
            @REM 如果.lic 文件所在目录没有私钥，则使用父目录里的privatekey.txt
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
@REM  调用了 /y 参数，从此开始执行
@REM  设置forceFlag=0,强制覆盖执行，否则跳过不执行
@REM
@REM ##########################################################################
:force
set /a forceFlag =0
@REM 第一步：请输入获取到的.lic文件名称，如 authorized.lic，如果不和bat文件在同一目录，请输入全路径，如：D:\license\authorized.lic
@REM 第二步：请输入解压后目标文件的名称，如 authorized.zip，如果不和bat文件在同一目录，请输入全路径，如：D:\license\authorized.zip
@REM 第三步：请输入存放私钥的文件的名称，如 privatekey.txt，如果不和bat文件在同一目录，请输入全路径，如：D:\license\privatekey.txt

IF "%~2" neq "" (

    set sourceFile="%~2"
    IF not exist !sourceFile! (
        @echo FAIL: 源文件不存在：!sourceFile!
        goto over
    )

    IF "%~3" equ "" (
        @REM 如果没有输入指定targetFile的名称，默认和lic文件同名，且后缀更改为zip
        set targetFile="%~dpn2.zip"
        IF exist !targetFile! (
            @echo 注意：目标文件已存在:!targetFile!，会覆盖再次生成。
        )
    ) else (
        set targetFile="%~3"
        @echo  注意：目标文件已存在:!targetFile!，会覆盖再次生成。
    )

    IF "%~4" equ "" (
        IF exist %~dp2privatekey.txt (
            @REM 如果.lic 文件所在目录有私钥，则使用这个私钥
            set privateKeyFile="%~dp2privatekey.txt"
        ) else (
            @REM 如果.lic 文件所在目录没有私钥，则使用父目录里的privatekey.txt
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
@REM 未指定 sourceFile targetFile privateKeyFile
@REM 循环遍历，当前目录以及子目录中所有的.lic,进行逐一处理
@REM
@REM 说明：
@REM        优先使用.lic 文件所在目录有私钥。
@REM        如果.lic 文件所在目录没有私钥，则使用父目录里的私钥
@REM
@REM ##########################################################################
:run
for /r %%i in (*.lic) do (
    set sourceFile="%%i"
    @REM 获取.lic 所在目录的 privateKey.txt
    @REM echo %%i
    @REM echo %%~dpiprivatekey.txt
    IF exist %%~dpiprivatekey.txt (
        @REM 如果.lic 文件所在目录有私钥，则使用这个私钥
        set privateKeyFile="%%~dpiprivatekey.txt"
    ) else (
        @REM 如果.lic 文件所在目录没有私钥，则使用父目录里的privatekey.txt
        for %%d in (%%~dpi..) do set ParentDirectory=%%~fd
        set privateKeyFile="!ParentDirectory!\privatekey.txt"
    )

    set targetFile="%%~dpni.zip"

    IF "!forceFlag!" == "0" (
        IF exist %%~dpni.zip (
            @echo  注意：目标文件已存在，会覆盖再次生成："%%~dpni.zip"
            call:load
        ) else (
            call:load
        )
    ) else (
        IF exist %%~dpni.zip (
            set /a skip + =1
            set /a total + =1
            @echo SKIP: 目标文件已存在："%%~dpni.zip"
        ) else (
            call:load
        )
    )
)

@REM ##########################################################################
@REM
@REM done.
@REM 正常运行结束
@REM 统计运行时间，计算总数，成功数，失败数，跳过数。
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
@REM 执行 jar包 -Duser.language=ch -Dfile.encoding=UTF8
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
    @echo FAIL: 密钥文件不匹配: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else if "%ERRORLEVEL%" == "2" (
    set /a fail + =1
    @echo FAIL: 密钥文件格式有误: %sourceFile% Decryption failed,by privateKeyFile:%privateKeyFile%
) else if "%ERRORLEVEL%" == "3" (
    set /a fail + =1
    @echo FAIL: 密钥文件不存在: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else if "%ERRORLEVEL%" == "4" (
    set /a fail + =1
    @echo FAIL: 源文件不存在: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else if "%ERRORLEVEL%" == "5" (
    set /a fail + =1
    @echo FAIL: 解密文件最终生成失败: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else if "%ERRORLEVEL%" == "99" (
    set /a fail + =1
    @echo FAIL: 请检查异常: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
) else (
    set /a fail + =1
    @echo FAIL: 请检查异常: %sourceFile% Decryption failed,by privateKeyFile: %privateKeyFile%
)
goto over

:showhelp
@echo 1. 双击可快速执行。若目标文件已存在则不重新生成。
@echo 2. 命令行执行：
@echo     %0 [/y] [sourceFile] [targetFile] [privateKeyFile]
@echo       /y：            当目标文件存在时，强制覆盖。
@echo       sourceFile：    获取到的.lic文件。如果不和bat文件在同一目录，请输入全路径，如：D:\license\authorized.lic
@echo       targetFile：    解压后的目标文件。如果不和bat文件在同一目录，请输入全路径，如：D:\license\authorized.zip
@echo       privateKeyFile：用于解密的私钥文件。如果不和bat文件在同一目录，请输入全路径，如：D:\license\privatekey.txt
@echo.
@echo     example:
@echo       %0 /y authorized.lic authorized.zip privatekey.txt

@REM ##########################################################################
@REM
@REM 程序运行结束
@REM
@REM ##########################################################################
:over