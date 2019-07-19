param ([switch][bool] $publish)

Get-Content -Encoding utf8 $PSScriptRoot\Loguu.psd1 | Out-File -Encoding unicode $PSScriptRoot\Loguu\Loguu.psd1
Get-Content -Encoding utf8 $PSScriptRoot\Loguu.psm1 | Out-File -Encoding unicode $PSScriptRoot\Loguu\Loguu.psm1
Get-Content -Encoding utf8 $PSScriptRoot\Sample.ps1 | Out-File -Encoding unicode $PSScriptRoot\Loguu\Sample.ps1
Get-Content -Encoding utf8 $PSScriptRoot\LICENSE | Out-File -Encoding unicode $PSScriptRoot\Loguu\LICENSE

if ($publish) {
    Publish-Module -Path "$PSScriptRoot\Loguu" -NuGetApiKey $env:PSGallery_APIKEY
}