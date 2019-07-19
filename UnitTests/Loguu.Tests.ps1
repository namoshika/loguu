Import-Module Pester
Push-Location $PSScriptRoot\..\

Describe "Loguu-Test (dev)" {
    Import-Module ..\Loguu
    Context "ロギング" {
        if (Test-Path -PathType Container .\log) {
            Remove-Item -Recurse .\log
        }
        $ErrorActionPreference = "Continue"
        $VerbosePreference = "Continue"
        $WarningPreference = "Continue"
        $InformationPreference = "Continue"
        
        It "ログディレクトリが無い場合には生成されること" {
            Mock -ModuleName "Loguu" Get-Date { [datetime]"2019-07-10 22:34:56" }
            Start-Log .\log -ExpireDay 2 "hoge_{0}.log" {
                Write-Information "called info."
            }
            ".\log\hoge_20190710_223456.log" | Should -Exist
        }
        It "全てのストリームが記録されていること" {
            Mock -ModuleName "Loguu" Get-Date { [datetime]"2019-07-11 12:34:56" }
            Start-Log .\log -ExpireDay 2 "hoge_{0}.log" {
                Write-Output "called output."
                Write-Error "called error."
                Write-Verbose "called verb."
                Write-Warning "called warn."
                Write-Information "called info."
            } *> .\log\output.txt
            ".\log\hoge_20190711_123456.log" | Should -Exist
            ".\log\hoge_20190711_123456.log" | Should -FileContentMatchExactly "called error."
            ".\log\hoge_20190711_123456.log" | Should -FileContentMatchExactly "called verb."
            ".\log\hoge_20190711_123456.log" | Should -FileContentMatchExactly "called warn."
            ".\log\hoge_20190711_123456.log" | Should -FileContentMatchExactly "called info."
        }
        It "例外発生時でも記録してること (throw)" {
            Mock -ModuleName "Loguu" Get-Date { [datetime]"2019-07-12 00:00:00" }
            {
                Start-Log .\log "hoge_{0}.log" {
                    throw "例外発生"
                }
            } | Should -Throw
            ".\log\hoge_20190712_000000.log" | Should -Exist
        }
        It "例外発生時でも記録してること (Write-Error)" {
            $ErrorActionPreference = "Stop"
            Mock -ModuleName "Loguu" Get-Date { [datetime]"2019-07-13 00:00:00" }
            {
                Start-Log .\log "hoge_{0}.log" {
                    Write-Error "error"
                }
            } | Should -Throw
            ".\log\hoge_20190713_000000.log" | Should -Exist
        }
    }
    Context "ローテーション" {
        It "ロギングされること" {
            Mock -ModuleName "Loguu" Get-Date { [datetime]"2019-07-11 12:34:56" }
            Start-Log TestDrive:\log -ExpireDay 2 "hoge_{0}.log" {
                Write-Information "info"
            }
            "TestDrive:\log\hoge_20190711_123456.log" | Should -Exist
        }
        It "ローテーションが誤爆しないこと" {
            Mock -ModuleName "Loguu" Get-Date { [datetime]"2019-07-12 00:00:00" }
            Start-Log TestDrive:\log -ExpireDay 2 "hoge_{0}.log" {
                Write-Information "info"
            }
            "TestDrive:\log\hoge_20190711_123456.log" | Should -Exist
            "TestDrive:\log\hoge_20190712_000000.log" | Should -Exist
        }
        It "ローテーションされること" {
            Mock -ModuleName "Loguu" Get-Date { [datetime]"2019-07-13 00:00:00" }
            Start-Log TestDrive:\log -ExpireDay 2 "hoge_{0}.log" {
                Write-Information "info"
            }
            "TestDrive:\log\hoge_20190711_123456.log" | Should -Not -Exist
            "TestDrive:\log\hoge_20190712_000000.log" | Should -Exist
            "TestDrive:\log\hoge_20190713_000000.log" | Should -Exist
        }
    }
    Remove-Module "Loguu"
}
Describe "Loguu-Test (prd)" {
    . "$PSScriptRoot\..\build.ps1"
    Import-Module ..\Loguu\Loguu
    It "本番相当の設定で正常動作すること" {
        Start-Log .\log "hoge_{0}.log" {
            Write-Output "called output."
            Write-Error "called error."
            Write-Verbose "called verb."
            Write-Warning "called warn."
            Write-Information "called info."
        } *> .\log\output.txt
    }
    Remove-Module "Loguu"
}

Pop-Location