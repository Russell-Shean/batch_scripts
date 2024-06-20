@echo off
cls
REM step above prevents echoing of commands

REM # Project name --------------------------------------------------------------------------------------------------------
REM Define the project name in one place
REM set tells command prompt to set the value of a variable
REM project_name is the variable name

REM the project_name should equal the name of the github repository
REM branch_name is the name of the branch you want to run code from

set project_name=YOUR_REPOS_NAME
set branch_name=main

REM # Find user name --------------------------------------------------------------------------------------------------
REM there's a builtin way to do this, so we don't need to do anything extra
REM %username% returns the current logged in user

REM # set a default folder to clone the project into
REM # the default will be "C:/users/%username%/R_projects/"
REM # but users will be given the option to change the file location
set r_projects_folder=C:/users/%username%/R_projects

REM the function that allows users to choose their own folder
REM is defined at the very bottom of the script

REM determine if the VPN is connected or if the user is on a remote desktop
REM for future use

rem # determine if VPN connection is found and store in a variable
ipconfig | findstr /ic:"VPN" >nul
if %errorlevel% EQU 0 ( set VPN_status=connected ) else ( set VPN_status=unconnected )


rem Determine if computer is a remote desktop
ipconfig | findstr /ic:"reddog" >nul
if %errorlevel% EQU 0 ( set RDP_status=RDP ) else ( set RDP_status=not_RDP )






