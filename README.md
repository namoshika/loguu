# Loguu
Simple logger for PowerShell.

* Write the output of Write-Error/Verbose/Warning/Information to a log
* Log rotation

# Sample

Install module ...

```powershell
# Way 1: Use packge manager.
Install-Module Loguu -Repository PowerShellGet

# Way 2: Save current directory.
# (*Ծ﹏Ծ)...
```

Write script ...

```powershell
# Import module.
# If you are install by way 2, use 'Import-Module .\Loguu' instead
Import-Module Loguu

Start-Log ./log "hoge_{0}.log" {
    Write-Error "called error."
    Write-Verbose "called verb."
    Write-Warning "called warn."
    Write-Information "called info."
}
```

Output log (./log/hoge_20190714_1254.log) ...
```log
2019-07-14 02:43:06 ERROR: 
                Write-Output "called output."
                Write-Error "called error."
                Write-Verbose "called verb."
                Write-Warning "called warn."
                Write-Information "called info."
             : called error.
At Loguu.psm1:27 char:9
+         & $TargetProc *>&1 | ForEach-Object {
+         ~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
+ FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException
 
2019-07-14 02:43:06 VERB: called verb.
2019-07-14 02:43:06 WARN: called warn.
2019-07-14 02:43:06 INFO: called info.

```

# Parameters
**`-LogDirectory` (Required)**  
Save the log to this path.

**`-LogFileFormat` (Required)**  
Set a template of log file name. Please set the date part to {0}.

**`-LogDateFormat` (Optional. Default 'yyyyMMdd_HHmmss')**  
You can specify the date style of the log filename.

**`-ExpireDay` (Optional. Default 30 days)**  
You can specify the days to keep the log.

**`-TargetProc` (Required)**  
Writing your processing in scriptblock.