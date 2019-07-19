function Start-Log {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [int] $ExpireDay = 30,
        [ValidateNotNullOrEmpty()][string] $LogDateFormat = "yyyyMMdd_HHmmss",
        [Parameter(Mandatory, Position = 0)][ValidateNotNullOrEmpty()][string] $LogDirectory,
        [Parameter(Mandatory, Position = 1)][ValidateNotNullOrEmpty()][string] $LogFileFormat,
        [Parameter(Mandatory, Position = 2)][ValidateNotNullOrEmpty()][scriptblock] $TargetProc
    )
    # ログ保存先が無ければ作る
    if (-not (Test-Path -PathType Container $LogDirectory)) {
        New-Item -ItemType Directory $LogDirectory | Out-Null
    }

    # ログファイルパス生成
    $logdate = Get-Date
    [string]$logfile_time = $logdate.ToString($LogDateFormat)
    [string]$logfile_path = $LogFileFormat -f $logfile_time
    [string]$logfile_path = Join-Path $LogDirectory $logfile_path

    try {
        # 本処理実行
        & $TargetProc *>&1 | ForEach-Object {
            $item = $_
            # ログ出力 & パイプラインへの再投入
            if ($item -is [System.Management.Automation.ErrorRecord]) {
                $item_text = Get-LogText "ERROR" $item
                Add-Content $logfile_path -Encoding utf8 $item_text
                Write-Error $item
            }
            elseif ($item -is [System.Management.Automation.WarningRecord]) {
                $item_text = Get-LogText "WARN" $item
                Add-Content $logfile_path -Encoding utf8 $item_text
                Write-Warning $item
            }
            elseif ($item -is [System.Management.Automation.VerboseRecord]) {
                $item_text = Get-LogText "VERB" $item
                Add-Content $logfile_path -Encoding utf8 $item_text
                Write-Verbose $item
            }
            elseif ($item -is [System.Management.Automation.DebugRecord]) {
                $item_text = Get-LogText "DEBUG" $item
                Add-Content $logfile_path -Encoding utf8 $item_text
                Write-Debug $item
            }
            elseif ($item -is [System.Management.Automation.InformationRecord]) {
                $item_text = Get-LogText "INFO" $item
                Add-Content $logfile_path -Encoding utf8 $item_text
                Write-Information $item
            }
            else {
                Write-Output $item
            }
        }
    }
    catch {
        # ロギング
        $item_text = Get-LogText "FAIL" $_
        Add-Content $logfile_path -Encoding utf8 $item_text

        # 再スロー
        throw
    }
    finally {
        # 古いログを列挙
        # 保持期間を2日間とした場合、今を1日目とし、昨日の日付(exp: -2 + 1 = 1)未満を消去対象とする。
        $expire_date = $logdate.Date.AddDays(-$ExpireDay + 1).ToString($LogDateFormat)
        $expire_log_name = $LogFileFormat -f $expire_date
        $expire_log_path = Get-ChildItem $LogDirectory `
        | Where-Object { $_.Name -like ($LogFileFormat -f "*") } `
        | Where-Object { $_.Name -lt $expire_log_name } `

        # 古いログを削除
        foreach ($item in $expire_log_path) {
            $logpath = $item.FullName
            $logtext = Get-LogText "INFO" "古いログを削除 ($logpath)"
            Remove-Item $logpath | Out-Null
            Add-Content $logfile_path -Encoding utf8 $logtext
        }
    }
}
function Get-LogText ([string]$category, $item) {
    [string]$item_text = $item | Out-String -Width 9999
    [string]$logtime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # 出力が複数行の場合にはログ時刻やログカテゴリと本文の行を分ける。
    # それらは文字列の先頭に付けるため、事前に本文の前に改行を入れる。
    $item_text = $item_text.Trim("`r`n")
    if ($item_text.Contains("`r`n")) {
        $item_text = "`r`n" + $item_text
    }

    return "$logtime ${category}: $item_text"
}
