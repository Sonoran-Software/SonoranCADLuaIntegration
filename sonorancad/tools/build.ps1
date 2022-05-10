# Pointless for end-users, supplied in case someone else needs to build a release.

# Place into folder above your [sonorancad] before running. Requires 7-zip to be installed.

$ReleaseVersion = Read-Host "Enter version to create"

$ResourcePath = "G:\git\sonoranplugins\server\resources\[sonorancad]"
$WorkPath = $PSScriptRoot + "\release\[sonorancad]"

Write-Host $ResourcePath
Write-Host $WorkPath

Robocopy.exe $ResourcePath $WorkPath /s /MIR /XD plugins .git .vscode /XF config.json config_*.lua .gitignore config.js config.lua *.ydr *.ytyp
New-Item -ItemType Directory "$WorkPath\sonorancad\plugins" -ErrorAction Ignore
Robocopy.exe "$ResourcePath\sonorancad\plugins\template" "$WorkPath\sonorancad\plugins\template" /s

Remove-Item "$PSScriptRoot\sonorancad-$ReleaseVersion.zip"

$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"

if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
    throw "7 zip file '$7zipPath' not found"
}

Set-Alias 7zip $7zipPath

7zip a -mx=9 "$PSScriptRoot\sonorancad-$ReleaseVersion.zip" $WorkPath