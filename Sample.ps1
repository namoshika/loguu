Import-Module .\Loguu.psm1

Start-Log .\log "hoge_{0}.log" -ExpireDay 2 {
    Write-Information "aa"
}