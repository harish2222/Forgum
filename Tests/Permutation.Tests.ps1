#Requires -Modules Pester

$script:ModuleRoot = Split-Path $PSScriptRoot -Parent
$script:TestHelpers = Join-Path $script:ModuleRoot 'Tests/TestHelpers.psm1'
Import-Module $script:TestHelpers -Force

Describe "Forgum Permutation Engine" {
    BeforeAll {
        $script:Module = Import-TestModule -Force
    }

    Context "Combinatorial Rendering" {
        $cows = @('default', 'dragon', 'tux', 'ghost')
        $eyesList = @('oo', '==', 'xx', '$$')
        $tongues = @('  ', 'U ')
        $thoughts = @('\', 'o')
        $lolcats = @($true, $false)
        $animations = @('static', 'bounce', 'typewriter')

        foreach ($cow in $cows) {
            foreach ($eyes in $eyesList) {
                foreach ($tongue in $tongues) {
                    foreach ($thought in $thoughts) {
                        foreach ($lolcat in $lolcats) {
                            foreach ($anim in $animations) {
                                
                                $testName = "Renders Cow:$cow | Eyes:$eyes | Tongue:$tongue | Thought:$thought | Lolcat:$lolcat | Anim:$anim"
                                
                                It $testName {
                                    $config = Get-CFConfig
                                    $config.cow.file = $cow
                                    $config.cow.eyes = $eyes
                                    $config.cow.tongue = $tongue
                                    $config.lolcat.enabled = $lolcat
                                    $config.animation.mode = $anim
                                    Set-CFConfig -Config $config

                                    $isThink = $thought -eq 'o'

                                    # We don't want to actually sleep during tests
                                    {
                                        & $script:Module { 
                                            Invoke-Forgum -Think:$isThink -ErrorAction Stop 
                                        }
                                    } | Should -Not -Throw
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