REM # Welcome message ---------------------------------------------------------------------------------------------------
REM display a welcome message
REM colors are made using ANSI escape sequences 
REM "[" tells command prompt to start a color
REM the numbers correspond to the code for each specific color
REM m ends the color code start tag
REM [0m is the ending tag for the color (where to stop that color)
echo [36m--------------------------------------------------------[0m
echo [36m               Oh hello there![0m
echo [36m--------------------------------------------------------[0m
echo:
echo [36mThis script will help you automatically run the[0m [32m%project_name%[0m [36mdata refresh.[0m 
echo:
echo [36mThe script will guide you through the following steps:[0m
echo [36m       1) Download and install all the software you need[0m
echo [36m       2) Create a folder to store all the code you need[0m
echo [36m       3) Clone all the code you need from Github[0m
echo [36m       4) Run the data processing scripts and save the refreshed data to network and cloud locations[0m
echo:    
timeout /t 15
echo:
echo [36mDuring the process you may see messages with instructions for things you need to do manually[0m
echo [36mBefore running the script, you will need to create an enterprise Github account and a Github Personal Access Token (PAT)[0m
echo:    
timeout /t 15
echo:
echo [36mFor more detailed instructions see[0m: LINK TO README - If you're seeing this it means I forgot to add the link :D [0m
echo:    
timeout /t 15
echo:
echo [36mIf you get an unexpected error try closing this window and re-runing the script. 
echo [36mMany unexpected errors will resolve themselves just by re-running the script
echo:    
echo [36m----------------------------------------------------------[0m
echo [36m        Press any key to begin software instalation[0m
echo [36m----------------------------------------------------------[0m
echo:
timeout /t 60


REM # Step 1: Check to make sure that R, Rstudio, Rtools, pandoc and git are all installed ---------------------------
echo:
echo [36m----------------------------------------------[0m
echo [36m                SOFTWARE CHECK                [0m
echo [36m----------------------------------------------[0m
echo:


REM ## R -------------------------------------------------------------------------------------------

REM check to see if an R folder exists in the program files folder

if exist "C:/Program Files/R" (

    echo [36mR is installed on your computer[0m - [32mPASS[0m

) else (
   
    echo [33mR is not installed. Please visit the company portal and install the R version 4.4.0 and Rstudio bundle. Then re-run this script.[0m

    REM sources: https://www.reddit.com/r/Intune/comments/15xggnv/comment/k7dcs9j/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    REM          https://www.systanddeploy.com/2022/09/run-application-from-company-portal.html?m=0
    REM          https://github.com/damienvanrobaeys/Intune_Scripts/blob/main/Run%20app%20through%20company%20portal/Run%20app%20through%20company%20portal.ps1
    rem To run this yourself you need to find the applicationID and to run powershell code from a batch script you need to do this bit:  powershell -Command followed by the entire script on a single line
    REM with line breaks marked by semicolons
    powershell -Command "& {start-process companyportal:ApplicationId=cd974c4a-765b-49db-af86-8732bdea2170; sleep 10; [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.SendKeys]::SendWait('^{i}');}"

    echo The script just tried to automatically install R version 4.4.0, if the install didn't work
    echo please install from the company portal manually
    echo Either way you'll need to re-run this script 

    REM this ends the script and leaves the window open
    cmd /k

)


REM ### R version ---------------------------------------------------------------
REM determine the r version so we can pass it as a variable below
REM we check in order of least prefered to most prefered
REM that way if we have the most prefered the most prefered value will write over the less prefered version

REM COMMENTING OUT THIS ENTIRE SECTION TO ADDRESS PRE 4.4.0 vulnerability in R
REM more about vulnerability: 

REM if exist "C:/Program Files/R/R-4.2.3" ( set "r_version=R-4.2.3" )
REM if exist "C:/Program Files/R/R-4.2.2" ( set "r_version=R-4.2.2" )
REM if exist "C:/Program Files/R/R-4.2.1" ( set "r_version=R-4.2.1" ) 

REM changing the script to only accept R version 4.4.0
if exist "C:/Program Files/R/R-4.4.0" ( set "r_version=R-4.4.0" ) 

if defined r_version (

    echo [36mA supported version of R was found[0m: [32m%r_version%[0m
    echo:

) else (

    echo [33mUh oh~ It looks like R is installed on your computer, but you don't have a version we support[0m
    echo [33mPlease visit the Company Portal and install version 4.4.0. Then re-run this script.[0m

    
    REM ALSO COMMENTED OUT FOR SECURITY REASONS, WE NOW INSTALL 4.4.0 from company portal instead of 4.2.1 from the software center
    REM this opens the software center (on R 4.2.1 page)
    REM C:\Windows\CCM\ClientUX\scclient.exe softwarecenter:SoftwareID=ScopeId_87824763-9988-4A8F-B3E5-01DCCB2B9AC1/Application_37048d68-3f16-4dcb-a69b-39ab3e3644cb
    
    echo [33mR is not installed. Please visit the company portal and install the R version 4.4.0 and Rstudio bundle. Then re-run this script.[0m

    REM this code tries to automatically install the R Rstudio bundle from the company portal
    REM source: https://www.reddit.com/r/Intune/comments/15xggnv/comment/k7dcs9j/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    powershell -Command "& {start-process companyportal:ApplicationId=cd974c4a-765b-49db-af86-8732bdea2170; sleep 10; [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.SendKeys]::SendWait('^{i}');}"

    echo The script just tried to automatically install R version 4.4.0, if the install didn't work
    echo please install from the company portal manually


    REM to just open software center: C:\Windows\CCM\ClientUX\scclient.exe

    REM this ends the script and leaves the window open
    cmd /k

)


REM ## RStudio-------------------------------------------------------------------------------------------

REM check to see if an R folder exists in the program files folder

if exist "C:/Program Files/RStudio" (

    echo [36mRStudio is installed on your computer[0m - [32mPASS[0m

) else (
   
    echo [33mRStudio is not installed. Please visit the software center and install RStudio. Then re-run this script.[0m


    if %VPN_status% == connected (

        REM if the VPN is connected launch the RStudio specific page
        C:\Windows\CCM\ClientUX\scclient.exe softwarecenter:SoftwareID=ScopeId_87824763-9988-4A8F-B3E5-01DCCB2B9AC1/Application_6e7a5936-d497-4357-9747-70883dae6fbb
        
        cmd /k

    ) else (

        if %RDP_status% == RDP (

            REM if the user is on an RDP launch the RStudio specific page
            C:\Windows\CCM\ClientUX\scclient.exe softwarecenter:SoftwareID=ScopeId_87824763-9988-4A8F-B3E5-01DCCB2B9AC1/Application_6e7a5936-d497-4357-9747-70883dae6fbb
            
            cmd /k
        
        ) else (

            REM if neither the VPN or RDP are connected, take the user to the software center's home page
            C:\Windows\CCM\ClientUX\scclient.exe 

            cmd /k

        )

    )

)



REM ## Rtools --------------------------------------------------------------------------------------------

REM check for installation first

if exist C:/rtools44 (

    echo [36mRtools44 is installed on your computer[0m - [32mPASS[0m

) else (


 

        ECHO [31mRtools44 is not availalbe on winget yet. Please download and install Rtools manually.[0m
        echo [31mhttps://cran.r-project.org/bin/windows/Rtools/rtools44/rtools.html[0m

        echo [33mA[33mYou may see an error about "error creating registry key". Click "ignore the error and continue"[0m
        echo:
        cmd /k


)

REM ## Pandoc  --------------------------------------------------------------------------------------------

REM check for installation first
REM if it's installed somewhere else, we'll still it install a second copy here:

if exist C:\Users\%username%\AppData\Local\Pandoc (

    echo [36mPandoc is installed on your computer[0m - [32mPASS[0m

) else (


    where /q winget
    IF ERRORLEVEL 1 (

        ECHO [31mwinget tool is not available. Please download and install Pandoc manually.[0m
        echo [31mOr... check to see if pandoc is already installed and on the path.[0m
        echo [31mhttps://pandoc.org/installing.html[0m

        cmd /k


    ) ELSE (

        echo [36mPandoc is not installed in the expected location. Installing using winget![0m
        echo [36mInstalling to: C:\Users\%username%\AppData\Local\Pandoc ![0m
        echo [33mPlease provide your password when the installer launches[0m
        echo [33mClick "yes" if a window pops up asking you if you'd like to let Pandoc make changes on your computer[0m

        echo:
        echo [33mYou may see an error about "error creating registry key". Click "ignore the error and continue"[0m
        echo:

        REM This may result in multiple pandoc instalations 
        REM if it's already installed somewhere besides AppData\Local\Pandoc
        winget install -e --accept-source-agreements --accept-package-agreements --force --location "C:\Users\%username%\AppData\Local\Pandoc" --id JohnMacFarlane.Pandoc

    )

)



REM ## Git -------------------------------------------------------------------------------------------

REM Check to see if git is installed

REM where asks windows to look for a software
where /q git

REM error level 1 means that windows couldn't find the software
IF ERRORLEVEL 1 (
    ECHO [36mGit is either not installed or not on your PATH. Installing git now![0m
    echo [33mPlease provide your password when the installer launches[0m
    echo [33mClick "yes" if a window pops up asking you if you'd like to let git make changes on your computer[0m
    echo:

    REM install git using the winget tool

    REM winget is a command line tool for installing software on windows
    REM it's similiar to apt-get in linux
    where /q winget
    IF ERRORLEVEL 1 (


        REM winget appears to be present on all our organization's computers, but it's a fairly new windows tool
        REM so we can't neccesarily assume it'll be on all computers
        REM at this point, if winget isn't on the computer, I just give up and tell people to install the software manually
        ECHO [31mwinget tool is not available. Please download and install git manually.[0m
        echo [31mhttps://git-scm.com/download/win[0m
        cmd /k


    ) ELSE (

        REM if winget is available, we use this winget command to install git
        REM old format: winget install -e --accept-source-agreements --accept-package-agreements --id Git.Git
        winget install -e --accept-source-agreements --accept-package-agreements --force --location "C:\Users\%username%\git"  --id Git.Git

        echo:
        ECHO [36mgit was just installed but is still not on the path[0m
        echo [33mPlease close this window and rerun the initiate_fbi_refresh.bat script to add git to the path[0m
        echo:
        cmd /k



    )
 

) 



rem figure out where git is and return it as a variable
REM Source: https://stackoverflow.com/questions/6359820/how-to-set-commands-output-as-a-variable-in-a-batch-file  
FOR /F "tokens=* USEBACKQ" %%F IN (`where git`) DO (

    SET git_path=%%F

    )


REM Here's a way to ignore case: https://stackoverflow.com/a/8759981

if /I "%git_path%" == "C:\Users\%username%\git\cmd\git.exe" (

    echo:
    echo [36mGit is installed on your computer and on the Path[0m - [32mPASS[0m

) ELSE (

        echo:
        ECHO [36mgit is installed but is in a weird location. Reinstalling![0m



        REM if winget is available, we use this winget command to install git
        REM old format: winget install -e --accept-source-agreements --accept-package-agreements --id Git.Git
        winget install -e --accept-source-agreements --accept-package-agreements --force --location "C:\Users\%username%\git"  --id Git.Git

        
        echo [33mPlease close this window and rerun this batch script to add git to the path[0m
        echo:
        cmd /k



    )


if defined git_path (

    echo [36mGit was found in the following location[0m: [32m%git_path%[0m
    echo:
)


timeout /t 15


REM ##################################################################################################################
REM ####                                END SOFTWARE CHECKS                                                        ###
REM ##################################################################################################################

echo:
echo [36m----------------------------------------------[0m
echo [36m         CLONE REPOSITORY FROM GITHUB         [0m
echo [36m----------------------------------------------[0m
echo:


REM # Pull the project from github and initiate a new git linked directory ---------------------------

REM We need to give the user the chance to change the default location where the project will be cloned

REM first we need to see if a default folder already exists
REM we'll do this by seeing if the name of the folder the batch script was opened in is the same as the project name




REM this returns the current working directory
REM as just the folder name, with out any of the parent path
REM source: https://superuser.com/a/160712

REM for exampe if the cd was C:/users/Russ/blorg
REM it'd return blorg
REM blorg is stored in a variable called current_dir
for %%I in (.) do set current_dir=%%~nxI





REM delayed expansion is neccesary because otherwise stuff inside the if clause is rendered at compilation instead of execution time
REM better explanation: https://stackoverflow.com/a/9102569
REM another link: https://stackoverflow.com/questions/30282784/variables-are-not-behaving-as-expected/30284028#30284028

setlocal EnableDelayedExpansion


REM check to see if current directory is equal to the project name

if %current_dir% == %project_name% (


    REM store  the current directory as a variable
    set "oldir=!cd!"

    REM change the current directory to the parent level
    cd ..

    REM store the parent level as a variable
    set "r_projects_folder=!cd!"


    REM restore the old current directory
    cd !oldir!

)

REM stop delayed execution becuase I'm not sure what sorts of side effects that may cause
setlocal DISableDelayedExpansion



echo:
echo [36mThis script will automatically clone the[0m [32m%project_name%[0m [36mfrom github to your computer[0m
echo [36mBy default the[0m [32m%project_name%[0m [36mfolder will be created as a subfolder of the following folder:[0m 
echo [32m%r_projects_folder%[0m
echo: 
echo [36mIf the[0m [32m%r_projects_folder%[0m [36mdoesn't currently exist on your computer, the script will automatically create it[0m
echo:

timeout /t 15


REM skip ahead to the :folder_choice section 
goto folder_choice

REM this only gets run if the user enters something weird
REM so the script will repeat the message
:response_not_understood2
echo:
echo [31mI'm sorry I didn't understand your response. Please enter a 1 or a 2.[0m
echo:



:folder_choice
echo: 
echo [36mWould you like to change this default and clone[0m [32m%project_name%[0m [36mto a different location on your computer?[0m
echo:
echo      [36m1. Yes, I'd like to choose a new folder right now[0m
echo      [36m2. No thanks, the default sounds great[0m
echo:

REM this creates an interactive set of choices that correspond to whatever input the user provides
REM if the input is 1, the code goes to the :yes section, 2 to the :no section
REM all other responses got back to the :folder_choice section which repeats the question about the guide infinitely 
REM until a 1 or 2 is provided

set /p Input=Please enter a number:
If /I "%Input%"=="1" goto new_folder
If /I "%Input%"=="2" goto default_folder
If /I "%Input%" NEQ "2" goto response_not_understood2


:new_folder
REM this calls the function that we defined below (lines 674-685)
REM the function opens a window and asks the user to pick a folder
call :folderdialog folder


echo You choose the following folder: [32m%folder%[0m
echo:

REM we need to extract the first character from the default folder name
REM which is stored in the %folder% variable
REM here's more details about how to extract the first character from a string: https://stackoverflow.com/questions/36857098/extract-first-character-from-a-string

REM store the first character in a variable named first_letter
set first_letter=%folder:~0,1%

REM echo %first_letter%

REM if the first letter isn't C
REM we force the user to choose a different folder on the C drive
REM because the network drives need a new function to set as the current directory
REM and that needs the slashes to be facing the other way
REM and changes the naming scheme
REM so it's a whole thing
REM the network drives don't have this problem, but I'm not a fan of running code from network drives
REM because then multiple people could modify the code so it becomes harder to track changes
REM it's also slower and requires a VPN connection to access it
REM probably surmountable problems, but we'll just return this error unless specifically requested to allow non C drive locations

REM 
if /I %first_letter% NEQ C (


    echo [31mSorry, that folder isn't supported! Please choose a folder in C:/%username%/ and try again[0m
    echo:

    goto new_folder

)


REM this is the error that's returned if the user hits cancel or enter without choosing a new folder
if not defined folder (


    echo [31mIt looks like you didn't choose a folder! Please try again[0m
    echo:

    goto folder_choice

)

REM change the value of the r_projects_folder equal to the folder that the user selected
REM and reverse the direction of slashes because windows can't choose one consistant way of 
REM doing slashes .....gahhhhhhh

set "r_projects_folder=%folder:\=/%"


echo [36mThe project will be cloned to the following location: %r_projects_folder%[0m
echo:

goto clone_project





:default_folder
echo:
echo [36mUsing the default folder![0m
echo:





:clone_project
REM Check to see if an  R_project folder exists
REM create it if it doesn't
if not exist "%r_projects_folder%" mkdir "%r_projects_folder%"


REM Check to see if a  project folder exists already

if exist "%r_projects_folder%/%project_name%" (


    echo [32mThe %project_name% folder already exists![0m
    echo:

    REM this switches the working directory 
    REM it's equivalent to setwd() in R
    cd "%r_projects_folder%/%project_name%"

    echo [36mpulling in changes from github![0m
    echo:
    git pull


) else (


    echo [36mThe %project_name% folder doesn't already exist. Creating it![0m
    echo [33mWhen prompted enter your personal access token (PAT^)[0m
    echo [33mTo create a PAT please refer to these instructions:[0m 
    echo [33mhttps://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens[0m


    pushd "%r_projects_folder%"
    git clone https://github.com/Russell-Shean/%project_name%

    REM check for git errors and stop the script
    REM the script's default is to keep running even if git errors out
    IF ERRORLEVEL 1 (

        ECHO [31mGit returned an error.[0m
        echo [31mPlease make sure you have a personal access token and try running this script again!.[0m

        cmd /k

        ) 


)



REM make sure we're in the correct branch

cd "%r_projects_folder%/%project_name%"
echo:
echo [36mSwitching branches![0m
git switch %branch_name%


IF ERRORLEVEL 1 (

    ECHO [31mGit returned an error.[0m
    echo [31mPlease resolve the git error and then try running this script again!.[0m

    cmd /k

    ) 


)


echo:
echo [36m----------------------------------------------[0m
echo [36m                 Refresh data?                [0m
echo [36m----------------------------------------------[0m
echo:


REM skip ahead past this error message section 
goto run_refresh

REM this only gets run if the user enters something weird
REM so the script will repeat the message
:response_not_understood3
echo:
echo [31mI'm sorry I didn't understand your response. Please enter a 1 or a 2.[0m
echo:


:run_refresh
REM echo: 
REM echo [32mYou have all the software you need![0m 
REM echo:
echo [36mWould you like to refresh any of the data today?[0m
echo:
echo      [36m1. No, just open the[0m [32m%project_name%[0m [36mfolder[0m
echo      [36m2. Yes, I'd like to refresh the[0m [32m%project_name%[0m [36mdata[0m
echo:

set /p Input=Please enter a number: 
If /I "%Input%"=="1" goto open_folder
If /I "%Input%"=="2" goto run_refresh
If /I "%Input%" NEQ "4" goto response_not_understood3


:open_folder
REM store the full path to the project folder in a variable
set project_folder=%r_projects_folder%\%project_name%

REM reverse the direction of the slashes
REM this is needed because explorer.exe needs them facing in the opposite direction
set "project_folder=%project_folder:/=\%"

echo:
echo [32mTaking you to the[0m [32m%project_name%[0m [36mfolder now![0m


timeout /t 15
explorer.exe %project_folder%


cmd /k


REM If the user decides to run the refresh

:run_refresh
REM here we use the r_version variable we store above to find the right executable
if defined r_version (

    echo:
    echo [36mRunning the script using R version:[0m [32m%r_version%[0m

    REM definitely redundant at this point, but sometimes overkill is good :D
    git pull

    REM this is the command that actually runs the script
    REM The first argument is the path to the R executable 
    REM the second is the (~~<em>relative</em>~~) path to the file we want R to execute

    "C:/Program Files/R/%r_version%/bin/Rscript.exe" "R/00-call_script.R"

    cmd /k


) else (

    echo:
    echo [33mSorry, I couldn't find a supported version of R on your computer. Please download version 4.4.0 from the companyportal and try again[0m

    cmd /k

)






REM ###############################################
REM ----      Folder picker function   ------------
REM ###############################################


REM this function is vbs code to launch a window that allows users to pick a folder
REM the code was generated by chat gpt based on code that I found that launched a hindow which gave users the option to choose a file

REM original code comes from here: https://code.activestate.com/recipes/580665-file-selector-dialog-in-batch/ 
REM Chat gpt was spooky good this time....
REM link to original prompt: https://chat.openai.com/c/06fb4e9a-9e16-4ff4-9268-1bc1452fcbe1 


REM Start chat GPT generated code --------
REM comments were not generated by ChatGPT....that was mee!
:folderdialog :: &folder
setlocal
set "dialog="


REM This section write the code line by line to a file called  "%temp%\folderdialog.vbs"
echo Set objShell = CreateObject("Shell.Application") > "%temp%\folderdialog.vbs"
echo set folder = objShell.BrowseForFolder(0, "Select a folder", 0, 0) >> "%temp%\folderdialog.vbs"
echo if not folder is nothing then >> "%temp%\folderdialog.vbs"
echo     Wscript.Echo folder.Self.Path >> "%temp%\folderdialog.vbs"
echo end if >> "%temp%\folderdialog.vbs"

REM this is batch script code that executes the VBS code above and stores the output in a variable named folder
for /f "delims=" %%p in ('cscript //nologo "%temp%\folderdialog.vbs"') do set "folder=%%p"

REM delete the temporary file where the vbs script was written to
del "%temp%\folderdialog.vbs"
endlocal & set %1=%folder%

REM end chatgpt generated code -------
