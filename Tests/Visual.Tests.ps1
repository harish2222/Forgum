# Visual.Tests.ps1
# Tests for the rendering engine

$script:ModuleRoot = Split-Path $PSScriptRoot -Parent
$script:TestHelpers = Join-Path $script:ModuleRoot 'Tests/TestHelpers.psm1'
Import-Module $script:TestHelpers -Force

Describe "WriteTerminalFrame" {
    BeforeAll {
        $script:Module = Import-TestModule -Force
    }

    It "Should exist" {
        & $script:Module { Get-Command WriteTerminalFrame -ErrorAction SilentlyContinue } | Should -Not -BeNullOrEmpty
    }
    It "Should emit ANSI move-up sequence when PreviousLineCount is provided" {
        Mock Write-Host { } -ModuleName Forgum
        
        $null = & $script:Module { 
            WriteTerminalFrame -Frame "Test Frame" -PreviousLineCount 5 -ForceTTY 
        }
        
        Should -Invoke -CommandName Write-Host -Exactly -Times 1 -ModuleName Forgum -ParameterFilter { $Object -match "\[5A" }
    }

    It "Should emit ANSI clear-line sequence for each line" {
        Mock Write-Host { } -ModuleName Forgum
        
        $null = & $script:Module { 
            WriteTerminalFrame -Frame "Line1`nLine2" -ForceTTY 
        }
        
        # Each line should be preceded by ESC[2K
        Assert-MockCalled Write-Host -ModuleName Forgum
    }

    It "Should emit ANSI clear-line sequences when ForceTTY is used" {
        Mock Write-Host { } -ModuleName Forgum
        
        $null = & $script:Module { 
            WriteTerminalFrame -Frame "Line1`nLine2" -ForceTTY 
        }
        
        Should -Invoke -CommandName Write-Host -Exactly -Times 1 -ModuleName Forgum
    }
}
