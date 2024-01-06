# Zig folder is C:\Users\%user%\AppData\Local\zig (LOCALAPPDATA)
$destinationFolder = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'zig')

# We create the folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder -PathType Container)) {
    New-Item -Path $destinationFolder -ItemType Directory
}

# We get the download list from the official json
$jsonUrl = 'https://ziglang.org/download/index.json'
Write-Host "Downloading download informations from $jsonUrl"
$jsonContent = Invoke-RestMethod -Uri $jsonUrl

# We get the zip url of the master version for x86_64-windows
$zipUrl = $jsonContent.master.'x86_64-windows'.tarball

# We get the zip filename
$lastFolderName = [System.IO.Path]::GetFileNameWithoutExtension($zipUrl)

# We set the full destination path
$fullDestinationPath = Join-Path -Path $destinationFolder -ChildPath $lastFolderName

# Download the zip file in silent mode to avoid a download speed bug
$ProgressPreference = 'SilentlyContinue'
Write-Host "Downloading $zipUrl"
Invoke-WebRequest -Uri $zipUrl -OutFile "$fullDestinationPath.zip"

# Unzip the content using dotnet assembly instead the expendable to speed things
if (Test-Path -Path $fullDestinationPath -PathType Container) {
    Write-Host "Destination folder $fullDestinationPath already exist, remove it if you want a new install"
}
else {
    Write-Host "Extracting to $fullDestinationPath"
    Add-Type -Assembly "System.IO.Compression.Filesystem"
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$fullDestinationPath.zip", "$destinationFolder")
}

# We remove the zip file
Remove-Item -Path "$fullDestinationPath.zip" -Force

# We set/update the PATH variable with the new folder

# Get the current PATH variable
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)

# Split the PATH into an array of individual paths
$pathArray = $currentPath -split ';'

# Filter out paths that start with the specified prefix
$newPathArray = $pathArray | Where-Object { -not $_.StartsWith($destinationFolder) }

# We add the new folder
$newPathArray = $newPathArray + $fullDestinationPath

# Join the filtered paths back into a semicolon-separated string
$newPath = $newPathArray -join ';'

# Update the PATH variable with the new value
# Check if the variables are not the same
if ($currentPath -ne $newPath) {
    Write-Host "Setting the user PATH variable, please restart your powershell terminal."
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, [System.EnvironmentVariableTarget]::User)
}

Write-Host "Zig installed"