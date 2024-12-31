##Import Functions
$FunctionPathPublic = $PSScriptRoot + "\Public\"
$FunctionPathPrivate = $PSScriptRoot + "\Private\"

# try {
    
if (Test-Path $FunctionPathPublic) {
    $PublicFunctions = Get-ChildItem $FunctionPathPublic | ForEach-Object {
        [System.IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8) + [Environment]::NewLine
    }
}
if (Test-Path $FunctionPathPrivate) {
    $PrivateFunctions = Get-ChildItem $FunctionPathPrivate | ForEach-Object {
        [System.IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8) + [Environment]::NewLine
    }
}

. ([scriptblock]::Create($PublicFunctions))
. ([scriptblock]::Create($PrivateFunctions))
<# }

catch {
    $FunctionListPublic = Get-ChildItem $FunctionPathPublic -Name
    $FunctionListPrivate = Get-ChildItem $FunctionPathPrivate -Name

    ForEach ($Function in $FunctionListPublic) {
        . ($FunctionPathPublic + $Function)
    }

    ForEach ($Function in $FunctionListPrivate) {
        . ($FunctionPathPrivate + $Function)
    }
}

#>