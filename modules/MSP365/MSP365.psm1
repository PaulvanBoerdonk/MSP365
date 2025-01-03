$CurrentDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$PublicDir = Join-Path -Path $CurrentDir -ChildPath "Public"
$PrivateDir = Join-Path -Path $CurrentDir -ChildPath "Private"

try {
    if (Test-Path $PublicDir) {
        $PublicScripts = Get-ChildItem -Path $PublicDir | ForEach-Object {
            [System.IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8) + [Environment]::NewLine
        }
    }

    if (Test-Path $PrivateDir) {
        $PrivateScripts = Get-ChildItem -Path $PrivateDir | ForEach-Object {
            [System.IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8) + [Environment]::NewLine
        }
    }

    . ([scriptblock]::Create($PublicScripts))
    . ([scriptblock]::Create($PrivateScripts))
}
catch {
    $PublicFiles = Get-ChildItem -Path $PublicDir -Name
    $PrivateFiles = Get-ChildItem -Path $PrivateDir -Name

    foreach ($File in $PublicFiles) {
        . (Join-Path -Path $PublicDir -ChildPath $File)
    }

    foreach ($File in $PrivateFiles) {
        . (Join-Path -Path $PrivateDir -ChildPath $File)
    }
}