Push-Location ../
Get-ChildItem -Recurse -Directory -Path * -Exclude ".github", "workflows" -Depth 1 | ForEach-Object {
    if ($_.Name -eq "core") {
        $hashes = @{}
        Write-Host $_
        gci -LiteralPath "$_/" -Depth 2 | ForEach-Object {
            $hash = Get-FileHash -LiteralPath $_.FullName -Algorithm MD5
            $hashes.Add($_.Name, $hash.Hash)
        }
        $output = $hashes | ConvertTo-Json
        [System.IO.File]::WriteAllLines("../manifest.json", $output)
    }
    elseif ($_.Name -eq "plugins") {
    
        gci -LiteralPath $_ -Exclude ".github" -Directory | ForEach-Object {
            Write-Host "Plugin: $_"
            $hashes = @{}
            # Begin Plugin

            gci -LiteralPath $_.FullName -Exclude ".gitignore" -Recurse | ForEach-Object {
                if ($_ -notlike "*main.yml" -and $_ -notlike ".git*" -and $_ -like "*.*") {
                    Write-Host "File: $_"
                    $hash = Get-FileHash -LiteralPath $_.FullName -Algorithm MD5
                    if ($hash) {
                        Write-Host "Name: $_"
                        $hashes.Add($_.Name, $hash.Hash)
                    }
                }
            }
            # Done, print out
            $path = Join-Path -Path $_.FullName -ChildPath "$_/manifest.json"
            $output = $hashes | ConvertTo-Json
            [System.IO.File]::WriteAllLines($path, $output)

        }
    }
}

Pop-Location