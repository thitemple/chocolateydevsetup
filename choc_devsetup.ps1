function global:Add-Path() {
	[Cmdletbinding()]
	param([parameter(Mandatory=$True,ValueFromPipeline=$True,Position=0)][String[]]$AddedFolder)

	# Get the current search path from the environment keys in the registry.

	$OldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path

	# See if a new folder has been supplied.

	IF (!$AddedFolder) { 
		Return 'No Folder Supplied. $ENV:PATH Unchanged'
	}

	# See if the new folder exists on the file system.

	IF (!(TEST-PATH $AddedFolder))
	{ Return 'Folder Does not Exist, Cannot be added to $ENV:PATH' }cd

	# See if the new Folder is already in the path.

	IF ($ENV:PATH | Select-String -SimpleMatch $AddedFolder)
	{ Return 'Folder already within $ENV:PATH' }

	# Set the New Path

	$NewPath=$OldPath+’;’+$AddedFolder

	Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath

	# Show our results back to the world

	Return $NewPath
}

FUNCTION GLOBAL:Get-Path() { Return $ENV:PATH }

Write-Host "Installing Chocolatey"
iex ((new-object net.webclient).DownloadString('http://bit.ly/psChocInstall'))
Write-Host

Write-Host "Installing applications from Chocolatey"
cinst git
cinst ruby -Version 1.9.3.44800
#cinst nodejs.install
cinst webpi
cinst poshgit
cinst notepadplusplus 
cinst sublimetext2 
cinst SublimeText2.PackageControl
cinst ConEmu
cinst python 
cinst DotNet4.0
cinst DotNet4.5
cinst putty
cinst Firefox
cinst GoogleChrome
cinst fiddler4
cinst filezilla
cinst dropbox
cinst winmerge
cinst winrar -Version 4.20.0
cinst mongodb
cinst NugetPackageExplorer
cinst SkyDrive 
cinst Evernote 
Write-Host

Write-Host "Setting home variable"
[Environment]::SetEnvironmentVariable("HOME", $HOME, "User")
Write-Host

Write-Host "Creating .bashrc file for use with Git Bash"
$filePath = $HOME + "\.bashrc"
New-Item $filePath -type file -value ((new-object net.webclient).DownloadString('http://vintem.me/winbashrc'))
Write-Host

#Write-Host "Creating autorun.bat for windows command prompt"
#$fileToCreate = $HOME + "\autorun.bat"
#$filePathForReg =  '"{0}\autorun.bat"' -f $HOME
#$autorun = @"
#doskey subl="C:\Program Files\Sublime Text 2\sublime_text.exe" $*
#cls
#"@
#New-Item $fileToCreate -type file -value $autorun

#Set-Location "HKCU:\Software\Microsoft\Command Processor"
#Set-ItemProperty . AutoRun $filePathForReg
#Pop-Location
#Write-Host

Write-Host "Configuring Git globals"
$userName = Read-Host 'Enter your name for git configuration'
$userEmail = Read-Host 'Enter your email for git configuration'

git config --global user.email $userEmail
git config --global user.name $userName
Write-Host

Write-Host "Installing apps from WebPI"
cinst WindowsInstaller31 -source webpi
cinst WindowsInstaller45 -source webpi
Write-Host

Write-Host
do {
	$createSiteData = Read-Host "Do you want to install SQLExpress? (Y/N)" 
} while ($createSiteData -ne "Y" -and $createSiteData -ne "N")
if ($createSiteData -eq "Y") { 
	cinst SqlServer2012Express
}
Write-Host

Write-Host
do {
	$createSiteData = Read-Host "Do you want to install Visual Studio 2012? (Y/N)" 
} while ($createSiteData -ne "Y" -and $createSiteData -ne "N")
if ($createSiteData -eq "Y") { 
	#[Environment]::OSVersion.Version -ge (new-object 'Version' 6,1)
	#[System.Environment]::OSVersion.Version
	#cinst VirtualCloneDrive
	
	#cinst Dogtail.VS2012.3 
}
Write-Host

Write-Host "Adding Git\bin to the path"
#$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
#$path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
#if (!$path.EndsWith(";")) 
#{
#	$path = $path + ";"
#}
#$path = $path + "C:\Program Files (x86)\Git\bin;"
#[Environment]::SetEnvironmentVariable("PATH", $path, "Machine")
Add-Path "C:\Program Files (x86)\Git\bin"
Write-Host

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

Write-Host "Update RubyGems"
cinst ruby.devkit.ruby193
gem update --system
gem install bundler compass
Write-Host

Write-Host "Install NPM packages"
#npm install -g yo grunt-cli karma bower jshint coffee-script nodemon generator-webapp generator-angular
Write-Host

Write-Host "Generating public/private rsa key pair"
Set-Location $home
$dirssh = "$home\.ssh"
mkdir $dirssh
$filersa = $dirssh + "\id_rsa"
ssh-keygen -t rsa -f $filersa -q -C $userEmail
Write-Host

Write-Host "Adding MongoDB to the path"
#$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
#$path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
#if (!$path.EndsWith(";")) 
#{
#	$path = $path + ";"
#}
#$path = $path + "C:\MongoDB\bin"
#[Environment]::SetEnvironmentVariable("PATH", $path, "Machine")
Add-Path "C:\MongoDB\bin"
Write-Host

Write-Host "Creating custom $profile for Powershell"
if (!(test-path $profile)) {
	New-Item -path $profile -type file -force
} 

Add-Content $profile @"
chcp 65001
Set-Alias subl "C:\Program Files\Sublime Text 2\sublime_text.exe"
"@
Write-Host