$version = "3.11.8"
$url = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"

reg.exe import .\enable_log_paths.reg

$installPath = "$($env:ProgramFiles)\Python-$version"
Invoke-WebRequest $url -OutFile python-$version-amd64.exe
Start-Process python-$version-amd64.exe -ArgumentList "/passive", 'InstallAllUsers="1"', 'PrependPath="1"', 'Include_test="0"', 'Include_exe="1"', 'Include_Launcher="1"', 'InstallLauncherAllUsers="1"', 'Include_pip="1"', 'Include_tcltk="1"', 'Include_tools="1"', 'Include_lib="1"' -Wait

$envVariable = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envVariable -notLike "*$installPath*"){
    [System.Environment]::SetEnvironmentVariable("Path", "$envVariable;$installPath", "Machine")
    Write-Host "Added Python to PATH"
}

Remove-Item python-$version-amd64.exe

python.exe -m pip install pathlib